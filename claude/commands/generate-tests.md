---
name: generate-tests
description: "Génère des tests complets pour le code spécifié"
---

# Générer des tests

Génère des tests complets pour le code spécifié.

## Instructions

1. Lire le(s) fichier(s) cible(s)
2. Identifier les unités testables (fonctions, classes, méthodes)
3. Générer les tests en suivant les conventions du projet
4. Assurer une couverture élevée des cas limites

## Processus de génération des tests

### 1. Analyser la cible
- Identifier les interfaces publiques
- Comprendre les dépendances
- Repérer les cas limites et les frontières

### 2. Détecter le framework de test
Vérifier la présence de :
- `jest.config.js` → Jest
- `vitest.config.ts` → Vitest
- `pytest.ini` → pytest
- `mocha` dans package.json → Mocha

### 3. Générer les tests
Suivre les conventions du framework détecté.

## Catégories de tests

### Chemin nominal
Comportement normal attendu avec des entrées valides.

### Cas limites
- Entrées vides
- Valeurs null/undefined
- Valeurs aux bornes (0, -1, MAX_INT)
- Un seul élément vs plusieurs éléments

### Cas d'erreur
- Types d'entrée invalides
- Paramètres requis manquants
- Échecs réseau/IO
- Scénarios de timeout

### Points d'intégration
- Interactions avec la base de données
- Appels d'API externes
- Opérations sur le système de fichiers

## Format de sortie

```typescript
describe('[ComponentName]', () => {
  describe('[methodName]', () => {
    // Chemin nominal
    it('should [expected behavior] when [condition]', () => {
      // Arrange
      // Act
      // Assert
    });

    // Cas limites
    it('should handle empty input', () => {});
    it('should handle null values', () => {});

    // Cas d'erreur
    it('should throw when [invalid condition]', () => {});
  });
});
```

## Conventions

- Une assertion par test (dans la mesure du possible)
- Noms de tests descriptifs
- Pattern AAA (Arrange-Act-Assert)
- Pas d'interdépendance entre les tests
- Mocker les dépendances externes

## Utilisation

```
/generate-tests src/utils/calculator.ts
/generate-tests src/services/
```

$ARGUMENTS
