---
name: optimize
description: "Analyser et suggérer des améliorations de performance pour du code, des requêtes ou des systèmes"
---

# Optimiseur de performance

Analyser et suggérer des améliorations de performance pour du code, des requêtes ou des systèmes.

## Objectif

Identifier les opportunités d'optimisation :
- Goulots d'étranglement des performances à l'exécution
- Problèmes d'utilisation mémoire
- Inefficacités des requêtes de base de données
- Problèmes de taille de bundle
- Complexité algorithmique

## Instructions

### Étape 1 : Identification du périmètre

Déterminer la cible d'optimisation :
- **Fonction** : Performance d'une seule fonction
- **Module** : Fonctions/classes connexes
- **Requête** : Optimisation de requête de base de données
- **Bundle** : Analyse du bundle frontend
- **Système** : Optimisation au niveau de l'architecture

### Étape 2 : Analyse des performances

#### Analyse à l'exécution

```bash
# Trouver les patterns potentiellement lents
grep -rn "forEach\|\.map\|\.filter\|\.reduce" --include="*.{ts,js}" . | head -20

# Trouver les boucles imbriquées (potentiel O(n²))
grep -rn "for.*for\|\.forEach.*\.forEach\|\.map.*\.map" --include="*.{ts,js}" . | head -10

# Trouver les opérations synchrones qui pourraient être asynchrones
grep -rn "readFileSync\|writeFileSync\|execSync" --include="*.{ts,js}" . | head -10
```

#### Analyse mémoire

```bash
# Opérations sur de grands tableaux
grep -rn "new Array\|Array\.from\|\.concat\|spread" --include="*.{ts,js}" . | head -10

# Fuites mémoire potentielles (écouteurs d'événements, intervalles)
grep -rn "addEventListener\|setInterval\|setTimeout" --include="*.{ts,js}" . | head -10
```

#### Analyse des requêtes de base de données

```bash
# Patterns de requêtes N+1
grep -rn "await.*find\|await.*query" --include="*.{ts,js}" . | head -15

# Indices manquants
grep -rn "WHERE\|ORDER BY\|GROUP BY" --include="*.{ts,js,sql}" . | head -15
```

#### Analyse du bundle

```bash
# Vérifier la taille du bundle (si applicable)
[ -f "package.json" ] && npm run build 2>/dev/null && ls -lh dist/*.js 2>/dev/null

# Dépendances volumineuses
[ -f "package.json" ] && cat package.json | jq '.dependencies | keys[]' | head -20
```

### Étape 3 : Priorisation

Classer les résultats par :
1. **Impact** : Dans quelle mesure cela améliorera-t-il les performances ?
2. **Effort** : Quelle est la difficulté du correctif ?
3. **Risque** : Qu'est-ce qui pourrait casser ?

## Format de sortie

---

### Analyse des performances

**Cible** : [fichier/module/système]
**Date d'analyse** : [horodatage]

### Métriques actuelles (si mesurables)

| Métrique | Actuel | Cible | Écart |
|----------|--------|-------|-------|
| Temps de réponse | Xms | <Yms | -Z% requis |
| Utilisation mémoire | XMB | <YMB | -Z% requis |
| Taille du bundle | XKB | <YKB | -Z% requis |

### Problèmes critiques

#### 1. [Titre du problème] - [Emplacement]

**Problème** : [Ce qui est lent et pourquoi]

**Actuel** :
```typescript
// O(n²) - boucles imbriquées
users.forEach(user => {
  permissions.forEach(perm => {
    if (user.id === perm.userId) { ... }
  });
});
```

**Optimisé** :
```typescript
// O(n) - lookup par Map
const permMap = new Map(permissions.map(p => [p.userId, p]));
users.forEach(user => {
  const perm = permMap.get(user.id);
  if (perm) { ... }
});
```

**Impact** : ~10x plus rapide pour 1000 utilisateurs
**Effort** : Faible (5 min)
**Risque** : Faible

### Haute priorité

| Problème | Emplacement | Impact | Effort |
|----------|-------------|--------|--------|
| [description] | fichier:ligne | [estimation] | [durée] |

### Priorité moyenne

| Problème | Emplacement | Impact | Effort |
|----------|-------------|--------|--------|
| [description] | fichier:ligne | [estimation] | [durée] |

### Gains rapides

1. [Petite modification à bon impact]
2. [Autre optimisation rapide]
3. [Fruit à portée de main]

### Feuille de route d'optimisation

```
Semaine 1 : Correctifs critiques (points 1-3)
Semaine 2 : Haute priorité (points 4-6)
Semaine 3 : Mesurer et valider les améliorations
```

---

## Patterns courants

### Opérations sur les tableaux

| Pattern | Problème | Correctif |
|---------|----------|-----------|
| `arr.filter().map()` | Deux itérations | `reduce()` ou `flatMap()` unique |
| `arr.find()` dans une boucle | O(n²) | Construire d'abord une Map/Set |
| `[...arr1, ...arr2]` | Allocation mémoire | `arr1.concat(arr2)` ou push |

### Base de données

| Pattern | Problème | Correctif |
|---------|----------|-----------|
| Boucle avec await | Requêtes N+1 | Requête par lot avec `IN` |
| `SELECT *` | Surrécupération | Sélectionner uniquement les colonnes nécessaires |
| Index WHERE manquant | Scan complet de table | Ajouter un index composite |

### React/Frontend

| Pattern | Problème | Correctif |
|---------|----------|-----------|
| Fonctions inline dans JSX | Re-rendus | `useCallback` |
| Rendu de grandes listes | Surcharge DOM | Virtualisation |
| Images non optimisées | LCP lent | Next/Image, lazy loading |

### Node.js

| Pattern | Problème | Correctif |
|---------|----------|-----------|
| Opérations fichier synchrones | Bloque l'event loop | Alternatives asynchrones |
| `JSON.parse` de gros fichiers | Pic mémoire | Parser en streaming |
| Pas de pool de connexions | Surcharge de connexion | Pool avec pg-pool, etc. |

## Utilisation

**Analyser un fichier spécifique :**
```
/optimize src/services/user.ts
```

**Se concentrer sur une zone spécifique :**
```
/optimize --queries src/repositories/
/optimize --bundle
/optimize --memory src/workers/
```

**Avec des métriques cibles :**
```
/optimize --target=100ms src/api/search.ts
```

**Analyse rapide :**
```
/optimize --quick
```

## Notes

- Les mesures valent mieux que les suppositions : profiler avant d'optimiser
- L'optimisation prématurée est la source de tous les maux (Knuth)
- Se concentrer sur les chemins chauds : optimiser ce qui s'exécute souvent
- Considérer les compromis : vitesse vs lisibilité vs maintenabilité

$ARGUMENTS
