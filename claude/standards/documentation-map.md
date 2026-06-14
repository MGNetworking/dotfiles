# Gabarit — documentation-map.md

Ce fichier est généré par `/bootstrap-context`.
Il décrit les catégories documentaires du projet et les fichiers qui les composent.
C'est lui que lisent les contextes et les commandes pour savoir où chercher la documentation.

## Format obligatoire

```yaml
root: <chemin absolu ou relatif vers la racine de la documentation>

categories:
  business:
    role: "Comment fonctionne le métier ?"
    docs:
      - <chemin-relatif-depuis-root>

  architecture:
    role: "Comment implémenter le métier ?"
    docs:
      - <chemin-relatif-depuis-root>

  product:
    role: "Que livre-t-on ?"
    docs:
      - <chemin-relatif-depuis-root>
```

## Catégories standard

| Catégorie | Question répondue | Contenu typique |
|---|---|---|
| `business` | Comment fonctionne le métier ? | Modèle domaine, règles métier, features |
| `architecture` | Comment implémenter le métier ? | Design applicatif, API, infrastructure, patterns |
| `product` | Que livre-t-on ? | Specs fonctionnelles, checklists, livrables |
| `integrations` | Comment se connecter à un service externe ? | Auth, paiement, imports, webhooks |
| `infrastructure` | Comment construire, configurer et déployer ? | CI/CD, config, jobs planifiés, conteneurs |
| `quality` | Comment valider que le résultat est correct ? | Critères d'acceptance, tests, couverture |

Créer uniquement les catégories qui ont des documents correspondants dans le projet.

## Règles

- `business` contient les documents métier — y compris `design-domain.md`
- `architecture` contient les documents d'implémentation uniquement — jamais `design-domain.md`
- Aucune information sur la structure physique du code dans ce fichier
- Aucune mention de Service, Repository, Controller, couche, classe ou fichier `.cs`
- Lu par les contextes (`contexts/*.md`) et les commandes projet pour résoudre les chemins documentaires
