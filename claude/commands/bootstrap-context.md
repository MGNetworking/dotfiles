# /bootstrap-context

Initialise le système de contextes du projet courant.
Produit des **index de navigation** vers la documentation — pas de la connaissance.

> Prérequis : exécuter `/format-claude-md` avant cette commande.

---

## Principe fondamental

La documentation reste la **source de vérité unique**.
Les contextes ne contiennent aucune connaissance — ils indiquent où la trouver.

Un contexte = une question + une liste ordonnée de fichiers à lire pour y répondre.

Ce qui est **interdit** dans les contextes :
- Règles métier, invariants, cas d'usage
- Chemins vers le code source (`.cs`, `.ts`, `.java`…)
- Références aux couches techniques (Service, Repository, Controller…)
- Toute information déjà présente dans la documentation

---

## Étape 1 — Lire CLAUDE.md

Identifier depuis `CLAUDE.md` :
- La racine de la documentation
- La racine du code source
- La racine des tests

**Ne pas explorer le code source à cette étape.**

---

## Étape 2 — Inventaire documentaire

Lister **tous** les fichiers de documentation sous la racine doc.
Les regrouper par dossier pour comprendre l'organisation documentaire réelle.

Ne pas lire le contenu des fichiers — les noms et l'arborescence suffisent.

---

## Étape 3 — Analyse physique du projet

Explorer uniquement :
- La structure des dossiers du code source
- La structure des dossiers des tests
- Le fichier de solution ou manifeste principal

Objectif : détecter l'architecture, les conventions de nommage, le framework de test.
Ne pas lire les fichiers source.

---

## Étape 4 — Rapport avant génération

Présenter et **attendre validation** :

```
STRUCTURE PHYSIQUE
code.root    : <chemin>
tests.root   : <chemin>
architecture : <détectée>
stack        : <détecté>
conventions  : <détectées>

MAPPING DOCUMENTAIRE PROPOSÉ
documentation.root : <chemin>

business      → <fichiers identifiés — métier, règles, features>
architecture  → <fichiers identifiés — design applicatif, API, infra, patterns>
product       → <fichiers identifiés — specs, livrables, checklists>
integrations  → <fichiers identifiés — services externes, imports>
infrastructure→ <fichiers identifiés — déploiement, config, jobs>
quality       → <fichiers identifiés — tests, critères d'acceptance>
```

---

## Étape 5 — Génération de project-analysis.md

Créer `.claude/project-analysis.md`.

Contient **uniquement** la structure physique :
- Racine code source et tests
- Stack technique (langage, framework, framework de test)
- Architecture détectée
- Conventions de nommage
- Couches et leurs rôles

Ne contient **pas** : chemins documentaires, métier, règles, concepts.

Gabarit : `claude/standards/project-analysis.md`

---

## Étape 6 — Génération de documentation-map.md

Créer `.claude/documentation-map.md`.

Contient **uniquement** le mapping documentaire :
- Racine de la documentation
- Catégories et fichiers associés

Catégories standard :

| Catégorie | Question répondue | Contenu typique |
|---|---|---|
| `business` | Comment fonctionne le métier ? | design-domain, règles métier, features |
| `architecture` | Comment implémenter le métier ? | design applicatif, API, infra, patterns |
| `product` | Que livre-t-on ? | specs fonctionnelles, checklists, livrables |
| `integrations` | Comment se connecter à X ? | services externes, imports, webhooks |
| `infrastructure` | Comment construire et déployer ? | CI/CD, config, jobs planifiés |
| `quality` | Comment valider ? | critères de test, acceptance, couverture |

Règle absolue : `design-domain.md` → `business`, jamais `architecture`.
Créer uniquement les catégories qui ont des fichiers correspondants.

Gabarit : `claude/standards/documentation-map.md`

---

## Étape 7 — Génération des contextes

Créer dans `.claude/contexts/` les fichiers correspondant aux catégories détectées :

| Fichier | Question couverte |
|---|---|
| `product.md` | Que fait ce produit, pour qui, dans quel périmètre ? |
| `business.md` | Quelles sont les règles métier de cette fonctionnalité ? |
| `architecture.md` | Comment implémenter une fonctionnalité dans l'architecture ? |
| `integrations.md` | Comment ce projet se connecte à un service externe ? |
| `infrastructure.md` | Comment construire, configurer et déployer le système ? |
| `quality.md` | Comment valider que le résultat est correct ? |

Chaque fichier contient **uniquement** :
- La question à laquelle il répond
- La liste ordonnée des fichiers doc à lire (chemins relatifs depuis `documentation-map.root`)
- Des tags métier

Si une catégorie n'a pas de documentation correspondante : ne pas créer le fichier.

Gabarit : `claude/standards/context-format.md`

---

## Étape 8 — Génération des commandes projet

Créer dans `.claude/commands/` :
- `implement-feature.md`
- `review-feature.md`
- `generate-tests.md`

Chaque commande suit ce flux universel :
```
1. Identifier la question posée
2. Lire le(s) contexte(s) pertinent(s) dans .claude/contexts/
3. Lire .claude/documentation-map.md → trouver les chemins documentaires
4. Lire chaque fichier doc référencé          → comprendre le QUOI (métier)
5. Lire .claude/project-analysis.md           → comprendre le OÙ (technique)
6. Lire le code existant dans les zones identifiées
7. Agir
```

La compréhension métier (étapes 2-4) précède toujours la compréhension technique (étape 5).

---

## Étape 9 — Rapport final

```
CRÉÉS
.claude/project-analysis.md    ← structure physique
.claude/documentation-map.md   ← mapping documentaire
.claude/contexts/
  - <liste des contextes créés>
.claude/commands/
  - implement-feature.md
  - review-feature.md
  - generate-tests.md
```

---

## Critère de validation

Pour chaque fichier généré, poser la question :
> Si je supprime toute la documentation du projet, ce fichier reste-t-il utile ?

Si **oui** → le fichier contient trop de connaissance. Le corriger.
Si **non** → il joue correctement son rôle d'index.
