---
name: git-setup-release-please
description: "Configurer Release Please pour automatiser la gestion des versions et la génération du CHANGELOG"
---

# Git Setup — Release Please

Configurer [Release Please](https://github.com/googleapis/release-please) pour automatiser :
- La création des PRs de release
- La gestion des versions (semver)
- La génération du `CHANGELOG.md`

## Instructions

Si appelé seul (sans argument), poser les questions suivantes :

1. **Type de release** ? (détermine comment la version est gérée)
   - `node` — `package.json`
   - `python` — `setup.py` / `pyproject.toml`
   - `go` — tags git
   - `java` — `pom.xml`
   - `rust` — `Cargo.toml`
   - `simple` — fichier `version.txt` (universel)

2. **Branche de release** ? (défaut : `main`)

3. **Préfixe de tag** ? (défaut : `v` → ex: `v1.2.3`)

Si appelé depuis `/git-setup`, utiliser les arguments fournis directement.

---

## Fichiers à créer

### 1. `release-please-config.json`
```json
{
  "$schema": "https://raw.githubusercontent.com/googleapis/release-please/main/schemas/config.json",
  "release-type": "<TYPE>",
  "packages": {
    ".": {}
  },
  "tag-separator": "-",
  "include-component-in-tag": false,
  "bump-minor-pre-major": false,
  "bump-patch-for-minor-pre-major": false,
  "changelog-sections": [
    { "type": "feat", "section": "Features" },
    { "type": "fix", "section": "Bug Fixes" },
    { "type": "perf", "section": "Performance Improvements" },
    { "type": "revert", "section": "Reverts" },
    { "type": "docs", "section": "Documentation", "hidden": false },
    { "type": "chore", "section": "Miscellaneous", "hidden": true },
    { "type": "refactor", "section": "Miscellaneous", "hidden": true }
  ]
}
```

### 2. `.release-please-manifest.json`
```json
{
  ".": "0.1.0"
}
```

---

## Notes importantes

- Release Please se base sur les **Conventional Commits** pour déterminer le type de bump :
  - `feat:` → bump mineur (`1.0.0` → `1.1.0`)
  - `fix:` → bump patch (`1.0.0` → `1.0.1`)
  - `feat!:` ou `BREAKING CHANGE:` → bump majeur (`1.0.0` → `2.0.0`)
- Le workflow GitHub Actions (`/git-setup-actions`) est nécessaire pour automatiser le déclenchement
- La PR de release est créée automatiquement après chaque push sur la branche principale

---

## Exécution

1. Créer `release-please-config.json` à la racine avec le type choisi
2. Créer `.release-please-manifest.json` à la racine avec la version initiale `0.1.0`
3. Confirmer la création des deux fichiers
4. Rappeler que le workflow GitHub Actions est nécessaire pour l'automatisation complète

$ARGUMENTS
