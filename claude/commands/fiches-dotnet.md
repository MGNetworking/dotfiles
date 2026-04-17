---
name: fiches-dotnet
description: "Fiches de révision .NET — liste les concepts disponibles ou ouvre une fiche"
---

# Fiches de révision .NET

## Utilisation

```
/fiches-dotnet          # Affiche le menu des fiches avec leurs concepts
/fiches-dotnet 1-6      # Ouvre la fiche phases 1–6 (Junior+)
/fiches-dotnet 7-10     # Ouvre la fiche phases 7–10 (Intermédiaire)
/fiches-dotnet 11-13    # Ouvre la fiche phases 11–13 (Intermédiaire confirmé)
/fiches-dotnet 14-16    # Ouvre la fiche phases 14–16 (Senior junior)
/fiches-dotnet 17       # Ouvre la fiche phase 17 (Senior / Avancé)
/fiches-dotnet 18-21    # Ouvre la fiche phases 18–21 (Senior+)
/fiches-dotnet niveau   # Ouvre le tableau de progression marché
```

## Instructions

### Si aucun argument n'est fourni

Lis les 5 fiches de révision et le fichier niveau, puis affiche un menu structuré comme ceci :

```
Quelle fiche veux-tu ouvrir ?

[1-6]   Junior+
        REST API · Architecture en couches · Interfaces & DI
        DTOs & PATCH · Gestion des erreurs · Tests unitaires (xUnit + Moq)
        async/await · CancellationToken · Task<T>

[7-10]  Intermédiaire
        SOLID (5 principes) · DDD (Aggregate Root, Value Object, record)
        Entity Framework Core · LINQ complet · Pagination · IDisposable
        Tests d'intégration

[11-13] Intermédiaire confirmé
        FluentValidation · Mapping DTO (AutoMapper, ProjectTo)
        Logging (ILogger, Serilog) · Configuration & Options Pattern

[14-16] Senior junior
        Authentification JWT · Versioning d'API
        Documentation Swagger / OpenAPI

[17]    Senior / Avancé
        Clean Architecture · CQRS · MediatR

[18-21] Senior+
        HttpClient & IHttpClientFactory · Background Services
        Caching (IMemoryCache, Redis) · Minimal APIs · Multi-tenancy

[niveau] Tableau de progression marché

→ Tape le numéro de groupe (ex: 7-10) pour ouvrir la fiche.
```

Puis attends la réponse de l'utilisateur et charge la fiche correspondante.

### Si un argument est fourni

- `1-6` → lis et affiche le contenu de `commands/resources/dotnet/fiches-phases1-6.md`
- `7-10` → lis et affiche le contenu de `commands/resources/dotnet/fiches-phases7-10.md`
- `11-13` → lis et affiche le contenu de `commands/resources/dotnet/fiches-phases11-13.md`
- `14-16` → lis et affiche le contenu de `commands/resources/dotnet/fiches-phases14-16.md`
- `17` → lis et affiche le contenu de `commands/resources/dotnet/fiches-phase17.md`
- `18-21` → lis et affiche le contenu de `commands/resources/dotnet/fiches-phases18-21.md`
- `niveau` → lis et affiche le contenu de `commands/resources/dotnet/niveau.md`

Si l'argument ne correspond à aucune valeur connue, affiche la liste des valeurs valides.

$ARGUMENTS
