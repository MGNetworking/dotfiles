---
name: learn-quiz
description: "Tester la compréhension du code récemment écrit ou accepté"
---

# Quiz

Tester la compréhension du code récemment écrit ou accepté.

## Utilisation

```
/learn:quiz                     # Quiz sur le dernier code travaillé
/learn:quiz error handling      # Focus sur un aspect spécifique
/learn:quiz --hard              # Questions plus difficiles
```

## Instructions

1. Identifier le dernier code travaillé (écrit, modifié ou accepté depuis l'IA)
2. Générer 3 à 5 questions qui testent la compréhension à différents niveaux :
   - **Mémorisation** : Que fait ce code ?
   - **Compréhension** : Pourquoi cette approche a-t-elle été choisie ?
   - **Application** : Que se passerait-il si X changeait ?
   - **Analyse** : Quels sont les compromis de cette approche ?
   - **Synthèse** : Comment étendriez-vous cela ?
3. Présenter les questions une par une
4. Attendre ma réponse avant de révéler la bonne réponse
5. Fournir des explications avec chaque réponse, pas seulement "correct/incorrect"

## Types de questions

### Niveau 1 : Mémorisation

- "Que retourne la fonction X ?"
- "Quels paramètres accepte Y ?"
- "Que se passe-t-il quand Z est appelé ?"

### Niveau 2 : Compréhension

- "Pourquoi utilise-t-on X plutôt que Y ici ?"
- "Quel problème ce patron résout-il ?"
- "Pourquoi cette ligne est-elle nécessaire ?"

### Niveau 3 : Application

- "Que se passerait-il si on supprimait la ligne X ?"
- "Comment ajouteriez-vous la fonctionnalité Y à ce code ?"
- "Qu'est-ce qui se casserait si l'entrée Z était fournie ?"

### Niveau 4 : Analyse

- "Quelles sont les implications de performance de cette approche ?"
- "Quels cas limites pourraient poser problème ?"
- "Comment cela se compare-t-il à l'alternative X ?"

### Niveau 5 : Synthèse

- "Comment refactorieriez-vous ceci pour une meilleure testabilité ?"
- "Qu'est-ce qui devrait changer pour supporter X ?"
- "Concevez une extension qui ajoute Y"

## Thèmes de focus

Quand un thème est spécifié (ex. `/learn:quiz error handling`), privilégier les questions sur :

| Thème             | Sujets de questions                                 |
| ----------------- | --------------------------------------------------- |
| `error handling`  | Try/catch, types d'erreurs, stratégies de récupération |
| `performance`     | Big-O, optimisation, goulots d'étranglement        |
| `security`        | Validation des entrées, XSS, injection              |
| `testing`         | Cas de test, cas limites, mocking                  |
| `architecture`    | Patrons, séparation des responsabilités, SOLID      |
| `types`           | Types TypeScript, inférence, génériques             |

## Modes de difficulté

### Par défaut

- 3 questions
- Mélange de niveaux 1-3
- Focus sur la compréhension du code actuel

### `--hard`

- 5 questions
- Niveaux 3-5
- Inclut des modifications hypothétiques
- Interroge sur les compromis et les alternatives

## Format de réponse

Pour chaque question :

```
## Question 1 sur 3

[Texte de la question]

Quelle est votre réponse ?

---
(Après la réponse de l'utilisateur)

### Feedback

[Si correct et pourquoi]

**Idée clé** : [Le concept que cela teste]

**Concept associé** : [Quelque chose à explorer davantage]

Prêt pour la prochaine question ?
```

## Après le quiz

Résumer :

- Score : X/Y corrects
- Points forts : [Sujets bien compris]
- À revoir : [Sujets à retravailler]
- Pratique suggérée : [Exercice spécifique]

## Exemple de session

```
Utilisateur : /learn:quiz

Claude : En regardant votre dernier code - le hook useEffect pour la récupération de données.

## Question 1 sur 3

Dans votre useEffect, vous avez un tableau de dépendances vide [].
Que signifie-t-il pour savoir quand l'effet s'exécute ?

Utilisateur : Il s'exécute une seule fois quand le composant est monté

Claude : ### Feedback
Correct ! Un tableau de dépendances vide signifie que l'effet s'exécute
uniquement au montage (et le nettoyage au démontage).

**Idée clé** : Le tableau de dépendances contrôle QUAND les effets se ré-exécutent.

**Concept associé** : Que se passe-t-il sans tableau vs. avec [uneValeur] ?

Prêt pour la Question 2 ?
```

## Conseils pour les utilisateurs

1. **Soyez honnête** — Les mauvaises réponses sont des opportunités d'apprentissage
2. **Expliquez votre raisonnement** — Aide à identifier les lacunes même dans les bonnes réponses
3. **Posez des questions de suivi** — Si le feedback n'est pas clair, approfondissez
4. **Notez les points faibles** — Repérez les sujets qui nécessitent plus de pratique

$ARGUMENTS
