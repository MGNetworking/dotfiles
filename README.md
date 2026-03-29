# dotfiles

Dotfiles personnels regroupant des commandes et skills Claude Code.

## Structure

```
dotfiles/
├── CLAUDE.md                  # Instructions du projet pour Claude Code
├── install.sh                 # Script d'installation des liens symboliques
└── claude/
    ├── commands/              # Commandes Claude Code (slash commands)
    │   ├── README.md          # Liste et description de toutes les commandes
    │   ├── git-setup*.md      # Initialisation complète d'un projet git
    │   ├── git-worktree*.md   # Gestion des worktrees git isolés
    │   ├── plan-*.md          # Planification et architecture
    │   ├── security*.md       # Audits et vérifications de sécurité
    │   ├── learn/             # Commandes d'apprentissage interactif
    │   └── resources/         # Ressources partagées (bases de données, etc.)
    └── skills/                # Skills Claude Code (capacités réutilisables)
        ├── tdd-workflow.md
        ├── security-checklist.md
        ├── pdf-generator.md
        └── ast-grep-patterns.md
```

## Contenu

### `claude/commands/`

Commandes invocables via `/nom-de-la-commande` dans Claude Code.
Voir [claude/commands/README.md](claude/commands/README.md) pour la liste complète.

Catégories disponibles :
- **Initialisation Git** — créer un projet de A à Z (`/git-setup`, `/git-setup-github`...)
- **Workflow de livraison** — du commit à la production (`/commit`, `/pr`, `/ship`...)
- **Planification** — architecture et revue avant de coder (`/plan-start`, `/plan-validate`...)
- **Qualité** — audits, tests et refactoring (`/audit-codebase`, `/qa`, `/refactor`...)
- **Sécurité** — OWASP, audits et surveillance (`/security`, `/security-audit`...)
- **Développement** — debug, explication, génération de tests
- **Apprentissage** — quiz, alternatives, explications progressives

### `claude/skills/`

Skills utilisés en interne par les commandes ou invocables directement.

| Skill | Description |
|---|---|
| `tdd-workflow` | Workflow TDD étape par étape |
| `security-checklist` | Checklist de sécurité OWASP |
| `pdf-generator` | Génération de fichiers PDF |
| `ast-grep-patterns` | Patterns de recherche AST avec ast-grep |

## Installation

```bash
git clone https://github.com/MGNetworking/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

Voir [install.sh](install.sh) pour le détail des liens symboliques créés.
