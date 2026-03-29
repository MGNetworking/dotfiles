---
name: plan-execute
description: "Exécuter un plan validé : isolation par worktree, scaffolding TDD, agents parallèles par niveau, verrou qualité avec smoke test, création et fusion de PR. Gère tout jusqu'à la PR fusionnée."
---

# Plan Execute — Exécution jusqu'à la PR fusionnée

Exécuter le plan validé dans un worktree isolé. Lancer des agents par tâche, vérifier la qualité, créer et fusionner la PR. Gère tout jusqu'au nettoyage.

Lancer `/clear` avant cette commande.

---

## Prérequis

Un plan validé doit exister dans `docs/plans/plan-{name}.md` avec tous les problèmes résolus (sortie de `/plan-validate`).

---

## Étape 1 : Mise en place du worktree

Créer un worktree git isolé :

```bash
git worktree add .worktrees/{plan-name} -b feature/{plan-name}
```

Toute l'exécution se passe à l'intérieur du worktree. La branche principale reste propre tout au long.

---

## Étape 2 : Scaffolding TDD

*Uniquement pour les tâches marquées TDD dans le plan.*

Pour chaque tâche TDD, avant toute implémentation :
1. Écrire le(s) test(s) en échec qui définissent les critères d'acceptation
2. Lancer les tests pour confirmer qu'ils échouent (rouge)
3. Committer les tests en échec
4. Marquer le fichier de test dans la tâche pour que l'agent d'implémentation le trouve

Ne pas écrire de code d'implémentation dans cette étape.

---

## Étape 3 : Exécution parallèle par niveau

Parser la liste des tâches depuis le plan. Regrouper les tâches par couche (Couche 1 = fondation, Couche 2 = dépend de la Couche 1, etc.).

**Pour chaque couche :**
1. Identifier toutes les tâches de la couche
2. Lancer un agent par tâche en parallèle (outil Task, run_in_background: true)
3. Chaque agent reçoit : sa description de tâche, les fichiers à modifier, les critères d'acceptation, et les ADRs pertinents
4. Surveiller tous les agents via une boucle de polling TaskOutput
5. Chaque agent commit à la fin de la tâche : `git commit -m "feat: {description-de-tâche}"`
6. Attendre que toutes les tâches de la couche soient terminées avant de démarrer la couche suivante

**Détection de dérive** : après chaque couche, comparer les changements réels avec la spécification du plan. Si l'implémentation dévie significativement du plan (nouveaux fichiers absents du plan, fichiers du plan non touchés), signaler et demander comment procéder. Ne pas continuer silencieusement en cas de dérive.

**Instructions pour les agents de chaque tâche :**
```
Tu implémentes une tâche d'un plan validé.
Tâche : {description}
Fichiers à modifier : {liste de fichiers}
Critères d'acceptation : {critères}
ADRs pertinents : {liste d'ADRs}

Principes fondamentaux :
- Construire à l'état de l'art. Pas de contournements, pas de patterns hérités.
- Corriger au bon niveau architectural, jamais avec des hacks au niveau composant.
- Si tu découvres que le plan est incorrect ou manque de contexte, arrête et signale — ne pas improviser l'architecture.

Committe tes changements une fois terminé avec le message : "feat: {description-de-tâche}"
```

---

## Étape 4 : Verrou qualité

Lancer en parallèle :
- Linter
- Vérificateur de types (si applicable)
- Suite de tests complète

Si tout passe : procéder au smoke test.

Si l'un échoue : lancer un agent de débogage `quality-fixer` avec la sortie d'échec. Il a droit à **3 tentatives de correction automatique**. Après chaque tentative, relancer le verrou qualité. Si toujours en échec après 3 tentatives : arrêter, rapporter l'échec avec la sortie d'erreur complète, et attendre l'intervention humaine.

**Smoke test d'intégration** *(passer pour les plans purement frontend ou docs-only)* :

Lancer les commandes smoke définies dans la section `## Vérification d'intégration` du plan. De plus :
- Si GraphQL : lancer une sonde d'introspection pour vérifier que le schéma est accessible
- Si services Docker : scanner les logs des conteneurs pour les entrées de niveau ERROR
- Si nouvelles routes API : vérifier que chacune retourne les codes de statut attendus

Les échecs de smoke test sont débogués par un agent `quality-fixer-smoke` avec la même limite de 3 tentatives.

---

## Étape 5 : Documentation pré-PR

*Dans le worktree, avant de créer la PR.*

**Réconciliation PRD** : comparer le comportement implémenté avec le PRD original. Noter toute déviation ou ajout découvert pendant l'implémentation. Mettre à jour le PRD avec les valeurs réelles. Ces mises à jour sont incluses dans la même PR que la fonctionnalité.

**Archivage du plan** : déplacer `docs/plans/plan-{name}.md` vers `docs/plans/completed/plan-{name}.md`. Mettre à jour l'en-tête de statut.

Committer les mises à jour de documentation : `docs: reconcile PRD and archive plan for {feature-name}`.

---

## Étape 6 : Push et PR

Pousser la branche du worktree et créer la PR :

```bash
git push origin feature/{plan-name}
gh pr create \
  --title "{feature-name}: {résumé en une ligne depuis le plan}" \
  --body "$(cat .pr-body.md)"
```

Template du corps de PR :
```markdown
## Résumé
{paragraphe de résumé du plan}

## Changements
{généré automatiquement depuis la liste des tâches : une puce par tâche avec les fichiers concernés}

## ADRs
{liste des ADRs créés pendant ce plan}

## Plan de test
{depuis la section plan de test du plan}

## Résultats du smoke test
{sortie de la vérification d'intégration}
```

Fusionner avec squash :
```bash
gh pr merge --squash --delete-branch
```

---

## Étape 7 : Métriques post-fusion

Revenir sur develop/main. Mettre à jour `docs/plans/metrics/{name}.json` avec les données d'exécution :
- Nombre de tâches et décomposition par couche
- Nombre de tâches TDD
- Statistiques du diff (fichiers modifiés, lignes ajoutées/supprimées)
- Résultats du verrou qualité (succès/échec, tentatives de correction)
- Résultats du smoke test
- Score de dérive (0-1, dans quelle mesure l'implémentation a suivi le plan)
- Données de PR (numéro, commit de fusion, horodatage)

Committer la mise à jour des métriques.

---

## Étape 8 : Nettoyage du worktree

```bash
git worktree remove .worktrees/{plan-name}
```

---

## Utilisation

```
/plan-execute
```

Reprend le plan validé le plus récent. Ou spécifier :

```
/plan-execute plan-user-authentication
```

## Sortie

```
Mise en place du worktree : .worktrees/user-authentication
Branche : feature/user-authentication

Scaffolding TDD : 2 tâches marquées TDD
  ✓ Tests en échec écrits pour : auth-token-validation
  ✓ Tests en échec écrits pour : refresh-token-rotation
  Commité : "test: failing tests for auth pipeline (TDD)"

Exécution Couche 1 (3 tâches, parallèle)...
  [agent-1] Implémentation : Service de génération de token JWT
  [agent-2] Implémentation : Modèle de session utilisateur
  [agent-3] Implémentation : Middleware d'auth
  ✓ Couche 1 terminée. 3 commits.

Vérification de dérive : Couche 1... ✓ Aucune dérive détectée.

Exécution Couche 2 (2 tâches, parallèle)...
  [agent-4] Implémentation : Endpoint de login
  [agent-5] Implémentation : Endpoint de refresh
  ✓ Couche 2 terminée. 2 commits.

Verrou qualité...
  ✓ Lint passé
  ✓ Vérification de types passée
  ✓ Tests : 47 passés, 0 échoués

Smoke test...
  ✓ Introspection GraphQL : OK
  ✓ POST /api/auth/login : 200
  ✓ POST /api/auth/refresh : 200

Documentation pré-PR...
  ✓ PRD réconcilié (1 déviation mineure notée)
  ✓ Plan archivé dans docs/plans/completed/

PR créée : #142 "user-authentication: JWT auth with refresh token rotation"
PR fusionnée (squash). Branche supprimée.

Métriques commitées. Worktree nettoyé.
✅ Fonctionnalité terminée.
```

## Quand l'utiliser

Après que `/plan-validate` confirme que tous les problèmes sont résolus. Ne jamais sauter la validation — exécuter un plan non validé saute la revue indépendante qui détecte en moyenne ~18 problèmes.

## Voir aussi

- [Pipeline Plan-Validate-Execute](../../guide/workflows/plan-pipeline.md)
- [Commande Git Worktree](./git-worktree.md)
- [TDD avec Claude](../guide/workflows/tdd-with-claude.md)
