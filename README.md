# dotfiles — Claude Code Toolkit

Boîte à outils personnelle pour **Claude Code** : commandes et skills qui automatisent les tâches répétitives du cycle de développement — de l'init git au déploiement en production.

> **Pourquoi ce projet ?**
> Claude Code permet d'écrire des commandes personnalisées en Markdown. J'ai construit ce toolkit pour ne plus jamais retaper les mêmes instructions, garder une cohérence entre mes projets, et me concentrer sur ce qui compte vraiment : le code.

---

## Ce que ça démontre

| Compétence | Comment |
|---|---|
| **Prompt engineering** | 48 commandes Markdown avec instructions précises, gestion du contexte et chaînage de tâches |
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
