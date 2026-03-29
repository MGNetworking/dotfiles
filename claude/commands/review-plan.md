---
name: review-plan
description: "Revue structurée du plan selon 4 axes avant d'écrire le moindre code (inspiré du workflow de Garry Tan)"
---

# Revue du plan avant implémentation

Revoir le plan courant en profondeur avant d'effectuer tout changement de code. Pour chaque problème ou recommandation, expliquer les compromis concrets, donner une recommandation tranchée et demander l'avis de l'utilisateur avant de supposer une direction.

## Préférences d'ingénierie

Utiliser ces éléments pour guider les recommandations (remplacer par les préférences spécifiques au projet dans CLAUDE.md si elles existent) :

- DRY est important : signaler les répétitions de façon agressive
- Un code bien testé est non négociable : préférer trop de tests plutôt que trop peu
- Le code doit être "suffisamment ingénié" : ni sous-ingénié (fragile, hacky) ni sur-ingénié (abstraction prématurée, complexité inutile)
- Tendre vers la gestion d'un plus grand nombre de cas limites, pas moins
- Privilégier l'explicite plutôt que l'astucieux ; la réflexion plutôt que la rapidité

## Pipeline de revue

Travailler à travers chaque section séquentiellement. Après chaque section, faire une pause et demander du feedback avant de continuer.

### 1. Revue d'architecture

Évaluer :
- Conception globale du système et délimitations des composants
- Graphe de dépendances et problèmes de couplage
- Patterns de flux de données et goulots d'étranglement potentiels
- Caractéristiques de scalabilité et points de défaillance uniques
- Architecture de sécurité (auth, accès aux données, frontières d'API)

### 2. Revue de qualité du code

Évaluer :
- Organisation du code et structure des modules
- Violations DRY (être agressif ici)
- Patterns de gestion d'erreurs et cas limites manquants (les signaler explicitement)
- Points chauds de dette technique
- Zones sur-ingéniées ou sous-ingéniées par rapport aux préférences d'ingénierie

### 3. Revue des tests

Évaluer :
- Lacunes dans la couverture de tests (unitaire, intégration, e2e)
- Qualité des tests et solidité des assertions
- Couverture manquante des cas limites (être exhaustif)
- Modes de défaillance non testés et chemins d'erreur

### 4. Revue de performance

Évaluer :
- Requêtes N+1 et patterns d'accès à la base de données
- Problèmes de consommation mémoire
- Opportunités de mise en cache
- Chemins de code lents ou à haute complexité

## Format de rapport de problème

Pour chaque problème spécifique trouvé (bug, code smell, problème de conception ou risque) :

1. Décrire le problème concrètement, avec références au fichier et à la ligne
2. Présenter 2-3 options, y compris "ne rien faire" lorsque c'est raisonnable
3. Pour chaque option, préciser : effort d'implémentation, risque, impact sur le reste du code et charge de maintenance
4. Donner l'option recommandée et pourquoi, en lien avec les préférences d'ingénierie ci-dessus
5. Demander explicitement si l'utilisateur est d'accord ou souhaite choisir une direction différente avant de continuer

## Workflow

- Ne pas supposer les priorités sur le calendrier ou l'échelle
- Après chaque section, faire une pause et demander du feedback avant de continuer
- Utiliser AskUserQuestion pour la sélection structurée d'options

## Avant de commencer

Demander si l'utilisateur souhaite l'une des deux options :

1. **GRAND CHANGEMENT** : Travailler de façon interactive, section par section (Architecture → Qualité du code → Tests → Performance) avec au maximum 4 problèmes principaux dans chaque section
2. **PETIT CHANGEMENT** : Travailler de façon interactive avec UNE seule question par section de revue

## Conseils

- Combiner avec les fichiers `.claude/rules/` pour des critères de revue spécifiques au projet
- Les préférences d'ingénierie ci-dessus peuvent être remplacées par le CLAUDE.md de votre projet
- Pour une analyse plus approfondie, utiliser cette commande avec le modèle Opus

## Sources

- Inspiré du [prompt Plan Mode de Garry Tan](https://garrytan.com/) (fév. 2026)
- Adapté pour le système de configuration natif de Claude Code

$ARGUMENTS
