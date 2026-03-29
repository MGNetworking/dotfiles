---
name: audit-agents-skills
description: Auditer la qualité des agents, skills et commandes dans un projet Claude Code
argument-hint: "[path] [--fix] [--verbose]"
---

# Audit Qualité Agents/Skills/Commandes

Audit qualité complet pour les agents, skills et commandes Claude Code. Attribue un score à chaque fichier selon des critères pondérés avec une note de maturité production.

## Arguments

- `[path]` - Répertoire à auditer (par défaut : `.claude/` du projet courant)
- `--fix` - Générer des suggestions de correction pour les critères échoués
- `--verbose` - Afficher les détails de tous les critères (pas seulement les échecs)

## Utilisation

```bash
/audit-agents-skills              # Auditer le projet courant
/audit-agents-skills --fix        # Audit + suggestions de correction
/audit-agents-skills ~/other-repo # Auditer un autre projet
/audit-agents-skills --verbose    # Détails complets pour tous les critères
```

---

## Phase 1 : Découverte

**Objectif** : Localiser et classifier tous les agents, skills et commandes

### Étapes

1. **Scanner les répertoires** :
   ```
   .claude/agents/
   .claude/skills/
   .claude/commands/
   examples/agents/      (si existant)
   examples/skills/      (si existant)
   examples/commands/    (si existant)
   ```

2. **Classifier les fichiers** :
   - **Agent** : Fichier dans le répertoire `agents/` avec un frontmatter YAML contenant un champ `tools:`
   - **Skill** : Fichier dans le répertoire `skills/` OU nommé `SKILL.md` OU frontmatter avec champ `allowed-tools:`
   - **Commande** : Fichier dans le répertoire `commands/` avec un frontmatter contenant `name:` et `description:`

3. **Afficher le résumé** :
   ```
   Trouvé : X agents, Y skills, Z commandes
   ```

---

## Phase 2 : Audit des Fichiers Individuels

Chaque type de fichier est scoré selon des **critères pondérés**. Scores maximaux :
- **Agents** : 32 points
- **Skills** : 32 points
- **Commandes** : 20 points

### Agents (32 points max)

#### Identité (poids : 3x) — 12 points

| Critère | Points | Détection |
|---------|--------|-----------|
| Champ `name` clair | 3 | Le frontmatter YAML possède un champ `name:` descriptif (pas générique comme "agent1") |
| `description` avec déclencheurs | 3 | La description contient les mots-clés "when", "use" ou "trigger" indiquant le contexte d'activation |
| `model` spécifié | 3 | Le frontmatter possède un champ `model:` (sonnet/haiku/opus) |
| `tools` restreint de façon appropriée | 3 | La liste des tools n'inclut pas Bash sans justification, ou inclut une explication pour les tools risqués |

**Justification** : L'identité détermine la **découvrabilité** et l'**activation**. Si les utilisateurs ne peuvent pas localiser ou invoquer l'agent, la qualité en aval n'a pas d'importance.

#### Qualité du Prompt (poids : 2x) — 8 points

| Critère | Points | Détection |
|---------|--------|-----------|
| Rôle défini | 2 | Contient une déclaration "You are" ou "Your role" définissant le persona de l'agent |
| Format de sortie spécifié | 2 | Possède une section intitulée "Output", "Format" ou "Deliverables" précisant la structure attendue |
| Périmètre/limites définis | 2 | Possède une section définissant le périmètre, les déclencheurs ou les cas où NE PAS utiliser l'agent |
| Mesures anti-hallucination | 2 | Contient les mots-clés : "verify", "cite", "source", "evidence", ou des avertissements contre les hallucinations |

**Justification** : La qualité du prompt détermine la **fiabilité** et l'**exactitude** des réponses de l'agent.

#### Validation (poids : 1x) — 4 points

| Critère | Points | Détection |
|---------|--------|-----------|
| 3+ exemples d'utilisation | 1 | Possède une section "Examples", "Usage" ou "Scenarios" avec au moins 3 exemples distincts |
| Cas limites documentés | 1 | Mentionne des scénarios "edge case", "error", "failure" ou "limitation" |
| Intégration documentée | 1 | Référence d'autres agents, skills ou tools avec lesquels il fonctionne |
| Gestion des erreurs décrite | 1 | Mentionne "fallback", "recovery", "error handling" ou les modes de défaillance |

**Justification** : La validation assure la **robustesse** via des scénarios de test complets.

#### Design (poids : 2x) — 8 points

| Critère | Points | Détection |
|---------|--------|-----------|
| Responsabilité unique | 2 | Taille du fichier <5000 tokens ET description focalisée (pas "general purpose" ou plusieurs verbes) |
| Pas de duplication | 2 | La description ne recouvre pas significativement d'autres agents (vérification similarité mots-clés >50%) |
| Composable (références de skills) | 2 | Référence des skills ou d'autres agents qu'il peut invoquer, montrant la modularité |
| Budget token raisonnable | 2 | Taille du fichier <8000 tokens (évite le gonflement du contexte) |

**Justification** : Les patterns de design déterminent la **maintenabilité** et la **scalabilité** de l'architecture d'agents.

---

### Skills (32 points max)

#### Structure (poids : 3x) — 12 points

| Critère | Points | Détection |
|---------|--------|-----------|
| SKILL.md valide ou frontmatter | 3 | Fichier nommé `SKILL.md` OU frontmatter YAML avec champ `name:` |
| `name` valide | 3 | Le nom est en minuscules, 1-64 caractères, correspond au pattern `[a-z0-9-]+` (pas d'espaces/caractères spéciaux) |
| `description` non vide | 3 | Le champ description existe et fait >20 caractères |
| `allowed-tools` spécifié | 3 | Le frontmatter possède un champ `allowed-tools:` listant les permissions de tools |

**Justification** : La conformité de structure assure la **compatibilité avec les spécifications** du runtime Claude Code.

#### Contenu (poids : 2x) — 8 points

| Critère | Points | Détection |
|---------|--------|-----------|
| Méthodologie/workflow décrit | 2 | Possède une section intitulée "Methodology", "Workflow", "Process" ou des étapes numérotées |
| Format de sortie spécifié | 2 | Possède une section précisant le format du livrable (Markdown, JSON, structure de rapport) |
| Exemples fournis | 2 | Possède une section "Examples", "Usage" ou "Scenarios" avec des instances concrètes |
| Checklists incluses | 2 | Contient la syntaxe de cases à cocher Markdown `- [ ]` ou `- [x]` pour les éléments actionnables |

**Justification** : La richesse du contenu détermine l'**utilisabilité** et la **courbe d'apprentissage**.

#### Technique (poids : 1x) — 4 points

| Critère | Points | Détection |
|---------|--------|-----------|
| Les scripts ont une gestion d'erreurs | 1 | Si des scripts embarqués existent, ils contiennent `set -e`, `trap` ou des patterns `|| exit` |
| Pas de chemins en dur | 1 | Pas de chemins absolus comme `/Users/`, `/home/`, `C:\` dans le code ou les instructions |
| Pas de secrets | 1 | Pas de mots-clés : "password", "secret", "token", "api_key", "credentials" en clair |
| Dépendances documentées | 1 | Si des outils externes sont requis, possède une section "Requirements", "Dependencies" ou "Prerequisites" |

**Justification** : L'hygiène technique prévient les **problèmes de portabilité** et les **risques de sécurité**.

#### Design (poids : 2x) — 8 points

| Critère | Points | Détection |
|---------|--------|-----------|
| Responsabilité unique | 2 | La description est focalisée sur un domaine (pas "general" ou multi-usage) |
| Déclencheurs clairs | 2 | Possède une section définissant "When to use", "Triggers" ou "Activation criteria" |
| Pas de chevauchement avec d'autres skills | 2 | La description ne duplique pas >50% des mots-clés des autres skills du projet |
| Portable | 2 | Pas d'extensions spécifiques à Claude Code qui cassent la portabilité (vérifier les APIs personnalisées) |

**Justification** : Le design détermine la **découvrabilité** et la **maintenabilité** entre projets.

---

### Commandes (20 points max)

#### Structure (poids : 3x) — 12 points

| Critère | Points | Détection |
|---------|--------|-----------|
| Frontmatter valide | 3 | Possède un frontmatter YAML avec les champs `name:` et `description:` |
| `argument-hint` si accepte des args | 3 | Si la variable `$ARGUMENTS` est utilisée dans le corps, le frontmatter possède un champ `argument-hint:` |
| Workflow étape par étape | 3 | Le corps contient des sections numérotées (1., 2., 3.) ou une structure de phases claire |
| Exemples d'utilisation | 3 | Possède une section intitulée "Usage", "Examples" ou montre des patterns d'invocation |

**Justification** : La structure détermine l'**utilisabilité** et la **facilité d'apprentissage** pour les utilisateurs de commandes.

#### Qualité (poids : 2x) — 8 points

| Critère | Points | Détection |
|---------|--------|-----------|
| Gestion des erreurs | 2 | Mentionne "error", "failure", "fallback" ou des chemins conditionnels pour les échecs |
| Format de sortie défini | 2 | Précise ce que la commande produit (rapport, fichier, résumé) et sa structure |
| Points de validation | 2 | Contient des points de contrôle, des étapes de vérification ou des vérifications "before proceeding" |
| Arguments correctement parsés | 2 | Si accepte des args, montre comment parser/valider `$ARGUMENTS` (valeurs par défaut, validation) |

**Justification** : La qualité détermine la **fiabilité** et la **maturité production**.

---

## Phase 3 : Scoring

### Score d'un Fichier Individuel

```
Score = (Points Obtenus / Points Max) × 100
```

**Exemple** : Un agent obtient 26/32 points → score de 81%

### Attribution des Notes

| Note | Plage de score | Statut |
|------|----------------|--------|
| A | 90-100% | Prêt pour la production ✅ |
| B | 80-89% | Bon (seuil de production) ⚠️ |
| C | 70-79% | Nécessite des améliorations 🔧 |
| D | 60-69% | Lacunes significatives ⚠️ |
| F | <60% | Problèmes critiques ❌ |

**Seuil de production** : 80% (Note B ou supérieure)

### Score Global du Projet

Moyenne pondérée par type de fichier :
```
Global = (Σ Scores Agents × Nb Agents + Σ Scores Skills × Nb Skills + Σ Scores Commandes × Nb Commandes) / Total Fichiers
```

---

## Phase 4 : Génération du Rapport

### Structure du Rapport

```markdown
# Audit : Agents/Skills/Commandes

**Projet** : {path}
**Date** : {date}
**Score Global** : {score}% ({grade})
**Fichiers Audités** : {total} ({n} agents, {n} skills, {n} commandes)
**Prêts pour la Production** : {count} fichiers ({percentage}%)

---

## Résumé

| Type | Fichiers | Score Moy. | Note | Prêts Production |
|------|----------|------------|------|------------------|
| Agents | X | Y% | Z | N/X (%) |
| Skills | X | Y% | Z | N/X (%) |
| Commandes | X | Y% | Z | N/X (%) |

---

## Scores Individuels

| Fichier | Type | Score | Note | Principaux Problèmes |
|---------|------|-------|------|----------------------|
| agent-name.md | Agent | 85% | B | Mesures anti-hallucination manquantes, pas de cas limites |
| skill-name/ | Skill | 72% | C | Chemins en dur, pas de gestion d'erreurs |
| command.md | Commande | 95% | A | Aucun |

---

## Principaux Problèmes (Tous Fichiers Confondus)

1. **Gestion des erreurs manquante** (8 fichiers concernés)
   - Impact : Échecs d'exécution non gérés
   - Correction : Ajouter des sections de gestion d'erreurs, des stratégies de fallback

2. **Chemins en dur** (5 fichiers concernés)
   - Impact : Portabilité cassée entre systèmes
   - Correction : Utiliser des chemins relatifs ou des variables d'environnement

3. **Pas d'exemples d'utilisation** (4 fichiers concernés)
   - Impact : Mauvaise facilité d'apprentissage, invocation peu claire
   - Correction : Ajouter une section "Examples" avec 3+ scénarios

---

## Détail par Fichier

<details>
<summary>agent-name.md (Agent, 85%, Note B)</summary>

### Scores par Catégorie

| Catégorie | Points | Max | Réussi |
|-----------|--------|-----|--------|
| Identité | 12 | 12 | ✅ |
| Qualité du Prompt | 6 | 8 | ⚠️ |
| Validation | 2 | 4 | ❌ |
| Design | 6 | 8 | ⚠️ |

### Critères Échoués

- ❌ **Mesures anti-hallucination** (2 pts) : Aucun mot-clé de vérification de source trouvé
- ❌ **Cas limites documentés** (1 pt) : Aucune mention de scénarios d'échec
- ❌ **Intégration documentée** (1 pt) : Aucune référence à d'autres agents/skills

### Recommandations

1. Ajouter une section "Vérification des Sources" exigeant la citation des affirmations
2. Documenter les cas limites : échecs API, scénarios de timeout, entrées invalides
3. Lister les skills/agents compatibles pour les patterns de composition

</details>

---

## Recommandations (Priorisées)

### Haute Priorité (Critique pour la production)

1. **Ajouter la gestion des erreurs à 8 fichiers**
   - Fichiers : [liste]
   - Action : Ajouter des sections de gestion d'erreurs, définir des comportements de fallback

2. **Supprimer les chemins en dur de 5 fichiers**
   - Fichiers : [liste]
   - Action : Remplacer par `$HOME`, des chemins relatifs ou des variables d'env

### Priorité Moyenne (Améliore la qualité)

3. **Ajouter des exemples d'utilisation à 4 fichiers**
   - Fichiers : [liste]
   - Action : Créer une section "Examples" avec 3+ scénarios

4. **Définir les formats de sortie dans 3 fichiers**
   - Fichiers : [liste]
   - Action : Préciser la structure du livrable (Markdown/JSON/rapport)

### Basse Priorité (Peaufinage)

5. **Ajouter la documentation d'intégration à 2 fichiers**
   - Fichiers : [liste]
   - Action : Lister les agents/skills compatibles pour la composition

---

## Prochaines Étapes

1. Examiner les échecs : se concentrer d'abord sur les fichiers de note D/F
2. Lancer avec `--fix` pour des suggestions automatisées
3. Ré-auditer après les améliorations pour suivre la progression
4. Viser 80%+ (Note B) sur tous les fichiers pour la maturité production
```

---

## Phase 5 : Mode Correction (Optionnel)

**Déclencheur** : flag `--fix`

Pour chaque critère échoué, générer une suggestion de correction spécifique :

### Exemples de Suggestions de Correction

**Fichier** : `agent-name.md`
**Problème** : Mesures anti-hallucination manquantes (2 pts perdus)

**Correction suggérée** :
```markdown
Ajouter cette section après la section "Methodology" :

## Vérification des Sources

- Toujours citer les sources pour les affirmations factuelles
- Utiliser des formulations comme "Selon [source]..." ou "D'après [documentation]..."
- En cas d'incertitude, indiquer explicitement "Je n'ai pas d'information vérifiée sur..."
- Ne jamais inventer des statistiques, numéros de version ou détails d'API
```

**Fichier** : `skill-debugging/scripts/analyze.sh`
**Problème** : Pas de gestion d'erreurs (1 pt perdu)

**Correction suggérée** :
```bash
Ajouter en haut du script :

set -e  # Quitter en cas d'erreur
trap 'echo "Erreur à la ligne $LINENO"' ERR

# Remplacer les commandes risquées :
curl https://api.example.com        # ❌ Pas de vérification d'erreur
curl https://api.example.com || {   # ✅ Erreur gérée
    echo "Appel API échoué"
    exit 1
}
```

---

## Mode Verbose (Optionnel)

**Déclencheur** : flag `--verbose`

Par défaut, le rapport n'affiche que les **critères échoués**. Le mode verbose affiche **tous les critères** avec leur statut réussi/échoué :

```markdown
### Tous les Critères (Verbose)

| Critère | Statut | Points | Notes |
|---------|--------|--------|-------|
| Nom clair | ✅ Réussi | 3/3 | Le nom est "debugging-specialist" (descriptif) |
| Description avec déclencheurs | ✅ Réussi | 3/3 | Contient "Use when debugging..." |
| Modèle spécifié | ❌ Échoué | 0/3 | Pas de champ `model:` dans le frontmatter |
| Tools restreints | ⚠️ Partiel | 2/3 | Inclut Bash mais sans justification |
| ... | ... | ... | ... |
```

---

## Contexte Industriel

**Source** : LangChain Agent Report 2026 (vérifié)

**Statistiques clés** :
- 29,5% des organisations déploient des agents sans évaluation systématique
- 18% citent les "bugs d'agents" comme leur principal défi
- Seulement 12% utilisent des contrôles de qualité automatisés

**Implication** : Cet audit répond à un **vrai manque dans l'industrie**. La plupart des équipes déploient des agents/skills sans validation, ce qui entraîne des problèmes en production. Le seuil de 80% (Note B) est aligné avec les meilleures pratiques de l'industrie pour la maturité production.

**Comparaison** : Les checklists manuelles (comme la Checklist de Validation d'Agents du Guide ligne 4921) sont complètes mais sujettes aux erreurs. Le scoring automatisé réduit les erreurs humaines et fournit des métriques quantitatives pour suivre les améliorations dans le temps.

---

## Liens Associés

- **Checklist de Validation d'Agents** (guide ligne 4921) : Checklist manuelle à 16 critères
- **Validation de Skills** (guide ligne 5491) : Documentation de conformité aux spécifications
- **Exemples** : `examples/agents/`, `examples/skills/`, `examples/commands/`
- **Audit Avancé** : Utiliser le skill `audit-agents-skills` (voir `examples/skills/`) pour une analyse comparative par rapport aux templates

---

## Notes d'Implémentation

### Patterns de Détection

**Parsing du Frontmatter** :
```python
import re
yaml_match = re.search(r'^---\n(.*?)\n---', content, re.DOTALL)
if yaml_match:
    import yaml
    frontmatter = yaml.safe_load(yaml_match.group(1))
```

**Détection de Mots-Clés** (insensible à la casse) :
```python
has_trigger = any(word in description.lower() for word in ['when', 'use', 'trigger'])
```

**Comptage de Tokens** (approximatif) :
```python
tokens = len(content.split()) * 1.3  # Estimation grossière : 1 token ≈ 0,75 mots
```

### Détection de Chevauchements

Comparer les descriptions avec la similarité de Jaccard :
```python
def jaccard_similarity(desc1, desc2):
    words1 = set(desc1.lower().split())
    words2 = set(desc2.lower().split())
    intersection = words1 & words2
    union = words1 | words2
    return len(intersection) / len(union) if union else 0

# Signaler si similarité > 0.5 (50% de chevauchement de mots-clés)
```

### Codage Couleur des Notes (Sortie Terminal)

```python
COLORS = {
    'A': '\033[92m',  # Vert
    'B': '\033[93m',  # Jaune
    'C': '\033[93m',  # Jaune
    'D': '\033[91m',  # Rouge
    'F': '\033[91m'   # Rouge
}
```

---

**Commande prête à l'emploi** : `/audit-agents-skills`
