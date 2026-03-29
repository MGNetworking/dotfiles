---
name: git-worktree-clean
description: "Nettoie les git worktrees obsolètes avec détection des branches mergées et rapport d'utilisation disque"
---

# Git Worktree Clean

Nettoyage en lot des git worktrees obsolètes. Supprime en toute sécurité les branches mergées, rapporte l'utilisation disque et gère les branches non mergées de façon interactive.

**Principe fondamental :** Nettoyage automatique des worktrees mergés, révision interactive pour les non mergés, rapport systématique de l'espace récupéré.

**Fait partie de :** [Suite Worktree Lifecycle](./git-worktree.md) | [`/git-worktree`](./git-worktree.md) | [`/git-worktree-status`](./git-worktree-status.md) | [`/git-worktree-remove`](./git-worktree-remove.md)

## Processus

1. **Lister tous les worktrees** : `git worktree list`
2. **Classifier chacun** : mergé vs non mergé vs protégé
3. **Calculer l'utilisation disque** : Taille par worktree
4. **Mode automatique** : Supprimer tous les worktrees mergés (sûr)
5. **Mode interactif** : Réviser les worktrees non mergés un par un
6. **Rappel de nettoyage base de données** : Lister les branches DB à nettoyer
7. **Rapport** : Résumé des actions effectuées et de l'espace récupéré

## Flags

| Flag | Effet |
|------|-------|
| `--dry-run` | Prévisualiser ce qui serait nettoyé, sans effectuer de changements |
| `--all` | Inclure les worktrees non mergés (confirmation interactive pour chacun) |
| `--force` | Supprimer tous les worktrees sans confirmation (dangereux) |

## Découverte des worktrees

```bash
# Obtenir le nom de la branche principale
MAIN_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
MAIN_BRANCH=${MAIN_BRANCH:-main}

# Branches protégées (jamais nettoyées automatiquement)
PROTECTED="main master develop staging production"

# Lister tous les worktrees (ignorer le working tree principal)
git worktree list --porcelain | while read line; do
  # Analyser le chemin et la branche du worktree
  # Ignorer le worktree principal (première entrée)
done
```

## Classification

```bash
for WORKTREE in $WORKTREES; do
  BRANCH=$(git -C "$WORKTREE" rev-parse --abbrev-ref HEAD)

  # Ignorer les branches protégées
  if echo "$PROTECTED" | grep -qw "$BRANCH"; then
    echo "PROTECTED: $BRANCH (ignoré)"
    continue
  fi

  # Vérifier le statut de merge
  if git merge-base --is-ancestor "$BRANCH" "$MAIN_BRANCH" 2>/dev/null; then
    echo "MERGED: $BRANCH → suppression sûre"
    MERGED_LIST="$MERGED_LIST $WORKTREE"
  else
    echo "UNMERGED: $BRANCH → révision requise"
    UNMERGED_LIST="$UNMERGED_LIST $WORKTREE"
  fi
done
```

## Calcul de l'utilisation disque

```bash
for WORKTREE in $ALL_WORKTREES; do
  # Calculer la taille en excluant les node_modules symlinkés
  SIZE=$(du -sh --exclude='node_modules' "$WORKTREE" 2>/dev/null | cut -f1)
  # Ou sur macOS :
  SIZE=$(du -sh -I 'node_modules' "$WORKTREE" 2>/dev/null | cut -f1)
  echo "  $WORKTREE: $SIZE"
done
```

## Mode Dry Run

```bash
# --dry-run : montrer ce qui se passerait sans effectuer de changements

echo "=== Dry Run ==="
echo ""
echo "Would remove (merged):"
for WT in $MERGED_LIST; do
  echo "  $WT ($BRANCH) - $SIZE"
done
echo ""
echo "Would ask about (unmerged):"
for WT in $UNMERGED_LIST; do
  echo "  $WT ($BRANCH) - $SIZE - last commit: $(git log -1 --format='%s' $BRANCH)"
done
echo ""
echo "Total space to reclaim: $TOTAL_SIZE"
echo ""
echo "Run without --dry-run to execute."
```

## Mode automatique (par défaut)

**Supprime uniquement les worktrees mergés. Sûr par défaut.**

```bash
echo "Cleaning merged worktrees..."

for WORKTREE in $MERGED_LIST; do
  BRANCH=$(git -C "$WORKTREE" rev-parse --abbrev-ref HEAD)

  # Supprimer le worktree
  git worktree remove "$WORKTREE"

  # Supprimer la branche locale
  git branch -d "$BRANCH" 2>/dev/null

  # Supprimer la branche distante
  git push origin --delete "$BRANCH" 2>/dev/null

  echo "  Removed: $WORKTREE ($BRANCH)"
done

# Signaler les non mergés (non touchés)
if [ -n "$UNMERGED_LIST" ]; then
  echo ""
  echo "Unmerged worktrees (kept):"
  for WT in $UNMERGED_LIST; do
    echo "  $WT - use /git-worktree-remove or --all to review"
  done
fi
```

## Mode interactif (--all)

**Révise les worktrees non mergés un par un :**

```bash
for WORKTREE in $UNMERGED_LIST; do
  BRANCH=$(git -C "$WORKTREE" rev-parse --abbrev-ref HEAD)
  LAST_COMMIT=$(git log -1 --format='%h %s (%cr)' "$BRANCH")
  AHEAD=$(git rev-list --count "$MAIN_BRANCH".."$BRANCH")

  echo ""
  echo "Unmerged: $WORKTREE"
  echo "  Branch: $BRANCH ($AHEAD commits ahead of $MAIN_BRANCH)"
  echo "  Last commit: $LAST_COMMIT"
  echo "  Size: $SIZE"
  echo ""
  echo "  [r]emove  [k]eep  [s]kip remaining"

  # Attendre la décision de l'utilisateur pour chaque worktree
done
```

## Format du rapport

**Après le nettoyage :**

```
=== Worktree Cleanup Report ===

Removed (merged):
  .worktrees/feat/auth (feat/auth) - 2.3 MB
  .worktrees/fix/login-bug (fix/login-bug) - 1.1 MB
  .worktrees/chore/deps-update (chore/deps-update) - 0.8 MB

Kept (unmerged):
  .worktrees/feat/experimental (feat/experimental) - 4.2 MB
    Last commit: a1b2c3d "WIP: new auth flow" (3 days ago)

Kept (protected):
  .worktrees/develop (develop)

Space reclaimed: 4.2 MB
Worktrees remaining: 2
References pruned: yes

DB branches to clean:
  neonctl branches delete feat-auth
  neonctl branches delete fix-login-bug
  neonctl branches delete chore-deps-update
```

**Rapport dry run :**

```
=== Dry Run - No Changes Made ===

Would remove (3 merged):
  .worktrees/feat/auth - 2.3 MB
  .worktrees/fix/login-bug - 1.1 MB
  .worktrees/chore/deps-update - 0.8 MB

Would keep (1 unmerged):
  .worktrees/feat/experimental - 4.2 MB

Would keep (1 protected):
  .worktrees/develop

Potential space savings: 4.2 MB
```

## Référence rapide

| Situation | Action |
|-----------|--------|
| Par défaut (sans flags) | Supprimer les worktrees mergés uniquement |
| `--dry-run` | Prévisualiser sans effectuer de changements |
| `--all` | Mergés (auto) + non mergés (interactif) |
| `--force` | Tout supprimer sauf les branches protégées |
| Branche protégée | Toujours conservée |
| Branche mergée | Supprimée automatiquement |
| Branche non mergée | Conservée (par défaut) ou interactive (--all) |
| Branches DB détectées | Rappel avec les commandes exactes |

## Erreurs fréquentes

**Utiliser `--force` sans faire un `--dry-run` d'abord**
- Toujours prévisualiser avec `--dry-run` avant un nettoyage forcé.

**Oublier le nettoyage des branches DB**
- Le nettoyage des worktrees ne supprime pas automatiquement les branches DB. Suivre les commandes du rappel.

**Ne pas faire le nettoyage régulièrement**
- Les worktrees obsolètes accumulent de l'espace disque. Lancer `/git-worktree-clean --dry-run` chaque semaine.

## Utilisation

```
/git-worktree-clean
/git-worktree-clean --dry-run
/git-worktree-clean --all
```

Flags : $ARGUMENTS
