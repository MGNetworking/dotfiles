---
name: tdd-workflow
description: Workflow de développement piloté par les tests (TDD) et bonnes pratiques
effort: low
---

# TDD Workflow Skill

## Le cycle TDD

```
RED → GREEN → REFACTOR
 ↑__________________|
```

### 1. RED : écrire un test en échec

- Écrire le plus petit test possible qui échoue
- Le test doit échouer pour la bonne raison
- Vérifier que le test est bien exécuté

### 2. GREEN : faire passer le test

- Écrire le minimum de code nécessaire
- Ne pas optimiser à ce stade
- Le code peut être imparfait

### 3. REFACTOR : améliorer

- Améliorer la structure du code
- Supprimer les duplications
- Garder les tests au vert

## Bonnes pratiques TDD

### Convention de nommage des tests

```
should_[expected behavior]_when_[condition]
```

Exemples :

- `should_return_empty_array_when_no_items`
- `should_throw_error_when_invalid_input`
- `should_calculate_total_when_items_present`

### Structure d’un test (AAA)

```typescript
it("should calculate discount when coupon applied", () => {
  // Arrange - préparation des données
  const cart = new Cart();
  cart.addItem({ price: 100 });
  const coupon = new Coupon("10OFF", 10);

  // Act - exécution
  cart.applyCoupon(coupon);

  // Assert - vérification
  expect(cart.total).toBe(90);
});
```

### Isolation des tests

- Chaque test doit être indépendant
- Aucun état partagé entre les tests
- Utiliser `beforeEach` pour la configuration
- Nettoyer avec `afterEach`

## Exemple de workflow TDD

### Feature : ajouter un item au panier

**Étape 1 : RED**

```typescript
describe("Cart", () => {
  it("should add item to cart", () => {
    const cart = new Cart();
    cart.addItem({ id: 1, name: "Book", price: 29.99 });
    expect(cart.items).toHaveLength(1);
  });
});
```

Exécution → ÉCHEC (Cart n’existe pas)

**Étape 2 : GREEN**

```typescript
class Cart {
  items = [];

  addItem(item) {
    this.items.push(item);
  }
}
```

Exécution → SUCCÈS

**Étape 3 : REFACTOR**

```typescript
class Cart {
  private _items: CartItem[] = [];

  get items(): ReadonlyArray<CartItem> {
    return this._items;
  }

  addItem(item: CartItem): void {
    this._items.push(item);
  }
}
```

Exécution → toujours SUCCÈS

### Itération suivante : calcul du total

Répéter le cycle pour chaque nouveau comportement.

## Quand utiliser le TDD

### Cas adaptés

- Logique métier
- Algorithmes complexes
- APIs
- Gestion d’état
- Fonctions utilitaires

### Moins adapté

- UI (tests visuels plus adaptés)
- Migrations base de données
- Intégrations externes
- Prototypage exploratoire

## Erreurs courantes

1. Écrire trop de tests d’un coup
2. Écrire trop de code
3. Ignorer le refactoring
4. Tester l’implémentation au lieu du comportement
5. Ignorer les tests en échec

## Doubles de test

| Type | Objectif                  | Exemple                           |
| ---- | ------------------------- | --------------------------------- |
| Stub | Retour de données fixes   | `jest.fn().mockReturnValue(42)`   |
| Mock | Vérifier interactions     | `expect(mock).toHaveBeenCalled()` |
| Spy  | Observer les appels       | `jest.spyOn(obj, 'method')`       |
| Fake | Implémentation simplifiée | Base en mémoire                   |
