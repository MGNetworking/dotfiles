---
name: security-audit
description: "Audit de sécurité complet avec évaluation de la posture de sécurité par score"
---

# Audit de Sécurité

Audit de sécurité complet de votre projet ET de la configuration Claude Code. Analyse l'exposition des secrets, les surfaces d'injection, les dépendances, la sécurité des hooks, et produit une évaluation de la posture de sécurité avec un score et un plan de remédiation priorisé.

**Durée** : 2-5 minutes | **Périmètre** : Projet complet + configuration Claude Code

> Pour une vérification rapide de la configuration uniquement, utilisez `/security-check`.

## Instructions

Vous êtes un ingénieur senior en sécurité applicative. Effectuez un audit de sécurité en 6 phases et produisez un rapport scoré avec un plan de remédiation priorisé.

---

### Pré-étape : Établir le contexte de l'audit

**Avant d'effectuer tout contrôle**, utilisez `AskUserQuestion` pour demander :

1. **Environnement** : Ce code tourne-t-il en production, en staging, ou en développement local ?
2. **Périmètre** : Audit complet ou zones spécifiques à prioriser ?

C'est essentiel pour des résultats précis :
- **Dev local** : `DEBUG=True`, CORS `*`, HTTP sans TLS, fichiers `.env` — tout cela est normal. Ne PAS signaler comme des vulnérabilités. Mentionner dans une section informative "Avant de passer en production".
- **Staging** : Les configurations doivent refléter la production. Signaler les écarts en MEDIUM.
- **Production** : Toute mauvaise configuration est un vrai finding avec sa sévérité complète.

Si l'utilisateur ne répond pas ou ne sait pas, choisir par défaut **production** (approche conservatrice).

---

### Phase 1 : Sécurité de la configuration (via /security-check)

Exécuter tous les contrôles de `/security-check` (la commande `examples/commands/security-check.md`). Cela couvre :
- Audit des serveurs MCP contre la base de données CVE
- Compétences & agents contre les entrées malveillantes connues
- Patterns d'exfiltration dans les hooks
- Détection d'empoisonnement de mémoire
- Révision des permissions & paramètres
- Secrets exposés dans la configuration Claude Code

Enregistrer les findings — ils contribuent au score final.

---

### Phase 2 : Scan des secrets du projet

Scanner l'ensemble du projet pour les secrets et identifiants exposés :

```bash
# Clés API et tokens
grep -rn --include="*.{js,ts,py,go,java,rb,php,yaml,yml,json,toml,env,cfg,ini,conf}" \
  -E '(?i)(api[_-]?key|apikey|secret|password|passwd|token|bearer|auth)\s*[=:]\s*["'\''"][^"'\'']{8,}["'\''"]\s' \
  --exclude-dir={node_modules,vendor,.git,dist,build,target,__pycache__,.venv} . 2>/dev/null | head -30

# Patterns de clés de providers connus
grep -rn -E 'sk-[a-zA-Z0-9]{20,}|sk-ant-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{36}|AKIA[A-Z0-9]{16}|xox[bps]-[a-zA-Z0-9\-]{20,}' \
  --exclude-dir={node_modules,vendor,.git,dist,build,target} . 2>/dev/null | head -20

# Clés privées
grep -rn 'BEGIN.*PRIVATE KEY' --exclude-dir={node_modules,vendor,.git} . 2>/dev/null

# Fichiers .env qui pourraient être commités
find . -name ".env*" -not -path "*/node_modules/*" -not -path "*/.git/*" -type f 2>/dev/null

# Vérifier la couverture du .gitignore
[ -f ".gitignore" ] && {
  grep -q "\.env" .gitignore && echo "✅ .env dans .gitignore" || echo "⚠️ .env PAS dans .gitignore"
  grep -q "\.pem" .gitignore && echo "✅ .pem dans .gitignore" || echo "⚠️ .pem PAS dans .gitignore"
  grep -q "\.key" .gitignore && echo "✅ .key dans .gitignore" || echo "⚠️ .key PAS dans .gitignore"
}
```

**Règle anti-faux-positif — OBLIGATOIRE avant de signaler tout finding de secret :**

Avant de remonter un finding de secret, exécuter ces commandes de vérification :

```bash
# 1. Vérifier que .env est bien dans .gitignore (si oui, le .env local n'est PAS un finding)
grep -n '\.env' .gitignore 2>/dev/null || echo ".env PAS dans .gitignore"

# 2. Vérifier que les secrets ont bien été commités (résultat vide = pas de finding)
git log --all -p -- '*.env' '*.key' '*.pem' '*.secret' 2>/dev/null | grep -E '^\+.*(password|secret|api_key|token)' | head -20

# 3. Vérifier l'historique git pour les patterns spécifiques aux providers
git log --all -p 2>/dev/null | grep -E '^\+(sk-[a-zA-Z0-9]{20,}|AKIA[A-Z0-9]{16}|ghp_[a-zA-Z0-9]{36})' | head -10
```

Ne signaler un finding de secret que si vous avez une **preuve concrète issue de ces commandes**. Un fichier `.env` présent localement n'est pas un finding s'il est dans `.gitignore`. Ne jamais signaler "des secrets pourraient être exposés" sur la seule base du pattern matching.

**Score :**
- 0 secret trouvé → +20 points
- 1-3 secrets → +10 points
- 4+ secrets → 0 points
- Clé privée commitée → -10 points

---

### Phase 3 : Surface d'injection de prompts

Analyser les fichiers markdown et de configuration pour les vecteurs d'injection :

```bash
# Caractères de largeur nulle (instructions invisibles)
grep -rPn '[\x{200B}-\x{200D}\x{FEFF}]' --include="*.md" --include="*.yaml" --include="*.json" . 2>/dev/null

# Commentaires HTML cachés avec instructions
grep -rn '<!--' --include="*.md" . 2>/dev/null | grep -i 'ignore\|system\|admin\|instruction\|override\|forget'

# Base64 dans les commentaires (payloads cachés potentiels)
grep -rn -E '[#;].*[A-Za-z0-9+/]{20,}={0,2}' --include="*.py" --include="*.js" --include="*.ts" --include="*.md" \
  --exclude-dir={node_modules,vendor,.git} . 2>/dev/null | head -10

# Séquences d'échappement ANSI
grep -rPn '\x1b\[|\x1b\]|\x1b\(' --exclude-dir={node_modules,vendor,.git} . 2>/dev/null | head -10

# Octets nuls
grep -rPn '\x00' --exclude-dir={node_modules,vendor,.git,dist} . 2>/dev/null | head -5

# Exécution de commandes imbriquées dans markdown/config
grep -rn -E '\$\([^)]+\)|`[^`]+`' --include="*.md" --include="*.yaml" --include="*.json" \
  --exclude-dir={node_modules,vendor,.git} . 2>/dev/null | head -10
```

**Score :**
- 0 vecteur d'injection → +15 points
- 1-2 vecteurs (probables faux positifs) → +10 points
- 3+ vecteurs → +5 points
- Injection confirmée dans CLAUDE.md → 0 points

---

### Phase 4 : Audit des dépendances

Exécuter l'audit de paquets approprié pour le projet :

```bash
# Node.js
[ -f "package-lock.json" ] && npm audit --json 2>/dev/null | jq '{total: .metadata.vulnerabilities.total, critical: .metadata.vulnerabilities.critical, high: .metadata.vulnerabilities.high}' 2>/dev/null

# Python
[ -f "requirements.txt" ] && pip-audit -r requirements.txt 2>/dev/null || [ -f "pyproject.toml" ] && pip-audit 2>/dev/null

# Rust
[ -f "Cargo.toml" ] && cargo audit 2>/dev/null

# Go
[ -f "go.mod" ] && govulncheck ./... 2>/dev/null
```

Si aucun gestionnaire de paquets n'est détecté, le noter et passer (sans pénalité).

**Score :**
- 0 vulnérabilité → +20 points
- 0 critique + 0 haute → +15 points
- 1-3 hautes → +10 points
- Au moins 1 critique → +5 points
- 10+ hautes ou 3+ critiques → 0 points

---

### Phase 5 : Évaluation de la sécurité des hooks

Vérifier que les hooks de sécurité de `guide/security-hardening.md` sont correctement installés :

```bash
# Vérifier les hooks de sécurité recommandés
echo "=== Vérification des hooks de sécurité ==="

# Hooks PreToolUse (doivent bloquer les patterns dangereux)
ls .claude/hooks/PreToolUse* 2>/dev/null || echo "⚠️ Aucun hook PreToolUse trouvé"

# Hooks PostToolUse (doivent surveiller la sortie)
ls .claude/hooks/PostToolUse* 2>/dev/null || echo "⚠️ Aucun hook PostToolUse trouvé"

# Vérifier si le détecteur d'injection de prompts existe
find . -path "*/hooks/*injection*" -o -path "*/hooks/*security*" -o -path "*/hooks/*scanner*" 2>/dev/null

# Vérifier la configuration des hooks dans settings.json
grep -c "hooks" .claude/settings.json 2>/dev/null || echo "Aucun hook dans settings.json"
```

**Score :**
- Hooks de sécurité PreToolUse installés → +10 points
- Scanner de sortie PostToolUse installé → +5 points
- Hook détecteur d'injection de prompts → +5 points
- Aucun hook du tout → 0 points

---

### Phase 6 : Score de posture & rapport

Calculer le score total et générer le rapport.

**Décomposition du score :**

| Catégorie | Points max | Source |
|-----------|-----------|--------|
| Sécurité config (Phase 1) | 30 | Résultats /security-check |
| Scan des secrets (Phase 2) | 20 | Secrets trouvés dans le projet |
| Surface d'injection (Phase 3) | 15 | Vecteurs d'injection trouvés |
| Dépendances (Phase 4) | 20 | Audit de vulnérabilités |
| Sécurité des hooks (Phase 5) | 15 | Hooks de sécurité installés |
| **Total** | **100** | |

**Détail du score de la Phase 1 :**
- 0 finding CRITICAL → +15 points
- 0 finding HIGH → +10 points
- 0 finding MEDIUM → +5 points
- Au moins 1 CRITICAL → 0 pour ce sous-score

**Échelle de notes :**

| Score | Note | Signification |
|-------|------|---------------|
| 90-100 | A | Excellent — posture de sécurité prête pour la production |
| 75-89 | B | Bon — améliorations mineures recommandées |
| 60-74 | C | Acceptable — traiter les problèmes HIGH avant la production |
| 40-59 | D | Médiocre — lacunes de sécurité significatives |
| 0-39 | F | Critique — ne pas déployer, traiter les problèmes CRITICAL immédiatement |

## Format de sortie

```
## 🛡️ Rapport d'audit de sécurité

**Date** : [horodatage]
**Projet** : [nom du répertoire]
**Périmètre** : Projet complet + configuration Claude Code

### Score de posture de sécurité : [XX]/100 (Note [X])

[Évaluation en 1 phrase]

### Résultats par phase

| Phase | Score | Max | Finding principal |
|-------|-------|-----|-------------------|
| 1. Sécurité config | XX | 30 | [résumé] |
| 2. Scan des secrets | XX | 20 | [résumé] |
| 3. Surface d'injection | XX | 15 | [résumé] |
| 4. Dépendances | XX | 20 | [résumé] |
| 5. Sécurité des hooks | XX | 15 | [résumé] |
| **Total** | **XX** | **100** | |

### 🔴 Findings critiques
[Chaque finding avec emplacement, description et correction exacte]

### 🟠 Findings hauts
[Chaque finding avec emplacement, description et correction]

### 🟡 Findings moyens
[Chaque finding avec emplacement, description et correction]

### 🔧 Plan de remédiation (par ordre de priorité)

| # | Action | Sévérité | Effort | Commande/Étapes |
|---|--------|----------|--------|-----------------|
| 1 | [action] | CRITICAL | [durée] | [comment] |
| 2 | [action] | HIGH | [durée] | [comment] |
| ... | | | | |

### 📊 Référentiel

Votre score par rapport aux recommandations de security-hardening.md :
- [X] éléments du guide sont implémentés
- [X] éléments sont manquants
- Top 3 des éléments manquants à implémenter ensuite : [...]

### 📚 Références
- Guide de durcissement : guide/security-hardening.md
- Base de données des menaces : examples/commands/resources/threat-db.yaml
- Vérification rapide : `/security-check`
- Outil de scan MCP : `npx mcp-scan` (Snyk)
```

$ARGUMENTS
