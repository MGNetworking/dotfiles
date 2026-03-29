---
name: git-setup-branches
description: "Créer les branches git recommandées selon la stratégie choisie (GitHub Flow, GitFlow, Trunk-based)"
---

# Git Setup — Branches

Créer et configurer les branches git selon la stratégie choisie.

## Instructions

Si appelé seul (sans argument), poser les questions suivantes :

1. **Stratégie de branches** ?
   - `github-flow` — `main` + branches de feature
   - `gitflow` — `main`, `develop`, `release/*`, `hotfix/*`, `feature/*`
   - `trunk` — `main` uniquement

2. **Nom de la branche principale** ? (défaut : `main`)

Si appelé depuis `/git-setup`, utiliser les arguments fournis directement.

---

## Branches selon la stratégie

### GitHub Flow
```
main          ← production, protégée
```
Convention de nommage des branches de travail :
- `feature/<nom>` — nouvelle fonctionnalité
- `fix/<nom>` — correction de bug
- `docs/<nom>` — documentation
- `chore/<nom>` — maintenance

### GitFlow
```
main          ← production, protégée
develop       ← intégration continue
```
Convention de nommage :
- `feature/<nom>` — développement depuis develop
- `release/<version>` — préparation d'une release
- `hotfix/<nom>` — correctif urgent depuis main

### Trunk-based
```
main          ← seule branche longue durée
```
Convention de nommage :
- `<pseudo>/<nom>` — branche courte durée (< 2 jours)

---

## Exécution

1. Vérifier que le dépôt git est initialisé (`git init` si nécessaire)
2. S'assurer qu'un commit initial existe (créer un commit vide si besoin)
3. Créer les branches selon la stratégie :

**GitHub Flow / Trunk-based :**
```bash
git checkout -b main 2>/dev/null || git checkout main
```

**GitFlow :**
```bash
git checkout -b main 2>/dev/null || git checkout main
git checkout -b develop
git checkout main
```

4. Afficher les branches créées avec `git branch -a`
5. Afficher la convention de nommage à retenir

$ARGUMENTS
