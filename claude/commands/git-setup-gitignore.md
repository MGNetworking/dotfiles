---
name: git-setup-gitignore
description: "Générer un fichier .gitignore adapté au langage, framework et OS du projet"
---

# Git Setup — .gitignore

Générer un fichier `.gitignore` complet et adapté au projet.

## Instructions

Si appelé seul (sans argument), poser les questions suivantes :

1. **Langage / Framework principal** ?
   - Node.js / TypeScript
   - Python
   - Go
   - Java / Kotlin
   - .NET / C#
   - PHP
   - Rust
   - Autre (préciser)

2. **Frameworks supplémentaires** ? (ex: React, Next.js, NestJS, Django, Laravel...)

3. **OS principal de l'équipe** ?
   - Linux / Mac
   - Windows
   - Mixte

4. **IDE utilisé** ?
   - VSCode
   - IntelliJ / WebStorm / PyCharm
   - Les deux
   - Autre

Si appelé depuis `/git-setup`, utiliser les arguments fournis directement.

---

## Contenu du .gitignore par section

### Section OS

**Mac/Linux :**
```
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
```

**Windows :**
```
Thumbs.db
ehthumbs.db
Desktop.ini
$RECYCLE.BIN/
```

### Section IDE

**VSCode :**
```
.vscode/
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
!.vscode/extensions.json
```

**IntelliJ :**
```
.idea/
*.iws
*.iml
*.ipr
out/
```

### Section Node.js / TypeScript
```
node_modules/
dist/
build/
.next/
.nuxt/
.cache/
*.tsbuildinfo
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.pnpm-debug.log*
.env
.env.local
.env.*.local
```

### Section Python
```
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
.venv/
venv/
ENV/
dist/
build/
*.egg-info/
.pytest_cache/
.mypy_cache/
.ruff_cache/
.env
```

### Section Go
```
*.exe
*.exe~
*.dll
*.so
*.dylib
*.test
*.out
vendor/
```

### Section Java / Kotlin
```
*.class
*.log
*.jar
*.war
*.ear
*.nar
target/
build/
.gradle/
gradle-app.setting
!gradle-wrapper.jar
```

### Section .NET / C#
```
bin/
obj/
*.user
*.suo
*.userosscache
*.sln.docstates
[Dd]ebug/
[Rr]elease/
x64/
x86/
.vs/
```

### Section Rust
```
target/
Cargo.lock
**/*.rs.bk
```

### Section commune (tous projets)
```
.env
.env.*
!.env.example
*.log
*.tmp
*.temp
coverage/
.nyc_output/
```

---

## Exécution

1. Composer le `.gitignore` en assemblant les sections pertinentes selon les réponses
2. Écrire le fichier `.gitignore` à la racine du projet
3. Confirmer la création avec le nombre de règles ajoutées

$ARGUMENTS
