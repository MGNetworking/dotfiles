---
name: fiches-dotnet
description: "Fiches de révision .NET — liste les modules disponibles ou ouvre un module"
---

# Modules de révision .NET

## Utilisation

```
/fiches-dotnet               → Affiche le menu de tous les modules
/fiches-dotnet api           → REST API, DTOs, DI, async/await, tests unitaires
/fiches-dotnet architecture  → SOLID, DDD (Aggregate Root, Value Object)
/fiches-dotnet efcore        → EF Core avancé : providers, IQueryable, N+1, migrations
/fiches-dotnet efcore-setup  → EF Core setup : packages, DbContext, migrations, AppDbContextFactory
/fiches-dotnet patterns      → FluentValidation, AutoMapper, Logging, Options Pattern
/fiches-dotnet security      → JWT, versioning d'API, OpenAPI/Swagger
/fiches-dotnet testing       → Tests unitaires (xUnit, Moq, controllers)
/fiches-dotnet advanced      → Clean Architecture, CQRS, MediatR
/fiches-dotnet performance     → HttpClient, Background Services, Caching, Minimal APIs
/fiches-dotnet multitenancy   → Multi-tenancy : row-level, HasQueryFilter, ITenantResolver
/fiches-dotnet niveau         → Tableau de progression marché
```

## Instructions

### Si aucun argument n'est fourni

Affiche le menu suivant puis attends la réponse de l'utilisateur :

```
Quel module veux-tu ouvrir ?

[api]           Junior
                REST API · Architecture en couches · DI · DTOs & PATCH
                Gestion des erreurs · Tests unitaires (xUnit + Moq) · async/await

[architecture]  Mid
                SOLID (5 principes) · DDD (Aggregate Root, Value Object)
                Tests d'intégration · LINQ · Pagination

[efcore]        Mid
                Providers · IQueryable vs IEnumerable · Exécution différée
                Compatibilité LINQ/SQL · Anti-pattern N+1 · Changement de BD

[efcore-setup]  Mid
                Packages NuGet · AppDbContext · ValueConverter
                AppDbContextFactory · migrations add vs Migrate() · __EFMigrationsHistory

[patterns]      Mid confirmé
                FluentValidation · AutoMapper · Logging (Serilog) · Options Pattern

[security]      Senior junior
                Authentification JWT · Versioning d'API · OpenAPI/Swagger

[testing]       Junior → Mid
                Tests unitaires (xUnit, Moq) · Arrange/Act/Assert
                Tests controllers · ActionResult<T> · Verify

[advanced]      Senior
                Clean Architecture · CQRS · MediatR

[performance]      Senior+
                   HttpClient & IHttpClientFactory · Background Services
                   Caching (IMemoryCache, Redis) · Minimal APIs

[multitenancy]     Senior+
                   Stratégies d'isolation · HasQueryFilter · ITenantResolver
                   Risques de fuite · Cache multi-tenant

[niveau]           Tableau de progression marché

→ Tape le nom du module pour l'ouvrir.
```

### Si un argument est fourni

- `api`          → lis et affiche `commands/resources/dotnet/module-api.md`
- `architecture` → lis et affiche `commands/resources/dotnet/module-architecture.md`
- `efcore`       → lis et affiche `commands/resources/dotnet/module-efcore.md`
- `efcore-setup` → lis et affiche `commands/resources/dotnet/module-efcore-setup.md`
- `patterns`     → lis et affiche `commands/resources/dotnet/module-patterns.md`
- `security`     → lis et affiche `commands/resources/dotnet/module-security.md`
- `testing`      → lis et affiche `commands/resources/dotnet/module-testing.md`
- `advanced`     → lis et affiche `commands/resources/dotnet/module-advanced.md`
- `performance`    → lis et affiche `commands/resources/dotnet/module-performance.md`
- `multitenancy`   → lis et affiche `commands/resources/dotnet/module-multitenancy.md`
- `niveau`         → lis et affiche `commands/resources/dotnet/niveau.md`

Si l'argument ne correspond à aucune valeur connue, affiche la liste des modules valides.

$ARGUMENTS
