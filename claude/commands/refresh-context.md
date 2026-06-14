# /refresh-context

Met à jour le système de contextes d'un projet existant sans tout reconstruire.
À utiliser quand la documentation a évolué depuis le dernier `/bootstrap-context`.

> Prérequis : `.claude/` doit déjà exister (généré par `/bootstrap-context`).

---

## Quand l'utiliser

- Nouveaux documents ajoutés dans `docs/`
- Documents supprimés ou déplacés
- Nouvelles features, intégrations ou conventions
- Les contextes existants semblent incomplets ou obsolètes

---

## Étape 1 — Lire l'état actuel

Lire sans modifier :
- `.claude/documentation-map.md` → cartographie actuelle
- `.claude/contexts/*.md` → contextes existants
- `.claude/project-analysis.md` → structure physique connue

---

## Étape 2 — Inventaire documentaire

Lister tous les fichiers sous la racine doc (`documentation-map.root`).
Comparer avec le contenu actuel de `documentation-map.md`.

Détecter :
- **Nouveaux documents** → absents de `documentation-map.md`
- **Documents supprimés** → référencés mais introuvables
- **Documents déplacés** → chemin incorrect dans `documentation-map.md`

---

## Étape 3 — Rapport de delta

Présenter et **attendre validation** :

```
NOUVEAUX DOCUMENTS DÉTECTÉS
- <catégorie proposée> : <chemin>

DOCUMENTS MANQUANTS (référencés mais introuvables)
- <chemin>

DOCUMENTS DÉPLACÉS
- ancien chemin → nouveau chemin

CONTEXTES POTENTIELLEMENT OBSOLÈTES
- <contexte> : référence <document> qui a changé
```

Si aucun delta : indiquer que le système est à jour et s'arrêter.

---

## Étape 4 — Mise à jour de documentation-map.md

Appliquer les changements validés :
- Ajouter les nouveaux documents dans la catégorie appropriée
- Supprimer les références invalides
- Corriger les chemins déplacés

Ne pas recréer le fichier — mettre à jour les entrées concernées uniquement.

---

## Étape 5 — Mise à jour des contextes

Pour chaque contexte dont la documentation a changé :
- Ajouter les références aux nouveaux documents pertinents
- Supprimer les références invalides

Ne pas recréer les contextes — mettre à jour les entrées concernées uniquement.

---

## Étape 6 — Mise à jour de project-analysis.md

Si de nouvelles couches, conventions ou dossiers ont été détectés :
- Mettre à jour uniquement les sections concernées

---

## Étape 7 — Rapport final

```
MIS À JOUR
documentation-map.md : <N> entrées modifiées
contexts/            : <liste des contextes mis à jour>
project-analysis.md  : <oui / non>

AUCUN CHANGEMENT
<liste des fichiers non modifiés>
```

---

## Ce que cette commande ne fait jamais

- Régénérer entièrement les fichiers existants
- Modifier les commandes projet (`implement-feature.md`, etc.)
- Toucher à `CLAUDE.md`
- Écraser des personnalisations manuelles
