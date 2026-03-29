---
name: git-setup-actions
description: "Générer les workflows GitHub Actions pour CI (tests) et/ou Release Please"
---

# Git Setup — GitHub Actions

Générer les workflows GitHub Actions adaptés au projet.

## Instructions

Si appelé seul (sans argument), poser les questions suivantes :

1. **Quels workflows générer ?**
   - `ci` — Tests automatiques sur chaque PR et push
   - `release` — Automatisation Release Please sur push main
   - `les deux`

2. **Langage / Framework** ? (pour adapter les commandes de test)

3. **Version du langage** ? (ex: Node 20, Python 3.12, Go 1.22...)

4. **Branche principale** ? (défaut : `main`)

5. **Package manager** ? (si Node.js : npm / yarn / pnpm)

Si appelé depuis `/git-setup`, utiliser les arguments fournis directement.

---

## Workflows à générer

### Workflow CI — `.github/workflows/ci.yml`

**Node.js :**
```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '<VERSION>'
          cache: '<PACKAGE_MANAGER>'
      - run: <PACKAGE_MANAGER> install
      - run: <PACKAGE_MANAGER> run lint
      - run: <PACKAGE_MANAGER> test
```

**Python :**
```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '<VERSION>'
      - run: pip install -e ".[dev]"
      - run: ruff check .
      - run: pytest
```

**Go :**
```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '<VERSION>'
      - run: go vet ./...
      - run: go test ./...
```

---

### Workflow Release — `.github/workflows/release-please.yml`

```yaml
name: Release Please

on:
  push:
    branches: [main]

permissions:
  contents: write
  pull-requests: write

jobs:
  release-please:
    runs-on: ubuntu-latest
    steps:
      - uses: googleapis/release-please-action@v4
        with:
          config-file: release-please-config.json
          manifest-file: .release-please-manifest.json
```

---

## Notes importantes

- Le workflow `release` nécessite les fichiers créés par `/git-setup-release-please`
- Les permissions `contents: write` et `pull-requests: write` sont requises pour Release Please
- Le cache du package manager accélère significativement les builds CI

---

## Exécution

1. Créer le dossier `.github/workflows/` si inexistant
2. Générer les fichiers de workflow selon les choix
3. Adapter les versions et commandes au stack du projet
4. Confirmer la création avec la liste des fichiers générés

$ARGUMENTS
