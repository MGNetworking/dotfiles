# Commandes Claude Code

Liste de toutes les commandes disponibles, regroupées par fonctionnalité.

---

## Initialisation Git

Commandes pour initialiser un projet git de A à Z.

| Commande | Description |
|---|---|
| `/git-setup` | Orchestrateur — questionnaire guidé pour initialiser un projet complet |
| `/git-setup-branches` | Créer les branches recommandées (GitHub Flow, GitFlow, Trunk-based) |
| `/git-setup-gitignore` | Générer un `.gitignore` adapté au langage, framework et OS |
| `/git-setup-gitattributes` | Générer un `.gitattributes` (fins de ligne, fichiers binaires) |
| `/git-setup-release-please` | Configurer Release Please pour automatiser versions et CHANGELOG |
| `/git-setup-actions` | Générer les workflows GitHub Actions (CI et/ou Release) |
| `/git-setup-github` | Créer le dépôt GitHub avec description, topics, remote et protection des branches |

---

## Git Worktrees

Commandes pour travailler avec des worktrees git isolés.

| Commande | Description |
|---|---|
| `/git-worktree` | Créer un worktree isolé pour développer une fonctionnalité |
| `/git-worktree-status` | Vérifier le statut des tâches en arrière-plan dans un worktree |
| `/git-worktree-remove` | Supprimer en toute sécurité un worktree avec nettoyage de branche |
| `/git-worktree-clean` | Nettoyer les worktrees obsolètes avec rapport d'utilisation disque |

---

## Workflow de livraison

Commandes pour gérer le cycle de vie du code, du commit à la production.

| Commande | Description |
|---|---|
| `/commit` | Générer un message de commit conventionnel pour les modifications stagées |
| `/pr` | Analyser les changements et créer une PR bien structurée |
| `/validate-changes` | Évaluer les changements stagés avec un LLM-as-a-Judge avant de commiter |
| `/release-notes` | Générer des notes de release en plusieurs formats à partir des commits git |
| `/ship` | Vérification pré-déploiement complète pour s'assurer de la disponibilité |
| `/land-and-deploy` | Fusionner la PR, attendre la CI, vérifier le déploiement, lancer le canary |
| `/canary` | Surveillance post-déploiement — alerter sur les régressions |

---

## Planification

Commandes pour planifier et valider une implémentation avant d'écrire du code.

| Commande | Description |
|---|---|
| `/plan-start` | Planification en 5 phases — produit un plan complet et des ADRs |
| `/plan-ceo-review` | Verrou produit stratégique — remettre en question le brief |
| `/plan-eng-review` | Verrou d'architecture technique — verrouiller l'architecture et les cas limites |
| `/review-plan` | Revue structurée du plan selon 4 axes avant d'écrire du code |
| `/plan-validate` | Validation du plan en 2 couches avec correction automatique |
| `/plan-execute` | Exécuter un plan validé jusqu'à la PR fusionnée |

---

## Qualité du code

Commandes pour auditer, tester et améliorer la qualité du code.

| Commande | Description |
|---|---|
| `/audit-codebase` | Audit de santé du code — score sur 7 catégories avec plan de progression |
| `/audit-agents-skills` | Auditer la qualité des agents, skills et commandes Claude Code |
| `/audit-prompts` | Auditer les fichiers prompt-générateur — complétude et cohérence |
| `/qa` | Tests QA systématiques d'une application web avec boucle corriger-et-vérifier |
| `/refactor` | Détecter les violations SOLID et suggérer des améliorations ciblées |
| `/optimize` | Analyser et suggérer des améliorations de performance |
| `/sonarqube` | Analyser les problèmes de qualité SonarCloud pour une PR spécifique |
| `/autoresearch` | Boucle d'amélioration autonome pilotée par métriques |

---

## Sécurité

Commandes pour auditer et surveiller la sécurité du projet.

| Commande | Description |
|---|---|
| `/security` | Évaluation rapide axée sur les vulnérabilités OWASP Top 10 |
| `/security-audit` | Audit de sécurité complet avec évaluation par score |
| `/security-check` | Vérification rapide contre la base de données des menaces connues |
| `/update-threat-db` | Mettre à jour la base de données des menaces de sécurité |
| `/sandbox-status` | Afficher le statut du sandbox natif et les violations récentes |

---

## Développement

Commandes pour assister pendant le développement au quotidien.

| Commande | Description |
|---|---|
| `/generate-tests` | Générer des tests complets pour le code spécifié |
| `/investigate` | Débogage systématique par recherche de cause racine |
| `/review-pr` | Effectuer une revue de code complète d'une pull request |
| `/explain` | Expliquer du code, des concepts ou le comportement d'un système |
| `/diagnose` | Assistant de dépannage interactif pour les problèmes Claude Code |

---

## Gestion de session

Commandes pour gérer le contexte et la continuité entre les sessions.

| Commande | Description |
|---|---|
| `/catchup` | Restaurer le contexte après `/clear` en résumant le travail récent |
| `/session-save` | Sauvegarder l'état de la session — décisions, fichiers, prochaines étapes |

---

## Apprentissage

Commandes pour approfondir sa compréhension du code et des concepts.

| Commande | Description |
|---|---|
| `/learn:teach` | Explication progressive d'un concept avec profondeur croissante |
| `/learn:alternatives` | Comparer différentes approches pour résoudre le même problème |
| `/learn:quiz` | Tester sa compréhension du code récemment écrit ou accepté |
