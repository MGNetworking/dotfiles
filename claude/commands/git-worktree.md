---
name: git-worktree
description: "Crée des git worktrees isolés pour le développement de fonctionnalités sans changer de branche"
---

# Git Worktree Setup

Crée des git worktrees isolés pour le développement de fonctionnalités sans changer de branche.

**Principe fondamental :** Sélection intelligente du répertoire + optimisation par symlinks + vérification en arrière-plan = isolation rapide et fiable.

**Requiert :** Git 2.5.0+ (juillet 2015)

**Commandes complémentaires :** [`/git-worktree-status`](./git-worktree-status.md) | [`/git-worktree-remove`](./git-worktree-remove.md) | [`/git-worktree-clean`](./git-worktree-clean.md)

## Processus

1. **Valider le nom de branche** : Vérifier la convention de nommage et les conflits
2. **Vérifier les répertoires existants** : `.worktrees/` ou `worktrees/`
3. **Vérifier le .gitignore** : S'assurer que le répertoire worktree est ignoré
4. **Créer le worktree** : `git worktree add`
5. **Symlinkter les dépendances** : Réutiliser `node_modules/` du worktree principal
6. **Détecter le fournisseur de base de données** : Vérifier la capacité de branching DB
7. **Installer les dépendances** : Détecter automatiquement le gestionnaire de paquets (si pas de symlink)
8. **Lancer la vérification en arrière-plan** : Vérification de types + tests en arrière-plan
9. **Rapporter l'emplacement** : Confirmer que le worktree est prêt avec son statut

## Flags

| Flag | Effet |
|------|-------|
| `--fast` | Ignorer l'installation des dépendances et les tests de base |
| `--isolated` | Installation fraîche de `node_modules` (pas de symlink) |
| `--skip-install` | Ignorer l'installation des dépendances, conserver les tests de base |

## Validation du nom de branche

```bash
# Préfixage automatique selon la convention de nommage
# "auth" → "feat/auth" (préfixe par défaut)
# "fix/login-bug" → conservé tel quel
# "refactor/db-layer" → conservé tel quel

# Préfixes acceptés : feat/, fix/, refactor/, chore/, docs/, test/, perf/
# Sans préfixe → préfixe par défaut feat/

# Rejeter les caractères invalides
echo "$BRANCH_NAME" | grep -qE '^[a-zA-Z0-9/_-]+$' || exit 1

# Vérifier que la branche n'existe pas déjà
git show-ref --verify --quiet "refs/heads/$BRANCH_NAME" && echo "Branch already exists" && exit 1
```

## Sélection du répertoire

### Ordre de priorité

```bash
# 1. Vérifier les répertoires existants
ls -d .worktrees 2>/dev/null     # Préféré (caché)
ls -d worktrees 2>/dev/null      # Alternative

# 2. Vérifier CLAUDE.md pour une préférence
grep -i "worktree.*director" CLAUDE.md 2>/dev/null

# 3. Demander à l'utilisateur si aucun n'existe
```

**Si les deux existent :** `.worktrees/` est prioritaire.

## Vérification de sécurité

**Pour les répertoires locaux au projet :**

```bash
# Vérifier que le répertoire est dans .gitignore
grep -q "^\.worktrees/$" .gitignore || grep -q "^worktrees/$" .gitignore
```

**Si NON présent dans .gitignore :**
1. Ajouter la ligne dans .gitignore
2. Committer la modification
3. Procéder à la création du worktree

**Pourquoi c'est critique :** Évite de committer accidentellement le contenu des worktrees.

## Étapes de création

```bash
# 1. Détecter le nom du projet
project=$(basename "$(git rev-parse --show-toplevel)")

# 2. Créer le worktree avec une nouvelle branche
git worktree add .worktrees/$BRANCH_NAME -b $BRANCH_NAME

# 3. Naviguer
cd .worktrees/$BRANCH_NAME
```

## Optimisation des dépendances (Node.js)

**Comportement par défaut :** Symlinkter `node_modules` depuis le worktree principal pour éviter les installations dupliquées (~30 s économisés).

```bash
# Symlinkter node_modules (par défaut, sauf --isolated)
if [ -d "../../node_modules" ] && [ ! "$ISOLATED" = true ]; then
  ln -s "$(cd ../.. && pwd)/node_modules" node_modules
  echo "Symlinked node_modules from main worktree"
fi

# Avec --isolated : installation fraîche
if [ "$ISOLATED" = true ]; then
  pnpm install   # ou npm/yarn selon la détection du lockfile
fi
```

**Quand utiliser `--isolated` :**
- Modifications de schéma nécessitant des versions de paquets différentes
- Tests de mises à jour de dépendances
- Débogage de problèmes liés à `node_modules`

## Détection automatique de la configuration (multi-stack)

```bash
# Node.js (si pas de symlink)
if [ -f package.json ] && [ ! -L node_modules ]; then
  pnpm install   # Détecter depuis le lockfile : pnpm-lock.yaml / yarn.lock / package-lock.json
fi

# Rust
if [ -f Cargo.toml ]; then cargo build; fi

# Python
if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
if [ -f pyproject.toml ]; then poetry install; fi

# Go
if [ -f go.mod ]; then go mod download; fi
```

## Vérification en arrière-plan

**Au lieu de bloquer sur la suite de tests complète, lancer la vérification en arrière-plan :**

```bash
# Créer le répertoire de logs
mkdir -p .worktree-logs

# Vérification de types en arrière-plan (Node.js)
if [ -f tsconfig.json ]; then
  npx tsc --noEmit > .worktree-logs/typecheck.log 2>&1 &
  echo "Type check running in background (check with /git-worktree-status)"
fi

# Lancement des tests en arrière-plan
if [ -f package.json ]; then
  npx vitest run --reporter=json > .worktree-logs/tests.log 2>&1 &
  echo "Tests running in background (check with /git-worktree-status)"
fi
```

**Avec `--fast` :** Ignorer toutes les vérifications.

## Rapport final

```
Worktree ready at <full-path>
Branch: feat/auth (created from main)
Dependencies: symlinked from main worktree
Background checks: type check + tests running
Check status: /git-worktree-status

Ready to implement <feature-name>
```

## Suggestion de branche de base de données

**Après la création du worktree, détecter le fournisseur de base de données et suggérer l'isolation.**

### Référence rapide des commandes

| Fournisseur | Commande suggérée |
|-------------|-------------------|
| **Neon** | `neonctl branches create --name <branch> --parent main` |
| **PlanetScale** | `pscale branch create <db> <branch>` |
| **Postgres local** | `psql -c "CREATE SCHEMA <schema>;"` |
| **Autre** | Configuration manuelle ou base de données partagée |

**Exemple de sortie :**

```
Worktree created at .worktrees/feat/auth

DB Isolation: neonctl branches create --name feat-auth --parent main
   Then update .env with new DATABASE_URL
   Full guide: ../workflows/database-branch-setup.md
```

### Configuration de .worktreeinclude

**Critique pour les variables d'environnement :**

```bash
# .worktreeinclude (à la racine du projet)
.env
.env.local
.env.development
**/.claude/settings.local.json
```

**Pourquoi :** Sans cela, les fichiers `.env` ne seront pas copiés dans les worktrees.

### Quand créer une branche de base de données

| Scénario | Créer une branche ? |
|----------|---------------------|
| Migrations de schéma | Oui |
| Refactoring du modèle de données | Oui |
| Correction de bug (sans changement de schéma) | Non |
| Expériences de performance | Oui |

**Voir :** [Guide de configuration des branches de base de données](../workflows/database-branch-setup.md) pour les workflows complets.

## Référence rapide

| Situation | Action |
|-----------|--------|
| `.worktrees/` existe | L'utiliser (vérifier .gitignore) |
| `worktrees/` existe | L'utiliser (vérifier .gitignore) |
| Les deux existent | Utiliser `.worktrees/` |
| Aucun n'existe | Vérifier CLAUDE.md, puis demander à l'utilisateur |
| Pas dans .gitignore | Ajouter + committer immédiatement |
| Pas de préfixe de branche | Préfixe automatique avec `feat/` |
| Projet Node.js | Symlinkter `node_modules` par défaut |
| Flag `--fast` | Ignorer installation + tests |
| Flag `--isolated` | Installation fraîche de `node_modules` |
| Neon détecté | Suggérer `neonctl branches create` |
| PlanetScale détecté | Suggérer `pscale branch create` |
| Pas de .worktreeinclude | Créer avec le pattern `.env` |

## Erreurs fréquentes

**Ignorer la vérification du .gitignore**
- Le contenu du worktree est tracké et pollue le statut git.

**Supposer l'emplacement du répertoire**
- Suivre la priorité : existant > CLAUDE.md > demander.

**Installer node_modules complet dans chaque worktree**
- Gaspille disque et temps. Utiliser le symlink par défaut, `--isolated` seulement si nécessaire.

**Ne pas copier .env dans le worktree**
- Symptôme : Claude échoue avec "DATABASE_URL not found"
- Correction : Ajouter `.env` dans `.worktreeinclude`

**Utiliser une base de données partagée pour des modifications de schéma**
- Symptôme : Conflits de migrations, environnement de développement cassé
- Correction : Créer une branche de base de données avant de modifier le schéma

## Utilisation

```
/git-worktree auth
/git-worktree fix/session-bug
/git-worktree feature/new-api --fast
/git-worktree refactor/db-layer --isolated
```

Nom de branche : $ARGUMENTS
