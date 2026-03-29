---
name: catchup
description: "Restaurer le contexte après /clear en résumant le travail récent et l'état du projet"
---

# Reprise de Contexte

Restaurer le contexte après `/clear` — résumer le travail récent et l'état du projet.

## Objectif

Après avoir effacé le contexte avec `/clear`, utiliser cette commande pour reconstruire rapidement la compréhension de :
- Ce qui a été modifié récemment
- L'état actuel du projet
- Les TODOs et problèmes en suspens
- Où reprendre le travail

## Instructions

### Étape 1 : Analyse de l'Historique Git

```bash
# Commits récents (10 derniers)
git log --oneline -10

# Fichiers modifiés dans les 5 derniers commits
git diff --stat HEAD~5 2>/dev/null || git diff --stat $(git rev-list --max-parents=0 HEAD)

# Branche courante et statut
git branch --show-current
git status --short
```

### Étape 2 : Résumé des Modifications Récentes

```bash
# Ce qui a changé aujourd'hui
git log --oneline --since="midnight" --author="$(git config user.name)" 2>/dev/null

# Travail non commité
git diff --name-only
git diff --cached --name-only
```

### Étape 3 : Scan des TODO/FIXME

```bash
# Trouver les marqueurs de travail en suspens dans les fichiers récemment modifiés
git diff --name-only HEAD~5 2>/dev/null | head -20 | xargs grep -n "TODO\|FIXME\|XXX\|HACK" 2>/dev/null | head -30
```

### Étape 4 : Vérification de l'État du Projet

```bash
# Vérifier les indicateurs d'état courants
[ -f "package.json" ] && echo "📦 Projet Node : $(jq -r '.name // "sans nom"' package.json)"
[ -f "Cargo.toml" ] && echo "🦀 Projet Rust : $(grep '^name' Cargo.toml | head -1)"
[ -f "pyproject.toml" ] && echo "🐍 Projet Python"
[ -f "go.mod" ] && echo "🐹 Projet Go : $(head -1 go.mod | cut -d' ' -f2)"

# Objectif de la branche active (d'après le nom de la branche)
BRANCH=$(git branch --show-current)
echo "🌿 Branche : $BRANCH"
```

## Format de Sortie

Fournir un résumé structuré :

---

### 📍 Contexte Restauré

**Projet** : [nom issu de package.json/Cargo.toml/etc]
**Branche** : [branche courante]
**Dernière Activité** : [heure du dernier commit]

### 🔄 Travail Récent (5 Derniers Commits)

1. [message du commit 1] - [fichiers concernés]
2. [message du commit 2] - [fichiers concernés]
...

### 📝 Modifications Non Commitées

- [liste des fichiers modifiés avec brève description des changements]

### ⚠️ TODOs en Suspens

- [fichier:ligne] TODO : [description]
- [fichier:ligne] FIXME : [description]

### 🎯 Prochaines Étapes Suggérées

En fonction de l'activité récente :
1. [Action la plus probable basée sur les patterns]
2. [Autre axe de focus]

---

## Exemples d'Utilisation

**Après une longue pause :**
```
/catchup
```
→ Restauration complète du contexte

**Vérification rapide de l'état :**
```
/catchup --brief
```
→ Uniquement les commits et les modifications non commitées

**Focus sur une zone spécifique :**
```
/catchup auth
```
→ Filtrer sur les modifications liées à l'authentification

## Conseils

1. **Documenter avant `/clear`** : Écrire une brève note dans un message de commit ou dans CLAUDE.md avant d'effacer le contexte
2. **Utiliser avec Memory Bank** : Combiner avec les fichiers `.claude/memory/` pour un état persistant
3. **Nommage des branches** : Utiliser des noms de branches descriptifs (ex. : `feat/user-auth`) pour faciliter la restauration du contexte

$ARGUMENTS
