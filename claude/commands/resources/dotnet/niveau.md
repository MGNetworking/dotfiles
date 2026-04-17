# Référence niveaux — .NET Backend

> Consulter pour se situer sur le marché.

---

## Tableau de progression

| Module | Ce que tu maîtrises | Niveau marché |
|---|---|---|
| api | REST API, architecture en couches, DI, DTOs, gestion d'erreurs, tests unitaires, async/await | Junior+ |
| architecture | SOLID, DDD (Aggregate Root, Value Object, record), EF Core, LINQ complet, pagination, IDisposable | Intermédiaire |
| patterns | FluentValidation, mapping DTO (AutoMapper), logging structuré (Serilog), Options Pattern | Intermédiaire confirmé |
| security | JWT, versioning d'API, documentation OpenAPI/Swagger | Senior junior |
| advanced | Clean Architecture, CQRS, MediatR | Senior / Avancé |
| performance + multitenancy | HttpClient/IHttpClientFactory, Background services, Caching, Minimal APIs, Multi-tenancy | Senior+ |

---

## Ce que chaque niveau permet de faire

### Junior+ (module api)
- Créer une API REST complète avec toutes les routes CRUD
- Organiser le code en couches sans mélanger les responsabilités
- Écrire des tests unitaires avec xUnit et Moq
- Gérer les erreurs de façon centralisée et cohérente

### Intermédiaire (module architecture)
- Analyser et corriger des violations SOLID dans un projet existant
- Modéliser un domaine riche avec DDD (règles métier dans l'entité, Value Objects)
- Intégrer EF Core avec migrations, ValueConverter, configuration fluente
- Écrire des tests d'intégration avec `WebApplicationFactory`

### Intermédiaire confirmé (module patterns)
- Centraliser la validation avec FluentValidation
- Ajouter du logging structuré avec différents niveaux et outputs (Serilog)
- Gérer la configuration typée avec `IOptions<T>`, `user-secrets`, variables d'environnement

### Senior junior (module security)
- Sécuriser une API avec JWT (génération, validation, claims, rôles)
- Versionner une API sans casser les clients existants
- Documenter une API avec OpenAPI/Swagger (annotations, auth JWT, ProducesResponseType)

### Senior / Avancé (module advanced)
- Structurer un projet en Clean Architecture (règle de dépendance)
- Implémenter CQRS avec MediatR (commands, queries, handlers séparés)

### Senior+ (modules performance + multitenancy)
- Appeler des APIs externes de façon résiliente avec `IHttpClientFactory` et Polly
- Implémenter des Background Services avec arrêt propre et gestion des scopes
- Mettre en cache avec `IMemoryCache` / `IDistributedCache` (Redis)
- Structurer une API avec les Minimal APIs (groupes, TypedResults, validation)

---

## Référence fiches de révision

| Module | Fiche |
|---|---|
| api | `resources/dotnet/module-api.md` |
| architecture | `resources/dotnet/module-architecture.md` |
| efcore-setup | `resources/dotnet/module-efcore-setup.md` |
| efcore | `resources/dotnet/module-efcore.md` |
| testing | `resources/dotnet/module-testing.md` |
| patterns | `resources/dotnet/module-patterns.md` |
| security | `resources/dotnet/module-security.md` |
| advanced | `resources/dotnet/module-advanced.md` |
| performance | `resources/dotnet/module-performance.md` |
| multitenancy | `resources/dotnet/module-multitenancy.md` |
