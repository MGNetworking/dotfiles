# Gabarit — Commandes projet

Ce gabarit est utilisé par `/bootstrap-context` pour générer les commandes adaptées au projet détecté.
Les commandes générées vivent dans `.claude/commands/` du projet cible — jamais dans les dotfiles.

## Principe

Les commandes projet sont les seules à connaître à la fois :
- le contexte documentaire (via `.claude/contexts/`)
- la structure physique (via `.claude/project-analysis.md`)

Elles orchestrent la lecture, pas la connaissance.

---

## Flux universel (commun aux 3 commandes)

```
1. Identifier l'intention (fonctionnalité, domaine, périmètre)
2. Lire .claude/contexts/<contexte-pertinent>.md → liste des docs à lire
3. Lire .claude/documentation-map.md             → résoudre les chemins documentaires
4. Lire chaque fichier doc référencé             → comprendre le QUOI (métier)
5. Lire .claude/project-analysis.md              → comprendre le OÙ (technique)
6. Scanner le code dans les zones identifiées
7. Agir
```

La compréhension métier (étapes 2-4) précède toujours la compréhension technique (étape 5).

---

## implement-feature.md

```markdown
# /implement-feature <fonctionnalité>

## Flux

1. Lire `.claude/contexts/business.md`      → quels docs métier lire
2. Lire `.claude/contexts/architecture.md`  → quels docs d'implémentation lire
3. Lire `.claude/documentation-map.md`      → résoudre les chemins documentaires
4. Lire les fichiers doc référencés         → comprendre le QUOI (métier + patterns)
5. Lire `.claude/project-analysis.md`       → comprendre le OÙ (couches, conventions)
6. Scanner le code existant dans les zones identifiées
7. Implémenter en respectant les conventions détectées

## Règles

- Respecter les conventions de nommage de `project-analysis.md`
- Ne jamais créer de fichier hors du périmètre demandé
- Stack : <STACK_DÉTECTÉE>
- Framework de test : <TEST_FRAMEWORK_DÉTECTÉ>
```

---

## review-feature.md

```markdown
# /review-feature <fonctionnalité>

## Flux

1. Lire `.claude/contexts/business.md`      → quels docs métier lire
2. Lire `.claude/contexts/architecture.md`  → quels docs d'implémentation lire
3. Lire `.claude/contexts/quality.md`       → quels docs de validation lire
4. Lire `.claude/documentation-map.md`      → résoudre les chemins documentaires
5. Lire les fichiers doc référencés         → comprendre le QUOI (référence de conformité)
6. Lire `.claude/project-analysis.md`       → comprendre le OÙ (conventions attendues)
7. Scanner le code de la fonctionnalité
8. Comparer : code vs documentation de référence

## Critères de revue

- Respect des règles métier (source : documentation)
- Respect des patterns d'architecture (source : documentation)
- Respect des conventions (source : project-analysis.md)
- Couverture de tests (framework : <TEST_FRAMEWORK_DÉTECTÉ>)
```

---

## generate-tests.md

```markdown
# /generate-tests <fonctionnalité>

## Flux

1. Lire `.claude/contexts/business.md`   → quels docs métier lire
2. Lire `.claude/contexts/quality.md`    → quels docs de validation lire
3. Lire `.claude/documentation-map.md`   → résoudre les chemins documentaires
4. Lire les fichiers doc référencés      → comprendre le QUOI (invariants, cas limites)
5. Lire `.claude/project-analysis.md`    → comprendre le OÙ (tests existants, conventions)
6. Scanner le code à tester
7. Générer les tests

## Stack de test

- Framework : <TEST_FRAMEWORK_DÉTECTÉ>
- Organisation : <ORGANISATION_TESTS_DÉTECTÉE>
- Convention de nommage : <CONVENTION_TESTS_DÉTECTÉE>

## Types de tests à générer

- Cas nominaux (chemin heureux)
- Invariants métier (violations → exceptions attendues)
- Cas limites (valeurs frontières)
```

---

## Instructions pour bootstrap-context

Lors de la génération :

1. Remplacer `<STACK_DÉTECTÉE>` par la valeur détectée dans `project-analysis.md`
2. Remplacer `<TEST_FRAMEWORK_DÉTECTÉ>` par le framework de test détecté
3. Remplacer `<ORGANISATION_TESTS_DÉTECTÉE>` par la structure des dossiers tests
4. Remplacer `<CONVENTION_TESTS_DÉTECTÉE>` par le pattern de nommage des tests
5. Adapter les contextes référencés à ceux effectivement créés (si `quality.md` absent, retirer la référence)
