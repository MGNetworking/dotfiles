---
name: git-setup-gitattributes
description: "Générer un fichier .gitattributes pour normaliser les fins de ligne et gérer les fichiers binaires"
---

# Git Setup — .gitattributes

Générer un fichier `.gitattributes` pour normaliser les fins de ligne et déclarer les fichiers binaires.

## Instructions

Si appelé seul (sans argument), poser les questions suivantes :

1. **OS principal de l'équipe** ?
   - Linux / Mac → `eol=lf`
   - Windows → `eol=crlf`
   - Mixte → `auto` (recommandé : normaliser en LF dans le dépôt)

2. **Langage / stack** ? (pour adapter les extensions déclarées)

3. **Des fichiers binaires spécifiques à déclarer** ? (images, polices, archives...)

Si appelé depuis `/git-setup`, utiliser les arguments fournis directement.

---

## Contenu du .gitattributes

### Section commune (tous projets)
```gitattributes
# Normalisation automatique des fins de ligne
* text=auto eol=lf

# Scripts shell — toujours LF
*.sh text eol=lf
*.bash text eol=lf

# Scripts Windows — toujours CRLF
*.bat text eol=crlf
*.cmd text eol=crlf
*.ps1 text eol=crlf
```

### Section texte par langage

**Node.js / TypeScript :**
```gitattributes
*.js text eol=lf
*.ts text eol=lf
*.jsx text eol=lf
*.tsx text eol=lf
*.json text eol=lf
*.md text eol=lf
```

**Python :**
```gitattributes
*.py text eol=lf
*.pyi text eol=lf
*.cfg text eol=lf
*.toml text eol=lf
```

**Go :**
```gitattributes
*.go text eol=lf
go.sum text eol=lf
go.mod text eol=lf
```

**Java / Kotlin :**
```gitattributes
*.java text eol=lf
*.kt text eol=lf
*.gradle text eol=lf
*.properties text eol=lf
```

**.NET / C# :**
```gitattributes
*.cs text eol=lf
*.csproj text eol=lf
*.sln text eol=lf
```

**PHP :**
```gitattributes
*.php text eol=lf
```

**Rust :**
```gitattributes
*.rs text eol=lf
*.toml text eol=lf
```

### Section config / CI
```gitattributes
*.yml text eol=lf
*.yaml text eol=lf
*.toml text eol=lf
*.xml text eol=lf
*.html text eol=lf
*.css text eol=lf
*.scss text eol=lf
Dockerfile text eol=lf
.env* text eol=lf
```

### Section binaires (tous projets)
```gitattributes
# Images
*.png binary
*.jpg binary
*.jpeg binary
*.gif binary
*.ico binary
*.svg text eol=lf
*.webp binary

# Polices
*.ttf binary
*.otf binary
*.woff binary
*.woff2 binary

# Archives
*.zip binary
*.tar binary
*.gz binary
*.7z binary

# Documents
*.pdf binary
*.doc binary
*.docx binary
*.xls binary
*.xlsx binary
```

---

## Exécution

1. Composer le `.gitattributes` en assemblant les sections pertinentes
2. Écrire le fichier `.gitattributes` à la racine du projet
3. Recommander d'exécuter `git add --renormalize .` si le dépôt contient déjà des fichiers

$ARGUMENTS
