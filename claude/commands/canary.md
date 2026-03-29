---
name: canary
description: "Surveillance post-déploiement — surveiller la production après un déploiement et alerter sur les régressions"
---

# Canary — Surveillance Post-Déploiement

Surveiller une application en production après un déploiement. Alerter sur les erreurs et les régressions. Comparer avec une baseline capturée avant déploiement.

**Deux modes :**
- `--baseline` — capturer l'état actuel AVANT de déployer
- *(par défaut)* — surveiller APRÈS le déploiement et comparer avec la baseline

## Instructions

### Phase 1 : Configuration

Analyser les arguments de l'utilisateur et détecter le contexte de déploiement.

```bash
# Détecter la branche courante et le commit de déploiement récent
git branch --show-current
git log --oneline -5

# Auto-détecter la plateforme à partir des fichiers de configuration
[ -f fly.toml ]         && echo "PLATEFORME: fly"
[ -f render.yaml ]      && echo "PLATEFORME: render"
[ -f vercel.json ]      && echo "PLATEFORME: vercel"
[ -f netlify.toml ]     && echo "PLATEFORME: netlify"
[ -f Procfile ]         && echo "PLATEFORME: heroku"
[ -f railway.toml ]     && echo "PLATEFORME: railway"

# Vérifier l'endpoint de santé
curl -sf "${URL}/health" -w "\n%{http_code}" 2>/dev/null | tail -1
curl -sf "${URL}/api/health" -w "\n%{http_code}" 2>/dev/null | tail -1
```

Créer le répertoire de travail :

```bash
mkdir -p .canary/baselines .canary/reports .canary/screenshots
```

---

### Phase 2 : Capture de Baseline (mode `--baseline`)

Lancer AVANT de déployer pour capturer l'état sain actuel.

Pour chaque page à surveiller, enregistrer :

1. **Statut HTTP** — la page retourne-t-elle 200 ?
2. **Temps de réponse** — combien de temps met-elle à charger ?
3. **Snapshot du contenu** — contenu textuel clé pour détecter les pages blanches ultérieurement

```bash
# Pour chaque URL de page
for PAGE_PATH in "/" "/dashboard" "/settings" "/api/health"; do
  SLUG=$(echo "$PAGE_PATH" | tr '/' '_' | tr -d '?&=')
  RESULT=$(curl -sf -o /dev/null -w "%{http_code}|%{time_total}" "${BASE_URL}${PAGE_PATH}" 2>/dev/null)
  STATUS=$(echo "$RESULT" | cut -d'|' -f1)
  TIME_MS=$(echo "$RESULT" | awk -F'|' '{printf "%.0f", $2 * 1000}')
  echo "  ${PAGE_PATH}: HTTP ${STATUS}, ${TIME_MS}ms"
done
```

Sauvegarder la baseline dans `.canary/baselines/baseline.json` :

```json
{
  "url": "<base-url>",
  "timestamp": "<ISO-8601>",
  "branch": "<branch-name>",
  "commit": "<git-SHA>",
  "pages": {
    "/": { "status": 200, "time_ms": 450 },
    "/dashboard": { "status": 200, "time_ms": 680 },
    "/api/health": { "status": 200, "time_ms": 45 }
  }
}
```

Puis **S'ARRÊTER** et indiquer à l'utilisateur : "Baseline capturée. Déployez vos modifications, puis lancez `/canary <url>` pour surveiller."

---

### Phase 3 : Découverte des Pages

Si aucune page n'a été spécifiée, découvrir automatiquement les pages à surveiller.

**Depuis l'application :**

```bash
# Vérifier le sitemap si disponible
curl -sf "${URL}/sitemap.xml" 2>/dev/null | grep -oP '(?<=<loc>)[^<]+' | head -10

# Vérifier le robots.txt pour les chemins connus
curl -sf "${URL}/robots.txt" 2>/dev/null | grep -i "allow\|disallow" | head -10

# Chemins courants à toujours vérifier
echo "Toujours vérifier : / /login /dashboard /settings /api/health"
```

Pages par défaut à surveiller si rien n'est trouvé : `/`, et la page d'accueil uniquement.

---

### Phase 4 : Boucle de Surveillance

Surveiller pendant la durée spécifiée (par défaut : 10 minutes). Lancer une vérification toutes les 60 secondes.

**Chaque cycle de vérification :**

```bash
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
CHECK_NUM=$((CHECK_NUM + 1))

for PAGE_PATH in "${PAGES[@]}"; do
  # Vérifier le statut HTTP et le temps de réponse
  RESULT=$(curl -sf -o /dev/null -w "%{http_code}|%{time_total}" \
    --max-time 10 "${BASE_URL}${PAGE_PATH}" 2>/dev/null || echo "0|0")
  STATUS=$(echo "$RESULT" | cut -d'|' -f1)
  TIME_MS=$(echo "$RESULT" | awk -F'|' '{printf "%.0f", $2 * 1000}')

  # Comparer avec la baseline
  BASELINE_STATUS=$(jq -r ".pages[\"${PAGE_PATH}\"].status // 200" .canary/baselines/baseline.json 2>/dev/null)
  BASELINE_TIME=$(jq -r ".pages[\"${PAGE_PATH}\"].time_ms // 1000" .canary/baselines/baseline.json 2>/dev/null)

  echo "  [Vérification #${CHECK_NUM}] ${PAGE_PATH}: HTTP ${STATUS} (${TIME_MS}ms)"
done
```

**Niveaux d'alerte :**

| Niveau | Condition | Déclencheur |
|--------|-----------|-------------|
| **CRITIQUE** | Échec de chargement de page | Le statut HTTP n'est pas 2xx, timeout curl, échec DNS |
| **ÉLEVÉ** | Nouvelles erreurs | Taux d'erreur augmenté vs baseline (erreurs console, réponses 5xx) |
| **MOYEN** | Régression de performance | Temps de réponse dépasse 2x la baseline |
| **FAIBLE** | Nouveaux liens cassés | Routes précédemment fonctionnelles retournent maintenant 404 |

**Principes clés :**
- **Alerter sur les changements, pas sur les valeurs absolues.** Une page avec 3 erreurs en baseline est normale si elle en a toujours 3. Une NOUVELLE erreur déclenche une alerte.
- **Tolérance aux transitoires.** N'alerter que sur les patterns persistant sur 2+ vérifications consécutives. Un seul problème réseau n'est pas une alerte.

**Quand une alerte CRITIQUE ou ÉLEVÉE se déclenche (2 vérifications consécutives) :**

```
ALERTE CANARY
════════════════════════════════════════
Heure :    [vérification #N à Xs écoulé]
Page :     [URL]
Niveau :   [CRITIQUE / ÉLEVÉ / MOYEN / FAIBLE]
Constat :  [ce qui a changé — soyez précis]
Baseline : [valeur de référence]
Actuel :   [valeur actuelle]
════════════════════════════════════════
Options :
  A) Investiguer maintenant — arrêter la surveillance, se concentrer sur ce problème
  B) Continuer la surveillance — attendre la prochaine vérification pour confirmer
  C) Rollback — revenir au déploiement précédent
  D) Ignorer — problème connu, continuer la surveillance
```

---

### Phase 5 : Rapport de Santé

Après la fin de la surveillance (ou arrêt par l'utilisateur), produire un résumé.

```
RAPPORT CANARY — [url]
═══════════════════════════════════════════════════
Durée :       [X minutes]
Vérifications : [N total par page]
Pages :       [N pages surveillées]
Commit :      [SHA déployé]
Statut :      [SAIN / DÉGRADÉ / CASSÉ]

Résultats par Page :
─────────────────────────────────────────
  Page           Statut      Temps Moy.  Alertes
  /              SAIN        450ms       0
  /dashboard     DÉGRADÉ     1100ms      1 moyen (était 450ms)
  /settings      SAIN        380ms       0
  /api/health    SAIN        45ms        0

Alertes Déclenchées : [N] (X critique, Y élevé, Z moyen, W faible)

VERDICT : [DÉPLOIEMENT SAIN / DÉPLOIEMENT PROBLÉMATIQUE — voir alertes ci-dessus]
═══════════════════════════════════════════════════
```

Sauvegarder le rapport dans `.canary/reports/<date>-canary.md`.

---

### Phase 6 : Mise à Jour de la Baseline

Si le déploiement est sain et que l'utilisateur souhaite mettre à jour la baseline :

```bash
cp .canary/reports/latest-snapshot.json .canary/baselines/baseline.json
echo "Baseline mise à jour vers le commit $(git rev-parse --short HEAD)"
```

---

## Format de Sortie

Voir la Phase 5 ci-dessus pour le modèle complet de RAPPORT CANARY.

Format d'alerte en ligne (pendant la surveillance) :
```
[08:42:15] Vérification #3 — /dashboard: ALERTE ÉLEVÉE — temps de réponse 1250ms (baseline: 420ms)
[08:43:15] Vérification #4 — /dashboard: ALERTE ÉLEVÉE — temps de réponse 1180ms (baseline: 420ms)
→ Cohérent sur 2 vérifications. Déclenchement de l'alerte.
```

## Utilisation

```
/canary https://app.example.com                # Surveiller la page d'accueil pendant 10 min
/canary https://app.example.com --baseline     # Capturer la baseline avant déploiement
/canary https://app.example.com --duration 5m  # Surveiller pendant 5 minutes
/canary https://app.example.com --quick        # Vérification de santé en passe unique (pas de boucle)
/canary https://app.example.com --pages /,/dashboard,/api/health
```

## Conseils

1. **Toujours capturer une baseline** avant de déployer en production — lancer `/canary <url> --baseline`
2. **Démarrer la surveillance immédiatement** après le déploiement — les 5 premières minutes détectent 90% des régressions
3. **Alertes CRITIQUES = investiguer immédiatement** — ne pas attendre la fin de la surveillance
4. **Alertes MOYENNES (performance)** — peut être un réchauffement du cache, attendre 2 à 3 vérifications supplémentaires avant d'agir
5. **Garder `.canary/baselines/` dans git** — pour que tout membre de l'équipe puisse lancer canary avec la même baseline

## Commandes Associées

- `/ship` — checklist pré-déploiement (à lancer avant de déployer)
- `/land-and-deploy` — pipeline complet merge-vers-vérification (lance canary automatiquement)
- `/qa` — tests QA interactifs avant mise en production

$ARGUMENTS
