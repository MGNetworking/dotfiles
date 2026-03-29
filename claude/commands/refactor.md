---
name: refactor
description: "Analyser le code pour détecter les violations SOLID et suggérer des améliorations ciblées"
---

# Assistant de Refactoring SOLID

Analyser le code pour détecter les violations SOLID et suggérer des améliorations ciblées.

## Objectif

Identifier les opportunités de refactoring basées sur :
- Les violations des principes SOLID
- Les code smells et anti-patterns
- Les métriques de complexité
- La détection de duplication

## Instructions

### Étape 1 : Analyse du périmètre

Déterminer le périmètre de refactoring depuis l'entrée utilisateur :
- Fichier unique : Analyse approfondie
- Répertoire : Détection de patterns à travers les fichiers
- Fonction/classe : Suggestions d'extraction ciblées

```bash
# Obtenir les stats du fichier/répertoire
if [ -f "$TARGET" ]; then
  wc -l "$TARGET"
  echo "Single file analysis"
elif [ -d "$TARGET" ]; then
  find "$TARGET" -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" \) | wc -l
  echo "Directory analysis"
fi
```

### Étape 2 : Détection des violations SOLID

#### S - Responsabilité unique (Single Responsibility)

Chercher :
- Fichiers > 300 lignes
- Fonctions > 50 lignes
- Classes avec > 10 méthodes
- Mélange de préoccupations (données + UI + logique métier)

```bash
# Trouver les fichiers volumineux
find . -name "*.{ts,js,py}" -exec wc -l {} + 2>/dev/null | sort -rn | head -10

# Fonctions avec un nombre élevé de lignes (approximatif)
grep -rn "function\|def \|fn " --include="*.{ts,js,py,rs}" . | head -20
```

#### O - Principe ouvert/fermé (Open/Closed)

Chercher :
- Instructions switch/case sur des types
- Vérifications répétées if/else de type
- Modifications directes vs extensions

#### L - Substitution de Liskov (Liskov Substitution)

Chercher :
- Méthodes surchargées qui lèvent "not implemented"
- Vérifications de type avant les appels de méthodes
- Surcharges de méthodes vides

#### I - Ségrégation des interfaces (Interface Segregation)

Chercher :
- Grandes interfaces (> 10 méthodes)
- Classes implémentant des méthodes d'interface inutilisées
- Classes de service trop chargées

#### D - Inversion des dépendances (Dependency Inversion)

Chercher :
- Instanciation directe de dépendances (`new Service()`)
- Références de classes codées en dur
- Injection de dépendances manquante

### Étape 3 : Code Smells

```bash
# Patterns de duplication
grep -rn --include="*.{ts,js,py}" . 2>/dev/null | \
  awk -F: '{print $3}' | sort | uniq -c | sort -rn | head -10

# Longues listes de paramètres (> 4 params)
grep -rn "function.*,.*,.*,.*," --include="*.{ts,js}" . 2>/dev/null | head -10

# Imbrication profonde (4+ niveaux)
grep -rn "^\s\{16,\}" --include="*.{ts,js,py}" . 2>/dev/null | head -10
```

### Étape 4 : Évaluation de la complexité

Pour chaque problème trouvé, évaluer :
- **Impact** : Quelle quantité de code est affectée ?
- **Risque** : Qu'est-ce qui pourrait casser ?
- **Effort** : Lignes à modifier, tests nécessaires ?

## Format de sortie

---

### 🔧 Analyse de Refactoring

**Cible** : [fichier/répertoire]
**Lignes analysées** : [nombre]

### 📊 Tableau de bord SOLID

| Principe | Statut | Problèmes trouvés |
|----------|--------|-------------------|
| Responsabilité unique | 🟡 | 3 grandes classes |
| Ouvert/Fermé | 🟢 | OK |
| Substitution de Liskov | 🟢 | OK |
| Ségrégation des interfaces | 🔴 | 2 interfaces trop chargées |
| Inversion des dépendances | 🟡 | 5 instanciations directes |

### 🎯 Refactorings prioritaires

#### 1. [Impact le plus élevé] - Extraire une classe de `UserService`

**Violation** : Responsabilité unique
**Actuel** : 450 lignes gérant auth + profil + notifications
**Suggéré** :
```
UserService.ts (450 lignes)
    ↓ Extraire
AuthService.ts (~150 lignes)
ProfileService.ts (~150 lignes)
NotificationService.ts (~100 lignes)
```
**Risque** : Moyen (mettre à jour les imports)
**Tests nécessaires** : Mettre à jour l'injection de dépendances dans les tests

#### 2. [Deuxième priorité] - Remplacer le switch par du polymorphisme

**Emplacement** : `src/handlers/payment.ts:45`
**Actuel** :
```typescript
switch (paymentType) {
  case 'card': // 50 lignes
  case 'bank': // 50 lignes
  case 'crypto': // 50 lignes
}
```
**Suggéré** : Pattern Strategy avec l'interface `PaymentProcessor`
**Risque** : Faible (changement isolé)

### 📝 Code Smells

| Smell | Emplacement | Sévérité |
|-------|-------------|----------|
| Méthode trop longue | `api.ts:calculateTotal` (120 lignes) | 🟠 Haute |
| Code dupliqué | `utils/*.ts` (3 blocs similaires) | 🟡 Moyenne |
| Imbrication profonde | `parser.ts:parse` (6 niveaux) | 🟡 Moyenne |

### 🚀 Gains rapides (Faible risque, haute valeur)

1. Extraire `validateEmail()` vers des utils partagés (utilisé en 4 endroits)
2. Remplacer les nombres magiques par des constantes nommées
3. Ajouter des retours anticipés pour réduire l'imbrication dans `processOrder()`

### ⚠️ Notes de dette technique

- [Élément à suivre pour les sprints futurs]

---

## Checklist de sécurité du refactoring

Avant d'appliquer les suggestions :

- [ ] Des tests existent pour le code affecté
- [ ] Créer une branche de fonctionnalité
- [ ] Commiter l'état actuel
- [ ] Appliquer un refactoring à la fois
- [ ] Lancer les tests après chaque changement
- [ ] Revoir le diff avant de commiter

## Utilisation

**Analyser un fichier spécifique :**
```
/refactor src/services/user.ts
```

**Analyser un répertoire :**
```
/refactor src/api/
```

**Se concentrer sur un principe spécifique :**
```
/refactor --focus=srp src/services/
```

**Avec un seuil de complexité :**
```
/refactor --threshold=high
```

## Références

- Catalogue de Refactoring de Martin Fowler
- Clean Code de Robert C. Martin
- Principes SOLID de Robert C. Martin

$ARGUMENTS
