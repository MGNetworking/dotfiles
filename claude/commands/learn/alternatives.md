---
name: learn-alternatives
description: "Compare différentes approches pour résoudre le même problème"
---

# Montrer les Alternatives

Compare différentes approches pour résoudre le même problème.

## Utilisation

```
/learn:alternatives              # Compare les approches pour le code actuel
/learn:alternatives auth         # Compare les méthodes d'authentification
/learn:alternatives state        # Compare les options de gestion d'état
/learn:alternatives --detailed   # Inclut des exemples de code pour chacune
```

## Instructions

1. Identifier le **problème à résoudre** (depuis le contexte ou l'argument)
2. Présenter **3 à 5 approches alternatives**
3. Pour chaque approche, expliquer :
   - Ce que c'est (une phrase)
   - Quand l'utiliser
   - Les compromis (avantages/inconvénients)
4. Fournir une **recommandation** selon le contexte
5. Optionnellement montrer des exemples de code pour les meilleurs choix

## Format de réponse

```markdown
## Problème : [Ce que l'on cherche à résoudre]

### Approche 1 : [Nom]

**Ce que c'est** : [Description en une phrase]

**Quand l'utiliser** :

- [Scénario 1]
- [Scénario 2]

**Avantages** : [Liste]
**Inconvénients** : [Liste]

---

### Approche 2 : [Nom]

...

---

## Tableau de comparaison

| Critère                | Approche 1 | Approche 2 | Approche 3 |
| ---------------------- | ---------- | ---------- | ---------- |
| Complexité             | Faible     | Moyenne    | Élevée     |
| Performance            | ★★☆        | ★★★        | ★★☆        |
| Taille du bundle       | Petite     | Moyenne    | Grande     |
| Courbe d'apprentissage | Facile     | Moyenne    | Difficile  |

## Recommandation

**Pour votre cas** : [Approche recommandée] car [raison basée sur le contexte]

**À envisager à la place si** : [Scénarios alternatifs]
```

## Critères de comparaison

Critères standard à évaluer (à ajuster selon le problème) :

| Critère                    | Description                                    |
| -------------------------- | ---------------------------------------------- |
| **Complexité**             | Difficulté d'implémentation et de maintenance  |
| **Performance**            | Vitesse d'exécution, utilisation mémoire       |
| **Taille du bundle**       | Impact sur le bundle frontend                  |
| **Courbe d'apprentissage** | Temps pour comprendre et utiliser correctement |
| **Flexibilité**            | Facilité d'extension ou de modification        |
| **Communauté**             | Documentation, écosystème, support             |
| **Testabilité**            | Facilité à tester                              |
| **Sécurité des types**     | Qualité du support TypeScript                  |

## Modes de profondeur

### Par défaut

- 3-4 alternatives
- Description brève de chacune
- Tableau de comparaison
- Recommandation

### `--detailed`

- 4-5 alternatives
- Exemple de code pour chacune
- Compromis détaillés
- Considérations de migration
- Études de cas réels

### `--quick`

- 2-3 alternatives
- Une ligne par alternative
- Recommandation rapide

## Exemple de session

```
Utilisateur : J'utilise useState pour l'état d'un formulaire. /learn:alternatives

Claude : ## Problème : Gérer l'état d'un formulaire en React

### Approche 1 : Plusieurs useState

**Ce que c'est** : Un useState séparé pour chaque champ

**Quand l'utiliser** :
- Formulaires simples (< 5 champs)
- Pas de validation complexe
- Pas de dépendances entre champs

**Avantages** : Simple, sans dépendances, facile à comprendre
**Inconvénients** : Verbeux avec beaucoup de champs, état dispersé

---

### Approche 2 : Un seul useState avec objet

**Ce que c'est** : Un useState contenant tous les champs en tant qu'objet

**Quand l'utiliser** :
- Formulaires moyens (5-10 champs)
- Besoin de réinitialiser tout le formulaire
- Envie d'un code plus propre

**Avantages** : État regroupé, réinitialisation facile, plus propre
**Inconvénients** : Nécessite l'opérateur spread, peut provoquer des re-rendus inutiles

---

### Approche 3 : useReducer

**Ce que c'est** : Patron reducer pour les transitions d'état complexes

**Quand l'utiliser** :
- Logique de validation complexe
- Formulaires multi-étapes
- Fonctionnalité annuler/rétablir

**Avantages** : Mises à jour prévisibles, gère la logique complexe, testable
**Inconvénients** : Plus de code standard, courbe d'apprentissage

---

### Approche 4 : Bibliothèque de formulaires (React Hook Form, Formik)

**Ce que c'est** : Bibliothèque dédiée à la gestion d'état des formulaires

**Quand l'utiliser** :
- Grands formulaires (10+ champs)
- Validation complexe (asynchrone, entre champs)
- Performance critique (nombreux champs)

**Avantages** : Re-rendus optimisés, validation intégrée, moins de code
**Inconvénients** : Dépendance, courbe d'apprentissage, taille du bundle

---

## Tableau de comparaison

| Critère    | useState | useReducer | React Hook Form |
|------------|----------|------------|-----------------|
| Complexité | Faible   | Moyenne    | Moyenne         |
| Performance | ★★☆     | ★★☆        | ★★★             |
| Bundle     | 0kb      | 0kb        | ~8kb            |
| Validation | Manuelle | Manuelle   | Intégrée        |
| Idéal pour | Simple   | Logique complexe | Grands formulaires |

## Recommandation

**Pour votre cas** : Si c'est un simple formulaire de connexion ou de contact, restez avec **useState**. Si vous construisez un checkout multi-étapes ou un formulaire d'administration, envisagez **React Hook Form** pour les bénéfices en validation et performance.

**Envisagez useReducer si** : Vous avez besoin d'annuler/rétablir, de machines d'état complexes, ou souhaitez des tests de style reducer.
```

## Comparaisons d'alternatives courantes

| Sujet                       | Alternatives typiques                               |
| --------------------------- | --------------------------------------------------- |
| **État**                    | useState, useReducer, Zustand, Redux, Jotai         |
| **Styles**                  | CSS Modules, Tailwind, styled-components, CSS-in-JS |
| **Récupération de données** | fetch, axios, React Query, SWR                      |
| **Formulaires**             | useState, React Hook Form, Formik                   |
| **Auth**                    | JWT, sessions, OAuth, magic links                   |
| **Design d'API**            | REST, GraphQL, tRPC, gRPC                           |
| **Tests**                   | Jest, Vitest, Testing Library, Cypress              |
| **Bases de données**        | PostgreSQL, MySQL, MongoDB, SQLite                  |

$ARGUMENTS
