# dotfiles — Outils personnels Claude Code

Configuration personnelle et outils pour Claude Code.

> Le Harness universel de collaboration IA est dans un projet séparé :
> `D:\Projet\harness\`

---

## Structure

```
dotfiles/
├── install.sh
└── claude/
    ├── commands/    ← outils personnels (git, qualité, sécurité, apprentissage...)
    └── skills/      ← skills réutilisables
```

---

## Commandes disponibles

| Catégorie | Commandes |
|---|---|
| **Git** | `/git-setup`, `/git-setup-github`, `/git-setup-actions`, `/git-worktree*` |
| **Planification** | `/plan-start`, `/plan-eng-review`, `/plan-ceo-review`, `/plan-execute`, `/plan-validate` |
| **Qualité** | `/audit-codebase`, `/qa`, `/refactor`, `/arch-check`, `/optimize` |
| **Sécurité** | `/security-audit`, `/security-check`, `/security`, `/update-threat-db`, `/sonarqube` |
| **Workflow** | `/commit`, `/pr`, `/validate-changes`, `/ship`, `/canary`, `/land-and-deploy` |
| **Développement** | `/investigate`, `/explain`, `/generate-tests`, `/review-pr`, `/review-plan` |
| **Apprentissage** | `/learn:teach`, `/learn:alternatives`, `/learn:quiz` |
| **Contexte** | `/catchup`, `/session-save`, `/diagnose`, `/sandbox-status` |
| **.NET** | `/fiches-dotnet`, `/resources:dotnet:*` |

---

## Harness universel

Les commandes Harness (bootstrap-context, plan-feature, etc.) sont dans :

```
D:\Projet\harness\adapters\claude\
```

Installation :
```bash
cd D:\Projet\harness\adapters\claude
./install.sh
```

---

## Installation

```bash
./install.sh
```

Crée des liens symboliques de `claude/commands/` et `claude/skills/` vers `~/.claude/`.

**Prérequis :** [Claude Code](https://claude.ai/code) installé.
