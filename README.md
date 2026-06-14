# dotfiles — Claude Code Toolkit

Boîte à outils personnelle pour **Claude Code** : commandes et skills qui automatisent les tâches répétitives du cycle de développement — de l'init git au déploiement en production.

> **Pourquoi ce projet ?**
> Claude Code permet d'écrire des commandes personnalisées en Markdown. J'ai construit ce toolkit pour ne plus jamais retaper les mêmes instructions, garder une cohérence entre mes projets, et me concentrer sur ce qui compte vraiment : le code.

---

## Ce que ça démontre

| Compétence | Comment |
|---|---|
| **Prompt engineering** | 50 commandes Markdown avec instructions précises, gestion du contexte et chaînage de tâches |
| **Culture qualité** | Workflow complet : audit de code, tests, revue de PR, vérification pré-prod |
| **Sécurité applicative** | Base de données de menaces (CVEs, OWASP Top 10, MCP threats), commandes d'audit et de surveillance |
| **Automatisation** | Script d'installation idempotent avec détection de conflits et sauvegarde automatique |
| **Documentation** | README structuré, guide de vérification du travail, catégorisation des outils |

---

## Structure

```
dotfiles/
├── CLAUDE.md                  # Instructions du projet pour Claude Code
├── install.sh                 # Script d'installation des liens symboliques
└── claude/
    ├── commands/              # 48 commandes (slash commands)
    │   ├── README.md          # Liste et guide d'utilisation
    │   ├── git-setup*.md      # Initialisation complète d'un projet git
    │   ├── git-worktree*.md   # Gestion des worktrees git isolés
    │   ├── plan-*.md          # Planification et architecture
    │   ├── security*.md       # Audits et vérifications de sécurité
    │   ├── learn/             # Commandes d'apprentissage interactif
    │   └── resources/         # Base de données de menaces (threat-db.yaml)
    └── skills/                # 4 skills réutilisables
```

---

## Commandes disponibles

Les commandes couvrent l'ensemble du cycle de développement. Voir [claude/commands/README.md](claude/commands/README.md) pour la liste complète et le guide de vérification.

```
init → plan → code → commit → PR → ship → monitor
```

| Catégorie | Commandes clés |
|---|---|
| **Initialisation Git** | `/git-setup`, `/git-setup-github`, `/git-setup-actions` |
| **Planification** | `/plan-start`, `/plan-eng-review`, `/plan-execute` |
| **Qualité** | `/audit-codebase`, `/qa`, `/refactor`, `/arch-check` |
| **Sécurité** | `/security-audit`, `/security-check`, `/update-threat-db` |
| **Workflow** | `/commit`, `/pr`, `/validate-changes`, `/ship`, `/canary` |
| **Développement** | `/investigate`, `/explain`, `/generate-tests` |
| **Apprentissage** | `/learn:teach`, `/learn:alternatives`, `/learn:quiz` |
| **Contexte projet** | `/format-claude-md`, `/bootstrap-context`, `/refresh-context`, `/audit-context` |

---

## Workflow — Contexte projet

Système de navigation documentaire intelligent permettant à Claude Code de comprendre un projet, générer du code, faire des revues et générer des tests — sans jamais dupliquer la documentation existante.

### Philosophie

```
Documentation  →  Documentation Map  →  Contextes  →  Commandes projet  →  Code
```

**Principe fondamental :** la connaissance vit uniquement dans `docs/`. Tous les autres fichiers organisent, référencent et guident — ils ne recopient jamais.

---

### Fichiers du workflow

#### Commandes (slash commands)

| Fichier | Commande | Rôle | Quand l'utiliser |
|---|---|---|---|
| `commands/format-claude-md.md` | `/format-claude-md` | Nettoie `CLAUDE.md` et produit un index pur de pointeurs | Au démarrage ou quand `CLAUDE.md` a grossi |
| `commands/bootstrap-context.md` | `/bootstrap-context` | Génère `project-analysis.md`, `documentation-map.md`, les 6 contextes et les 3 commandes projet adaptées au stack | Après `/format-claude-md`, sur tout nouveau projet |
| `commands/refresh-context.md` | `/refresh-context` | Met à jour le système sans tout reconstruire — détecte les docs ajoutées, supprimées ou déplacées | Après ajout de features, nouvelles intégrations, évolution de la doc |
| `commands/audit-context.md` | `/audit-context` | Contrôle la cohérence du système — liens cassés, couverture documentaire, composants orphelins, universalité, score global | À tout moment pour vérifier l'état du système |
| | `/audit-context --strict` | Mode strict — échec si couverture < 100% ou toute référence cassée | Avant un merge ou une livraison |

#### Gabarits (standards)

| Fichier | Utilisé par | Rôle | Ce qu'il contient |
|---|---|---|---|
| `standards/project-analysis.md` | `/bootstrap-context` | Structure du fichier analyse physique | Couches, stack, conventions, tests — zéro doc |
| `standards/documentation-map.md` | `/bootstrap-context` | Structure du fichier mapping documentaire | Catégories doc, chemins — zéro physique |
| `standards/context-format.md` | `/bootstrap-context` | Structure des 6 fichiers contexte | Question couverte, ordre de lecture, tags |
| `standards/project-command-template.md` | `/bootstrap-context` | Structure des 3 commandes projet | Flux universel + placeholders remplacés au stack détecté |

---

### Ordre d'exécution

**Étape 1 — Nettoyer `CLAUDE.md`**

```
/format-claude-md
```

Classifie chaque bloc du `CLAUDE.md` actuel et le déplace au bon endroit :

| Type | Critère | Destination |
|---|---|---|
| Projet | Specs, design, invariants, routes | Pointer vers `docs/` |
| Méthodologie | Méthode de travail, process, guides | `playbook/` ou dotfiles |
| Personnel | Profil, préférences, décisions | `memory/` |
| Temporaire | WIP, ticket en cours | `CLAUDE.staging.md` |
| Obsolète | Information dépassée | Supprimer |

Produit un `CLAUDE.md` tenant sur une page — index pur, pointeurs uniquement.

---

**Étape 2 — Initialiser le système de contexte**

```
/bootstrap-context
```

Lit `CLAUDE.md`, inventorie la documentation, analyse la structure physique, puis génère dans `.claude/` du projet :

```
.claude/
├── project-analysis.md        ← structure physique (stack, couches, conventions, tests)
├── documentation-map.md       ← cartographie documentaire (catégories → fichiers)
├── contexts/
│   ├── product.md             ← Que fait ce produit, pour qui ?
│   ├── business.md            ← Comment fonctionne le métier ?
│   ├── architecture.md        ← Comment implémenter ?
│   ├── integrations.md        ← Comment se connecter à X ?
│   ├── infrastructure.md      ← Comment déployer et configurer ?
│   └── quality.md             ← Comment valider ?
└── commands/
    ├── implement-feature.md   ← adaptée au stack détecté
    ├── review-feature.md      ← adaptée au stack détecté
    └── generate-tests.md      ← adaptée au stack détecté
```

Seuls les contextes ayant une documentation correspondante sont créés.

---

**Étape 3 — Travailler**

```
/implement-feature <fonctionnalité>
/review-feature <fonctionnalité>
/generate-tests <fonctionnalité>
```

Chaque commande projet suit ce flux :

```
1. Lire .claude/contexts/<contexte-pertinent>.md  → quels docs lire
2. Lire .claude/documentation-map.md              → résoudre les chemins
3. Lire les fichiers doc référencés               → comprendre le QUOI (métier)
4. Lire .claude/project-analysis.md               → comprendre le OÙ (technique)
5. Scanner le code existant                       → identifier les fichiers
6. Agir
```

La compréhension métier précède toujours la compréhension technique.

---

### Responsabilités — ce que chaque fichier connaît

| Fichier | Connaît | Ne connaît jamais |
|---|---|---|
| `CLAUDE.md` | Pointeurs vers sources de vérité | Contenu métier ou technique |
| `project-analysis.md` | Stack, couches, conventions, chemins code | Documentation, règles métier, noms de domaines |
| `documentation-map.md` | Catégories doc et chemins associés | Chemins code, services, repositories, controllers |
| `contexts/*.md` | Quelle question + quels docs lire dans quel ordre | Chemins `.cs`, couches, classes, services |
| `commands/*.md` | Tout — orchestre la lecture et l'action | — |

### Gabarits — ce que chaque standard définit

| Fichier | Définit | Utilisé par |
|---|---|---|
| `standards/project-analysis.md` | Format YAML de la structure physique | `/bootstrap-context` |
| `standards/documentation-map.md` | Format YAML + 6 catégories documentaires | `/bootstrap-context` |
| `standards/context-format.md` | Format des 6 fichiers contexte | `/bootstrap-context` |
| `standards/project-command-template.md` | Flux universel + gabarits des 3 commandes projet | `/bootstrap-context` |

### Cycle de vie complet

```
Nouveau projet          →  /format-claude-md  →  /bootstrap-context
Doc évolue             →  /refresh-context
Vérification qualité   →  /audit-context
```

### Critère de validation d'un contexte

> Si je supprime toute la documentation du projet, ce contexte reste-t-il utile ?

- **Oui** → il contient trop de connaissance. Le corriger.
- **Non** → il joue correctement son rôle d'index.

### Catégories documentaires standard

| Contexte | Question répondue | Contenu typique |
|---|---|---|
| `product.md` | Que fait ce produit, pour qui ? | Introduction, cas d'usage, specs fonctionnelles |
| `business.md` | Comment fonctionne le métier ? | Modèle domaine, règles métier, features |
| `architecture.md` | Comment implémenter le métier ? | Design applicatif, API, patterns |
| `integrations.md` | Comment se connecter à un service externe ? | Auth, paiement, imports, webhooks |
| `infrastructure.md` | Comment construire et déployer ? | CI/CD, config, jobs planifiés |
| `quality.md` | Comment valider ? | Critères d'acceptance, tests, couverture |

---

## Base de données de menaces (`threat-db.yaml`)

`claude/commands/resources/threat-db.yaml` est une base de renseignements sur les menaces de sécurité spécifique à l'écosystème **agents IA / Claude Code** — un domaine très récent (2025-2026).

Elle est utilisée par deux commandes :

- **`/security-check`** — compare ta configuration Claude Code contre la base pour détecter :
  - skills et auteurs malveillants connus (campagnes ClawHavoc, MCPoison...)
  - serveurs MCP avec CVEs actifs
  - patterns suspects dans les hooks (reverse shells, exfiltration de données)
  - secrets exposés dans les fichiers de configuration

- **`/update-threat-db`** — met à jour la base via recherche web (Perplexity / WebSearch) avec les dernières menaces, nouveaux CVEs MCP et campagnes malveillantes

> Concrètement : c'est l'équivalent d'une base antivirus locale, ciblée sur les vecteurs d'attaque propres aux agents de codage IA.

La base référence uniquement des données publiques (CVEs, publications de recherche en sécurité de Snyk, Checkpoint, JFrog, Recorded Future...).

---

## Skills

Skills utilisés en interne par les commandes ou invocables directement.

| Skill | Description |
|---|---|
| `tdd-workflow` | Workflow TDD étape par étape |
| `security-checklist` | Checklist de sécurité OWASP |
| `pdf-generator` | Génération de fichiers PDF |
| `ast-grep-patterns` | Patterns de recherche AST avec ast-grep |

---

## Installation

```bash
git clone https://github.com/MGNetworking/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

Le script crée des liens symboliques de `claude/commands/` et `claude/skills/` vers `~/.claude/`, avec détection de conflits et sauvegarde automatique des fichiers existants.

**Prérequis :** [Claude Code](https://claude.ai/code) installé.
