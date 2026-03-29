---
name: learn-teach
description: "Explication progressive d'un concept avec profondeur croissante"
---

# Apprenez-moi

Explication progressive d'un concept avec profondeur croissante.

## Utilisation

```
/learn:teach React hooks         # Apprendre les hooks React
/learn:teach async/await         # Comprendre les patrons async
/learn:teach SOLID principles    # Apprendre les principes de design
/learn:teach --deep SQL joins    # Explication approfondie
```

## Instructions

1. Commencer par une **définition en une phrase** du concept
2. Expliquer **pourquoi c'est important** (problème réel que cela résout)
3. Montrer un **exemple minimal** (code le plus simple possible)
4. Décomposer **chaque partie** de l'exemple avec des commentaires
5. Montrer un **exemple pratique** (cas d'utilisation réel)
6. Souligner les **erreurs courantes** que font les débutants
7. Suggérer les **prochains concepts** à apprendre

## Format de réponse

```markdown
## [Nom du concept]

**En une phrase** : [Définition claire et simple]

### Pourquoi c'est important

[1-2 phrases sur le problème que cela résout]

### Exemple minimal

\`\`\`[langage]
// Démonstration la plus simple possible
[code]
\`\`\`

**Ligne par ligne** :

- Ligne 1 : [explication]
- Ligne 2 : [explication]
  ...

### Exemple pratique

\`\`\`[langage]
// Scénario du monde réel
[code]
\`\`\`

### Erreurs courantes

1. **[Erreur]** : [Pourquoi c'est faux et quoi faire à la place]
2. **[Erreur]** : [Pourquoi c'est faux et quoi faire à la place]

### Points clés

- [Point 1]
- [Point 2]
- [Point 3]

### À apprendre ensuite

- [Concept associé 1] — [pourquoi il est lié]
- [Concept associé 2] — [pourquoi il est lié]

---

**Défi pratique** : [Petit exercice pour renforcer le concept]
```

## Modes de profondeur

### Par défaut

- Définition en une phrase
- Un exemple minimal
- Un exemple pratique
- 2-3 erreurs courantes

### `--deep`

- Explication étendue avec historique/contexte
- Plusieurs exemples de complexité croissante
- Cas limites et pièges
- Considérations de performance
- Comparaison avec les alternatives
- Détails utiles en entretien

### `--quick`

- Définition uniquement
- Un seul exemple
- Rien de plus

## Règles d'adaptation

### Pour les débutants

- Utiliser des analogies du quotidien
- Éviter le jargon (ou l'expliquer immédiatement)
- Plus de commentaires dans le code
- Exemples de code plus courts

### Pour les intermédiaires

- Supposer une connaissance de la syntaxe de base
- Mettre l'accent sur le "pourquoi" plutôt que le "quoi"
- Inclure les compromis
- Montrer les patrons idiomatiques

### Pour les sujets avancés

- Référencer la documentation officielle
- Discuter de l'implémentation interne quand c'est pertinent
- Inclure les implications de performance
- Mentionner les patrons associés

## Exemple de session

```
Utilisateur : /learn:teach useEffect

Claude : ## useEffect

**En une phrase** : useEffect vous permet d'exécuter des effets de bord (récupération de données, abonnements, modifications du DOM) après que React rende un composant.

### Pourquoi c'est important

Les composants React sont des fonctions pures qui rendent de l'UI. Mais les vraies applications doivent interagir avec le monde extérieur — APIs, événements navigateur, timers. useEffect est le pont entre le monde déclaratif de React et les effets de bord impératifs.

### Exemple minimal

\`\`\`jsx
import { useEffect, useState } from 'react';

function Timer() {
  const [seconds, setSeconds] = useState(0);

  useEffect(() => {
    const id = setInterval(() => {
      setSeconds(s => s + 1);
    }, 1000);

    return () => clearInterval(id);  // Nettoyage
  }, []);  // Tableau vide = exécuter une seule fois

  return <div>{seconds}s</div>;
}
\`\`\`

**Ligne par ligne** :
- `useEffect(() => {...}, [])` : Exécuter cette fonction après le premier rendu
- `setInterval(...)` : Démarrer un timer (effet de bord)
- `return () => clearInterval(id)` : Nettoyage quand le composant est démonté
- `[]` : Tableau de dépendances vide = s'exécuter uniquement au montage

### Erreurs courantes

1. **Tableau de dépendances manquant** : Sans `[]`, l'effet s'exécute à CHAQUE rendu
2. **Oubli du nettoyage** : Les intervals/abonnements fuient sans fonction de retour
3. **Closures obsolètes** : Utilisation d'anciennes valeurs d'état au lieu de mises à jour fonctionnelles

---

**Défi pratique** : Ajoutez un bouton pause qui arrête et reprend le timer.
```

## Sujets bien adaptés à /learn:teach

| Catégorie      | Exemples                                             |
| -------------- | ---------------------------------------------------- |
| **React**      | hooks, context, suspense, server components          |
| **JavaScript** | closures, promises, event loop, prototypes           |
| **TypeScript** | génériques, mapped types, utility types              |
| **Patrons**    | SOLID, DI, composition, factories                    |
| **Backend**    | REST, GraphQL, authentification, cache               |
| **Base de données** | index, jointures, transactions, normalisation   |
| **DevOps**     | containers, CI/CD, infrastructure as code            |

$ARGUMENTS
