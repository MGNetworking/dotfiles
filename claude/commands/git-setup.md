---
name: git-setup
description: "Initialiser un projet git complet avec branches, fichiers de config et CI/CD via un questionnaire guidé"
---

# Git Setup — Initialisation complète d'un projet

Initialiser un projet git de manière interactive en plusieurs étapes.

## Instructions

Poser les questions **une étape à la fois**, attendre la réponse avant de passer à la suivante.
Ne pas tout demander d'un coup. Valider chaque réponse avant de continuer.

---

## Étape 1 — Informations projet

Poser ces questions (une par une) :

1. **Nom du projet** ?
2. **Langage / Framework principal** ? (Node.js, Python, Go, Java, .NET, PHP, Rust, autre)
3. **OS principal de l'équipe** ? (Linux/Mac → LF, Windows → CRLF, Mixte → auto)

---

## Étape 2 — Stratégie de branches

Poser la question :

> Quelle stratégie de branches souhaites-tu utiliser ?
> - **GitHub Flow** — simple : `main` + branches de feature (recommandé pour petites équipes)
> - **GitFlow** — structuré : `main`, `develop`, `release/*`, `hotfix/*`, `feature/*`
> - **Trunk-based** — minimaliste : `main` uniquement + feature flags

---

## Étape 3 — Release Please

Poser la question :

> Veux-tu configurer **Release Please** pour automatiser les versions et changelogs ?
> (Oui / Non)

Si oui :
> Quelle branche déclenche les releases ? (défaut : `main`)

---

## Étape 4 — GitHub Actions

Poser la question :

> Quels workflows GitHub Actions veux-tu générer ?
> - **CI** — tests automatiques sur chaque PR
> - **Release** — déclenchement release-please sur push main
> - **Les deux**
> - **Aucun**

---

## Étape 5 — Récapitulatif et exécution

Afficher un récapitulatif de tous les choix :

```
Projet     : <nom>
Langage    : <langage>
OS         : <os>
Branches   : <stratégie>
Release    : <oui/non>
Actions    : <ci/release/les deux/aucun>
```

Demander confirmation : **"Je lance l'initialisation ?"**

---

## Exécution

Une fois confirmé, exécuter dans l'ordre :

1. `/git-setup-branches` avec la stratégie choisie
2. `/git-setup-gitignore` avec le langage et l'OS
3. `/git-setup-gitattributes` avec l'OS
4. `/git-setup-release-please` si activé
5. `/git-setup-actions` si activé

Confirmer chaque étape à l'utilisateur au fur et à mesure.

$ARGUMENTS
