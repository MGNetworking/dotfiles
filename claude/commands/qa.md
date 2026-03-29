---
name: qa
description: "Tests QA systématiques d'une application web — diff-aware, à niveaux, avec boucle corriger-et-vérifier"
---

# QA — Tests d'application web

Tester systématiquement une application web à la recherche de bugs, puis corriger et vérifier chaque problème trouvé.

Trois niveaux de profondeur. Périmètre diff-aware — teste ce qui a réellement changé.

## Instructions

### Étape 1 : Détection du périmètre

Déterminer quelles pages et fonctionnalités tester.

**Mode diff-aware (par défaut) :** Identifier les routes affectées par les changements de la branche courante.

```bash
# Fichiers modifiés dans cette branche
git diff --name-only origin/main...HEAD 2>/dev/null || git diff --name-only HEAD~5

# Identifier les routes affectées depuis les fichiers modifiés
# ex. : changements dans src/pages/dashboard/ → tester /dashboard
# changements dans api/payments/ → tester les flux de paiement
```

**Mode complet** (`/qa --full`) : Tester l'application entière, en commençant par les chemins critiques.

**Périmètre explicite** (`/qa /dashboard /settings`) : Tester uniquement les pages spécifiées.

---

### Étape 2 : Sélection du niveau

| Niveau | Flag | Périmètre | Utiliser quand |
|--------|------|-----------|----------------|
| Rapide | `--quick` | Sévérité Critique + Haute uniquement | Vérification rapide pré-commit |
| Standard | *(par défaut)* | + Sévérité Moyenne | Review pré-PR |
| Exhaustif | `--exhaustive` | + Faible + cosmétique | Candidat à la release |

---

### Étape 3 : Arbre de travail propre

Avant de tester, s'assurer de pouvoir commiter les corrections de façon atomique.

```bash
git status --short
```

S'il y a des changements non commités : les stasher d'abord (`git stash`), ou les commiter. Tester sur un arbre de travail sale rend impossible l'isolation des commits de correction.

---

### Étape 4 : Tests

Pour chaque page dans le périmètre, vérifier systématiquement toutes les catégories pertinentes au niveau sélectionné.

#### Comment tester

Utiliser les outils de navigation disponibles :
- **MCP browser tools** (si configuré) — navigation automatisée et captures d'écran
- **Playwright/Puppeteer** (si dans le projet) — exécutions de tests scriptés
- **Tests manuels** — naviguer vers l'URL, documenter les observations systématiquement

Pour chaque page, couvrir :

```
1. Charger la page — s'affiche-t-elle sans erreurs ?
2. Vérifier la console — erreurs non capturées, requêtes échouées, avertissements ?
3. Tester l'action principale — la fonctionnalité centrale de cette page
4. Tester l'état vide — qu'affiche-t-on quand il n'y a pas de données ?
5. Tester l'état d'erreur — que se passe-t-il quand une action échoue ?
6. Tester sur viewport étroit — casse-t-il en dessous de 375px ?
```

#### Taxonomie des problèmes

**Visuel** (mise en page, espacement, typographie, couleurs, réactivité)
**Fonctionnel** (interactions cassées, fonctionnalités manquantes, comportement incorrect)
**UX** (flux confus, feedback manquant, messages d'erreur insuffisants)
**Contenu** (fautes de frappe, texte incorrect, texte d'espace réservé en production)
**Performance** (chargements lents, décalages de mise en page, images non optimisées)
**Console** (erreurs JavaScript, requêtes réseau échouées, avertissements de dépréciation)
**Accessibilité** (texte alt manquant, pièges clavier, labels manquants, contraste)

#### Niveaux de sévérité

| Sévérité | Critères | Exemples |
|----------|----------|---------|
| **Critique** | Fonctionnalité entièrement cassée ou risque de perte de données | Erreur 500, page blanche, formulaire qui perd des données |
| **Haute** | Fonctionnalité majeure dégradée, préjudice UX significatif | Données incorrectes affichées, CTA principal cassé, mise en page mobile brisée |
| **Moyenne** | Problème mineur de fonctionnalité, visible mais contournement possible | Glitch visuel, état vide confus, chargement lent |
| **Faible** | Cosmétique, à peine perceptible | Espacement mineur, problème de texte mineur, avertissement console peu sévère |

**Niveau Rapide** : Critique + Haute uniquement
**Niveau Standard** : Critique + Haute + Moyenne
**Niveau Exhaustif** : Toutes les sévérités

---

### Étape 5 : Documenter les observations

Suivre chaque problème avec un identifiant unique.

```
ISSUE-001
  Sévérité:  [Critique / Haute / Moyenne / Faible]
  Catégorie: [Visuel / Fonctionnel / UX / Contenu / Performance / Console / Accessibilité]
  Page:      [URL ou route]
  Observation: [Ce qui ne va pas — précis, pas vague]
  Étapes:    [Comment reproduire]
  Attendu:   [Ce qui devrait se passer]
  Preuve:    [Chemin de capture d'écran ou sortie console]
```

---

### Étape 6 : Boucle corriger-et-vérifier

Pour chaque problème Critique et Haute (et Moyen/Faible dans les niveaux Standard/Exhaustif) :

1. **Corriger le problème** dans le code source
2. **Commiter de façon atomique** — un commit par correction

```bash
git add <changed-files>
git commit -m "fix: <brève description de ce qui a été corrigé>"
```

3. **Re-vérifier** — naviguer vers la même page et confirmer que le problème est résolu
4. **Mettre à jour le statut du problème** à CORRIGÉ avec le hash du commit

Ne pas regrouper plusieurs corrections dans un seul commit. Chaque correction doit être individuellement réversible.

---

## Format de sortie

```
RAPPORT QA
════════════════════════════════════════
Branche:   [branche courante]
Périmètre: [pages testées]
Niveau:    [Rapide / Standard / Exhaustif]
Durée:     [temps écoulé]

SCORES DE SANTÉ
─────────────────────────────────────────
  Visuel        [PASS / WARN / FAIL]  [N problèmes]
  Fonctionnel   [PASS / WARN / FAIL]  [N problèmes]
  UX            [PASS / WARN / FAIL]  [N problèmes]
  Contenu       [PASS / WARN / FAIL]  [N problèmes]
  Performance   [PASS / WARN / FAIL]  [N problèmes]
  Console       [PASS / WARN / FAIL]  [N problèmes]
  Accessibilité [PASS / WARN / FAIL]  [N problèmes]

PROBLÈMES TROUVÉS : N (X critique, Y haute, Z moyenne, W faible)
PROBLÈMES CORRIGÉS : N
PROBLÈMES RESTANTS : N

─────────────────────────────────────────
ISSUE-001 [CORRIGÉ | OUVERT]
  Sévérité:  Haute
  Catégorie: Fonctionnel
  Page:      /dashboard
  Observation: Le bouton Enregistrer ne fait rien quand le formulaire contient des erreurs de validation — aucun feedback affiché
  Correction: Ajout d'une notification toast d'erreur (commit abc1234)

ISSUE-002 [OUVERT]
  Sévérité:  Moyenne
  Catégorie: Visuel
  Page:      /settings
  Observation: Les champs de saisie dépassent du conteneur en dessous de 375px de viewport
  ...

─────────────────────────────────────────
ÉTAT POUR LA MISE EN PRODUCTION
  Problèmes critiques : [0 restant / N restant — BLOQUANT]
  Problèmes hauts :     [0 restant / N restant — PRÉOCCUPATION]

VERDICT : [PRÊT À DÉPLOYER / PAS PRÊT — traiter d'abord les problèmes critiques et hauts]
════════════════════════════════════════
```

## Utilisation

```
/qa                          # Niveau Standard, périmètre diff-aware
/qa --quick                  # Niveau Rapide (critique + haute uniquement)
/qa --exhaustive             # Couverture complète incluant les problèmes cosmétiques
/qa --full                   # Niveau Standard, tester toute l'app (pas seulement le diff)
/qa /dashboard /settings     # Tester des pages spécifiques
/qa https://staging.app.com  # Tester une URL spécifique
```

## Conseils

1. **Lancer après chaque fonctionnalité significative** — pas seulement avant le déploiement
2. **Diff-aware en premier** — tester ce qui a changé avant d'élargir le périmètre
3. **Corriger les critiques et hauts avant de continuer** — ne pas accumuler les problèmes non corrigés
4. **Preuve par capture d'écran** — toujours capturer avant/après pour les corrections critiques
5. **Vérifier le mobile** — la plupart des bugs visuels apparaissent à 375px de largeur

## Commandes liées

- `/investigate` — analyse de cause racine quand le QA trouve un bug complexe
- `/ship` — checklist pré-déploiement (lancer après validation du QA)
- `/canary` — surveillance post-déploiement (lancer après le déploiement)

$ARGUMENTS
