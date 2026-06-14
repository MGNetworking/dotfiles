# /audit-context

Contrôle la cohérence complète du système de contextes d'un projet.
Détecte les dérives, les liens cassés, les composants orphelins et les documents non couverts.

Usage :
- `/audit-context` — rapport complet avec erreurs et avertissements
- `/audit-context --strict` — échec si couverture < 100% ou toute référence cassée

> Prérequis : `.claude/` doit déjà exister (généré par `/bootstrap-context`).

---

## Vérification 1 — Documentation

Lire `documentation-map.md` → collecter tous les chemins référencés.

Pour chaque chemin :
- Vérifier que le fichier ou dossier existe sous `documentation-map.root`

Signaler en **erreur** :
- Fichier référencé introuvable (supprimé, déplacé, renommé)

Signaler en **avertissement** :
- Dossier référencé présent mais vide

---

## Vérification 2 — Documentation Map

Vérifier la présence des 6 catégories standard :

```
product / business / architecture / integrations / infrastructure / quality
```

Vérifier l'absence de contenu interdit dans chaque catégorie :
- Aucune mention de Service, Repository, Controller, Handler, UseCase
- Aucun chemin vers du code source (`.cs`, `.ts`, `.java`, `.py`…)
- Aucune mention de couche technique (Domain, Application, Infrastructure, API)

Signaler en **erreur** :
- `documentation-map.md` absent
- Catégorie obligatoire manquante (`business`, `architecture`)
- Référence documentaire cassée

Signaler en **avertissement** :
- Catégorie présente mais vide
- Contenu interdit détecté (code, couches techniques)

---

## Vérification 3 — Contextes

Pour chaque fichier dans `contexts/` :
- Vérifier qu'il référence uniquement des catégories existantes dans `documentation-map.md`
- Vérifier l'absence de contenu métier (invariants, règles, classes, chemins code)

Signaler en **erreur** :
- Référence à une catégorie absente de `documentation-map.md`

Signaler en **avertissement** :
- Contenu métier détecté (Aggregate Root, Entity, Value Object, invariants…)
- Contexte vide

---

## Vérification 4 — Commandes projet

Pour chaque fichier dans `commands/` (`implement-feature`, `review-feature`, `generate-tests`) :
- Vérifier que le flux respecte l'ordre obligatoire :

```
1. Contexte(s)
2. Documentation Map
3. Documentation        ← QUOI (métier)
4. Project Analysis     ← OÙ (technique)
5. Code
6. Agir
```

Signaler en **erreur** :
- Commande obligatoire absente (`implement-feature`, `review-feature`, `generate-tests`)
- `project-analysis` lu avant la documentation

---

## Vérification 5 — Couverture documentaire

Lister tous les fichiers `.md` sous `documentation-map.root`.
Comparer avec les fichiers référencés dans `documentation-map.md`.

Signaler en **avertissement** :
- Document présent dans `docs/` mais absent de la map
- Taux de couverture < 80%

En mode `--strict` : **erreur** si couverture < 100% ou tout document non référencé.

---

## Vérification 6 — Cohérence du workflow

Valider le chaînage complet :

```
Contextes → Documentation Map → Documentation → Project Analysis → Code
```

Vérifier que :
- Chaque catégorie de `documentation-map.md` est utilisée par au moins un contexte
- Chaque contexte est utilisé par au moins une commande projet
- Chaque document référencé est accessible depuis au moins un contexte

Signaler en **avertissement** :
- Catégorie documentaire jamais référencée par un contexte (catégorie morte)
- Contexte jamais utilisé par aucune commande (contexte orphelin)
- Document référencé dans la map mais inatteignable depuis un contexte

---

## Vérification 7 — Standards du framework

Vérifier la présence des gabarits dotfiles :

```
standards/project-analysis.md
standards/documentation-map.md
standards/context-format.md
standards/project-command-template.md
```

Signaler en **erreur** :
- Standard manquant

Signaler en **avertissement** :
- Standard présent mais vide

---

## Vérification 8 — Maintenance (refresh-context)

Vérifier que `refresh-context.md` existe.

Vérifier que la commande respecte ses limites de responsabilité :
- Ne modifie pas `CLAUDE.md`
- Ne touche jamais `docs/`
- Agit uniquement sur `documentation-map.md`, `contexts/`, `commands/`

Signaler en **erreur** :
- `refresh-context.md` absent

Signaler en **avertissement** :
- Dérive de responsabilité détectée (mention de `CLAUDE.md` ou `docs/` comme cible de modification)

---

## Vérification 9 — Universalité des contextes

Vérifier l'absence de termes DDD ou d'architecture dans les contextes :

```
Aggregate Root / Entity / Value Object / Repository / Service / Controller
Domain Layer / Application Layer / Infrastructure Layer
Handler / UseCase / Command / Query
```

Signaler en **avertissement** :
- Terme d'architecture détecté dans un contexte

Objectif : garantir que le workflow reste utilisable sur `.NET`, `Java`, `Node`, `React`, `Python`, `Go` indépendamment de l'architecture choisie.

---

## Vérification 10 — Références multiples

Détecter :
- Documents présents dans plusieurs catégories
- Catégories avec exactement les mêmes documents

Signaler en **avertissement** :
- Document référencé dans plus d'une catégorie (possible doublon de catégorie)
- Deux catégories avec un contenu identique

---

## Vérification 11 — Catégories inutilisées

Détecter :
- Catégorie jamais référencée par un contexte
- Catégorie jamais utilisée par une commande projet

Signaler en **avertissement** :
- Catégorie morte détectée

---

## Rapport final

```
WORKFLOW STATUS
───────────────────────────────────────────────────

Documentation            ✓ OK  |  ✗ <N> liens cassés
Documentation Map        ✓ OK  |  ✗ catégories manquantes / contenu interdit
Contextes                ✓ OK  |  ✗ <N> contextes avec contenu métier
Commandes projet         ✓ OK  |  ✗ flux incorrect / commande absente
Standards                ✓ OK  |  ✗ <N> standards manquants
Maintenance              ✓ OK  |  ✗ refresh-context absent / dérive
Universalité             ✓ OK  |  ✗ termes d'architecture détectés

───────────────────────────────────────────────────
COUVERTURE DOCUMENTAIRE

  Documents couverts     : <N> / <total>
  Documents non référencés : <liste>
  Taux de couverture     : <N>%

───────────────────────────────────────────────────
COHÉRENCE DU WORKFLOW

  Catégories inutilisées : <liste>
  Contextes orphelins    : <liste>
  Références multiples   : <liste>

───────────────────────────────────────────────────
SCORE GLOBAL

  Documentation          <N>%
  Documentation Map      <N>%
  Contextes              <N>%
  Commandes              <N>%
  Couverture docs        <N>%

  Score Workflow         <N> / 100

───────────────────────────────────────────────────
RÉSUMÉ

  Erreurs          : <N>
  Avertissements   : <N>
```

---

## Ce que cette commande ne fait jamais

- Modifier les fichiers
- Corriger automatiquement les erreurs détectées
- Toucher à `CLAUDE.md` ou à `docs/`

Pour appliquer les corrections : utiliser `/refresh-context`.
