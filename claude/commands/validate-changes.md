---
name: validate-changes
description: Évaluer les changements stagés avec un LLM-as-a-Judge avant de commiter
---

# Valider les changements avant le commit

Évaluer les changements git stagés en utilisant l'agent output-evaluator pour détecter les problèmes avant de commiter.

## Processus

### Étape 1 : Vérifier les changements stagés

Lancer `git diff --cached --stat` pour voir ce qui est stagé. Si rien n'est stagé, en informer l'utilisateur et quitter.

### Étape 2 : Obtenir le diff complet

Lancer `git diff --cached` pour obtenir le diff complet de tous les changements stagés.

### Étape 3 : Invoquer l'évaluateur

Utiliser l'outil Task pour lancer l'agent `output-evaluator` avec le diff :

```
Évalue ces changements stagés pour leur exactitude, leur complétude et leur sécurité.
Retourne un verdict JSON avec des scores et les problèmes trouvés.

Changements :
[coller le git diff ici]
```

### Étape 4 : Analyser et agir sur le verdict

Selon le résultat de l'évaluation :

**Si APPROVE :**
- Indiquer à l'utilisateur que les changements ont passé l'évaluation
- Afficher le résumé et les scores
- Demander s'il souhaite procéder au commit

**Si NEEDS_REVIEW :**
- Afficher tous les problèmes trouvés (regroupés par sévérité)
- Afficher la suggestion de l'évaluateur
- Demander à l'utilisateur comment procéder :
  - Corriger les problèmes et réévaluer
  - Commiter quand même (en reconnaissant les risques)
  - Abandonner

**Si REJECT :**
- Indiquer clairement que les changements ont été rejetés
- Afficher les problèmes critiques qui ont causé le rejet
- Ne PAS proposer de commiter quand même
- Suggérer des corrections spécifiques

### Étape 5 : Commit (si approuvé)

Si l'utilisateur confirme, créer le commit en suivant le flux de commit standard.

## Exemples d'utilisation

```
/validate-changes
```

Sortie :
```
Évaluation de 3 fichiers stagés...

VERDICT : NEEDS_REVIEW

Scores :
  Exactitude :   8/10
  Complétude :   6/10
  Sécurité :     9/10

Problèmes trouvés :
  [MEDIUM] src/api/handler.ts:45
    Gestion des erreurs réseau manquante

  [LOW] src/utils/format.ts:12
    Envisager d'ajouter une validation des entrées

Suggestion : Ajouter un try-catch autour de l'appel fetch dans handler.ts

Comment souhaitez-vous procéder ?
  1. Corriger les problèmes et réévaluer
  2. Commiter quand même (1 problème medium)
  3. Abandonner
```

## Conscience des coûts

Cette commande invoque une évaluation LLM, qui consomme des tokens API :
- **Coût typique** : 0,01-0,05 $ par évaluation (avec Haiku)
- **Diffs plus larges** : Peut coûter plus en raison de l'utilisation accrue de tokens

## Quand l'utiliser

- Après des modifications de code significatives avant de commiter
- Quand on travaille sur des parties du codebase qui ne sont pas familières
- Pour des modifications qui affectent du code sensible à la sécurité
- Avant de pousser vers des branches partagées

## Quand ne pas l'utiliser

- Changements triviaux (fautes de frappe, formatage)
- Changements de documentation uniquement
- Quand vous avez déjà effectué une revue manuelle approfondie
- Quand vous itérez rapidement sur une branche de fonctionnalité

## Intégration avec les hooks Git

Pour une évaluation automatique à chaque commit, voir le hook `pre-commit-evaluator.sh`.
Cette commande est l'alternative manuelle pour contrôler quand l'évaluation s'exécute.
