---
name: git-setup-github
description: "Créer un dépôt GitHub avec description, topics, remote origin et protection des branches"
---

# Git Setup — GitHub

Créer et configurer un dépôt GitHub pour le projet local.

## Prérequis

- `gh` (GitHub CLI) installé et authentifié (`gh auth login`)
- Un dépôt git local initialisé avec au moins un commit

## Instructions

Si appelé seul (sans argument), poser les questions suivantes une par une :

1. **Nom du dépôt** ? (défaut : nom du dossier courant)

2. **Visibilité** ?
   - `public` — visible par tous
   - `private` — visible uniquement par toi et les collaborateurs

3. **Description courte du projet** ? (1 phrase, affichée dans l'About GitHub)
   - Ex : "API REST de gestion de tâches avec authentification JWT"

4. **Langage / stack principal** ? (pour générer les topics automatiquement)
   - Ex : Node.js, Python, Go, React, NestJS...

5. **Topics supplémentaires** ? (mots-clés libres, séparés par des virgules)
   - Ex : `api, rest, authentication, docker`
   - Les topics seront combinés avec ceux déduits du stack

6. **URL du site web du projet** ? (optionnel — laisser vide si aucun)

Si appelé depuis `/git-setup`, utiliser les arguments fournis directement.

---

## Topics déduits automatiquement par stack

| Stack | Topics ajoutés automatiquement |
|---|---|
| Node.js | `nodejs`, `javascript` |
| TypeScript | `typescript`, `nodejs` |
| React | `react`, `frontend`, `javascript` |
| Next.js | `nextjs`, `react`, `typescript` |
| NestJS | `nestjs`, `nodejs`, `typescript`, `api` |
| Python | `python` |
| Django | `django`, `python`, `web` |
| FastAPI | `fastapi`, `python`, `api` |
| Go | `golang` |
| Rust | `rust` |
| Java | `java` |
| Spring | `spring`, `java`, `api` |
| .NET | `dotnet`, `csharp` |
| PHP | `php` |
| Laravel | `laravel`, `php`, `web` |

---

## Exécution

### 1. Créer le dépôt GitHub

```bash
gh repo create <NOM> \
  --<VISIBILITÉ> \
  --description "<DESCRIPTION>" \
  --source=. \
  --remote=origin \
  --push
```

### 2. Ajouter les topics (About → Tags)

```bash
gh repo edit <NOM> --add-topic <topic1> --add-topic <topic2> ...
```

### 3. Ajouter l'URL du site (si fournie)

```bash
gh repo edit <NOM> --homepage "<URL>"
```

---

## Récapitulatif final

Afficher à la fin :

```
Dépôt créé  : https://github.com/<owner>/<nom>
Visibilité  : public / private
Description : <description>
Topics      : <liste des topics>
Remote      : origin → https://github.com/<owner>/<nom>
```

$ARGUMENTS
