---
name: plan-ceo-review
description: Verrou produit stratégique — remettre en question le brief, trouver le produit 10 étoiles caché dans la demande, avant d'écrire la moindre ligne de code
version: 1.0.0
inspired-by: https://github.com/garrytan/gstack
---

# /plan-ceo-review — Verrou produit stratégique

Commande de pré-implémentation. Insère un verrou explicite entre "j'ai une demande" et "je commence à coder". Remet en question la demande littérale et interroge ce que le vrai produit devrait être.

**À utiliser en mode plan, avant toute implémentation.**

---

## Le problème que cela résout

Claude Code est optimisé pour construire ce qu'on lui demande. Si tu dis "ajoute X", il construit X. Il ne demandera pas si X est réellement le bon produit. Cette commande corrige cela en basculant explicitement en mode réflexion produit avant que l'instinct d'implémentation ne s'enclenche.

---

## Quand l'utiliser

- Avant d'implémenter toute demande de fonctionnalité significative
- Surtout quand la demande est précise ("ajouter le téléversement de photos") — la précision signale souvent que le demandeur a déjà réduit l'espace des solutions
- Quand on veut tester une direction sous pression avant d'y investir du temps d'ingénierie

---

## Trois modes

La commande demande à l'utilisateur d'en choisir un avant de continuer :

| Mode | Posture | Utiliser quand |
|------|---------|----------------|
| **EXPANSION DU PÉRIMÈTRE** | Trouver le produit 10 étoiles, élargir le périmètre | La direction est floue, envie de rêver grand |
| **PÉRIMÈTRE FIXE** | Accepter la direction, rendre le plan à toute épreuve | La direction est verrouillée, besoin de rigueur |
| **RÉDUCTION DU PÉRIMÈTRE** | Réduire au minimum viable, couper sans pitié | Backlog surchargé, besoin de livrer vite |

L'assistant s'engage dans le mode sélectionné et n'en dévie pas pendant la revue.

---

## Template de prompt

```markdown
# /plan-ceo-review

Tu es en mode revue CEO / fondateur. Ton rôle N'EST PAS d'implémenter quoi que ce soit.
Ton rôle est de revoir le plan ou la demande de fonctionnalité avec une réflexion niveau produit
et de retourner un meilleur brief.

## Étape 0 : Choisir le mode

Demander à l'utilisateur quel mode utiliser (si non précisé) :
- EXPANSION DU PÉRIMÈTRE : Trouver le produit 10 étoiles. Élargir le périmètre. Quelle est la version
  qui semble inévitable et délicieuse ?
- PÉRIMÈTRE FIXE : Accepter la direction. Rendre ce plan à toute épreuve. Identifier chaque
  mode d'échec et hypothèse non formulée.
- RÉDUCTION DU PÉRIMÈTRE : Trouver la version minimale viable qui atteint le résultat central.
  Couper tout le reste.

Une fois que l'utilisateur a choisi, s'engager dans ce mode pour toute la revue.

## Étape 1 : Reformuler la demande

Résumer la demande littérale en 1-2 phrases. Être précis — sans éditorialisation.

## Étape 2 : Remettre en question la prémisse

Poser la question plus importante : à quoi sert réellement ce produit ?

- Quel est le vrai travail à accomplir pour l'utilisateur ?
- La demande littérale est-elle le meilleur moyen d'y répondre ?
- Quelle hypothèse la demande fait-elle qui pourrait être fausse ?

## Étape 3 : Le vrai produit (EXPANSION) / Plan à toute épreuve (FIXE) / MVP (RÉDUCTION)

**EXPANSION DU PÉRIMÈTRE** : Décrire la version 10 étoiles de ce produit.
- Qu'est-ce qui le rendrait 10x meilleur pour 2x l'effort ?
- Que veulent vraiment les utilisateurs, pas ce qu'ils ont demandé ?
- Lister 5 à 8 fonctionnalités ou décisions de conception spécifiques qui rendraient cela
  inévitable.

**PÉRIMÈTRE FIXE** : Accepter la direction. Trouver maintenant tout ce qui peut mal tourner.
- Hypothèses non formulées dans la demande
- Cas limites non couverts
- États d'erreur manquants
- Lacunes UX
- Problèmes de sécurité ou de frontières de confiance
- Préoccupations opérationnelles (surveillance, rollback, migration de données)

**RÉDUCTION DU PÉRIMÈTRE** : Quelle est la version la plus petite qui prouve la valeur centrale ?
- Quelle est la seule chose que cela doit faire ?
- Qu'est-ce qui peut être coupé sans perdre l'essentiel ?
- Qu'est-ce qui peut être reporté à la v2 ?

## Étape 4 : Recommandation

Retourner l'une des options suivantes :
- **Procéder tel quel** — la demande originale est le bon produit
- **Recadrer** — voici le meilleur brief (avec les détails)
- **Rejeter** — voici pourquoi c'est la mauvaise direction, et ce qu'il faut construire à la place

Ne faire AUCUN changement de code. C'est une revue, pas une implémentation.
```

---

## Exemple

**Entrée** : "Permettre aux vendeurs de téléverser une photo pour leur annonce"

**Sortie (EXPANSION DU PÉRIMÈTRE)** :
> "Le téléversement de photo" n'est pas la fonctionnalité. Le vrai travail est d'aider les vendeurs à créer des annonces qui vendent vraiment.
>
> Voici la version 10 étoiles : identifier automatiquement le produit depuis la photo, récupérer le SKU et les spécifications depuis le web, rédiger automatiquement un titre et une description, suggérer quelle photo téléversée convertit le mieux en image principale, détecter les photos de mauvaise qualité (sombres, encombrées, peu fiables) avant leur mise en ligne.
>
> **Recommandation** : Recadrer. Le brief devrait être "création d'annonce intelligente depuis une photo" et non "téléversement de photo".

---

## Intégration avec les autres commandes

```
/plan-ceo-review    → verrouiller la direction produit
/plan-eng-review    → verrouiller l'architecture technique
[implémenter]
/review             → vérification paranoïaque pré-fusion
/ship               → livraison
```

## Voir aussi

- [Changement de mode cognitif](../../guide/workflows/gstack-workflow.md) — contexte complet du workflow
- [plan-eng-review](./plan-eng-review.md) — étape suivante une fois la direction verrouillée
- [plan-start](./plan-start.md) — commande native du mode plan
