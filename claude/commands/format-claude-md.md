# /format-claude-md

Restructure le fichier `CLAUDE.md` du projet courant en index pur.
Un `CLAUDE.md` ne doit contenir que des pointeurs — jamais du contenu.

## Étape 1 — Lecture

Lis `CLAUDE.md` dans son intégralité.

## Étape 2 — Inventaire

Identifie les fichiers de documentation disponibles :
`docs/`, `README.md`, `memory/`, `playbook/`, `~/.claude/`

Pour chaque bloc de `CLAUDE.md`, détermine sa nature :

| Type | Critère | Destination |
|---|---|---|
| **Projet** | Specs, design, invariants, routes, état courant | Pointer vers `docs/` |
| **Méthodologie** | Méthode de travail, process, guides, techniques d'analyse | Déplacer vers `playbook/` ou `~/.claude/` |
| **Personnel** | Profil utilisateur, préférences, décisions collaboratives | Déplacer vers `memory/` |
| **Temporaire** | WIP, ticket en cours, staging | `CLAUDE.staging.md` |
| **Obsolète** | Information dépassée, décision annulée | Supprimer |

## Étape 3 — Rapport avant modification

Présente le rapport suivant et attends la validation :

```
POINTEURS À CONSERVER
- <liste>

PROJET → pointeurs vers :
- <contenu> → <fichier docs/>

MÉTHODOLOGIE → à déplacer vers :
- <contenu> → playbook/ ou ~/.claude/

PERSONNEL → à déplacer vers :
- <contenu> → memory/

TEMPORAIRE → CLAUDE.staging.md
- <liste>

OBSOLÈTE → à supprimer
- <liste>
```

## Étape 4 — Exécution

Après validation :

1. Déplacer chaque contenu vers sa destination naturelle
2. Créer `CLAUDE.staging.md` si des contenus temporaires sans destination existent
3. Réécrire `CLAUDE.md` selon ce format cible — tenir sur une page :

```markdown
# <Nom du projet>

## Sources de vérité
→ <fichier> — <rôle>
→ <fichier> — <rôle>

## Contextes
→ .claude/contexts/

## État projet
→ <fichier de suivi>

## Prochaine étape
<ticket ou phase — une ligne>
```

## Règles

- Aucun contenu dans `CLAUDE.md` — uniquement des pointeurs
- Aucune suppression sans avoir vérifié qu'une destination existe
- `CLAUDE.staging.md` est temporaire — chaque item doit être résolu
