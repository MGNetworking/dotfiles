---
name: release-notes
description: "Générer des notes de release en plusieurs formats à partir des commits git"
---

# Générateur de notes de release

Générer des notes de release en 3 formats à partir des commits git pour les releases en production.

## Processus

1. **Analyser l'historique Git** : Scanner les commits depuis le dernier tag de release
2. **Récupérer les détails des PR** : Obtenir titres et descriptions via `gh api`
3. **Catégoriser les changements** : Regrouper par type (feat, fix, perf, etc.)
4. **Vérifier les migrations** : Détecter les fichiers de migration de base de données
5. **Générer 3 sorties** : CHANGELOG, corps de PR, message de communication
6. **Transformer le langage** : Convertir le jargon technique en langage produit

## Formats de sortie

### 1. Section CHANGELOG.md

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Résumé
[Présentation en 1-2 phrases de cette release]

### Nouvelles fonctionnalités
#### [Nom de la fonctionnalité] (#PR)
- **Description** : Fonctionnalité ajoutée côté utilisateur
- **Impact** : Comment elle bénéficie aux utilisateurs

### Corrections de bugs
- **[Module]** : Description (#issue, identifiant-suivi)

### Améliorations techniques
- [Améliorations internes, refactoring, performance]

### Migrations de base de données
[Si applicable - lister les fichiers de migration]

### Statistiques
- PRs : X | Fonctionnalités : Y | Corrections : Z | Fichiers modifiés : N
```

### 2. Corps de PR Release

Utilise le template de release de votre projet :
- `.github/PULL_REQUEST_TEMPLATE/release.md`
- `.github/pull_request_template_release.md`
- Ou emplacement personnalisé spécifié dans la config du projet

### 3. Annonce de communication

Générer une annonce destinée aux utilisateurs (Slack, email, etc.) :
- Langage non technique
- Focus sur l'impact utilisateur
- Formatage lisible (emojis optionnels)

Exemples d'emplacement de template :
- `.github/COMMUNICATION_TEMPLATE/slack-release.md`
- `docs/templates/release-announcement.md`

## Alerte de migration

**Si des migrations sont détectées :**

```
╔══════════════════════════════════════════════════════════════════╗
║  ⚠️  [ATTENTION] MIGRATIONS DE BASE DE DONNÉES REQUISES          ║
╠══════════════════════════════════════════════════════════════════╣
║  Cette release contient X migration(s) :                         ║
║  • 20250110_add_user_preferences                                 ║
║  • 20250112_create_audit_log_table                               ║
║  Action requise : Lancer la commande de migration après déploiement ║
╚══════════════════════════════════════════════════════════════════╝
```

**Si aucune migration :**
```
✅ [OK] Aucune migration de base de données requise
```

## Transformation technique → produit

Convertir les commits techniques en descriptions accessibles aux utilisateurs :

| Technique | Langage produit/utilisateur |
|-----------|----------------------------|
| "Optimize N+1 queries with DataLoader" | "Temps de chargement plus rapides pour les listes" |
| "Implement AI embeddings with pgvector" | "Nouvelle fonctionnalité de recherche intelligente" |
| "Fix permissions scope bug" | "Problème d'accès résolu pour certains utilisateurs" |
| "Migration webpack -> Turbopack" | *Interne uniquement - ne pas communiquer* |
| "Refactor React hooks architecture" | *Interne uniquement - ne pas communiquer* |
| "Add rate limiting to API endpoints" | "Stabilité et sécurité du système améliorées" |

## Catégories de commits

| Préfixe | Catégorie | Inclure dans l'annonce ? |
|---------|-----------|--------------------------|
| `feat:` | Nouvelles fonctionnalités | Oui |
| `fix:` | Corrections de bugs | Oui (si visible par l'utilisateur) |
| `perf:` | Performance | Oui (simplifié) |
| `security:` | Sécurité | Oui |
| `refactor:` | Architecture | Non |
| `chore:` | Maintenance | Non |
| `docs:` | Documentation | Non |
| `test:` | Tests | Non |
| `build:` | Système de build | Non |
| `ci:` | CI/CD | Non |

## Commandes à exécuter

```bash
# 1. Obtenir le dernier tag de release
LAST_TAG=$(git tag --sort=-v:refname | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | head -n 1)

# 2. Lister les commits depuis le tag (sans les merges)
git log $LAST_TAG..HEAD --oneline --no-merges

# 3. Obtenir les détails des commits avec les numéros de PR
git log $LAST_TAG..HEAD --format="%h %s" --no-merges

# 4. Vérifier les migrations (adapter le chemin à votre ORM)
# Prisma :
git diff $LAST_TAG..HEAD --name-only -- prisma/migrations/
# Sequelize :
git diff $LAST_TAG..HEAD --name-only -- migrations/
# Django :
git diff $LAST_TAG..HEAD --name-only -- '**/migrations/*.py'
# Alembic :
git diff $LAST_TAG..HEAD --name-only -- alembic/versions/

# 5. Obtenir les détails des PR via GitHub CLI
gh api repos/{owner}/{repo}/pulls/{number}

# 6. Calculer les statistiques
TOTAL_PRS=$(git log $LAST_TAG..HEAD --oneline --merges | wc -l)
FEATURES=$(git log $LAST_TAG..HEAD --oneline --no-merges | grep -c 'feat:')
FIXES=$(git log $LAST_TAG..HEAD --oneline --no-merges | grep -c 'fix:')
```

## Versionnage sémantique

Déterminer le numéro de version en fonction des changements :

| Type de changement | Incrément de version | Exemple |
|--------------------|----------------------|---------|
| Changement cassant | MAJEUR (X.0.0) | API supprimée, changement incompatible |
| Nouvelle fonctionnalité | MINEUR (0.X.0) | Nouvelle fonctionnalité, compatible en arrière |
| Correction de bug / patch | PATCH (0.0.X) | Corrections de bugs uniquement |

**Indicateurs** :
- `BREAKING CHANGE:` dans le corps du commit → MAJEUR
- Commits `feat:` présents → MINEUR
- Uniquement `fix:` / `perf:` → PATCH

## Intégration au workflow

Workflow de release typique :

```
1. Vérifier que toutes les PRs sont mergées dans la branche develop
2. Lancer : /release-notes (ou spécifier version/plage)
3. Vérifier la précision des sorties générées
4. Créer la PR : develop -> main avec le label "release"
5. Ajouter la section CHANGELOG générée dans CHANGELOG.md
6. Utiliser le corps de PR généré comme description de PR
7. Après le merge : Créer et pousser le tag git
8. Publier l'annonce de communication (Slack/email/etc.)
9. Surveiller le déploiement et les migrations
```

## Création de tag Git

Après le merge de la PR, créer un tag annoté :

```bash
# Créer un tag annoté
git tag -a v1.2.3 -m "Release v1.2.3: Brève description"

# Pousser le tag vers le remote
git push origin v1.2.3

# Ou pousser tous les tags
git push --tags
```

## Personnalisation par projet

Adapter ces chemins à votre projet :

```
# Détection de migration (adapter le chemin ORM)
prisma/migrations/        → Votre répertoire de migration ORM
db/migrate/               → Migrations Rails
alembic/versions/         → Migrations Alembic

# Fichiers de template (créer si nécessaire)
.github/PULL_REQUEST_TEMPLATE/release.md
.github/COMMUNICATION_TEMPLATE/announcement.md
docs/templates/release-notes.md
```

## Conseils

- **Lancer depuis la racine du dépôt** : Assure le bon fonctionnement des commandes git
- **Authentifier GitHub CLI** : Lancer `gh auth login` si nécessaire
- **Vérifier avant de publier** : Toujours contrôler le contenu généré
- **Changements cassants** : Rechercher `BREAKING CHANGE:` dans les messages de commit
- **Issues liées** : Inclure les numéros d'issue/ticket pour la traçabilité
- **Migrations de base de données** : Tester en staging avant la production

## Cas limites

| Scénario | Comportement |
|----------|--------------|
| Aucun tag trouvé | Partir du premier commit |
| Aucun commit depuis le dernier tag | Erreur : "Aucun changement à releaser" |
| Plusieurs tags sur le même commit | Utiliser le plus récent par date |
| Tags de pré-release (v1.0.0-beta.1) | Exclure de la recherche "dernière release" |
| Commits sans format conventionnel | Catégoriser comme "Autres changements" |

## Exemples d'utilisation

```bash
# Générer les notes de release du dernier tag à HEAD
/release-notes

# Spécifier la version manuellement
/release-notes v1.5.0

# Spécifier une plage
/release-notes from v1.4.0 to HEAD

# Prévisualiser sans créer de fichiers
/release-notes --preview

# Inclure les commits de pré-release
/release-notes --include-pre-release
```

Version/Plage : $ARGUMENTS
