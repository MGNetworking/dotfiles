---
name: commit
description: "Générer un message de commit conventionnel pour les modifications stagées"
---

# Commit Conventionnel

Générer un message de commit conventionnel pour les modifications stagées.

## Instructions

1. Lancer `git diff --cached` pour voir les modifications stagées
2. Analyser la nature des modifications
3. Générer un message de commit selon le format ci-dessous

## Format du Commit

```
<type>(<scope>): <sujet>

[corps optionnel]

[pied de page optionnel]
```

### Types
- `feat` : Nouvelle fonctionnalité
- `fix` : Correction de bug
- `docs` : Documentation uniquement
- `style` : Formatage, points-virgules manquants, etc.
- `refactor` : Modification du code qui ne corrige ni n'ajoute de fonctionnalité
- `perf` : Amélioration des performances
- `test` : Ajout de tests manquants
- `chore` : Tâches de maintenance

### Règles
- Sujet : mode impératif, sans point final, 50 caractères max
- Corps : expliquer QUOI et POURQUOI, pas COMMENT
- Pied de page : changements incompatibles, références aux issues

## Exemples

```
feat(auth): add password reset functionality

Implement password reset flow with email verification.
Users can now request a reset link and set new password.

Closes #123
```

```
fix(api): prevent race condition in order processing

Add mutex lock to ensure orders are processed sequentially.
This fixes duplicate charge issues reported by users.

Fixes #456
```

```
refactor(cart): extract pricing logic to separate module

No functional changes. Improves testability and
separates concerns for future discount feature.
```

## Exécution

Après analyse des modifications stagées, suggérer un message de commit.
Demander confirmation avant d'exécuter `git commit -m "..."`.

> Cette commande est invoquée manuellement par l'utilisateur.
> Ne pas ajouter de ligne `Co-Authored-By` dans le message de commit.
> L'utilisateur est le seul auteur du commit.

$ARGUMENTS
