---
name: investigate
description: "Débogage systématique par recherche de cause racine — trouver la cause avant d'écrire un correctif"
---

# Investigate — Débogage par cause racine

Débogage systématique avec investigation obligatoire de la cause racine avant toute modification du code.

**Loi d'airain : PAS DE CORRECTIF SANS INVESTIGATION DE LA CAUSE RACINE D'ABORD.**

Corriger les symptômes crée un débogage en mode whack-a-mole. Chaque correctif qui ne traite pas la cause racine rend le prochain bug plus difficile à trouver.

## Instructions

### Phase 1 : Collecter les symptômes

Rassembler tout le contexte disponible avant de formuler une hypothèse.

1. Lire en intégralité les messages d'erreur, les stack traces et les étapes de reproduction
2. Poser UNE question ciblée si l'utilisateur n'a pas fourni suffisamment de contexte :
   - "Quel est le message d'erreur exact ?"
   - "Pouvez-vous reproduire cela de façon consistante ?"
   - "Quand est-ce que cela a commencé ?"
3. Identifier le composant affecté et ses frontières

**Résultat** : Un énoncé précis du symptôme — ce qui échoue, quand, avec quelle erreur.

---

### Phase 2 : Lire le code

Retracer le chemin du code depuis le symptôme jusqu'aux causes potentielles. Ne pas deviner.

```bash
# Trouver toutes les références au composant défaillant
grep -rn "ComponentName\|function_name\|error_string" src/ --include="*.{ts,js,py,rb,go}" | head -30

# Vérifier les modifications récentes sur les fichiers affectés
git log --oneline -15 -- <affected-file>

# Lire le diff réel de chaque commit récent
git show <commit-hash> -- <affected-file>
```

Utiliser Grep pour trouver toutes les références, Read pour comprendre la logique. Ne jamais sauter la lecture du code.

---

### Phase 3 : Vérifier les modifications récentes

```bash
# Ce qui a changé récemment dans tout le dépôt
git log --oneline -20

# Modifications des fichiers liés au symptôme
git log --oneline -20 -- <affected-files>

# Diff complet des N derniers commits
git diff HEAD~3..HEAD -- <affected-directory>
```

**Question clé** : Est-ce que ça fonctionnait avant ? Si oui, la cause racine est dans le diff récent.

- Régression = la cause racine est dans les modifications, pas dans le code d'origine
- Toujours cassé = problème architectural ou hypothèse incorrecte

---

### Phase 4 : Reproduire

Avant de corriger quoi que ce soit, confirmer qu'on peut déclencher le bug de façon déterministe.

```bash
# Lancer la suite de tests ciblant la zone affectée
npm test -- --testPathPattern="affected-module" 2>/dev/null || \
pnpm test -- --testPathPattern="affected-module" 2>/dev/null || \
pytest tests/test_affected.py -v 2>/dev/null

# Vérifier les logs si disponibles
tail -50 logs/error.log 2>/dev/null || \
journalctl -u app-service --lines=50 2>/dev/null
```

Si la reproduction est impossible : rassembler plus de preuves. Ne pas corriger ce qu'on ne peut pas vérifier comme étant cassé.

---

### Phase 5 : Analyse des patterns

Faire correspondre le symptôme aux patterns de bugs connus :

| Pattern | Signature | Où chercher |
|---------|-----------|-------------|
| Race condition | Échecs intermittents, dépendants du timing | Accès concurrent à un état partagé, ordre des async/await |
| Propagation de null | TypeError, undefined is not a function | Guards manquants sur les valeurs optionnelles, réponses API non vérifiées |
| Corruption d'état | Données incohérentes, mises à jour partielles | Transactions, callbacks, mutation d'objets partagés |
| Échec d'intégration | Timeout, forme de réponse inattendue | Appels d'API externes, frontières de services, changements de schéma |
| Dérive de configuration | Fonctionne en local, échoue en staging/prod | Variables d'env, feature flags, état de la base de données, secrets manquants |
| Cache périmé | Affiche d'anciennes données, se corrige au redémarrage | Redis, CDN, cache navigateur, mémoïsation |
| Erreur d'import/module | "Cannot find module", "is not a function" | Versions de paquets, imports circulaires, artefacts de build |

Vérifier aussi :
- `TODOS.md` ou le tracker de tickets pour les problèmes connus dans la même zone
- `git log` pour les correctifs précédents dans les mêmes fichiers — des bugs récurrents au même endroit sont un signe architectural

**Recherche externe :** Si le pattern ne correspond pas, rechercher :
`{framework} {type-d-erreur-generique}` — supprimer les noms d'hôtes, chemins de fichiers, données internes. Chercher la catégorie d'erreur, pas le message brut.

**Formuler une hypothèse** : "Hypothèse de cause racine : [affirmation spécifique et testable sur ce qui est faux et pourquoi]"

---

### Phase 6 : Test de l'hypothèse

Avant d'écrire un correctif, vérifier l'hypothèse.

1. **Confirmer l'hypothèse** : Ajouter un log temporaire, une assertion ou une sortie de débogage à la cause racine supposée. Lancer la reproduction. Les preuves correspondent-elles ?

```javascript
// Exemple : diagnostic temporaire
console.log('[DEBUG investigate]', { value, expected, type: typeof value });
```

```python
# Exemple : diagnostic temporaire
import sys; print(f'[DEBUG investigate] value={value!r} type={type(value)}', file=sys.stderr)
```

2. **Si l'hypothèse est fausse** : Rassembler plus de preuves. Retourner à la Phase 2. Ne pas deviner.

3. **Règle des 3 tentatives** : Si 3 hypothèses échouent, STOP. Il s'agit peut-être d'un problème architectural.

   Présenter ceci à l'utilisateur :
   ```
   3 hypothèses testées, aucune confirmée. Cela nécessite probablement une investigation plus approfondie.

   Options :
   A) J'ai une nouvelle hypothèse : [décrire] — continuer l'investigation
   B) Ajouter de l'instrumentation et attendre — capturer le bug en action la prochaine fois
   C) Escalader — cela nécessite quelqu'un avec une connaissance plus approfondie du système
   ```

**Signaux d'alarme — ralentir immédiatement :**
- "Correctif rapide pour l'instant" — il n'y a pas de "pour l'instant"
- Proposer un correctif avant de retracer le flux de données — c'est deviner
- Chaque correctif révèle un nouveau problème ailleurs — mauvaise couche, pas mauvais code

---

### Phase 7 : Implémentation

Une fois la cause racine confirmée :

1. **Corriger la cause racine, pas le symptôme.** La modification la plus petite qui élimine le vrai problème.

2. **Diff minimal** : Le moins de fichiers touchés, le moins de lignes modifiées. Résister à la refactorisation du code adjacent.

3. **Écrire un test de régression** qui :
   - **Échoue** sans le correctif (prouve que le test est pertinent)
   - **Passe** avec le correctif (prouve que le correctif fonctionne)

4. **Lancer la suite de tests complète** et coller la sortie. Aucune régression tolérée.

5. **Vérification du rayon d'impact** : Si le correctif touche plus de 5 fichiers, s'arrêter et confirmer :

   ```
   Ce correctif touche N fichiers. C'est un rayon d'impact important pour un bug fix.

   A) Continuer — la cause racine couvre réellement ces fichiers
   B) Diviser — corriger le chemin critique maintenant, différer le nettoyage plus large
   C) Repenser — il existe peut-être une approche plus ciblée
   ```

---

## Format de sortie

```
DEBUG REPORT
════════════════════════════════════════════════════
Symptom:          [ce que l'utilisateur a observé]
Root cause:       [ce qui était réellement faux — spécifique, pas vague]
Fix:              [ce qui a été modifié, avec les références fichier:ligne]
Evidence:         [sortie de test ou reproduction montrant que le correctif fonctionne]
Regression test:  [fichier:ligne du nouveau test]
Related:          [problèmes connus, bugs précédents dans la même zone, notes architecturales]
Status:           DONE | DONE_WITH_CONCERNS | BLOCKED
════════════════════════════════════════════════════
```

**Définitions des statuts :**
- **DONE** — cause racine trouvée, correctif appliqué, test de régression écrit, tous les tests passent
- **DONE_WITH_CONCERNS** — corrigé mais impossible de vérifier complètement (intermittent, nécessite staging)
- **BLOCKED** — cause racine incertaine après investigation complète

**Format d'escalade (quand BLOCKED) :**
```
STATUS: BLOCKED
REASON: [1-2 phrases expliquant ce qui a été essayé et pourquoi ça a échoué]
ATTEMPTED: [liste des hypothèses testées]
RECOMMENDATION: [ce que l'utilisateur devrait faire ensuite — ajouter du logging, escalader, revue architecturale]
```

## Règles importantes

- **Ne jamais appliquer un correctif qu'on ne peut pas vérifier.** Si on ne peut pas reproduire et confirmer, ne pas livrer.
- **Ne jamais dire "ça devrait corriger le problème".** Vérifier et prouver. Lancer les tests.
- **Ne jamais corriger plus de 3 choses non liées dans une investigation.** Si d'autres bugs sont trouvés, les noter mais rester focalisé.
- **Supprimer toutes les instructions de log de débogage** avant de committer le correctif.
- **3+ hypothèses échouées → remettre en question l'architecture**, pas ses compétences d'hypothèse.

## Utilisation

```
/investigate TypeError: Cannot read properties of undefined (reading 'map')
/investigate the payment flow is silently dropping some transactions
/investigate
```

## Commandes associées

- `/review-pr` — revoir le correctif avant de merger
- `/qa` — lancer les QA navigateur sur la fonctionnalité affectée après correction
- `/ship` — checklist pré-déploiement après la fin de l'investigation

$ARGUMENTS
