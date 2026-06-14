# Gabarit — Fichier contexte

Un fichier contexte est un **index de navigation documentaire**.
Il répond à une seule question : "Pour répondre à cette question, quels documents dois-je lire, et dans quel ordre ?"

Il ne contient pas de connaissance. La connaissance est dans la documentation.

## Les 6 contextes universels

| Fichier | Question couverte |
|---|---|
| `product.md` | Que fait ce produit, pour qui, dans quel périmètre ? |
| `business.md` | Quelles sont les règles métier de cette fonctionnalité ? |
| `architecture.md` | Comment implémenter une fonctionnalité dans l'architecture ? |
| `integrations.md` | Comment ce projet se connecte à un service externe ? |
| `infrastructure.md` | Comment construire, configurer et déployer le système ? |
| `quality.md` | Comment valider que le résultat est correct ? |

Si un contexte n'a pas de documentation correspondante dans le projet : ne pas le créer.

## Format obligatoire

```markdown
# <nom-du-contexte>

> Répond à : "<question couverte>"

## Documentation — ordre de lecture

1. <chemin-relatif-depuis-documentation-map.root>
2. <chemin-relatif-depuis-documentation-map.root>
3. ...

## Tags

`tag-métier` `tag-métier` `tag-métier`
```

## Règles

- `Documentation` : chemins relatifs depuis `root` défini dans `.claude/documentation-map.md`
- L'ordre de lecture est intentionnel — du plus général au plus spécifique
- `Tags` : mots-clés métier libres — servent à orienter la recherche
- Zéro contenu métier — zéro règle — zéro invariant — zéro cas d'usage
- Zéro chemin vers le code source (`.cs`, `.ts`, `.java`…)
- Zéro référence aux couches techniques (Service, Repository, Controller…)
- La source de vérité est la documentation, pas ce fichier

## Critère de validation

> Si je supprime toute la documentation du projet, ce fichier reste-t-il utile ?

- **Oui** → il contient trop de connaissance. Le corriger.
- **Non** → il joue correctement son rôle d'index.
