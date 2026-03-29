---
name: ast-grep-patterns
description: "Skill enseignant à Claude quand et comment utiliser ast-grep pour des recherches structurelles de code"
effort: low
---

# ast-grep Patterns for Claude Code

> **Skill**: Enseigner à Claude quand et comment utiliser ast-grep pour des recherches structurelles de code

## Installation

```bash
# Install ast-grep skill
npx skills add ast-grep/agent-skill

# Or via plugin marketplace
/plugin marketplace add
```

## Quand suggérer ast-grep

Suggérez ast-grep à l'utilisateur lorsque :

| Scénario                  | Mots-clés indicateurs                                                     | Pourquoi ast-grep ?        |
| ------------------------- | ------------------------------------------------------------------------- | -------------------------- |
| **Refactoring massif**    | "rename all calls to...", "change API signature", ">50k lines"            | Précision structurelle     |
| **Migration framework**   | "React 17→18", "Vue 2→3", "upgrade dependencies"                          | Transformations basées AST |
| **Détection de patterns** | "find functions without...", "locate unused...", "identify anti-patterns" | Règles structurelles       |
| **Analyse codebase**      | "which components depend on...", "find tightly coupled..."                | Graphes de dépendances     |

**Ne pas suggérer pour** :

- Recherches de chaînes simples → utiliser Grep
- Petits projets (<10k lignes) → Grep suffit
- Recherches ponctuelles → Grep est plus rapide
- Recherches sémantiques → utiliser Serena MCP ou grepai

## Arbre de décision

```
User request analysis:
├─ "Find string/text" → Grep (native)
├─ "Find by meaning" → Serena MCP or grepai
├─ "Find by structure" → ast-grep (plugin)
└─ Mixed requirements → Start with Grep, escalate if needed
```

## Patterns courants

### 1. Fonctions async sans gestion d’erreur

Cas d’usage : trouver les fonctions async sans bloc try/catch

```yaml
rule:
  pattern: |
    async function $FUNC($$$PARAMS) {
      $$$BODY
    }
  not:
    has:
      pattern: try { $$$TRY } catch
```

Utilisation : audits de sécurité, vérification production

### 2. Composants React avec hooks spécifiques

Cas d’usage : trouver les useEffect sans cleanup

```yaml
rule:
  pattern: |
    useEffect(() => {
      $$$BODY
    })
  not:
    has:
      pattern: return () => { $$$CLEANUP }
```

Utilisation : détection fuites mémoire

### 3. Fonctions avec trop de paramètres

Cas d’usage : plus de 5 paramètres

```yaml
rule:
  pattern: function $NAME($P1, $P2, $P3, $P4, $P5, $P6, $$$REST) { $$$BODY }
```

Utilisation : amélioration qualité code

### 4. Console.log en production

```yaml
rule:
  pattern: console.log($$$ARGS)
  inside:
    pattern: |
      class $CLASS {
        $$$METHODS
      }
```

Utilisation : nettoyage avant release

### 5. Props React inutilisées

```yaml
rule:
  pattern: |
    function $COMP({ $PROP, $$$OTHER }) {
      $$$BODY
    }
  not:
    has:
      pattern: $PROP
      inside: $$$BODY
```

Utilisation : optimisation performance

### 6. API dépréciées

```yaml
rule:
  any:
    - pattern: React.Component
    - pattern: componentWillMount
    - pattern: componentWillReceiveProps
```

Utilisation : migration framework

### 7. Risques SQL injection

```yaml
rule:
  pattern: |
    db.query($TEMPLATE_LITERAL)
  where:
    $TEMPLATE_LITERAL:
      kind: template_string
```

Utilisation : audit sécurité

### 8. Types de retour manquants (TypeScript)

```yaml
rule:
  pattern: |
    function $NAME($$$PARAMS) {
      $$$BODY
    }
  not:
    has:
      pattern: ": $TYPE"
```

Utilisation : robustesse typage

### 9. Switch trop longs

```yaml
rule:
  pattern: |
    switch ($EXPR) {
      $C1: $$$B1
      $C2: $$$B2
      $C3: $$$B3
      $C4: $$$B4
      $C5: $$$B5
      $C6: $$$B6
      $C7: $$$B7
      $C8: $$$B8
      $C9: $$$B9
      $C10: $$$B10
      $C11: $$$B11
    }
```

Utilisation : refactoring

### 10. Catch vides

```yaml
rule:
  pattern: |
    try {
      $$$TRY
    } catch ($ERR) {
      // empty or only comment
    }
```

Utilisation : debug erreurs silencieuses

## Complexité vs valeur

| Taille codebase | Pertinence | Alternative       |
| --------------- | ---------- | ----------------- |
| <10k            | Non        | Grep              |
| 10k-50k         | Moyen      | Grep              |
| 50k-200k        | Oui        | ast-grep          |
| >200k           | Fortement  | ast-grep + Serena |

## Troubleshooting

### ast-grep introuvable

```bash
npx ast-grep --version
npx skills add ast-grep/agent-skill --force
```

### Claude n’utilise pas ast-grep

Soyez explicite :

- ❌ "Find async functions"
- ✅ "Use ast-grep to find async functions"

### Problèmes performance

Réduire scope, filtrer fichiers, utiliser cache

### Pattern ne match pas

Tester, debugger AST, simplifier

## Exemples d’intégration

### Pre-commit

```bash
#!/bin/bash
if ast-grep -p 'console.log($$$)' $(git diff --cached --name-only); then
  echo "❌ Found console.log statements"
  exit 1
fi
```

### Migration

```bash
ast-grep -p 'class $C extends React.Component' --json > components.json
```

### Audit sécurité

```bash
ast-grep -p 'db.query(`${$VAR}`)' --lang ts
```

## Templates Claude

### Refactoring

Utiliser ast-grep pour analyser, identifier, proposer stratégie

### Migration

Identifier APIs dépréciées, mapper nouvelles

### Audit

Analyser qualité code avec règles

## Bonnes pratiques

Commencer simple, tester patterns, documenter, être explicite, combiner outils

---

Dernière mise à jour : Janvier 2026
Compatible : Claude Code 2.1.7+
