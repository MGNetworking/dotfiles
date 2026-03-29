---
name: git-worktree-remove
description: "Supprime en toute sécurité un git worktree avec nettoyage de branche et vérifications de sécurité"
---

# Git Worktree Remove

Supprime en toute sécurité un seul git worktree avec nettoyage de branche, vérification du merge et démantèlement des ressources de base de données.

**Principe fondamental :** Vérifications de sécurité d'abord, puis suppression propre du worktree + branche + ressources DB.

**Fait partie de :** [Suite Worktree Lifecycle](./git-worktree.md) | [`/git-worktree`](./git-worktree.md) | [`/git-worktree-status`](./git-worktree-status.md) | [`/git-worktree-clean`](./git-worktree-clean.md)

## Processus

1. **Valider la cible** : Identifier le worktree à supprimer
2. **Vérification de sécurité** : Protéger les branches main/develop
3. **Vérifier le statut de merge** : Avertir si la branche a des modifications non mergées
4. **Vérifier les modifications non commitées** : Avertir si le worktree est dans un état sale
5. **Supprimer le worktree** : `git worktree remove`
6. **Supprimer la branche locale** : `git branch -d` (ou `-D` avec confirmation)
7. **Supprimer la branche distante** : `git push origin --delete` (avec confirmation)
8. **Rappel de nettoyage base de données** : Suggérer la suppression de la branche DB si applicable
9. **Nettoyer les références** : `git worktree prune`

## Vérifications de sécurité

### Branches protégées

```bash
# Ne jamais supprimer les worktrees de ces branches (configurable)
PROTECTED_BRANCHES="main master develop staging production"

if echo "$PROTECTED_BRANCHES" | grep -qw "$BRANCH"; then
  echo "BLOCKED: Cannot remove worktree for protected branch '$BRANCH'"
  echo "Protected branches: $PROTECTED_BRANCHES"
  exit 1
fi
```

### Modifications non commitées

```bash
cd "$WORKTREE_PATH"
if [ -n "$(git status --porcelain)" ]; then
  echo "WARNING: Worktree has uncommitted changes:"
  git status --short
  echo ""
  echo "Options:"
  echo "  1. Commit changes first"
  echo "  2. Force remove (--force)"
  echo "  3. Cancel"
  # Attendre la décision de l'utilisateur
fi
```

### Statut de merge

```bash
# Vérifier si la branche est mergée dans main
MAIN_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')

if git merge-base --is-ancestor "$BRANCH" "$MAIN_BRANCH" 2>/dev/null; then
  echo "Branch '$BRANCH' is merged into $MAIN_BRANCH. Safe to delete."
  MERGED=true
else
  echo "WARNING: Branch '$BRANCH' is NOT merged into $MAIN_BRANCH."
  echo "You may lose work if you delete this branch."
  MERGED=false
fi
```

## Étapes de suppression

```bash
# 1. Supprimer le worktree
git worktree remove "$WORKTREE_PATH"
# Si l'état est sale et que l'utilisateur a confirmé le force :
# git worktree remove --force "$WORKTREE_PATH"

# 2. Supprimer la branche locale
if [ "$MERGED" = true ]; then
  git branch -d "$BRANCH"
else
  echo "Delete unmerged branch '$BRANCH'? (requires confirmation)"
  # Après confirmation :
  git branch -D "$BRANCH"
fi

# 3. Supprimer la branche distante (avec confirmation)
if git ls-remote --heads origin "$BRANCH" | grep -q "$BRANCH"; then
  echo "Delete remote branch 'origin/$BRANCH'?"
  # Après confirmation :
  git push origin --delete "$BRANCH"
fi

# 4. Nettoyer les références obsolètes
git worktree prune
```

## Nettoyage des branches de base de données

**Après la suppression du worktree, rappeler les branches de base de données associées :**

```bash
# Détecter le fournisseur de base de données (même logique que /git-worktree)
if [ -f ".env" ] && grep -q "neon" ".env"; then
  echo ""
  echo "DB Cleanup: neonctl branches delete $BRANCH_SLUG"
elif [ -f ".pscale.yml" ]; then
  echo ""
  DB_NAME=$(grep 'database:' .pscale.yml | awk '{print $2}')
  echo "DB Cleanup: pscale branch delete $DB_NAME $BRANCH_SLUG"
elif [ -f ".env" ] && grep -q "postgresql" ".env"; then
  echo ""
  echo "DB Cleanup: psql \$DATABASE_URL -c \"DROP SCHEMA ${BRANCH_SLUG} CASCADE;\""
fi
```

## Format du rapport

**Suppression réussie (branche mergée) :**

```
Removed worktree: .worktrees/feat/auth
  Worktree directory: deleted
  Local branch feat/auth: deleted (was merged)
  Remote branch origin/feat/auth: deleted
  References: pruned

DB reminder: neonctl branches delete feat-auth
```

**Suppression avec avertissements (branche non mergée) :**

```
Removed worktree: .worktrees/feat/experimental
  Worktree directory: deleted
  Local branch feat/experimental: deleted (was NOT merged - forced)
  Remote branch: no remote branch found
  References: pruned

WARNING: Branch was not merged. Changes may be lost.
Last commit: a1b2c3d "WIP: experimental auth flow"
```

## Flags

| Flag | Effet |
|------|-------|
| `--force` | Ignorer l'avertissement sur les modifications non commitées |
| `--keep-branch` | Supprimer le worktree mais conserver la branche |
| `--keep-remote` | Ne pas supprimer la branche distante |

## Référence rapide

| Situation | Action |
|-----------|--------|
| Branche mergée | Suppression sûre (branch -d) |
| Branche non mergée | Avertissement + confirmation requise (branch -D) |
| Modifications non commitées | Avertissement + proposer force/annulation |
| Branche protégée (main/develop) | Suppression bloquée |
| Branche distante existante | Demander confirmation pour supprimer |
| Branche DB détectée | Rappel avec la commande exacte |
| Références obsolètes | Nettoyage automatique |

## Erreurs fréquentes

**Supprimer le worktree de main/develop**
- Toujours bloqué par la vérification de sécurité. Reconfigurer les branches protégées si nécessaire.

**Supprimer une branche non mergée sans vérifier**
- Toujours vérifier le statut de merge. Les branches non mergées nécessitent un `--force` ou `-D` explicite.

**Oublier le nettoyage des branches de base de données**
- Laisse des branches DB orphelines qui consomment des ressources. La commande rappelle automatiquement.

**Utiliser `rm -rf` au lieu de `git worktree remove`**
- Laisse des références de worktree obsolètes dans `.git/worktrees/`. Toujours utiliser les commandes git.

## Utilisation

```
/git-worktree-remove feat/auth
/git-worktree-remove fix/login-bug --force
/git-worktree-remove refactor/db --keep-branch
```

Branche ou chemin du worktree : $ARGUMENTS
