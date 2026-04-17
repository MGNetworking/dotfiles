# Référence niveaux — .NET Backend

> Consulter en fin de phase pour se situer sur le marché.

---

## Tableau de progression

| Phases | Ce que tu maîtrises | Niveau marché |
|---|---|---|
| 1–6, 6.5 | REST API, architecture en couches, DI, DTOs, gestion d'erreurs, tests unitaires, async/await | Junior+ |
| 7–10 | SOLID, DDD (Aggregate Root, Value Object, record), EF Core, LINQ complet, pagination, IDisposable | Intermédiaire |
| 11–13 | FluentValidation, mapping DTO (AutoMapper), logging structuré (Serilog), Options Pattern | Intermédiaire confirmé |
| 14–16 | JWT, versioning d'API, documentation OpenAPI/Swagger | Senior junior |
| 17   | Clean Architecture, CQRS, MediatR | Senior / Avancé |
| 18–22 | HttpClient/IHttpClientFactory, Background services, Caching, Minimal APIs, Multi-tenancy | Senior+ |

---

## Ce que chaque niveau permet de faire

### Junior+ (phases 1–6)
- Créer une API REST complète avec toutes les routes CRUD
- Organiser le code en couches sans mélanger les responsabilités
- Écrire des tests unitaires avec xUnit et Moq
- Gérer les erreurs de façon centralisée et cohérente

### Intermédiaire (phases 7–10)
- Analyser et corriger des violations SOLID dans un projet existant
- Modéliser un domaine riche avec DDD (règles métier dans l'entité, Value Objects)
- Intégrer EF Core avec migrations, ValueConverter, configuration fluente
- Écrire des tests d'intégration avec `WebApplicationFactory`

### Intermédiaire confirmé (phases 11–13)
- Centraliser la validation avec FluentValidation
- Ajouter du logging structuré avec différents niveaux et outputs (Serilog)
- Gérer la configuration typée avec `IOptions<T>`, `user-secrets`, variables d'environnement

### Senior junior (phases 14–16)
- Sécuriser une API avec JWT (génération, validation, claims, rôles)
- Versionner une API sans casser les clients existants
- Documenter une API avec OpenAPI/Swagger (annotations, auth JWT, ProducesResponseType)

### Senior / Avancé (phase 17)
- Structurer un projet en Clean Architecture (règle de dépendance)
- Implémenter CQRS avec MediatR (commands, queries, handlers séparés)

### Senior+ (phases 18–21)
- Appeler des APIs externes de façon résiliente avec `IHttpClientFactory` et Polly
- Implémenter des Background Services avec arrêt propre et gestion des scopes
- Mettre en cache avec `IMemoryCache` / `IDistributedCache` (Redis)
- Structurer une API avec les Minimal APIs (groupes, TypedResults, validation)

---

## Référence fiches de révision

| Phases | Fiche |
|---|---|
| 1–6, 6.5 | `resources/dotnet/fiches-phases1-6.md` |
| 7–10 | `resources/dotnet/fiches-phases7-10.md` |
| 11–13 | `resources/dotnet/fiches-phases11-13.md` |
| 14–16 | `resources/dotnet/fiches-phases14-16.md` |
| 17   | `resources/dotnet/fiches-phase17.md` |
| 18–21 | `resources/dotnet/fiches-phases18-21.md` |
