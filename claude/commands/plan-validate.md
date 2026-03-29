---
name: plan-validate
description: "Validation du plan en 2 couches : vérifications structurelles instantanées + agents spécialistes déclenchés par règles. Correction automatique des problèmes via ADRs et premiers principes. Chaque problème doit être résolu avant l'exécution."
---

# Plan Validate — Validation en 2 couches

Valider indépendamment le plan produit par `/plan-start`. Aucun code n'est écrit. Lancer `/clear` après cette commande avant de lancer `/plan-execute`.

La validation est séparée de la planification par conception : les validateurs qui n'ont pas écrit le plan ne sont pas ancrés à ses hypothèses.

---

## Prérequis

Un fichier de plan commité doit exister dans `docs/plans/plan-{name}.md`. Si plusieurs plans existent, les lister et demander à l'utilisateur lequel valider.

---

## Couche 1 : Validation structurelle

Lancer immédiatement, sans agents. Vérifier le document de plan pour :

**Format & Complétude**
- [ ] Toutes les sections requises présentes (Résumé, Décisions, Architecture, Tâches, Plan de test, Hors périmètre)
- [ ] Chaque tâche a : description, fichiers concernés, critères d'acceptation, attribution de couche

**Chaîne de dépendances**
- [ ] Pas de dépendances circulaires entre tâches
- [ ] Les tâches des couches supérieures ne dépendent que de tâches des couches inférieures
- [ ] Toutes les dépendances déclarées existent dans le plan

**Existence des fichiers**
- [ ] Chaque fichier listé pour modification existe réellement dans le codebase (utiliser Glob)
- [ ] Les nouveaux fichiers sont dans des répertoires appropriés selon les conventions du projet

**Cohérence ADR**
- [ ] Les décisions du plan s'alignent avec les ADRs créés pendant `/plan-start`
- [ ] Pas de contradiction avec les ADRs existants dans `docs/adr/`

**Conformité CLAUDE.md**
- [ ] Le plan respecte toutes les règles strictes de CLAUDE.md
- [ ] Pas de violation des premiers principes (pas de contournements, pas de shims de rétrocompatibilité)

**Couverture de tests**
- [ ] Chaque nouvelle fonction/composant a une tâche de test correspondante
- [ ] Les tâches marquées TDD ont un test en échec écrit avant la tâche d'implémentation

Enregistrer tous les problèmes de la Couche 1 avec leur sévérité (BLOCAGE / AVERTISSEMENT / INFO) avant de passer à la Couche 2.

---

## Couche 2 : Revue spécialisée

Sélectionner les agents en appliquant les règles de déclenchement au contenu du plan. Aucune saisie utilisateur requise — les déclencheurs sont objectifs.

**Pool d'agents de validation :**

| Agent | Déclencheur | Modèle |
|-------|-------------|--------|
| `security-reviewer` | Auth, paiements, PII, RBAC, nouvelles APIs publiques | Opus |
| `db-migration-reviewer` | Nouvelles tables, colonnes, index ou fichiers de migration | Opus |
| `performance-reviewer` | Nouvelles requêtes, resolvers, routes ou dépendances ajoutées | Sonnet |
| `design-system-reviewer` | Nouveaux composants UI ou changements de style visuel | Sonnet |
| `ux-reviewer` | Nouvelles pages, formulaires, modales ou patterns d'interaction | Sonnet |
| `cross-platform-reviewer` | Changements touchant web et mobile, ou packages partagés | Sonnet |
| `native-app-reviewer` | Écrans mobiles, changements de package UI natif | Sonnet |
| `integration-reviewer` | Nouveaux services externes, bibliothèques ou config OTEL | Opus |

Lancer les agents déclenchés en parallèle (outil Task, run_in_background: true). Chaque agent reçoit : le fichier de plan, les ADRs pertinents, et des questions ciblées selon son domaine.

Surveiller via une boucle de polling TaskOutput. Rapporter la progression à l'utilisateur.

Chaque agent doit retourner des résultats structurés :
```
RÉSULTAT: [BLOCAGE|AVERTISSEMENT|INFO]
Emplacement: [section du plan ou référence de fichier]
Problème: [description concrète]
Risque: [ce qui casse si ce n'est pas adressé]
Suggestion: [correctif spécifique ou alternative]
```

---

## Phase de correction automatique

Fusionner les problèmes structurels de la Couche 1 + les résultats des spécialistes de la Couche 2 en une liste unique. Chaque problème doit être résolu. Pas d'exception.

**Trier chaque problème :**

**Catégorie A — Résolution automatique :**
- Le problème correspond à une décision ADR existante → citer l'ADR, marquer résolu
- Le problème correspond à un pattern confirmé dans PATTERNS.md → citer le pattern, marquer résolu
- Le problème résolvable depuis les premiers principes dans CLAUDE.md → appliquer la règle, marquer résolu

**Catégorie B — Nécessite une saisie humaine :**
- Nouvelle question architecturale non couverte par les décisions existantes
- ADRs en conflit sans précédent clair
- Blocage sans résolution évidente

Pour les éléments de Catégorie B : présenter le problème, expliquer pourquoi il ne peut pas être résolu automatiquement, proposer des options, attendre une décision. Enregistrer la décision dans la section `## Décisions` du plan et créer un nouvel ADR si c'est architecturalement significatif.

**Appliquer tous les correctifs en un seul lot** une fois que tous les problèmes sont triés. Mettre à jour le fichier de plan. Committer le plan mis à jour.

---

## Persistance des problèmes

Enregistrer chaque problème dans `docs/plans/metrics/{name}.json` sous `validation.issues` :

```json
{
  "id": "S-001",
  "layer": 1,
  "severity": "WARNING",
  "category": "test-coverage",
  "description": "Pas de tâche de test pour le nouveau gestionnaire de webhook",
  "reporting_agent": "structural",
  "triage": "A",
  "resolution_source": "first-principles",
  "resolution": "Tâche de test ajoutée dans la Couche 2 du plan"
}
```

Ces données alimentent `/plan-metrics` pour l'analyse de patterns dans le temps.

---

## Transition automatique

Si tous les problèmes sont résolus automatiquement (Catégorie A uniquement) : démarrer automatiquement `/plan-execute` sans demander.

Si une saisie humaine a été requise (Catégorie B) : demander "Tous les problèmes résolus. Prêt à exécuter ?" avant de continuer.

---

## Utilisation

```
/plan-validate
```

Reprend automatiquement le plan non commité le plus récent. Ou spécifier :

```
/plan-validate plan-user-authentication
```

## Sortie

```
Couche 1 : Validation structurelle...
  ✓ Format complet
  ✓ Dépendances valides
  ⚠ AVERTISSEMENT S-001 : Tâche de test manquante pour le gestionnaire de webhook
  ✓ Conforme à CLAUDE.md

Couche 2 : Déclenchement des agents spécialistes...
  → security-reviewer (changements auth détectés) [Opus]
  → db-migration-reviewer (nouvelle table users) [Opus]
  → performance-reviewer (nouvelle requête dans /api/users) [Sonnet]
  Surveillance... 1/3 terminé... 2/3 terminé... fait.

  BLOCAGE B-001 [security-reviewer] : Expiration JWT non validée sur l'endpoint de refresh
  AVERTISSEMENT B-002 [db-migration-reviewer] : La migration manque d'une stratégie de rollback

Phase de correction automatique :
  S-001 → résolu automatiquement (premiers principes : règle de couverture de tests)
  B-001 → NÉCESSITE UNE SAISIE (pas d'ADR existant pour la stratégie de refresh JWT)
  B-002 → résolu automatiquement (ADR-0003 : pattern de rollback de migration)

[Saisie utilisateur demandée pour B-001]
Décision enregistrée. ADR-0011 créé.

3 problèmes résolus. Plan mis à jour.
→ Démarrage automatique de /plan-execute
```

## Quand l'utiliser

Toujours — avant tout appel à `/plan-execute`. Le coût de la validation (0,20 $–3,00 $) est négligeable face au coût de découvrir des problèmes en cours d'exécution.

## Voir aussi

- [Pipeline Plan-Validate-Execute](../../guide/workflows/plan-pipeline.md)
- [Agent Revieweur d'intégration](../agents/integration-reviewer.md)
- [Agent Challengeur de plan](../agents/plan-challenger.md)
