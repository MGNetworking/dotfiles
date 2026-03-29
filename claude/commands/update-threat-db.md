---
name: update-threat-db
description: "Rechercher et mettre à jour la base de données de renseignements sur les menaces de sécurité des agents IA"
---

# Mise à jour de la base de données des menaces

Rechercher et mettre à jour la base de données de renseignements sur les menaces de sécurité des agents IA avec les dernières menaces, CVEs, compétences malveillantes et campagnes.

**Durée** : 3-8 minutes | **Périmètre** : `examples/commands/resources/threat-db.yaml`

> Nécessite le MCP Perplexity (ou une recherche web manuelle). À lancer mensuellement ou après les avis de sécurité majeurs.

## Instructions

Vous êtes un analyste en renseignement sur les menaces spécialisé dans la sécurité des agents de codage IA. Recherchez les dernières menaces et mettez à jour la base de données des menaces.

---

### Phase 1 : Évaluation de l'état actuel

Lire la base de données des menaces actuelle :

```
Read examples/commands/resources/threat-db.yaml
```

Noter :
- La `version` actuelle et la date `updated`
- Le nombre d'auteurs malveillants, compétences, CVEs, campagnes
- Les entrées les plus récentes pour éviter les doublons

---

### Phase 2 : Recherche de nouvelles menaces

Lancer **4 recherches Perplexity ciblées** (en parallèle si possible) :

**Recherche 1 : Nouvelles compétences malveillantes & campagnes**
```
Requête : "malicious AI agent skills ClawHub OpenClaw skills.sh 2026 new campaigns malware supply chain"
Focus : Nouveaux noms de compétences malveillantes, auteurs, campagnes absents de threat-db.yaml
```

**Recherche 2 : Nouveaux CVEs pour les serveurs MCP**
```
Requête : "MCP server CVE vulnerability 2025 2026 model context protocol security advisory"
Focus : Nouveaux CVEs pour les serveurs MCP, vulnérabilités du SDK, failles au niveau du transport
```

**Recherche 3 : Nouvelles techniques d'attaque**
```
Requête : "AI coding agent attack prompt injection Claude Code Cursor supply chain security research 2026"
Focus : Nouveaux vecteurs d'attaque, techniques, articles de recherche
```

**Recherche 4 : Nouveaux outils défensifs & listes de blocage**
```
Requête : "MCP security scanner tool mcp-scan alternative AI agent skills security scanning 2026"
Focus : Nouveaux outils de scan, listes de blocage, frameworks défensifs
```

Si le MCP Perplexity n'est pas disponible, utiliser WebSearch pour chaque requête.

---

### Phase 3 : Analyse & déduplication

Pour chaque finding de la Phase 2 :

1. **Vérifier s'il est déjà dans threat-db.yaml** — ignorer les doublons
2. **Vérifier la crédibilité de la source** — privilégier : bases de données CVE, blogs de fournisseurs de sécurité, recherches peer-reviewed
3. **Catégoriser** — dans quelle section cela appartient-il ?
   - `malicious_authors` — nouveaux éditeurs malveillants confirmés
   - `malicious_skills` — nouveaux noms de compétences/paquets malveillants confirmés
   - `malicious_skill_patterns` — nouveaux patterns de préfixes pour la correspondance wildcard
   - `cve_database` — nouveaux CVEs avec composant, sévérité, fixed_in
   - `minimum_safe_versions` — mettre à jour si de nouveaux correctifs sont disponibles
   - `iocs` — nouvelles IPs C2, URLs d'exfiltration, hachages de malwares
   - `campaigns` — nouvelles campagnes coordonnées
   - `attack_techniques` — nouveaux vecteurs d'attaque documentés
   - `scanning_tools` — nouveaux outils ou mises à jour majeures
   - `defensive_resources` — nouveaux frameworks, listes de blocage

4. **Évaluer le niveau de risque** :
   - `critical` — malveillant confirmé, exploitation active
   - `high` — vulnérabilité confirmée, exploit disponible
   - `medium` — risque théorique, pas d'exploitation connue
   - `low` — informatif

---

### Phase 4 : Mise à jour de threat-db.yaml

Appliquer les changements en suivant ces règles :

1. **Incrémenter la version** — incrémenter le mineur (ex. 2.0.0 → 2.1.0) pour les nouvelles entrées, le majeur pour les changements de schéma
2. **Mettre à jour la date `updated`** — définir à aujourd'hui
3. **Ajouter de nouvelles sources** — ajouter toute nouvelle source de recherche à la liste `sources`
4. **Maintenir la validité YAML** — utiliser des guillemets simples pour les patterns contenant des antislashs
5. **Préserver les entrées existantes** — ne jamais supprimer d'entrées sauf si un faux positif est confirmé
6. **Respecter le format existant** — correspondre exactement à la structure des entrées existantes

**Important** : Après la modification, valider le YAML :
```bash
python3 -c "import yaml; yaml.safe_load(open('examples/commands/resources/threat-db.yaml')); print('YAML valide')"
```

---

### Phase 5 : Mise à jour des fichiers dépendants (si nécessaire)

Vérifier si les nouveaux CVEs doivent aussi être ajoutés au guide de durcissement :

```bash
# Comparer le nombre de CVEs dans threat-db vs security-hardening
grep -c "id:" examples/commands/resources/threat-db.yaml
grep -c "CVE-" guide/security-hardening.md
```

Si des CVEs majeurs sont trouvés (sévérité critical/high) :
- Envisager de les ajouter au tableau CVE de `guide/security-hardening.md`
- Mettre à jour `minimum_safe_versions` si de nouveaux correctifs sont publiés

---

### Phase 6 : Rapport de synthèse

## Format de sortie

```
## Rapport de mise à jour de la base de données des menaces

**Date** : [horodatage]
**Version précédente** : [ancienne version]
**Nouvelle version** : [nouvelle version]

### Résumé des changements

| Catégorie | Ajoutés | Mis à jour | Total |
|-----------|---------|------------|-------|
| Auteurs malveillants | +X | ~X | XX |
| Compétences malveillantes | +X | ~X | XX |
| CVEs | +X | ~X | XX |
| Campagnes | +X | ~X | XX |
| IOCs | +X | ~X | XX |
| Techniques d'attaque | +X | ~X | XX |
| Outils de scan | +X | ~X | XX |

### Nouvelles entrées

[Lister chaque nouvelle entrée avec sa source et son niveau de risque]

### Résultats notables

[Mettre en évidence tout ce qui est particulièrement important ou urgent]

### Aucun changement nécessaire

[Si rien de nouveau n'a été trouvé, expliquer ce qui a été recherché et confirmé à jour]

### Prochaines étapes

- [ ] Lancer `/security-check` pour tester contre la base de données mise à jour
- [ ] Mettre à jour `guide/security-hardening.md` si de nouveaux CVEs critiques
- [ ] Commit : `docs(security): update threat-db vX.Y.Z — [résumé]`
```

$ARGUMENTS
