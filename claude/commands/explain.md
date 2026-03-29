---
name: explain
description: "Explique du code, des concepts ou le comportement d'un système avec des niveaux de profondeur ajustables"
---

# Explication de code

Explique du code, des concepts ou le comportement d'un système avec des niveaux de profondeur ajustables.

## Objectif

Obtenir des explications claires sur :
- Comment fonctionne un code spécifique
- Pourquoi certains patterns sont utilisés
- Ce que fait un système ou un module
- Les décisions d'architecture et leurs compromis

## Instructions

### Étape 1 : Définir le périmètre

Identifier ce qui doit être expliqué :
- **Fichier** : Structure et objectif global du fichier
- **Fonction/Méthode** : Détails spécifiques de l'implémentation
- **Concept** : Pattern architectural ou décision de conception
- **Flux** : Comment les données ou le contrôle circulent dans le système

### Étape 2 : Évaluer la complexité

```
Simple (1-2 min de lecture)     → Résumé rapide, points clés seulement
Standard (3-5 min de lecture)   → Objectif, fonctionnement, décisions clés
Approfondi (10+ min de lecture) → Décomposition complète, alternatives, compromis
```

### Étape 3 : Rassembler le contexte

```bash
# Pour les explications de fichiers
head -50 "$FILE"  # Voir les imports et la structure

# Pour les explications de fonctions
grep -A 30 "function $NAME\|def $NAME\|fn $NAME" "$FILE"

# Pour les explications de modules
ls -la "$DIR"
cat "$DIR/index.ts" 2>/dev/null || cat "$DIR/__init__.py" 2>/dev/null
```

### Étape 4 : Structurer l'explication

## Format de sortie

---

### 📖 Explication : [Cible]

**Périmètre** : [fichier/fonction/concept/flux]
**Profondeur** : [simple/standard/approfondi]

### Ce que ça fait

[1 à 3 phrases décrivant l'objectif]

### Comment ça fonctionne

[Décomposition étape par étape adaptée au niveau de profondeur]

### Décisions clés

| Décision | Pourquoi | Alternative |
|----------|----------|-------------|
| [choix effectué] | [raisonnement] | [ce qui pourrait aussi fonctionner] |

### Exemple d'utilisation

```typescript
// Comment l'utiliser correctement
```

### Code associé

- `path/to/related.ts` - [relation]
- `path/to/dependency.ts` - [relation]

### 💡 Notes d'apprentissage (avec le flag --learn)

[Contexte supplémentaire pour comprendre le pattern plus général]

---

## Niveaux de profondeur

### Simple (`/explain --simple`)

```markdown
**validateUser()** vérifie que l'objet utilisateur possède les champs requis
(email, password) et retourne un booléen. Utilise une regex pour le format email.
```

### Standard (`/explain` - par défaut)

```markdown
**validateUser(user: User): ValidationResult**

**Objectif** : Valide les données utilisateur avant les opérations en base de données.

**Flux** :
1. Vérifier que les champs requis existent (email, password)
2. Valider le format email avec une regex
3. Vérifier que le mot de passe respecte les critères (8+ caractères, caractère spécial)
4. Retourner { valid: boolean, errors: string[] }

**Utilisé par** : signup(), updateProfile()
```

### Approfondi (`/explain --deep`)

```markdown
[Tout ce qui est dans Standard, plus :]

**Décisions de conception** :
- Retourne ValidationResult au lieu de lever une exception pour permettre la validation par lot
- Regex choisie plutôt qu'une bibliothèque pour ne pas ajouter de dépendances
- Les règles de mot de passe sont configurables via config.ts

**Compromis** :
- Avantage : Rapide, aucune dépendance
- Inconvénient : La validation email par regex n'est pas conforme RFC

**Alternatives envisagées** :
- Zod schema : Plus puissant mais ajoute 50 Ko
- Class-validator : Mieux adapté aux décorateurs mais très orienté OOP
```

## Exemples d'utilisation

**Expliquer un fichier :**
```
/explain src/auth/middleware.ts
```

**Expliquer une fonction :**
```
/explain the handleWebhook function in payments.ts
```

**Expliquer un concept :**
```
/explain how our event sourcing works
```

**Expliquer avec un niveau de profondeur spécifique :**
```
/explain --deep the authentication flow
/explain --simple what useCallback does
```

**Expliquer pour apprendre :**
```
/explain --learn the repository pattern used here
```

## Conseils

1. **Soyez précis** : "Explique les lignes 45-60" > "Explique ce fichier"
2. **Indiquez votre niveau** : "Je débute en TypeScript" aide à calibrer l'explication
3. **Posez des questions de suivi** : "Pourquoi ne pas utiliser X à la place ?" approfondit la compréhension
4. **Demandez des analogies** : "Explique comme si je connaissais Python mais pas TypeScript"

$ARGUMENTS
