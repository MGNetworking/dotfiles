---
name: git-worktree-status
description: "Vérifie le statut des tâches de vérification en arrière-plan lancées dans un git worktree"
---

# Git Worktree Status

Vérifie les tâches de vérification en arrière-plan (vérification de types, tests, build) lancées par `/git-worktree`.

**Principe fondamental :** Retour non bloquant sur l'état du worktree sans interrompre le flux de développement.

**Fait partie de :** [Suite Worktree Lifecycle](./git-worktree.md) | [`/git-worktree`](./git-worktree.md) | [`/git-worktree-remove`](./git-worktree-remove.md) | [`/git-worktree-clean`](./git-worktree-clean.md)

## Processus

1. **Détecter le worktree actuel** : Vérifier qu'on est bien à l'intérieur d'un git worktree
2. **Vérifier les fichiers de log** : Lire `.worktree-logs/` pour les résultats des tâches en arrière-plan
3. **Analyser les résultats** : Extraire le nombre de succès/échecs et les erreurs
4. **Rapporter le statut** : Résumé coloré avec les prochaines étapes à effectuer

## Détection du worktree

```bash
# Vérifier si on est dans un worktree (pas le dépôt principal)
git rev-parse --git-common-dir 2>/dev/null | grep -q "\.git/worktrees" || {
  echo "Not inside a worktree. Use from a worktree directory."
  exit 1
}

# Obtenir les informations du worktree
WORKTREE_PATH=$(git rev-parse --show-toplevel)
BRANCH=$(git rev-parse --abbrev-ref HEAD)
MAIN_REPO=$(git rev-parse --git-common-dir | sed 's|/\.git/worktrees/.*||')
```

## Vérifications des tâches en arrière-plan

### Statut de la vérification de types

```bash
LOG=".worktree-logs/typecheck.log"

if [ -f "$LOG" ]; then
  if grep -q "error TS" "$LOG"; then
    ERROR_COUNT=$(grep -c "error TS" "$LOG")
    echo "Type check: FAIL ($ERROR_COUNT errors)"
    # Afficher les 5 premières erreurs
    grep "error TS" "$LOG" | head -5
  else
    echo "Type check: PASS"
  fi
elif pgrep -f "tsc --noEmit" > /dev/null; then
  echo "Type check: RUNNING..."
else
  echo "Type check: NOT RUN"
fi
```

### Statut des tests

```bash
LOG=".worktree-logs/tests.log"

if [ -f "$LOG" ]; then
  if grep -q '"numFailedTests":0' "$LOG"; then
    TOTAL=$(grep -o '"numTotalTests":[0-9]*' "$LOG" | cut -d: -f2)
    echo "Tests: PASS ($TOTAL tests)"
  else
    FAILED=$(grep -o '"numFailedTests":[0-9]*' "$LOG" | cut -d: -f2)
    echo "Tests: FAIL ($FAILED failures)"
    # Afficher les noms des tests échoués
    grep '"fullName"' "$LOG" | head -5
  fi
elif pgrep -f "vitest run" > /dev/null; then
  echo "Tests: RUNNING..."
else
  echo "Tests: NOT RUN"
fi
```

### Statut du build

```bash
LOG=".worktree-logs/build.log"

if [ -f "$LOG" ]; then
  if [ $? -eq 0 ]; then
    echo "Build: PASS"
  else
    echo "Build: FAIL"
    tail -10 "$LOG"
  fi
elif pgrep -f "cargo build\|next build\|go build" > /dev/null; then
  echo "Build: RUNNING..."
else
  echo "Build: NOT RUN"
fi
```

## Format du rapport

```
Worktree Status: .worktrees/feat/auth
Branch: feat/auth (from main, 3 commits ahead)

Checks:
  Type check:  PASS
  Tests:       PASS (142 tests)
  Build:       NOT RUN

Dependencies: symlinked from main
Disk usage: 2.3 MB (excl. node_modules)

Log files: .worktree-logs/
```

**En cas d'échecs détectés :**

```
Worktree Status: .worktrees/feat/auth
Branch: feat/auth (from main, 3 commits ahead)

Checks:
  Type check:  FAIL (3 errors)
    src/auth.ts:42 - error TS2345: Argument of type 'string' is not assignable
    src/auth.ts:67 - error TS2304: Cannot find name 'AuthConfig'
    src/middleware.ts:12 - error TS7006: Parameter 'req' implicitly has an 'any' type
  Tests:       FAIL (2 failures)
    auth.test.ts > should validate token
    auth.test.ts > should reject expired token
  Build:       NOT RUN

Action: Fix type errors before proceeding. Run `npx tsc --noEmit` for full output.
```

## Gestion des logs

```bash
# Supprimer les anciens logs (utile pour relancer les vérifications)
rm -rf .worktree-logs/*.log

# Relancer toutes les vérifications
npx tsc --noEmit > .worktree-logs/typecheck.log 2>&1 &
npx vitest run --reporter=json > .worktree-logs/tests.log 2>&1 &
```

## Référence rapide

| Situation | Sortie |
|-----------|--------|
| Toutes les vérifications passent | Statut vert, prêt à travailler |
| Vérifications en cours | "RUNNING..." avec le PID |
| Erreurs de types détectées | Nombre d'erreurs + 5 premières erreurs |
| Échecs de tests | Nombre d'échecs + noms des tests échoués |
| Aucun log trouvé | "NOT RUN" (utiliser `--fast` ou logs supprimés) |
| Pas dans un worktree | Message d'erreur avec les instructions |

## Utilisation

```
/git-worktree-status
```

Aucun argument nécessaire. Lancer depuis n'importe quel répertoire worktree.
