---
name: autoresearch
description: "Boucle d'amélioration autonome — analyse les métriques du code source, génère les fichiers d'expérimentation, exécute des itérations pilotées par agent jusqu'à amélioration de la métrique"
usage: /autoresearch [--scaffold <loop-name>] [--run <loop-name>] [--status]
examples:
  - /autoresearch
  - /autoresearch --scaffold loop-remove-as-any
  - /autoresearch --run loop-remove-as-any
  - /autoresearch --status
---

# Autoresearch — Boucle d'Amélioration Autonome

Analyse les métriques de qualité du code source, propose des boucles d'amélioration et exécute des itérations autonomes par agent. Inspiré de [karpathy/autoresearch](https://github.com/karpathy/autoresearch) — adapté de la recherche ML à la qualité du code.

**Concept** : L'agent propose une modification du code, exécute la mesure, conserve la modification si la métrique s'est améliorée, revient en arrière via `git reset` dans le cas contraire, et répète jusqu'à arrêt manuel.

**Durée** : Scan ~30s | Par itération : selon le périmètre | Boucle : s'exécute indéfiniment jusqu'à arrêt

---

## Mode 1 : Scan (par défaut)

Mesurer l'état actuel, détecter les boucles existantes, proposer les prochaines actions.

### Instructions

Exécuter les métriques suivantes et afficher un tableau de propositions priorisées.

**Étape 1 : Mesurer les métriques du code source**

Adapter les patterns grep aux conventions de votre projet. Ce sont les valeurs par défaut TypeScript — ajustez selon votre stack.

```bash
# M1 : Déclarations de fonctions (préférer les fonctions fléchées)
M1=$(grep -r "export function " src/ --include="*.ts" --include="*.tsx" -l 2>/dev/null | wc -l | tr -d ' ')

# M2 : Déclarations d'interfaces (préférer les alias de types)
M2=$(grep -r "export interface " src/ --include="*.ts" --include="*.tsx" -l 2>/dev/null | wc -l | tr -d ' ')

# M3 : Désactivations ESLint
M3=$(grep -r "eslint-disable" src/ --include="*.ts" --include="*.tsx" -l 2>/dev/null | wc -l | tr -d ' ')

# M4 : Casts de type vers any
M4=$(grep -r " as any" src/ --include="*.ts" --include="*.tsx" -l 2>/dev/null | wc -l | tr -d ' ')

# M5 : Commentaires TODO
M5=$(grep -r "// TODO" src/ --include="*.ts" --include="*.tsx" -l 2>/dev/null | wc -l | tr -d ' ')
```

**Étape 2 : Détecter les boucles existantes**

```bash
for dir in scripts/autoresearch/loop-*/; do
  [ -d "$dir" ] || continue
  LOOP_NAME=$(basename "$dir")
  # Vérifier si la boucle a des résultats
  if [[ -f "$dir/results.tsv" ]]; then
    ITERS=$(wc -l < "$dir/results.tsv" | tr -d ' ')
    BEST=$(sort -t$'\t' -k2 -n "$dir/results.tsv" | head -1 | cut -f2)
    echo "ACTIVE:$LOOP_NAME:iterations=$ITERS:best=$BEST"
  else
    echo "SCAFFOLDED:$LOOP_NAME"
  fi
done
```

**Étape 3 : Afficher**

```
Scan Autoresearch — {date}

Métriques du code source :

| # | Boucle              | Métrique            | Actuel | Cible | Priorité | Risque |
|---|---------------------|---------------------|--------|-------|----------|--------|
| A | loop-remove-as-any  | casts `as any`      | {M4}   | 0     | P1       | FAIBLE |
| B | loop-eslint-disable | eslint-disable      | {M3}   | 0     | P2       | MOYEN  |
| C | loop-export-fn      | export function     | {M1}   | 0     | P1       | FAIBLE |
| D | loop-interface-type | export interface    | {M2}   | 0     | P1       | FAIBLE |
| E | loop-todo-comments  | commentaires TODO   | {M5}   | 0     | P3       | FAIBLE |

Boucles existantes : {boucles détectées ou "aucune pour l'instant"}

Prochaine étape recommandée (P1, risque FAIBLE) :
  /autoresearch --scaffold loop-remove-as-any
  Puis écrire program.md, créer un worktree, et lancer la boucle.
```

---

## Mode 2 : `--scaffold <loop-name>`

Générer les 3 fichiers mécaniques d'une boucle. **Ne génère pas `program.md`** — écrivez-le vous-même pour encoder les contraintes spécifiques au projet.

### Instructions

Créer les fichiers suivants dans `scripts/autoresearch/{loop-name}/` :

**`measure.sh`** — le harnais d'évaluation (métrique unique, retourne un entier) :

```bash
#!/usr/bin/env bash
# measure.sh — {loop-name}
# Retourne un entier. Direction : plus bas = meilleur (sauf si la boucle cible la couverture/le score).
set -euo pipefail
grep -r "PATTERN" src/ --include="*.ts" --include="*.tsx" 2>/dev/null | wc -l | tr -d ' '
```

**`direction.txt`** — direction d'amélioration :

```
lower
```

(Utiliser `higher` pour les métriques comme la couverture de tests ou le score de qualité.)

**`files.txt`** — périmètre sur lequel l'agent doit opérer :

```
src/
```

Après la création des fichiers, afficher :

```
Boucle générée : scripts/autoresearch/{loop-name}/

  measure.sh  : {pattern} dans {scope} → {N} occurrences aujourd'hui
  direction   : lower (moins = mieux)
  files.txt   : src/

Métrique actuelle : {N} (cible : 0)

Prochaines étapes :
  1. Écrire program.md — comportement de l'agent, contraintes, ce qu'il peut/ne peut pas toucher
     Référence : scripts/autoresearch/loop-remove-as-any/program.md
  2. Créer un worktree : /worktree feature/autoresearch-{loop-name}
  3. Se placer dans le worktree
  4. bash scripts/autoresearch/runner.sh {loop-name} 0 15
```

---

## Mode 3 : `--run <loop-name>`

Exécuter la boucle autonome. L'agent tourne indéfiniment — arrêtez-le manuellement quand vous êtes satisfait.

### Instructions

**Vérifier les prérequis :**

```bash
[ -f "scripts/autoresearch/{loop-name}/measure.sh" ] || { echo "ERREUR: measure.sh manquant. Lancez --scaffold d'abord."; exit 1; }
[ -f "scripts/autoresearch/{loop-name}/program.md" ] || { echo "ERREUR: program.md manquant. Écrivez-le d'abord — il encode vos contraintes."; exit 1; }
```

**Lancer la boucle :**

Lire `scripts/autoresearch/{loop-name}/program.md` en entier avant de commencer. Puis entrer dans le cycle suivant — répéter jusqu'à arrêt :

```
ITÉRATION DE BOUCLE #{N}

1. Métrique actuelle : bash scripts/autoresearch/{loop-name}/measure.sh
2. Lire les contraintes de program.md
3. Proposer UNE modification ciblée des fichiers dans files.txt
4. Appliquer la modification
5. Re-mesurer : bash scripts/autoresearch/{loop-name}/measure.sh
6. Évaluer :
   - direction=lower ET nouveau < précédent → GARDER (git add -p && git commit -m "autoresearch: {description}")
   - sinon → ANNULER (git checkout -- .)
7. Consigner dans results.tsv : {timestamp}\t{métrique}\t{statut}\t{description}
8. Continuer à l'itération #{N+1}
```

**Critères d'arrêt** (issus de program.md) :
- La métrique atteint la cible (ex. : 0)
- Plus aucune modification mécanique possible
- L'utilisateur arrête manuellement le processus

**Afficher chaque itération :**

```
[iter #{N}] métrique: {avant} → {après} | {GARDÉ/ANNULÉ} | {description de la modification}
```

---

## Mode 4 : `--status`

Afficher l'état de toutes les boucles du projet.

### Instructions

```bash
for dir in scripts/autoresearch/loop-*/; do
  [ -d "$dir" ] || continue
  NAME=$(basename "$dir")
  CURRENT=$(bash "$dir/measure.sh" 2>/dev/null || echo "?")
  ITERS=$([ -f "$dir/results.tsv" ] && wc -l < "$dir/results.tsv" | tr -d ' ' || echo "0")
  KEPT=$([ -f "$dir/results.tsv" ] && grep -c "KEPT" "$dir/results.tsv" || echo "0")
  echo "$NAME | actuel: $CURRENT | iters: $ITERS | gardés: $KEPT"
done
```

Afficher :

```
État Autoresearch

| Boucle               | Actuel | Itérations | Gardés | Statut      |
|----------------------|--------|------------|--------|-------------|
| loop-remove-as-any   | {N}    | {N}        | {N}    | ACTIVE      |
| loop-export-fn       | {N}    | 0          | 0      | SCAFFOLDED  |
```

---

## Écrire `program.md` — Le Fichier le Plus Important

`program.md` est le contrat de comportement de l'agent. Écrivez-le vous-même — ne le générez jamais automatiquement. Il doit encoder ce que l'agent peut ou ne peut pas toucher dans votre code source spécifique.

**Structure minimale :**

```markdown
# Programme : {loop-name}

## Objectif
Réduire `{métrique}` dans `src/` à 0. Une modification mécanique par itération.

## Mesure
bash scripts/autoresearch/{loop-name}/measure.sh
Plus bas = mieux. Cible : 0.

## Ce que vous POUVEZ faire
- Remplacer `export function X(` par `export const X = (`
- Garder la signature de fonction identique

## Ce que vous NE POUVEZ PAS faire
- Modifier les fichiers de test
- Changer les signatures de fonctions
- Toucher des fichiers en dehors de src/
- Effectuer plusieurs modifications par itération

## Arrêter quand
- Métrique = 0
- Plus aucun remplacement mécanique possible
```

---

## Le Pattern (Contexte)

Cette commande implémente le pattern de **boucle autoresearch** de [karpathy/autoresearch](https://github.com/karpathy/autoresearch) :

| Recherche ML (karpathy) | Qualité du Code (cette commande) |
|-------------------------|----------------------------------|
| Modifier `train.py` | Modifier les fichiers `src/` |
| Mesurer `val_bpb` | Mesurer le nombre grep |
| Budget GPU de 5 minutes | Une modification atomique par itération |
| Garder si val_bpb s'améliore | Garder si le compteur diminue |
| `git reset` sinon | `git checkout -- .` sinon |
| `program.md` = skill de l'agent | `program.md` = skill de l'agent |

Insight clé : une métrique fixe et objective + git comme mécanisme de rollback = itération autonome sécurisée. L'agent n'a jamais besoin d'approbation humaine par modification car toute mauvaise modification est automatiquement annulée.

---

## Utilisation

**Scanner et proposer des boucles :**
```
/autoresearch
```

**Générer les fichiers pour une boucle spécifique :**
```
/autoresearch --scaffold loop-remove-as-any
```

**Lancer la boucle autonome (après avoir écrit program.md) :**
```
/autoresearch --run loop-remove-as-any
```

**Vérifier l'état de toutes les boucles :**
```
/autoresearch --status
```

$ARGUMENTS
