---
name: security
description: "Évaluation rapide de sécurité axée sur les vulnérabilités OWASP Top 10"
---

# Audit de sécurité rapide

Évaluation rapide de sécurité axée sur les vulnérabilités OWASP Top 10.

## Objectif

Effectuer un scan de sécurité rapide pour identifier les vulnérabilités courantes :
- Secrets et identifiants codés en dur
- Risques d'injection SQL
- Vulnérabilités XSS
- Dépendances non sécurisées
- Problèmes d'authentification/autorisation

## Instructions

### Étape 1 : Scan des secrets

```bash
# Patterns de secrets courants
grep -rn --include="*.{js,ts,py,go,java,rb,php,env}" \
  -E "(password|secret|api_key|apikey|token|auth|credential).*[=:].*['\"][^'\"]{8,}['\"]" \
  --exclude-dir={node_modules,vendor,.git,dist,build} . 2>/dev/null | head -20

# Fichiers .env qui pourraient être commités
find . -name ".env*" -not -path "*/node_modules/*" -type f 2>/dev/null

# Vérifier si les secrets sont dans le .gitignore
[ -f ".gitignore" ] && grep -q "\.env" .gitignore && echo "✅ .env dans .gitignore" || echo "⚠️ .env PAS dans .gitignore"
```

### Étape 2 : Vulnérabilités par injection

```bash
# Patterns d'injection SQL (requêtes brutes avec concaténation de chaînes)
grep -rn --include="*.{js,ts,py,go,java,php}" \
  -E "(query|execute|raw|sql).*\+.*\$|f['\"].*SELECT|\.format\(.*SELECT" \
  --exclude-dir={node_modules,vendor,.git} . 2>/dev/null | head -15

# Patterns d'injection de commandes
grep -rn --include="*.{js,ts,py,go,rb,php}" \
  -E "(exec|spawn|system|shell_exec|popen)\s*\(" \
  --exclude-dir={node_modules,vendor,.git} . 2>/dev/null | head -15
```

### Étape 3 : Patterns XSS

```bash
# Utilisations dangereuses de innerHTML/dangerouslySetInnerHTML
grep -rn --include="*.{js,ts,jsx,tsx,vue}" \
  -E "(innerHTML|dangerouslySetInnerHTML|v-html)" \
  --exclude-dir={node_modules,.git,dist} . 2>/dev/null | head -15

# Littéraux de gabarit non échappés dans un contexte HTML
grep -rn --include="*.{js,ts,jsx,tsx}" \
  -E "\`.*\$\{.*\}.*<" \
  --exclude-dir={node_modules,.git,dist} . 2>/dev/null | head -10
```

### Étape 4 : Vérification des dépendances

```bash
# Vérifier les vulnérabilités connues dans les paquets npm
[ -f "package-lock.json" ] && npm audit --json 2>/dev/null | jq '{vulnerabilities: .metadata.vulnerabilities}' 2>/dev/null

# Vérifier les paquets obsolètes avec des problèmes de sécurité
[ -f "package.json" ] && npm outdated --json 2>/dev/null | jq 'to_entries | map(select(.value.current != .value.latest)) | length' 2>/dev/null
```

### Étape 5 : Problèmes d'authentification & de session

```bash
# Secrets JWT codés en dur
grep -rn --include="*.{js,ts,py,go}" \
  -E "(jwt|JWT).*secret.*[=:].*['\"].{8,}['\"]" \
  --exclude-dir={node_modules,vendor,.git} . 2>/dev/null

# Patterns de protection CSRF manquante
grep -rn --include="*.{js,ts,py}" \
  -E "(POST|PUT|DELETE|PATCH).*fetch|axios\.(post|put|delete|patch)" \
  --exclude-dir={node_modules,vendor,.git} . 2>/dev/null | head -10
```

## Format de sortie

---

### 🛡️ Rapport d'audit de sécurité

**Date du scan** : [horodatage]
**Périmètre** : [répertoire scanné]

### 🔴 Problèmes critiques

| Problème | Emplacement | Description |
|----------|-------------|-------------|
| [type] | [fichier:ligne] | [description brève] |

### 🟠 Sévérité haute

| Problème | Emplacement | Recommandation |
|----------|-------------|----------------|
| [type] | [fichier:ligne] | [suggestion de correction] |

### 🟡 Sévérité moyenne

| Problème | Emplacement | Note |
|----------|-------------|------|
| [type] | [fichier:ligne] | [contexte] |

### 📊 Résumé

- **Critique** : X problèmes
- **Haute** : X problèmes
- **Moyenne** : X problèmes
- **Dépendances** : X vulnérabilités

### 🔧 Corrections rapides

1. [Correction de la plus haute priorité avec commande/code]
2. [Deuxième priorité]
3. [Troisième priorité]

---

## Niveaux de sévérité

| Niveau | Exemples | Action |
|--------|----------|--------|
| 🔴 Critique | Secrets de prod codés en dur, injection SQL | Corriger immédiatement |
| 🟠 Haute | Authentification manquante, vecteurs XSS | Corriger avant le déploiement |
| 🟡 Moyenne | Dépendances obsolètes, CSRF manquant | Planifier la remédiation |
| 🟢 Basse | Violations des bonnes pratiques | Suivre pour amélioration |

## Utilisation

**Audit complet :**
```
/security
```

**Cibler une zone spécifique :**
```
/security auth
/security deps
/security injection
```

**Fichier/répertoire spécifique :**
```
/security src/api/
```

## Notes

- Il s'agit d'un scan heuristique rapide, pas d'un audit de sécurité complet
- Pour les systèmes en production, compléter avec des outils dédiés (Snyk, SonarQube, OWASP ZAP)
- Des faux positifs sont possibles — vérifier les findings manuellement
- Voir `examples/hooks/security-hooks.sh` pour les vérifications de sécurité automatisées en pre-commit

$ARGUMENTS
