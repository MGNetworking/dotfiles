---
name: sonarqube
description: "Analyser les problèmes de qualité SonarCloud pour une PR spécifique"
---

# Analyse SonarQube

Analyse des problèmes de qualité SonarCloud pour une PR spécifique. Génère un rapport complet avec les métriques, les fichiers les plus problématiques et un plan d'action.

**Principe fondamental :** Analyse uniquement = aucune modification de code, pure extraction d'informations.

## Processus

1. **Vérifier le token** : Contrôler la variable d'environnement `$SONARQUBE_TOKEN`
2. **Récupérer les problèmes** : Appeler l'API SonarCloud pour les problèmes de la PR
3. **Analyser les données** : Regrouper par sévérité, type, fichier, règle
4. **Générer le rapport** : Sortie structurée avec plan d'action
5. **Nettoyage** : Supprimer les fichiers temporaires

## Prérequis

### Variable d'environnement

```bash
# Définir le token SonarQube (ajouter à ~/.bashrc ou ~/.zshrc)
export SONARQUBE_TOKEN="your_token_here"

# Vérifier que le token est défini
echo $SONARQUBE_TOKEN
```

**Pour obtenir le token :**
1. Aller sur SonarCloud → Mon compte → Sécurité
2. Générer un nouveau token
3. Copier et exporter comme variable d'environnement

### Configuration du projet

Configurer les détails de votre projet SonarCloud :

```bash
# Ajouter au CLAUDE.md du projet ou comme variables d'environnement
SONAR_ORGANIZATION="your-org-name"
SONAR_PROJECT_KEY="your-org_your-project"
SONAR_BASE_URL="https://sonarcloud.io/api"
```

**Si non défini :** Demander à l'utilisateur de fournir l'organisation et la clé du projet.

## Récupérer les problèmes

**Important :** Le `curl` direct avec `-u "$SONARQUBE_TOKEN:"` échoue dans zsh en raison du parsing de l'authentification. Utiliser un script bash intermédiaire :

```bash
# Créer un script bash temporaire pour gérer l'authentification
cat > /tmp/fetch_sonar.sh << 'SCRIPT'
#!/bin/bash
curl -s -u "${SONARQUBE_TOKEN}:" \
  "https://sonarcloud.io/api/issues/search?componentKeys=${SONAR_PROJECT_KEY}&pullRequest=$1&issueStatuses=OPEN,CONFIRMED&sinceLeakPeriod=true&ps=500"
SCRIPT

chmod +x /tmp/fetch_sonar.sh
/tmp/fetch_sonar.sh $PR_NUMBER > /tmp/sonar_pr_$PR_NUMBER.json
```

**Paramètres de l'API :**
- `componentKeys` : La clé de votre projet
- `pullRequest` : Numéro de la PR
- `issueStatuses` : OPEN,CONFIRMED (exclure les résolus)
- `sinceLeakPeriod` : Uniquement les nouveaux problèmes de cette PR
- `ps` : Taille de page (max 500)

## Script d'analyse

Créer le script d'analyse Node.js dans `/tmp/sonar_analyze.js` :

```javascript
const fs = require('fs');
const prNumber = process.argv[2];
const data = JSON.parse(fs.readFileSync(`/tmp/sonar_pr_${prNumber}.json`, 'utf8'));
const issues = data.issues || [];

// Regrouper par sévérité
const bySeverity = issues.reduce((acc, i) => {
  acc[i.severity] = (acc[i.severity] || 0) + 1;
  return acc;
}, {});

// Regrouper par type
const byType = issues.reduce((acc, i) => {
  acc[i.type] = (acc[i.type] || 0) + 1;
  return acc;
}, {});

// Regrouper par fichier
const byFile = issues.reduce((acc, i) => {
  const file = i.component.split(':')[1] || i.component;
  acc[file] = (acc[file] || 0) + 1;
  return acc;
}, {});

// Regrouper par règle
const byRule = issues.reduce((acc, i) => {
  if (!acc[i.rule]) {
    acc[i.rule] = {
      count: 0,
      severity: i.severity,
      message: i.message
    };
  }
  acc[i.rule].count++;
  return acc;
}, {});

// Sortie des données structurées
console.log(JSON.stringify({
  total: data.total,
  bySeverity,
  byType,
  topFiles: Object.entries(byFile)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 10),
  topRules: Object.entries(byRule)
    .map(([rule, d]) => ({ rule, ...d }))
    .sort((a, b) => b.count - a.count)
    .slice(0, 5)
}, null, 2));
```

**Lancer l'analyse :**
```bash
node /tmp/sonar_analyze.js $PR_NUMBER > /tmp/sonar_analysis_$PR_NUMBER.json
```

## Format du rapport

Générer le rapport formaté depuis l'analyse :

```
📊 Analyse SonarCloud - PR #XXX

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📈 RÉSUMÉ EXÉCUTIF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total des problèmes : {TOTAL}

Par sévérité :
🔴 Bloquant/Critique : {COUNT} ({PERCENTAGE}%)
🟡 Majeur : {COUNT} ({PERCENTAGE}%)
🔵 Mineur/Info : {COUNT} ({PERCENTAGE}%)

Par type :
🐛 Bugs : {COUNT}
🛡️ Vulnérabilités : {COUNT}
🧹 Code Smells : {COUNT}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📂 TOP 10 DES FICHIERS AVEC DES PROBLÈMES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. src/components/UserProfile.tsx - 8 problèmes
2. src/services/auth.service.ts - 5 problèmes
3. src/utils/validation.ts - 4 problèmes
...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ TOP 5 DES RÈGLES VIOLÉES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. typescript:S1854 (MAJOR) - 12 occurrences
   "Les affectations mortes doivent être supprimées"

2. typescript:S3776 (CRITICAL) - 8 occurrences
   "La complexité cognitive des fonctions ne doit pas être trop élevée"

3. typescript:S1186 (MINOR) - 6 occurrences
   "Les fonctions ne doivent pas être vides"
...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ PLAN D'ACTION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Priorité 1 - CRITICAL/BLOCKER ({COUNT} problèmes) :
  • Corriger immédiatement avant le merge
  • Se concentrer sur : {TOP_FILES}

Priorité 2 - MAJOR ({COUNT} problèmes) :
  • Traiter dans cette PR si possible
  • Envisager un ticket de dette technique si trop important

Priorité 3 - MINOR/INFO ({COUNT} problèmes) :
  • Peut être traité dans une PR de suivi
  • Ajouter au backlog pour le sprint de refactorisation

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔗 LIENS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Voir dans SonarCloud :
https://sonarcloud.io/project/pull_requests_list?id={PROJECT_KEY}&pullRequest={PR_NUMBER}
```

## Correspondance des sévérités

| SonarCloud | Symbole | Priorité | Action |
|------------|---------|----------|--------|
| BLOCKER | 🔴 | P0 | Corriger immédiatement |
| CRITICAL | 🔴 | P0 | Corriger immédiatement |
| MAJOR | 🟡 | P1 | Corriger dans cette PR |
| MINOR | 🔵 | P2 | Envisager pour le suivi |
| INFO | 🔵 | P3 | Amélioration optionnelle |

## Types de problèmes

| Type | Symbole | Description |
|------|---------|-------------|
| BUG | 🐛 | Code manifestement incorrect |
| VULNERABILITY | 🛡️ | Problèmes de sécurité |
| CODE_SMELL | 🧹 | Problème de maintenabilité |
| SECURITY_HOTSPOT | 🔒 | Code sensible à la sécurité à réviser |

## Nettoyage

Toujours nettoyer les fichiers temporaires après l'exécution :

```bash
rm -f /tmp/fetch_sonar.sh
rm -f /tmp/sonar_pr_$PR_NUMBER.json
rm -f /tmp/sonar_analyze.js
rm -f /tmp/sonar_analysis_$PR_NUMBER.json
```

## Gestion des erreurs

| Erreur | Cause | Action |
|--------|-------|--------|
| Token non défini | `$SONARQUBE_TOKEN` manquant | Demander à l'utilisateur d'exporter le token |
| 401 Non autorisé | Token invalide ou expiré | Demander un nouveau token sur SonarCloud |
| 404 Non trouvé | La PR n'existe pas dans SonarCloud | Vérifier le numéro de PR et la clé du projet |
| Réponse vide | Aucun problème trouvé | Signaler une PR propre, féliciter l'équipe |
| >500 problèmes | Limite de pagination atteinte | Avertir d'un résultat incomplet, suggérer de filtrer |
| Erreur réseau | API inaccessible | Vérifier la connexion internet, réessayer |

## Options de configuration

### Configuration au niveau du projet

Créer `.sonarcloud.properties` ou ajouter dans `CLAUDE.md` :

```properties
# Configuration SonarCloud
SONAR_ORGANIZATION=your-org
SONAR_PROJECT_KEY=your-org_your-project
SONAR_EXCLUSIONS=**/*.test.ts,**/*.spec.ts,**/migrations/**
SONAR_COVERAGE_EXCLUSIONS=**/*.test.ts,src/test/**
```

### Limites de l'API

Limites de l'API SonarCloud :
- Offre gratuite : 10 000 requêtes/jour
- Offre payante : Illimité

**Conseil :** Mettre en cache les résultats pour les requêtes répétées sur la même PR.

## Exemples d'intégration

### GitHub Actions

```yaml
- name: Analyse SonarQube
  run: |
    export SONARQUBE_TOKEN=${{ secrets.SONAR_TOKEN }}
    export SONAR_PROJECT_KEY="${{ secrets.SONAR_PROJECT }}"
    claude -p "/sonarqube ${{ github.event.pull_request.number }}"
```

### Hook pré-merge

Ajouter dans `.claude/hooks/pre-merge.sh` :

```bash
#!/bin/bash
PR_NUMBER=$(gh pr view --json number -q .number)
claude -p "/sonarqube $PR_NUMBER"
```

## À ne jamais faire

**Ne jamais :**
- ❌ Modifier le code ou corriger automatiquement les problèmes (commande d'analyse uniquement)
- ❌ Ignorer la vérification du token (risque de sécurité)
- ❌ Laisser des fichiers temporaires dans `/tmp` (nettoyage obligatoire)
- ❌ Commiter le token SonarQube dans le dépôt (utiliser les variables d'env)
- ❌ Lancer sans vérifier l'expiration du token

**Toujours :**
- ✅ Générer un rapport structuré et actionnable
- ✅ Nettoyer après l'exécution
- ✅ Gérer les erreurs d'API correctement
- ✅ Vérifier la validité du token avant les appels API
- ✅ Analyser et présenter les données clairement

## Utilisation avancée

### Filtres personnalisés

```bash
# Afficher uniquement les problèmes critical/blocker
/sonarqube 123 --severity BLOCKER,CRITICAL

# Afficher uniquement les bugs et vulnérabilités
/sonarqube 123 --types BUG,VULNERABILITY

# Pattern de fichier spécifique
/sonarqube 123 --files "src/services/**"
```

### Plusieurs PRs

```bash
# Comparer les problèmes entre plusieurs PRs
/sonarqube 123,124,125 --compare
```

## Dépannage

### Problème : "curl: (22) The requested URL returned error: 401"

**Cause :** Token invalide ou manquant

**Correction :**
```bash
# Régénérer le token dans SonarCloud
# Exporter le nouveau token
export SONARQUBE_TOKEN="new_token_here"
```

### Problème : "Réponse vide ou aucun problème"

**Cause :** Analyse pas encore terminée ou PR non analysée

**Correction :** Attendre que l'analyse SonarCloud soit complète (~2-5 minutes après la création de la PR)

### Problème : "componentKeys non trouvé"

**Cause :** Clé de projet incorrecte

**Correction :** Vérifier la clé du projet dans l'URL SonarCloud :
```
https://sonarcloud.io/project/overview?id=YOUR_PROJECT_KEY
```

## Exemples d'utilisation

```bash
# Utilisation de base
/sonarqube 170

# Avec préfixe PR
/sonarqube PR #234

# Via URL de la PR
/sonarqube https://github.com/org/repo/pull/170

# Filtre de sévérité personnalisé (si implémenté)
/sonarqube 170 --critical-only
```

Numéro de PR : $ARGUMENTS
