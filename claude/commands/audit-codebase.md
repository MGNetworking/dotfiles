---
name: audit-codebase
description: "Audit de santé du code source — score sur 7 catégories avec plan de progression"
---

# Audit de Santé du Code Source

Évaluez votre code source sur 7 catégories de santé, identifiez les points faibles et obtenez un plan de progression priorisé. Chaque catégorie est notée de 1 à 10 avec des constats spécifiques et actionnables.

**Durée** : 3 à 8 minutes selon la taille du code source | **Périmètre** : Projet complet

## Instructions

Vous êtes un consultant senior en ingénierie réalisant une évaluation de santé du code source. Analysez le projet sur les 7 catégories (ou un sous-ensemble si `$ARGUMENTS` spécifie des catégories), notez chacune et produisez un plan de progression.

Si `$ARGUMENTS` contient des noms de catégories (ex. : "secrets security tests"), n'auditez que ces catégories. Sinon, auditez les 7.

---

### Catégorie 1 : Secrets (Poids : 15%)

Rechercher les identifiants en dur, clés API et données sensibles dans le code.

```bash
# Clés API et tokens dans le code
grep -rn --include="*.{js,ts,py,go,java,rb,php,yaml,yml,json,toml,env,cfg,ini,conf}" \
  -E '(?i)(api[_-]?key|apikey|secret[_-]?key|password|passwd|token|bearer)\s*[=:]\s*["'\''"][^"'\'']{8,}' \
  --exclude-dir={node_modules,vendor,.git,dist,build,target,__pycache__,.venv} . 2>/dev/null | head -20

# Patterns de fournisseurs connus
grep -rn -E 'sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{36}|AKIA[A-Z0-9]{16}|xox[bps]-[a-zA-Z0-9\-]{20,}' \
  --exclude-dir={node_modules,vendor,.git,dist,build,target} . 2>/dev/null | head -10

# Fichiers .env commités
find . -name ".env*" -not -name ".env.example" -not -path "*/node_modules/*" -not -path "*/.git/*" -type f 2>/dev/null

# Couverture du .gitignore
[ -f ".gitignore" ] && {
  for pattern in ".env" "*.pem" "*.key" "*.p12"; do
    grep -q "$pattern" .gitignore 2>/dev/null && echo "OK: $pattern dans .gitignore" || echo "MANQUANT: $pattern absent du .gitignore"
  done
}
```

**Scoring :**
- 10 : Zéro secret, .gitignore couvre tous les patterns sensibles, .env.example présent
- 7-9 : Pas de secrets dans le code, quelques lacunes mineures du .gitignore
- 4-6 : 1 à 3 secrets potentiels trouvés (possibles faux positifs), ou .env commité
- 1-3 : Plusieurs secrets dans le code, clés privées commitées, pas de protection .gitignore

---

### Catégorie 2 : Sécurité (Poids : 15%)

Vérifier les vulnérabilités de style OWASP et les patterns non sécurisés.

```bash
# Patterns d'injection SQL
grep -rn --include="*.{js,ts,py,java,go,rb,php}" \
  -E '(query|execute|exec)\s*\(\s*[`"'\''"].*\+|\$\{|%s|\.format\(' \
  --exclude-dir={node_modules,vendor,.git,dist,build,target,test,__test__} . 2>/dev/null | head -15

# Utilisation de eval/exec
grep -rn -E '\b(eval|exec|execSync|Function\(|setTimeout\([^,]*[+`]|setInterval\([^,]*[+`])' \
  --include="*.{js,ts,py}" --exclude-dir={node_modules,vendor,.git,dist} . 2>/dev/null | head -10

# Désérialisation non sécurisée
grep -rn -E '(pickle\.loads|yaml\.load\(|JSON\.parse\(.*user|unserialize\()' \
  --exclude-dir={node_modules,vendor,.git,dist} . 2>/dev/null | head -10

# Validation des entrées manquante sur les routes/endpoints
grep -rn -E '(app\.(get|post|put|delete|patch)|router\.(get|post|put|delete))' \
  --include="*.{js,ts}" --exclude-dir={node_modules,.git,dist} . 2>/dev/null | wc -l
```

**Scoring :**
- 10 : Pas de patterns d'injection, pas d'eval/exec, validation des entrées sur tous les endpoints, headers CSP
- 7-9 : Problèmes mineurs (1-2 usages d'eval dans du code non exposé aux utilisateurs)
- 4-6 : Quelques patterns d'injection, validation manquante sur plusieurs endpoints
- 1-3 : Risque d'injection SQL actif, eval avec entrée utilisateur, pas d'assainissement des entrées

---

### Catégorie 3 : Dépendances (Poids : 15%)

Auditer la santé des packages, les CVEs connus et leur fraîcheur.

```bash
# Audit Node.js
[ -f "package-lock.json" ] && npm audit --json 2>/dev/null | jq '.metadata.vulnerabilities' 2>/dev/null
[ -f "package.json" ] && npx npm-check 2>/dev/null | tail -20

# Python
[ -f "requirements.txt" ] && pip-audit -r requirements.txt 2>/dev/null | tail -20
[ -f "pyproject.toml" ] && pip-audit 2>/dev/null | tail -20

# Rust
[ -f "Cargo.toml" ] && cargo audit 2>/dev/null | tail -20

# Go
[ -f "go.mod" ] && govulncheck ./... 2>/dev/null | tail -20

# Présence du lockfile
for lockfile in package-lock.json yarn.lock pnpm-lock.yaml Cargo.lock go.sum poetry.lock; do
  [ -f "$lockfile" ] && echo "OK: $lockfile présent"
done
[ ! -f "package-lock.json" ] && [ ! -f "yarn.lock" ] && [ ! -f "pnpm-lock.yaml" ] && [ -f "package.json" ] && echo "MANQUANT: Pas de lockfile pour le projet Node.js"
```

**Scoring :**
- 10 : Zéro CVE, lockfile présent, toutes les dépendances datant de moins de 6 mois
- 7-9 : Pas de CVE critique/élevé, quelques packages légèrement obsolètes
- 4-6 : 1 à 3 CVE élevés, ou >50% des dépendances obsolètes depuis plus d'un an
- 1-3 : CVE critiques, pas de lockfile, dépendances abandonnées

---

### Catégorie 4 : Structure (Poids : 10%)

Évaluer l'organisation des fichiers, les conventions de nommage et les limites de modules.

```bash
# Nombre de fichiers par répertoire de premier niveau
for dir in */; do
  [ -d "$dir" ] && [ "$dir" != "node_modules/" ] && [ "$dir" != ".git/" ] && [ "$dir" != "vendor/" ] && \
    echo "$dir: $(find "$dir" -type f -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | wc -l) fichiers"
done

# Fichiers profondément imbriqués (indicateur de complexité)
find . -type f -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/vendor/*" -mindepth 6 2>/dev/null | head -10

# Conventions de nommage mixtes
find . -type f -name "*_*" -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | head -5
find . -type f -name "*-*" -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | head -5

# Indicateurs de dépendances circulaires (pour les projets JS/TS)
[ -f "package.json" ] && npx madge --circular --extensions ts,js src/ 2>/dev/null | head -20
```

**Scoring :**
- 10 : Limites de modules claires, nommage cohérent, pas de dépendances circulaires, hiérarchie plate
- 7-9 : Bonne structure avec des incohérences mineures
- 4-6 : Conventions mixtes, quelques dépendances circulaires, limites de modules floues
- 1-3 : Pas de structure claire, fichiers profondément imbriqués, dépendances circulaires généralisées

---

### Catégorie 5 : Tests (Poids : 15%)

Évaluer la couverture de tests, la qualité des tests et les pratiques de test.

```bash
# Nombre de fichiers de test vs fichiers sources
TEST_COUNT=$(find . -type f \( -name "*.test.*" -o -name "*.spec.*" -o -name "test_*" -o -path "*/test/*" -o -path "*/__tests__/*" \) \
  -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | wc -l)
SRC_COUNT=$(find . -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.go" -o -name "*.java" \) \
  -not -name "*.test.*" -not -name "*.spec.*" -not -name "test_*" \
  -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/dist/*" 2>/dev/null | wc -l)
echo "Fichiers de test: $TEST_COUNT | Fichiers sources: $SRC_COUNT | Ratio: $(echo "scale=2; $TEST_COUNT / ($SRC_COUNT + 1)" | bc)"

# Présence de la configuration de couverture
for cfg in jest.config.* vitest.config.* .nycrc .coveragerc pytest.ini setup.cfg; do
  [ -f "$cfg" ] && echo "OK: $cfg présent"
done

# Rapport de couverture (si disponible)
[ -d "coverage" ] && [ -f "coverage/coverage-summary.json" ] && cat coverage/coverage-summary.json | jq '.total' 2>/dev/null

# Nombre de tests snapshot (charge de maintenance potentielle)
find . -name "*.snap" -not -path "*/node_modules/*" 2>/dev/null | wc -l
```

**Scoring :**
- 10 : Ratio de tests >0,8, couverture >80%, CI exécute les tests, pas de snapshots obsolètes
- 7-9 : Ratio de tests >0,5, couverture >60%, configuration de couverture présente
- 4-6 : Certains tests existent mais les lacunes sont évidentes, pas de suivi de couverture
- 1-3 : Ratio de tests <0,2 ou pas de tests du tout

---

### Catégorie 6 : Imports (Poids : 10%)

Vérifier les imports inutilisés, les dépendances circulaires et la couverture des types.

```bash
# Imports inutilisés (TypeScript/JavaScript)
[ -f "tsconfig.json" ] && npx tsc --noEmit 2>&1 | grep -c "declared but" 2>/dev/null
[ -f "tsconfig.json" ] && npx tsc --noEmit 2>&1 | grep "declared but" | head -10

# Mode strict TypeScript
[ -f "tsconfig.json" ] && grep -E '"strict"|"noImplicitAny"|"strictNullChecks"' tsconfig.json 2>/dev/null

# Imports inutilisés Python
[ -f "pyproject.toml" ] || [ -f "setup.py" ] && python -m pyflakes . 2>/dev/null | grep "imported but unused" | head -10

# Imports avec wildcard (code smell)
grep -rn 'import \*' --include="*.{py,ts,js}" --exclude-dir={node_modules,vendor,.git} . 2>/dev/null | head -10
```

**Scoring :**
- 10 : Zéro import inutilisé, mode strict TypeScript, pas d'imports wildcard
- 7-9 : <5 imports inutilisés, mode strict activé avec quelques lacunes mineures
- 4-6 : 5 à 20 imports inutilisés, pas de mode strict, quelques imports wildcard
- 1-3 : >20 imports inutilisés, imports wildcard généralisés, pas de vérification de types

---

### Catégorie 7 : Patterns IA (Poids : 20%)

Évaluer la maturité de la configuration Claude Code et la préparation au développement assisté par IA.

```bash
# Présence et qualité de CLAUDE.md
[ -f "CLAUDE.md" ] && echo "OK: CLAUDE.md présent ($(wc -l < CLAUDE.md) lignes)" || echo "MANQUANT: Pas de CLAUDE.md"
[ -f ".claude/settings.json" ] && echo "OK: .claude/settings.json présent" || echo "MANQUANT: Pas de .claude/settings.json"

# Commandes personnalisées
COMMANDS=$(find .claude/commands -name "*.md" 2>/dev/null | wc -l)
echo "Commandes personnalisées: $COMMANDS"

# Hooks
HOOKS_CFG=$(grep -c "hooks" .claude/settings.json 2>/dev/null || echo "0")
echo "Configurations de hooks: $HOOKS_CFG"

# Fichiers de règles
RULES=$(find .claude/rules -name "*.md" 2>/dev/null | wc -l)
echo "Fichiers de règles: $RULES"

# Agents
AGENTS=$(find .claude/agents -name "*.md" 2>/dev/null | wc -l)
echo "Définitions d'agents: $AGENTS"

# Skills
SKILLS=$(find .claude/skills -name "*.md" 2>/dev/null | wc -l)
echo "Skills: $SKILLS"

# .gitignore pour les artefacts IA
grep -q "claude" .gitignore 2>/dev/null && echo "OK: Patterns Claude dans .gitignore" || echo "INFO: Pas de patterns Claude dans .gitignore"
```

**Scoring :**
- 10 : CLAUDE.md avec conventions, hooks configurés, commandes personnalisées, règles, agents
- 7-9 : CLAUDE.md présent avec contexte du projet, quelques commandes ou règles
- 4-6 : CLAUDE.md basique, pas de hooks ni de commandes
- 1-3 : Pas de CLAUDE.md ou CLAUDE.md vide

---

## Scoring et Rapport

### Calcul du Score Global

```
Global = (Secrets × 0,15) + (Sécurité × 0,15) + (Dépendances × 0,15) +
         (Structure × 0,10) + (Tests × 0,15) + (Imports × 0,10) +
         (Patterns IA × 0,20)
```

Arrondir à une décimale.

### Format de Sortie

```markdown
## Audit de Santé du Code Source

**Projet** : [nom du répertoire]
**Date** : [horodatage]
**Catégories auditées** : [les 7 ou sous-ensemble filtré]

### Score Global : [X,X] / 10

| Catégorie | Score | Poids | Pondéré | Constat Principal |
|-----------|-------|-------|---------|-------------------|
| Secrets | X/10 | 15% | X,XX | [résumé en une ligne] |
| Sécurité | X/10 | 15% | X,XX | [résumé en une ligne] |
| Dépendances | X/10 | 15% | X,XX | [résumé en une ligne] |
| Structure | X/10 | 10% | X,XX | [résumé en une ligne] |
| Tests | X/10 | 15% | X,XX | [résumé en une ligne] |
| Imports | X/10 | 10% | X,XX | [résumé en une ligne] |
| Patterns IA | X/10 | 20% | X,XX | [résumé en une ligne] |
| **Global** | | **100%** | **X,XX** | |

### Constats Détaillés

#### 🔴 Critique (corriger immédiatement)
- [Constat avec référence fichier:ligne et correction concrète]

#### 🟡 Avertissement (corriger cette semaine)
- [Constat avec contexte et approche suggérée]

#### 🟢 Information (amélioration appréciée)
- [Observation avec suggestion optionnelle]

### Plan de Progression

[En fonction du score global, afficher le palier approprié]

#### Palier 1 : Fondation (score actuel <5, objectif : 5)
Se concentrer sur l'élimination des risques critiques avant tout.

| Priorité | Action | Catégorie | Impact | Effort |
|----------|--------|-----------|--------|--------|
| 1 | [action spécifique] | [catégorie] | [gain de score] | [estimation de temps] |
| 2 | [action spécifique] | [catégorie] | [gain de score] | [estimation de temps] |
| ... | | | | |

#### Palier 2 : Solide (score actuel 5-7, objectif : 8)
Construire des pratiques fiables sur la fondation.

| Priorité | Action | Catégorie | Impact | Effort |
|----------|--------|-----------|--------|--------|
| 1 | [action spécifique] | [catégorie] | [gain de score] | [estimation de temps] |
| ... | | | | |

#### Palier 3 : Excellent (score actuel 8+, objectif : 10)
Peaufiner et optimiser pour maximiser la vélocité de l'équipe.

| Priorité | Action | Catégorie | Impact | Effort |
|----------|--------|-----------|--------|--------|
| 1 | [action spécifique] | [catégorie] | [gain de score] | [estimation de temps] |
| ... | | | | |

### Gains Rapides (< 30 minutes chacun)
1. [Action qui améliore le score avec un effort minimal]
2. [...]
3. [...]
```

### Répartition par Sévérité

Environ 70% des constats devraient être automatisables (scripts, linters, vérifications CI peuvent les détecter). Signaler les 30% restants comme nécessitant un jugement humain, et expliquer pourquoi l'automatisation est insuffisante dans ces cas.

---

**Sources** :
- Plugin d'analyse de code source Variant Systems (variantsystems.io, février 2026) : framework d'analyse à 7 catégories
- OWASP Top 10 (2021) : patterns de la catégorie Sécurité
- Guide de renforcement de la sécurité Claude Code : base de référence de la catégorie Patterns IA

$ARGUMENTS
