---
name: plan-start
description: "Commande de planification en 5 phases : analyse PRD, revue de design, décisions techniques, équipe de recherche dynamique, métriques. Produit un plan d'implémentation complet + ADRs avant d'écrire la moindre ligne de code."
---

# Plan Start — Planification en 5 phases

Analyser la demande et produire un plan d'implémentation complet à travers des phases structurées. Aucun code n'est écrit. Chaque décision significative est enregistrée. Lancer `/clear` après cette commande avant de lancer `/plan-validate`.

---

## Phase 1 : Analyse PRD & Design

### Étape 1.1 — Analyse PRD

*Passer si aucun PRD n'existe (refactoring, changement d'infra, correction de bug).*

Lire tous les fichiers PRD et `docs/INFORMATION_ARCHITECTURE.md` si présent. Scanner le codebase pour comprendre le statut d'implémentation actuel.

Faire remonter les résultats dans 3 catégories :

**Exigences manquantes** — critères d'acceptation absents ou incomplets
**Exigences ambiguës** — éléments avec plusieurs interprétations valides
**Problèmes de conformité** — implications de sécurité, confidentialité des données, contrats d'API

Pour chaque résultat : présenter les options avec des pour/contre concrets. Discuter avec l'utilisateur. Enregistrer chaque décision dans le fichier de plan sous une section `## Décisions` avant de continuer. Ne pas avancer sur des ambiguïtés non résolues.

### Étape 1.2 — Analyse du design

*Passer si aucun changement UI n'est dans le périmètre.*

Lire : `DESIGN_SYSTEM.md`, ADRs UX existants, règles UX de CLAUDE.md.

Produire des spécifications pour :
- **Inventaire des écrans** : nouveaux/modifiés, placement des routes, audit de réutilisation des composants
- **Catalogue d'états** : vide, chargement, rempli, erreur, et états partiels pour chaque élément interactif
- **Spécifications d'interaction** : flux utilisateurs (chemin nominal + alternatives), comportement focus/clavier
- **Spécifications d'animation** : mapper chaque interaction aux keyframes existants ou en spécifier de nouveaux, inclure les fallbacks `prefers-reduced-motion`
- **Comportement responsive** : points de rupture, décisions de divergence web/mobile
- **Accessibilité** : sélection de pattern WAI-ARIA, régions live, visibilité des erreurs

Créer des ADRs de design pour les décisions UX significatives (choix de pattern d'interaction, nouvelle convention d'animation, divergence de plateforme). Enregistrer les choix de mise en page mineurs directement dans le fichier de plan.

---

## Phase 2 : Analyse technique

Lancer 1 à 2 agents d'exploration pour une recherche ciblée dans le codebase. Les lancer en arrière-plan via l'outil Task.

Pendant que les agents tournent, vérifier :
- Les ADRs existants dans `docs/adr/` — si 3+ ADRs confirment une décision → résoudre automatiquement sans demander
- PATTERNS.md — appliquer directement les patterns confirmés

Quand les agents retournent : présenter les décisions d'architecture avec 2 à 3 options chacune, des pour/contre concrets, et une recommandation. Demander l'avis de l'utilisateur sur chaque décision non résolue.

Pour chaque décision significative :
1. Créer `docs/adr/ADR-XXXX.md` en utilisant le format Nygard standard (Contexte / Décision / Statut / Conséquences)
2. Mettre à jour `docs/adr/PATTERNS.md` avec la nouvelle observation

---

## Phase 3 : Évaluation du périmètre

Appliquer les règles de déclenchement pour déterminer quels agents de recherche sont nécessaires. Présenter l'équipe proposée avec la justification de chaque inclusion.

**Pool d'agents de recherche :**

| Agent | Déclencheur | Modèle |
|-------|-------------|--------|
| `code-explorer` | Toujours | Sonnet |
| `arch-researcher` | Les changements touchent 2+ couches architecturales | Sonnet |
| `database-analyst` | Tout changement de schéma BDD | Sonnet |
| `security-analyst` | Auth, paiements, PII, RBAC, rate limiting | Opus |
| `test-analyzer` | Fonctionnalité non triviale (pas seulement un bug fix) | Sonnet |
| `cross-platform-specialist` | Parité web + mobile requise | Sonnet |
| `native-app-specialist` | Les tâches touchent le package UI mobile/natif | Sonnet |
| `design-system-researcher` | Changements UI dans le périmètre | Sonnet |
| `dependency-researcher` | Nouveaux packages à ajouter | Sonnet |
| `devops-specialist` | Changements Docker, variables d'env, CI/CD | Sonnet |
| `integration-researcher` | Nouveaux services, bibliothèques, config OTEL | Opus |
| `planning-coordinator` | Toujours, quand 2+ agents sélectionnés | Opus |

**Étiquettes de niveau** (descriptives, non prescriptives) :
- Niveau 0 (0 agents) : Solo — recherche inline, pas de spawn
- Niveau 1 (1-3 agents) : Ciblé
- Niveau 2 (4-6 agents) : Standard
- Niveau 3 (7-9 agents) : Complet
- Niveau 4 (10+ agents) : Spectre complet

Dire à l'utilisateur : "Je recommande une équipe de **[Niveau N - Étiquette]** : [liste d'agents avec justification en une ligne chacun]. Tu veux ajouter ou retirer des agents ?"

Attendre l'approbation avant la Phase 4.

---

## Phase 4 : Recherche & Création du plan

**Niveau 0** : Effectuer la recherche inline. Écrire le plan directement sans lancer d'agents.

**Niveau 1+** : Lancer les agents approuvés en parallèle via l'outil Task (run_in_background: true). Pour chaque agent, fournir :
- Son périmètre de recherche spécifique
- Les fichiers/zones pertinents à investiguer
- Les questions auxquelles il doit répondre

Surveiller les agents via une boucle de polling TaskOutput. Rapporter la progression : "3/6 agents terminés..."

Quand tous les agents retournent : si `planning-coordinator` a été lancé, lui envoyer tous les rapports d'agents et lui faire synthétiser le plan final. Sinon, synthétiser directement.

**Structure du fichier de plan** (`docs/plans/plan-{name}.md`) :

```markdown
# Plan : {feature-name}
Créé le : {date} | Branche : {branch-name} | Niveau : {N}

## Résumé
Un paragraphe : ce qui est implémenté et pourquoi.

## Décisions
Décisions enregistrées pendant la Phase 1 (analyse PRD).

## Architecture
ADRs créés, patterns appliqués, choix architecturaux effectués.

## Tâches
Liste de tâches ordonnée avec couches (1 = fondation, 2 = dépend de 1, etc.)

### Couche 1
- [ ] Tâche A — description, fichiers concernés, critères d'acceptation
- [ ] Tâche B — description, fichiers concernés, critères d'acceptation

### Couche 2
- [ ] Tâche C — dépend de A — description, fichiers concernés, critères d'acceptation

## Plan de test
Comment chaque tâche sera vérifiée. Les tâches TDD sont marquées explicitement.

## Vérification d'intégration
Commandes de smoke test à lancer après l'exécution (si backend/services dans le périmètre).

## Hors périmètre
Ce que ce plan n'adresse explicitement pas.
```

Committer : fichier de plan + fichiers ADR + manifestes de rapports d'agents.

---

## Phase 5 : Finalisation des métriques

Enregistrer les horodatages, durées des phases, nombre d'agents et estimations de coût dans `docs/plans/metrics/{name}.json`. Committer.

---

## Transition automatique

Si la Phase 1 n'a produit aucune ambiguïté non résolue et la Phase 2 aucune décision non résolue : démarrer automatiquement `/plan-validate` sans demander.

Si une discussion humaine a eu lieu : demander "Prêt à valider ce plan ?" avant de continuer.

---

## Utilisation

```
/plan-start
```

Fournir la description de la fonctionnalité ou pointer vers un fichier PRD quand demandé. La commande gère le reste de manière interactive.

## Quand l'utiliser

Utiliser pour toute fonctionnalité non triviale : tout ce qui touche plus de 2 fichiers, implique des décisions d'architecture, ou pour laquelle une erreur de planification serait coûteuse à corriger.

Pour les changements simples (fautes de frappe, refactorings triviaux) : utiliser le mode `/plan` à la place.

## Voir aussi

- [Pipeline Plan-Validate-Execute](../../guide/workflows/plan-pipeline.md)
- [Agent Coordinateur de planification](../agents/planning-coordinator.md)
- [Agent Rédacteur d'ADR](../agents/adr-writer.md)
