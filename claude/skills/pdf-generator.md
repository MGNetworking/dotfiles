---
name: pdf-generator
description: Générer des PDFs professionnels avec Quarto/Typst et un template moderne
effort: low
version: 1.0.0
---

# PDF Generator Skill

Générer des PDFs professionnels avec une typographie moderne en utilisant Quarto + Typst.

## Objectif du Skill

Ce skill permet de :

- Configurer des projets Quarto/Typst
- Créer des templates de documents
- Générer des PDFs à partir de Markdown
- Diagnostiquer les problèmes de rendu
- Personnaliser les systèmes de design

## Stack

| Tool       | Version | Rôle                          |
| ---------- | ------- | ----------------------------- |
| **Quarto** | ≥1.4.0  | Moteur de rendu de documents  |
| **Typst**  | 0.13.0  | Typographie moderne (intégré) |
| **Pandoc** | 3.x     | Conversion Markdown (intégré) |

### Pipeline de génération

```
  SOURCE              OUTIL           TEMPLATE              OUTPUT
  ──────              ─────           ────────              ──────

  .qmd  ──────────► Quarto ────► --to whitepaper-typst ──► Typst 0.13 ──► .pdf ✅
  (Markdown           │           (_extensions/               (~270K–1.7M,
  + YAML)             │            typst-template.typ)         stylé)
                      │
                      └──────► --to epub ──► Pandoc ──────────────────► .epub
                                             + epub-styles.css

  ⚠️  --to pdf (sans template) → PDF petit, non stylé → Toujours préférer --to whitepaper-typst
```

### Formats disponibles

```
  ┌──────────────────────┬────────────────────────┬──────────────────┐
  │ Format               │ Commande               │ Sortie           │
  ├──────────────────────┼────────────────────────┼──────────────────┤
  │ PDF stylé ✅         │ --to whitepaper-typst  │ ~270K–1.7M       │
  │ PDF standard ❌      │ --to pdf               │ ~80-190K, brut   │
  │ EPUB                 │ --to epub              │ epub-output/     │
  └──────────────────────┴────────────────────────┴──────────────────┘
```

## Démarrage rapide

### Installation

```bash
# macOS
brew install quarto

# Linux
wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.4.555/quarto-1.4.555-linux-amd64.deb
sudo dpkg -i quarto-1.4.555-linux-amd64.deb

# Windows
winget install Posit.Quarto
```

### Générer un PDF

```bash
# Single file
quarto render document.qmd

# All files
quarto render *.qmd

# Preview with hot-reload
quarto preview document.qmd
```

## Template YAML Frontmatter

```yaml
---
title: "Document Title"
subtitle: "Optional subtitle"
author: "Author Name"
date: 2026-01-17
date-format: "MMMM YYYY"
format:
  typst:
    toc: true
    toc-depth: 2
    section-numbering: "1.1"
lang: en
---
```

### Paramètres disponibles

| Parameter           | Type    | Description          |
| ------------------- | ------- | -------------------- |
| `title`             | string  | Titre principal      |
| `subtitle`          | string  | Sous-titre optionnel |
| `author`            | string  | Auteur(s)            |
| `date`              | date    | Format ISO           |
| `date-format`       | string  | Format affiché       |
| `toc`               | boolean | Table des matières   |
| `toc-depth`         | number  | Profondeur TOC       |
| `section-numbering` | string  | Format               |
| `lang`              | string  | Langue               |

## Structure du projet

```
project/
├── _extensions/
│   └── custom-template/
│       ├── _extension.yml
│       ├── typst-template.typ
│       └── typst-show.typ
├── document.qmd
└── document.pdf
```

## Syntaxe Markdown

### Sauts de page

```markdown
{{< pagebreak >}}
```

### Code blocks

````markdown
```bash
npm install
```
````

### Tables

```markdown
| Column A | Column B |
| -------- | -------- |
| Value 1  | Value 2  |
```

### Images

```markdown
![Caption](path/to/image.png){width=50%}
```

## Template personnalisé

### Configuration extension

```yaml
title: My Template
author: Your Name
version: 1.0.0
contributes:
  formats:
    typst:
      template: typst-template.typ
      template-partials:
        - typst-show.typ
```

### Design System (Typst)

```typst
#let primary = rgb("#0f172a")
#let secondary = rgb("#334155")
#let accent = rgb("#6366f1")
#let muted = rgb("#64748b")
#let light-bg = rgb("#f8fafc")
#let border-light = rgb("#e2e8f0")
```

### Typographie

```typst
#set text(
  font: ("Inter", "Helvetica Neue", "Arial"),
  size: 11pt,
)

#set par(
  leading: 0.75em,
  justify: true,
)
```

## Troubleshooting

### Validation rapide

````bash
quarto --version
ls _extensions/*/
grep -c '^```' document.qmd
file -i document.qmd
````

### Problèmes courants

| Issue      | Cause        | Fix       |
| ---------- | ------------ | --------- |
| Code cassé | mauvais ```  | ajuster   |
| Extension  | mauvais path | corriger  |
| Encoding   | mauvais UTF  | convertir |

## Cas d’usage

Documentation technique, whitepapers, rapports internes

## Ressources

- https://quarto.org/docs/guide/
- https://typst.app/docs/
- https://quarto.org/docs/output-formats/typst.html
