---
name: review-pr
description: "Effectuer une revue de code complète d'une pull request"
---

# Revue de Pull Request

Effectuer une revue de code complète d'une pull request.

## Instructions

1. Obtenir les informations de la PR : `gh pr view $ARGUMENTS --json title,body,files,additions,deletions`
2. Revoir chaque fichier modifié
3. Fournir un feedback structuré

## Checklist de revue

### Qualité du code
- [ ] Le code est lisible et bien organisé
- [ ] Les fonctions ont une taille appropriée
- [ ] Pas de duplication de code
- [ ] Noms de variables/fonctions significatifs

### Fonctionnalité
- [ ] La logique est correcte
- [ ] Les cas limites sont gérés
- [ ] La gestion des erreurs est complète
- [ ] Pas de bugs évidents

### Sécurité
- [ ] Pas de secrets codés en dur
- [ ] Validation des entrées présente
- [ ] Pas de vulnérabilités d'injection
- [ ] Vérifications d'autorisation en place

### Tests
- [ ] Tests ajoutés pour le nouveau code
- [ ] Les tests existants passent toujours
- [ ] Les cas limites sont testés

### Documentation
- [ ] Le code est auto-documenté ou commenté
- [ ] README mis à jour si nécessaire
- [ ] Les changements d'API sont documentés

## Format de sortie

```markdown
## Revue PR : #[numéro] - [titre]

### Résumé
[Présentation en 1-2 phrases]

### Statut d'approbation
[ ] Approuvé
[ ] Approuvé avec suggestions
[ ] Changements demandés

### Observations

#### Critique (À corriger obligatoirement)
- [ ] [Description du problème] - `fichier:ligne`

#### Suggestions (À considérer)
- [ ] [Amélioration] - `fichier:ligne`

#### Détails mineurs (Optionnel)
- [ ] [Suggestion mineure] - `fichier:ligne`

### Points positifs
- [Ce qui est bien fait]

### Questions
- [Clarifications nécessaires]
```

## Utilisation

```
/review-pr 123
/review-pr https://github.com/owner/repo/pull/123
```

---

## Avancé : Revue multi-agents

Pour des revues de niveau production nécessitant des perspectives spécialisées et des garde-fous anti-hallucination.

### Vérification préalable

Avant de revoir, vérifier s'il s'agit d'une passe de suivi pour éviter de répéter les suggestions :

```bash
# Détecter si Claude a déjà reviewé cette PR
git log --oneline -10 | grep "Co-Authored-By: Claude"
```

Si détecté, noter : "Il semble s'agir d'une passe de suivi. Je me concentrerai sur les nouveaux problèmes et éviterai de répéter les suggestions précédentes."

### Détection de dérive de périmètre

Croiser le diff de la PR avec le plan initial pour détecter les changements non intentionnels.

```bash
# Détecter la branche courante
BRANCH=$(git branch --show-current)

# Rechercher un fichier de plan associé à cette branche
ls ~/.claude/plans/ 2>/dev/null | grep -i "$BRANCH" | head -3

# Fichiers réellement modifiés dans cette PR
git diff --stat origin/main...HEAD | head -30
```

Si un fichier de plan existe pour cette branche :
1. Lire le fichier de plan — quel était le périmètre déclaré ?
2. Comparer le périmètre déclaré vs le `git diff --stat` réel
3. Signaler les fichiers modifiés qui n'étaient PAS mentionnés dans le plan

Format de sortie :
```
VÉRIFICATION DE DÉRIVE DE PÉRIMÈTRE
─────────────────────────────────────────
Périmètre du plan : [ce que le plan prévoyait de modifier]
Diff réel :         [fichiers réellement modifiés]
Dérive :            [fichiers modifiés hors périmètre du plan, le cas échéant]
Verdict :           DANS LE PÉRIMÈTRE / DÉRIVE DÉTECTÉE
```

Si aucun fichier de plan n'existe : noter "Aucun fichier de plan trouvé pour cette branche — vérification de dérive de périmètre ignorée."

### Spécialisation multi-agents

Lancer 3 agents spécialisés en parallèle (voir [Split Role Sub-Agents](../../guide/ultimate-guide.md#split-role-sub-agents)) :

**Agent 1 : Auditeur de cohérence**
```
Focus : Violations DRY, logique dupliquée, incohérences de patterns
Vérifier :
- Blocs de code dupliqués (>5 lignes similaires)
- Conventions de nommage incohérentes
- Violations de patterns (si le projet utilise le pattern X, l'appliquer)
```

**Agent 2 : Analyste des principes SOLID**
```
Focus : Violations du principe de responsabilité unique, complexité
Vérifier :
- Fonctions >50 lignes (probablement trop de responsabilités)
- Conditions imbriquées >3 niveaux
- Complexité cyclomatique >10
- Préoccupations mélangées dans un seul composant
```

**Agent 3 : Auditeur de code défensif**
```
Focus : Échecs silencieux, bugs masqués, fallbacks cachés, frontière de confiance des sorties LLM
Vérifier :
- Blocs catch vides : try { } catch (e) { } // avale l'erreur
- Fallbacks silencieux : return data || DEFAULT // cache les données manquantes
- null/undefined non vérifiés : user.name sans validation
- Rejets de promesse ignorés : async fn sans .catch()

Frontière de confiance des sorties LLM (particulièrement pertinent dans les bases de code assistées par IA) :
- Valeurs générées par LLM (emails, URLs, noms, IDs) écrites en DB ou passées à des
  fonctions en aval sans validation de format — ajouter des gardes légers
  (regex email, parsing URL, .trim()) avant de persister
- Sorties d'outils structurées (tableaux, objets issus d'outils IA) acceptées sans
  vérifications de type/forme avant les écritures en DB ou le rendu
- SQL ou chaînes de code générés par IA exécutés sans assainissement
```

### Règles anti-hallucination

**Vérifier avant d'affirmer** :
- Utiliser `Grep` ou `Glob` pour vérifier les patterns avant de les recommander
- Si on suggère "utiliser le pattern UserService existant", confirmer d'abord que UserService existe
- Ne jamais affirmer "le projet utilise X" sans vérifier la base de code réelle

**Règle des occurrences** :
- Pattern avec >10 occurrences = établi (niveau Suggestion)
- Pattern avec <3 occurrences = non établi (Peut Ignorer ou demander au mainteneur)
- Lire le contexte complet du fichier, pas seulement les lignes du diff

**Marqueurs d'incertitude** :
- Utiliser "❓ À vérifier :" quand on n'est pas sûr des conventions du projet
- Utiliser "💡 À considérer :" pour les améliorations optionnelles
- Utiliser "🔴 À corriger obligatoirement :" uniquement pour les bugs critiques/sécurité

### Réconciliation

Après que les agents ont rapporté leurs observations :

1. **Dédupliquer** : Supprimer les suggestions qui se recoupent entre les agents
2. **Prioriser les patterns existants** : Si la base de code utilise le pattern X, recommander X (pas le pattern idéal Y)
3. **Marquer les suggestions ignorées** : "Ignorer [suggestion] car le projet utilise [pattern alternatif]"
4. **Suivre le raisonnement** : Documenter pourquoi la suggestion a été conservée ou ignorée

### Classification de la sévérité

```
🔴 À corriger obligatoirement (Bloquants)
- Vulnérabilités de sécurité
- Risques de perte de données
- Changements cassants sans migration
- Échecs silencieux masquant des bugs

🟡 À corriger (Améliorations)
- Violations SOLID causant des problèmes de maintenance
- Violations DRY (>3 duplications)
- Goulots d'étranglement de performance (requêtes N+1)
- Gestion des erreurs manquante pour les chemins critiques

🟢 Peut ignorer (Agréable à avoir)
- Incohérences de style (sans linter)
- Améliorations mineures de nommage
- Code trop imbriqué (si <3 niveaux)
- Lacunes de documentation (si le code est auto-documenté)
```

### Heuristique "Corriger en premier"

Déterminer s'il faut corriger automatiquement chaque observation ou la soumettre à la décision de l'utilisateur.

```
CORRECTION AUTOMATIQUE (appliquer sans demander) :  DEMANDER (nécessite jugement humain) :
├─ Code mort / variables inutilisées              ├─ Changements de sécurité (auth, XSS, injection)
├─ Requêtes N+1 (eager loading manquant)          ├─ Conditions de course
├─ Commentaires périmés contredisant le code      ├─ Décisions de conception
├─ Nombres magiques → constantes nommées          ├─ Corrections importantes (>20 lignes modifiées)
├─ Import manquant / chemins incorrects           ├─ Complétude des enums
├─ Variables assignées mais jamais lues           ├─ Tout ce qui supprime une fonctionnalité
└─ Incohérences évidentes version/doc             └─ Changements de comportement visibles par l'utilisateur
```

**Règle** : Si un ingénieur senior appliquerait la correction en 30 secondes sans discussion, c'est CORRECTION AUTOMATIQUE. Si des ingénieurs raisonnables pourraient ne pas être d'accord, c'est DEMANDER.

Après que les agents ont rapporté leurs observations :
1. Appliquer tous les éléments de CORRECTION AUTOMATIQUE immédiatement avec des modifications minimales et ciblées
2. Regrouper tous les éléments DEMANDER en une seule décision utilisateur (pas une question par élément)

### Boucle de correction automatique (Optionnel)

Pour une convergence automatisée :

```
Revoir → Identifier les problèmes → Corriger → Re-revoir → Répéter jusqu'à changements minimaux

Garde-fous :
- Maximum 3 itérations pour éviter les boucles infinies
- Lancer tsc/lint avant chaque itération
- Ignorer la correction automatique pour les fichiers protégés (package.json, migrations, etc.)
```

**Exemple de prompt** :
```
Revoir cette PR avec correction automatique activée :
1. Revoir en utilisant les 3 agents ci-dessus
2. Corriger tous les problèmes 🔴 À corriger obligatoirement
3. Re-revoir pour vérifier les corrections
4. Répéter pour 🟡 À corriger (max 2 itérations supplémentaires)
5. S'arrêter quand il ne reste que des 🟢 Peut ignorer
```

### Chargement de contexte conditionnel

Charger du contexte supplémentaire selon le contenu du diff (agnostique au stack) :

| Si le diff contient... | Alors vérifier... |
|------------------------|-------------------|
| Requêtes de base de données | Index, patterns N+1, optimisation des requêtes |
| Endpoints API | Middleware d'auth, validation des entrées, rate limiting |
| Logique d'authentification | Hachage des mots de passe, gestion des sessions, tokens CSRF |
| Uploads de fichiers | Limites de taille, validation MIME, sécurité du stockage |
| Opérations date/heure | Gestion des fuseaux horaires, cas limites DST |
| Appels d'API externes | Configs de timeout, logique de retry, gestion des erreurs |
| Variables d'environnement | Présence dans .env.example, validation au démarrage |

### Intégration avec les outils existants

**Plugin SE-CoVe** : Utiliser pour la vérification générale des faits des affirmations de revue (complémentaire aux règles anti-hallucination ci-dessus)

**Worktrunk** : Pour l'analyse de patterns à l'échelle de la base de code avant de suggérer des changements

**AST-grep** : Pour la correspondance de patterns structurels (ex. trouver tous les blocs try/catch similaires)

---

## Sources

- Template de base : Claude Code Ultimate Guide
- Revue multi-agents : [Pat Cullen](https://gist.github.com/patyearone/c9a091b97e756f5ed361f7514d88ef0b) (jan. 2026)
- Patterns anti-hallucination : système de revue de code [Méthode Aristote](https://github.com/FlorianBruniaux)

$ARGUMENTS
