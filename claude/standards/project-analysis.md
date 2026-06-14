# Gabarit — project-analysis.md

Ce fichier est généré par `/bootstrap-context`.
Il décrit uniquement la structure physique du projet — aucune information documentaire.

## Format obligatoire

```yaml
code:
  root: <chemin du code source>

tests:
  root: <chemin des tests>

stack:
  language: <ex: C# 13>
  framework: <ex: ASP.NET Core 10>
  test-framework: <ex: xUnit + Moq>

architecture:
  style: <DDD 4 couches | hexagonale | monolithe | microservices>

layers:
  <nom-couche>:
    project: <nom-exact-du-projet-ou-dossier>
    role: <Domain | Application | Infrastructure | API>

conventions:
  services: <ex: XxxService>
  repositories: <ex: IXxxRepository>
  tests: <ex: XxxTest>
```

## Règles

- Aucune référence documentaire dans ce fichier
- Mis à jour par `/bootstrap-context` à chaque exécution
- Lu par les commandes pour résoudre les chemins de code uniquement
