---
name: land-and-deploy
description: "Fusionner la PR, attendre la CI, vérifier le déploiement, lancer le canary — le pipeline de mise en production complet"
---

# Land and Deploy

Pipeline de mise en production complet : fusionner la PR, attendre la CI, vérifier le déploiement, effectuer un bilan de santé.

Prend le relais là où `/ship` s'est arrêté. `/ship` crée la PR. Cette commande la fusionne et vérifie la production.

**Non-interactif par défaut.** L'utilisateur a dit "lance ça" — alors on lance. On s'arrête uniquement pour le verrou de préparation critique et les blocages durs.

## Instructions

### Étape 1 : Pré-vol

```bash
# Vérifier que le CLI GitHub est authentifié
gh auth status

# Détecter la PR depuis la branche courante (ou utiliser l'argument fourni)
gh pr view --json number,state,title,url,mergeStateStatus,mergeable,baseRefName,headRefName
```

**Conditions d'arrêt :**
- CLI GitHub non authentifié → "Exécute `gh auth login` d'abord"
- Aucune PR trouvée → "Aucune PR trouvée pour cette branche. Lance `/ship` d'abord."
- PR déjà fusionnée → "La PR est déjà fusionnée."
- PR fermée → "La PR est fermée. Rouvre-la d'abord."

---

### Étape 2 : Vérification du statut CI

```bash
# Vérifier le statut CI actuel
gh pr checks --json name,state,status,conclusion

# Vérifier les conflits de fusion
gh pr view --json mergeable -q .mergeable
```

**Conditions d'arrêt :**
- Checks requis EN ÉCHEC → afficher les checks échoués, s'arrêter
- `mergeable` est `CONFLICTING` → "La PR a des conflits de fusion. Résous-les et pousse avant de continuer."
- Checks requis EN ATTENTE → passer à l'Étape 3 (attendre la CI)
- Tous les checks passent → passer directement à l'Étape 3.5 (verrou de préparation)

---

### Étape 3 : Attendre la CI (si en attente)

```bash
# Surveiller les checks CI avec un timeout de 15 minutes
gh pr checks --watch --fail-fast
```

- CI passe → continuer à l'Étape 3.5
- CI échoue → s'arrêter, afficher les échecs
- Timeout (15 min) → "La CI tourne depuis 15 minutes. Investigate manuellement."

Enregistrer la durée d'attente de la CI pour le rapport de déploiement.

---

### Étape 3.5 : Verrou de préparation pré-fusion

**C'est la seule confirmation critique avant une fusion irréversible.** Collecter toutes les preuves, puis obtenir une approbation explicite.

#### Vérification de fraîcheur des revues

```bash
# Combien de commits depuis la dernière revue sur cette branche ?
git log --oneline $(git merge-base HEAD origin/main)..HEAD | wc -l

# Qu'est-ce qui a changé après qu'une revue ait été effectuée ?
git log --oneline -10
```

Seuils de fraîcheur :
- 0–3 commits depuis la revue → À JOUR (vert)
- 4+ commits touchant du code → PÉRIMÉ (jaune — la revue peut ne pas refléter le code actuel)
- Aucune revue trouvée → NON EFFECTUÉE (jaune)

#### Résultats des tests

```bash
# Lancer les tests maintenant — tests rapides uniquement
npm test 2>/dev/null || pnpm test 2>/dev/null || \
  pytest --tb=short -q 2>/dev/null || \
  go test ./... 2>/dev/null

# Vérifier le code de sortie
echo "Tests exit code: $?"
```

Tests en échec = BLOCAGE. Impossible de fusionner avec des tests en échec.

#### Vérification de la documentation

```bash
# Est-ce que CHANGELOG et les docs ont été mis à jour sur cette branche ?
git diff --name-only $(git merge-base HEAD origin/main)...HEAD -- \
  README.md CHANGELOG.md ARCHITECTURE.md CONTRIBUTING.md CLAUDE.md VERSION
```

Si CHANGELOG.md et VERSION n'ont PAS été modifiés et que le diff inclut de nouvelles fonctionnalités → AVERTISSEMENT.

#### Rapport de préparation

Présenter un résumé et demander une confirmation explicite :

```
╔══════════════════════════════════════════════════════════╗
║         RAPPORT DE PRÉPARATION PRÉ-FUSION                ║
╠══════════════════════════════════════════════════════════╣
║  PR: #NNN — [titre]                                      ║
║  Branche: feature-branch → main                          ║
║                                                          ║
║  REVUES                                                  ║
║    Revue:      À JOUR / PÉRIMÉE (N commits) / NON FAITE  ║
║                                                          ║
║  TESTS                                                   ║
║    Tests rapides: PASS / FAIL (blocage)                  ║
║                                                          ║
║  DOCUMENTATION                                           ║
║    CHANGELOG:  Mis à jour / NON MIS À JOUR (avert.)      ║
║    VERSION:    Incrémentée / NON INCRÉMENTÉE (avert.)    ║
║                                                          ║
║  AVERTISSEMENTS: N  |  BLOCAGES: N                       ║
╚══════════════════════════════════════════════════════════╝

Options :
  A) Fusionner — tous les checks sont verts
  B) Ne pas fusionner encore — traiter les avertissements d'abord
  C) Fusionner quand même — je comprends les risques
```

Si l'utilisateur choisit B, lister exactement ce qui doit être fait et s'arrêter.

---

### Étape 4 : Fusionner la PR

```bash
# Fusionner (détecter automatiquement la méthode depuis les paramètres du dépôt, supprimer la branche après)
gh pr merge --auto --delete-branch

# Repli si la fusion automatique n'est pas activée
# gh pr merge --squash --delete-branch
```

Enregistrer le SHA du commit de fusion et l'horodatage.

Si la fusion échoue avec une erreur de permission → "Tu n'as pas les droits de fusion. Demande à un mainteneur de fusionner."

Si une file de fusion est active, sonder jusqu'à la fusion :

```bash
# Sonder toutes les 30 secondes, timeout après 30 minutes
gh pr view --json state -q .state
```

---

### Étape 5 : Détection de la plateforme

Détecter comment ce projet se déploie pour savoir quoi vérifier.

```bash
# Détecter la plateforme depuis les fichiers de configuration
[ -f fly.toml ]         && echo "PLATFORM: fly"
[ -f render.yaml ]      && echo "PLATFORM: render"
[ -f vercel.json ] || [ -d .vercel ] && echo "PLATFORM: vercel"
[ -f netlify.toml ]     && echo "PLATFORM: netlify"
[ -f Procfile ]         && echo "PLATFORM: heroku"
[ -f railway.toml ]     && echo "PLATFORM: railway"

# Détecter les workflows de déploiement GitHub Actions
for f in .github/workflows/*.yml .github/workflows/*.yaml; do
  [ -f "$f" ] && grep -qiE "deploy|release|production|cd" "$f" 2>/dev/null && echo "DEPLOY_WORKFLOW: $f"
done

# Classifier la portée du diff (frontend / backend / docs / config)
git diff --name-only $(git merge-base HEAD~1 origin/main)...HEAD | \
  awk '{
    if (/\.(css|scss|tsx|jsx|html|svg)$/ || /components|pages|public\//) f=1;
    if (/api\/|server\/|backend\/|\.(go|py|rb|java)$/) b=1;
    if (/README|CHANGELOG|docs\/|\.(md)$/) d=1;
    if (/\.env|config\/|\.toml$|\.yaml$/) c=1;
  } END {
    if (f) print "SCOPE_FRONTEND=true";
    if (b) print "SCOPE_BACKEND=true";
    if (d) print "SCOPE_DOCS=true";
    if (c) print "SCOPE_CONFIG=true";
  }'
```

**Arbre de décision :**
- Diff docs uniquement → passer la vérification du déploiement, aller à l'Étape 8
- Pas de workflow de déploiement + pas d'URL fournie → demander à l'utilisateur si ce projet a un déploiement web
- Sinon → passer à l'Étape 6

---

### Étape 6 : Attendre le déploiement

**Workflow de déploiement GitHub Actions :**

```bash
# Trouver le run déclenché par le commit de fusion
gh run list --branch main --limit 10 --json databaseId,headSha,status,conclusion,workflowName

# Sonder jusqu'à la complétion (intervalle 30s, timeout 20 min)
gh run view <run-id> --json status,conclusion
```

**Stratégies par plateforme :**

| Plateforme | Détection | Stratégie d'attente |
|------------|-----------|---------------------|
| Vercel / Netlify | Déploiement auto au push | Attendre 60s de propagation, puis vérifier |
| Fly.io | `fly.toml` présent | `fly status --app <app>` — vérifier le statut `started` |
| Render | `render.yaml` présent | Sonder l'URL de production jusqu'à réponse 200 |
| Heroku | `Procfile` présent | `heroku releases --app <app> -n 1` |
| Railway | `railway.toml` présent | Sonder l'URL de production |
| GitHub Actions uniquement | `.github/workflows/` avec étape de déploiement | Sonder `gh run view` |

Si le déploiement échoue → proposer d'investiguer les logs ou de créer un commit de revert.

Enregistrer la durée du déploiement pour le rapport.

---

### Étape 7 : Bilan de santé en production

Utiliser la portée du diff (de l'Étape 5) pour déterminer la profondeur des vérifications :

| Portée du diff | Profondeur du canary |
|----------------|----------------------|
| Docs uniquement | Déjà sauté à l'Étape 5 |
| Config uniquement | Vérification smoke HTTP 200 uniquement |
| Backend uniquement | Vérification statut + temps de réponse |
| Frontend (n'importe lequel) | Complet : statut + temps de réponse + vérification du contenu |
| Mixte | Vérification complète |

**Séquence de bilan de santé complet :**

```bash
# 1. Page se charge (statut 200)
curl -sf -o /dev/null -w "%{http_code}" "${PROD_URL}" 2>/dev/null

# 2. Vérification du temps de réponse
curl -sf -o /dev/null -w "%{time_total}" "${PROD_URL}" 2>/dev/null

# 3. Endpoint de santé (si existant)
curl -sf "${PROD_URL}/health" 2>/dev/null || \
curl -sf "${PROD_URL}/api/health" 2>/dev/null

# 4. Vérification du contenu — la page n'est pas vide
curl -sf "${PROD_URL}" 2>/dev/null | wc -c
```

Critères de réussite :
- Statut HTTP 200
- Temps de réponse inférieur à 10 secondes
- La page a du contenu (>500 octets)
- L'endpoint de santé retourne 200 (si configuré)

Si une vérification échoue → proposer un revert :

```
Le bilan de santé post-déploiement a détecté des problèmes :
  [constat — spécifique]

Options :
  A) Investiguer — cela peut être normal (réchauffement du cache, cohérence éventuelle)
  B) Rollback — annuler le commit de fusion
  C) Continuer — je vais surveiller manuellement
```

---

### Étape 8 : Revert (si nécessaire)

```bash
# Récupérer la dernière version de la branche de base
git fetch origin main

# Créer un commit de revert
git checkout main
git revert <merge-commit-sha> --no-edit
git push origin main
```

Si conflits → "Le revert a des conflits. Lance `git revert <sha>` manuellement pour les résoudre."
Si protections de branche → "Crée une PR de revert : `gh pr create --title 'revert: <titre>'`"

---

### Étape 9 : Rapport de déploiement

```
RAPPORT LAND & DEPLOY
═════════════════════════════════════════
PR :           #NNN — [titre]
Branche :      feature-branch → main
Fusionnée :    [horodatage] (squash / merge)
SHA fusion :   [SHA court]

Durées :
  Attente CI :    [Xm Ys / sauté]
  Déploiement :   [Xm Ys / aucun workflow détecté]
  Bilan santé :   [Xs / sauté]
  Total :         [durée bout en bout]

CI :           PASSED / FAILED / SKIPPED
Déploiement :  PASSED / FAILED / NO WORKFLOW
Production :   HEALTHY / DEGRADED / SKIPPED / REVERTED
  Statut :     [code HTTP]
  Réponse :    [Xms]

VERDICT : DÉPLOYÉ ET VÉRIFIÉ / DÉPLOYÉ (NON VÉRIFIÉ) / ANNULÉ
═════════════════════════════════════════
```

---

### Étape 10 : Suggestions de suivi

Après le rapport de déploiement, suggérer les prochaines étapes pertinentes :

- Si l'URL de production a été vérifiée : "Lance `/canary <url>` pour une surveillance étendue de 10 minutes."
- Si de nouvelles fonctionnalités ont été livrées : "Lance `/document-release` pour mettre à jour la documentation du projet."

---

## Règles importantes

- **Ne jamais forcer le push.** Utiliser `gh pr merge` — c'est sûr.
- **Ne jamais sauter la CI.** Checks en échec = arrêt.
- **Vérification de production en une seule passe.** Pour une surveillance étendue, utiliser `/canary`.
- **Le revert est toujours une option.** À chaque point d'échec, proposer le revert comme échappatoire.
- **Supprimer la branche de fonctionnalité** après la fusion (via `--delete-branch`).
- **L'objectif** : l'utilisateur tape `/land-and-deploy`, la prochaine chose qu'il voit est le rapport de déploiement.

## Utilisation

```
/land-and-deploy                                    # Détecter la PR automatiquement, pas d'URL canary
/land-and-deploy https://app.example.com            # Détecter la PR automatiquement + vérifier cette URL
/land-and-deploy 123                                # Numéro de PR spécifique
/land-and-deploy 123 https://app.example.com        # Numéro de PR + URL de vérification
```

## Commandes associées

- `/ship` — lancer ceci d'abord pour créer la PR
- `/canary` — surveillance post-déploiement étendue en boucle
- `/review-pr` — revoir la PR avant de la merger

$ARGUMENTS
