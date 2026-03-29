---
name: ship
description: "Vérification pré-déploiement complète pour s'assurer de la disponibilité à la mise en production"
---

# Commande Ship - Checklist pré-déploiement

Vérification pré-déploiement complète pour s'assurer de la disponibilité à la mise en production.

## Objectif

À lancer avant chaque déploiement en production pour vérifier :
- Les critères de qualité du code
- La couverture de tests
- Les vérifications de sécurité
- Les mises à jour de documentation
- La disponibilité de l'environnement

## Checklist pré-déploiement

### 🔴 Bloquants (doivent passer)

```bash
# 1. Tous les tests passent
npm test 2>/dev/null || pnpm test 2>/dev/null || yarn test 2>/dev/null
echo "Code de sortie : $?"

# 2. Pas d'erreurs TypeScript/lint
npm run typecheck 2>/dev/null || npx tsc --noEmit
npm run lint 2>/dev/null || npx eslint .

# 3. Le build réussit
npm run build 2>/dev/null || pnpm build 2>/dev/null

# 4. Pas de secrets dans le code
grep -rn "API_KEY=\|SECRET=\|PASSWORD=" --include="*.{ts,js,json}" . 2>/dev/null | grep -v node_modules | grep -v ".env.example"
```

### 🟠 Haute priorité (devraient passer)

```bash
# 5. Audit de sécurité
npm audit --audit-level=high 2>/dev/null || echo "Lancer manuellement : npm audit"

# 6. Pas de console.log dans le code de production
grep -rn "console\.log\|console\.debug" --include="*.{ts,js,tsx,jsx}" src/ 2>/dev/null | grep -v "// allowed" | head -10

# 7. Pas de TODO/FIXME dans les chemins critiques
grep -rn "TODO\|FIXME\|XXX\|HACK" --include="*.{ts,js}" src/ 2>/dev/null | head -10

# 8. Migrations de base de données prêtes
[ -d "prisma/migrations" ] && echo "Migrations Prisma : $(ls prisma/migrations | wc -l) au total"
[ -d "migrations" ] && echo "Migrations : $(ls migrations | wc -l) au total"
```

### 🟡 Recommandé (souhaitable)

```bash
# 9. Documentation mise à jour
git diff --name-only HEAD~5 | grep -E "README|CHANGELOG|docs/" | head -10

# 10. Version incrémentée
cat package.json | jq -r '.version' 2>/dev/null || echo "Vérifier la version manuellement"

# 11. Variables d'environnement documentées
[ -f ".env.example" ] && echo "✅ .env.example existe" || echo "⚠️ .env.example manquant"
```

## Format de sortie

---

### 🚀 Rapport de disponibilité au déploiement

**Branche** : [branche courante]
**Commit** : [hash court HEAD]
**Cible** : [production/staging]
**Horodatage** : [date/heure]

### Bloquants (à corriger avant le déploiement)

| Contrôle | Statut | Détails |
|----------|--------|---------|
| Tests | ✅/❌ | X réussis, Y échoués |
| TypeScript | ✅/❌ | X erreurs |
| Lint | ✅/❌ | X avertissements, Y erreurs |
| Build | ✅/❌ | Réussi/Échoué |
| Secrets | ✅/❌ | X fuites potentielles |

### Haute priorité

| Contrôle | Statut | Action |
|----------|--------|--------|
| Audit de sécurité | ⚠️/✅ | X vulnérabilités |
| Console Logs | ⚠️/✅ | X trouvés dans src/ |
| TODOs | ⚠️/✅ | X TODOs critiques |
| Migrations | ⚠️/✅ | X en attente |

### Recommandé

| Contrôle | Statut | Note |
|----------|--------|------|
| Docs mises à jour | ⚠️/✅ | CHANGELOG mis à jour |
| Version incrémentée | ⚠️/✅ | Actuelle : X.Y.Z |
| Env documenté | ⚠️/✅ | .env.example présent |

### 📊 Résumé

```
🔴 Bloquants :    X/5 passés
🟠 Haute :        X/4 passés
🟡 Recommandé :   X/3 passés
─────────────────────────────
Global :          [PRÊT À DÉPLOYER / PAS PRÊT]
```

### 🎯 Actions à effectuer

1. [Correction la plus critique nécessaire]
2. [Deuxième priorité]
3. [Troisième priorité]

---

## Vérifications spécifiques à l'environnement

### Déploiement production

```bash
# Vérifier les variables d'environnement de production
[ -f ".env.production" ] && echo "Env de production existe"

# Vérifier les flags de debug
grep -rn "DEBUG=true\|NODE_ENV=development" .env* 2>/dev/null

# Vérifier que les endpoints API pointent vers la production
grep -rn "localhost\|127\.0\.0\.1" --include="*.{ts,js,json}" src/ 2>/dev/null | grep -v test | head -5
```

### Déploiement staging

```bash
# Vérifications spécifiques au staging
[ -f ".env.staging" ] && echo "Env de staging existe"

# Feature flags pour le staging
grep -rn "FEATURE_FLAG\|ENABLE_" .env* 2>/dev/null
```

## Intégration CI/CD

Ajouter à votre pipeline :

```yaml
# Exemple GitHub Actions
ship-check:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - name: Lancer la checklist ship
      run: |
        npm ci
        npm test
        npm run typecheck
        npm run lint
        npm run build
        npm audit --audit-level=high
```

## Vérification post-déploiement

Après le déploiement, vérifier :

```bash
# 1. Vérification de santé
curl -s https://your-app.com/health | jq .

# 2. Vérification de version
curl -s https://your-app.com/version | jq .

# 3. Tests de fumée
npm run test:smoke 2>/dev/null || echo "Lancer les tests de fumée manuellement"
```

## Préparation du rollback

Avant de déployer, s'assurer de pouvoir revenir en arrière :

```bash
# Noter le tag de production actuel
git describe --tags --abbrev=0

# Vérifier que la procédure de rollback existe
[ -f "docs/runbooks/rollback.md" ] && echo "✅ Documentation de rollback existante"

# Vérifier la réversibilité des migrations de base de données
# Prisma : prisma migrate diff
# Rails : rails db:rollback (dry-run)
```

## Utilisation

**Checklist complète :**
```
/ship
```

**Déploiement production :**
```
/ship --production
```

**Vérification rapide (bloquants uniquement) :**
```
/ship --quick
```

**Avec une cible spécifique :**
```
/ship --target=staging
```

## Conseils

1. **Lancer tôt, lancer souvent** : Ne pas attendre le jour du déploiement
2. **Automatiser dans le CI** : Faire échouer le pipeline sur les bloquants
3. **Accord d'équipe** : Définir ce qui est bloquant vs avertissement
4. **Documenter les exceptions** : Si un contrôle est ignoré, noter pourquoi
5. **Surveiller après le déploiement** : Le ship n'est terminé que quand le monitoring confirme le succès

## Commandes associées

- `/release-notes` - Générer le changelog et les annonces
- `/validate-changes` - Revue de code basée sur LLM
- `/security` - Audit de sécurité approfondi

$ARGUMENTS
