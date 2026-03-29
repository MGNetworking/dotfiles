---
name: pr
description: "Analyser les changements, détecter les problèmes de périmètre et créer une PR bien structurée"
---

# Créer une Pull Request

Analyser les changements, détecter les problèmes de périmètre et créer une PR bien structurée en respectant les conventions du projet.

## Processus

1. **Analyser les changements** : Calculer le score de complexité à partir des fichiers, commits et répertoires
2. **Détecter les problèmes de périmètre** : Avertir si la PR est trop grande ou mélange des changements sans rapport
3. **Suggérer un découpage** : Si nécessaire, regrouper les commits par périmètre et proposer des PRs séparées
4. **Collecter les informations** : Demander le type, la branche cible, le statut draft, les labels
5. **Générer le contenu** : Créer un TLDR + description + checklist
6. **Créer la PR** : Exécuter `gh pr create` avec le formatage approprié
7. **Rappeler les étapes suivantes** : Afficher la checklist post-PR (SonarQube, Claude Review)

## Score de complexité

Calculer la complexité de la PR pour détecter si un découpage est nécessaire :

| Critère | Poids | Description |
|---------|-------|-------------|
| Fichiers de code | x2 | `*.ts, *.tsx` (hors tests) |
| Fichiers de tests | x0.5 | `*.test.ts, *.spec.ts` |
| Fichiers de config | x1 | `*.json, *.yml, *.md` |
| Répertoires | x3 | Répertoires `src/*` distincts |
| Commits | x1 | Nombre de commits |

**Seuils** : 0-15 ✅ Normal | 16-25 ⚠️ Grande | 26+ 🔴 Découpage recommandé

## Cohérence du périmètre

| Modèle | Verdict |
|--------|---------|
| Périmètre unique | ✅ OK |
| Périmètres liés (sessions + calendrier) | ✅ OK |
| Périmètres sans rapport (paiements + auth) | 🔴 Découper |
| feat + fix même périmètre | ✅ OK |
| feat + fix périmètres différents | 🔴 Découper |

## Format de suggestion de découpage

Lorsque le découpage est recommandé, afficher :

```
🔴 Scope trop large (score: 32)

Commits par scope :
├── payments (5 commits, 8 fichiers)
│   ├── feat(payments): add Stripe checkout
│   └── fix(payments): handle currency
│
└── notifications (3 commits, 6 fichiers)
    └── feat(notifications): add email templates

💡 Suggestion :
1. PR #1 : feature/payments-stripe → Commits payments
2. PR #2 : feature/notifications → Commits notifications

Options :
[A] Continuer avec une seule PR (non recommandé)
[B] Découper (semi-auto - commandes git fournies)
[C] Voir détail fichiers
```

**Découpage semi-automatique** fournit des commandes à copier-coller :
```bash
git checkout develop
git checkout -b feature/payments-stripe
git cherry-pick abc1234 def5678
git push -u origin feature/payments-stripe
```

## Questions à poser

1. **Type** : feature | fix | tech | docs | security
2. **Branche cible** : Afficher les branches récentes (develop, main, autres)
3. **Draft** : Oui (WIP) | Non (prêt pour review)
4. **Labels** : Basés sur le type + optionnel (breaking-change, security)

## Format du titre de PR

```
<type>(<scope>): <description>
```

Exemples :
- `feat(payments): add Stripe checkout integration`
- `fix(sessions): resolve timezone calculation bug`

## Template du corps de PR

```markdown
## TLDR
<!-- 2 lignes max - Résumé exécutif -->

---

## Type
{Feature | Fix | Tech | Docs | Security}

## Description
{Contexte et changements}

## Changements techniques
{Liste des principales modifications}

## Tests
- [ ] Tests unitaires ajoutés/passants
- [ ] Tests manuels effectués

## Checklist
- [ ] Le code respecte les conventions
- [ ] Pas de console.log restant
- [ ] Types OK (`pnpm typecheck`)

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

## Labels disponibles

| Label | Couleur | Utiliser quand |
|-------|---------|----------------|
| `feature` | 🟢 | Nouvelle fonctionnalité |
| `fix` | 🔴 | Correction de bug |
| `tech` | 🔵 | Refactoring, dette technique |
| `docs` | 📘 | Documentation uniquement |
| `security` | 🟣 | Correction de sécurité |
| `breaking-change` | ⚫ | Changements cassants |
| `WIP` | 🟡 | Travail en cours (draft) |

## Commandes à exécuter

```bash
# 1. Obtenir la branche de base (généralement develop)
BASE_BRANCH="develop"

# 2. Calculer le score de complexité
CODE=$(git diff --name-only $BASE_BRANCH..HEAD | grep -E '\.(ts|tsx)$' | grep -v test | wc -l)
TESTS=$(git diff --name-only $BASE_BRANCH..HEAD | grep -E '\.test\.|\.spec\.' | wc -l)
DIRS=$(git diff --name-only $BASE_BRANCH..HEAD | cut -d'/' -f1-2 | sort -u | wc -l)
COMMITS=$(git rev-list --count $BASE_BRANCH..HEAD)
SCORE=$((CODE * 2 + TESTS / 2 + DIRS * 3 + COMMITS))

# 3. Obtenir les scopes depuis les commits
git log --oneline $BASE_BRANCH..HEAD --format="%s" | sed -n 's/^\w*(\([^)]*\)).*/\1/p' | sort | uniq -c

# 4. Branches récentes pour la sélection
git branch --sort=-committerdate --format='%(refname:short)' | head -5

# 5. Créer la PR
gh pr create \
  --title "<type>(<scope>): <description>" \
  --body "$BODY" \
  --base $BASE_BRANCH \
  --label "<label>" \
  --draft  # si WIP
```

## Sortie post-PR

Après la création de la PR, TOUJOURS afficher :

```
✅ PR créée : https://github.com/org/repo/pull/XXX

📋 Prochaines étapes automatiques :
   • SonarQube analysera la qualité du code (bugs, vulnérabilités, code smells)
   • Claude Code Review fournira un feedback IA sur votre PR

⏳ Pensez à surveiller ces analyses dans les prochaines minutes.
   Si des problèmes sont détectés, corrigez-les avant de demander une review humaine.
```

## Cas limites

| Situation | Comportement |
|-----------|--------------|
| Pas de scope dans les commits | Analyser par répertoires |
| Commits non conventionnels | Avertir + demander le type manuellement |
| Aucun commit (identique à la base) | Erreur : "Aucun changement" |
| Commit unique | Utiliser le message de commit comme titre |
| Merge commits | Ignorer (`--no-merges`) |

## Utilisation

```
/pr
/pr --base main
/pr --draft
```

Cible : $ARGUMENTS (optionnel : --base, --draft)
