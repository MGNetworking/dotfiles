---
description: Audite tous les fichiers prompt-generateur-*.md du projet. Vérifie la complétude de la structure, le respect de la philosophie produit/technique, et la cohérence interne de chaque fichier. Signale les problèmes détectés et propose des corrections.
allowed-tools: Read, Glob, Grep
---

# Audit des fichiers prompts

Tu es chargé d'auditer tous les fichiers `prompt-generateur-*.md` présents dans ce projet.

## Étape 1 — Découverte des fichiers

Liste tous les fichiers correspondant au pattern `prompt-generateur-*.md` à la racine du projet.
Pour chaque fichier trouvé, effectue l'audit complet décrit ci-dessous.

## Étape 2 — Audit de structure (pour chaque fichier)

Vérifie la présence des 4 sections obligatoires définies dans `CLAUDE.md` :

- [ ] `## Rôle de ce document` — présent et décrit clairement la nature du fichier
- [ ] `## Ce que le document produit doit contenir` — liste les éléments attendus
- [ ] `## Ce que le document ne doit jamais contenir` — liste les exclusions explicites
- [ ] `## Prompt` — présent avec le prompt encadré par des triple backticks

## Étape 3 — Audit du prompt (pour chaque fichier)

Lis le contenu du prompt et vérifie :

- [ ] L'instruction "une par une / attends ma réponse" est présente
- [ ] Les règles de validation automatique sont présentes avant la livraison du document
- [ ] Si ce n'est pas le premier fichier du workflow : le prompt exige explicitement le document précédent avant de commencer

## Étape 4 — Audit de la philosophie

**Pour `prompt-generateur-prd.md` :**

- [ ] Aucune technologie, framework ou langage n'est mentionné dans le prompt
- [ ] Toutes les questions sont formulées du point de vue utilisateur/produit
- [ ] La structure du document généré ne contient aucune décision technique
- [ ] Les critères de succès ET d'échec sont présents dans la structure générée
- [ ] La règle de validation couvre les critères de succès ET d'échec

**Pour `prompt-generateur-cadrage-technique.md` :**

- [ ] Chaque question technique demande une justification par rapport au PRD
- [ ] Aucune question n'est rhétorique (le LLM ne doit pas se répondre à lui-même)
- [ ] Pour les choix architecturaux, le LLM propose des options et demande validation
- [ ] La structure du document généré commence par les références au PRD
- [ ] La règle de validation vérifie la justification de chaque décision par le PRD

## Étape 5 — Rapport

Pour chaque fichier, produis un tableau :

| Critère | Statut       | Remarque |
| ------- | ------------ | -------- |
| ...     | ✅ / ⚠️ / ❌ | ...      |

Puis un score global `/10` et la liste des problèmes détectés avec leur localisation (`fichier:ligne`).

## Étape 6 — Conclusion

- Si tout est conforme : indique que les fichiers sont validés.
- Si des problèmes sont détectés : liste-les clairement et demande si tu dois les corriger.
