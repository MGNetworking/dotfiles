# Fiches de révision — Phases 18 à 21
# Niveau : Senior junior+ / Avancé

> Consulte ces fiches pour réviser un concept précis ou t'auto-évaluer.
> Pour un quiz interactif sur ton code actuel, utilise `/learn:quiz`.
>
> **Score minimum** : 12/15 pour valider le niveau

---

## PHASE 18 — HttpClient et appels vers des APIs externes

### Vocabulaire clé
| Terme | Tu sais l'expliquer ? |
|---|---|
| `HttpClient` | ⬜ |
| `IHttpClientFactory` | ⬜ |
| Named client | ⬜ |
| Typed client | ⬜ |
| Socket exhaustion | ⬜ |

### Questions

**Q111.** `[Facile]` Pourquoi ne pas instancier `HttpClient` avec `new HttpClient()` dans un service ? Quel problème cela cause-t-il ?

<!-- EXEMPLE: Montre comment un service qui crée un HttpClient à chaque appel peut épuiser les sockets disponibles -->

<details>
<summary>Réponse</summary>

Instancier et disposer `HttpClient` à chaque requête cause un **socket exhaustion** : les sockets TCP ne sont pas libérés immédiatement (état TIME_WAIT), ce qui peut épuiser les ports disponibles sous charge.

```csharp
// ❌ Dangereux : crée/ferme une connexion TCP à chaque appel
public async Task<string> GetData()
{
    using var client = new HttpClient();
    return await client.GetStringAsync("https://api.exemple.com/data");
}
```

Solution : utiliser `IHttpClientFactory` qui gère le cycle de vie des `HttpMessageHandler` et réutilise les connexions TCP.

</details>

---

**Q112.** `[Normal]` Comment configure-t-on un Named Client avec `IHttpClientFactory` dans ASP.NET Core ?

<!-- EXEMPLE: Montre comment configurer un client pour appeler une API externe depuis le projet courant -->

<details>
<summary>Réponse</summary>

```csharp
// Program.cs
builder.Services.AddHttpClient("ExterneApi", client =>
{
    client.BaseAddress = new Uri("https://api.externe.com/");
    client.DefaultRequestHeaders.Add("Accept", "application/json");
    client.Timeout = TimeSpan.FromSeconds(30);
});

// Service
public class ExterneService(IHttpClientFactory factory)
{
    public async Task<string> GetAsync(CancellationToken ct)
    {
        var client = factory.CreateClient("ExterneApi");
        return await client.GetStringAsync("endpoint", ct);
    }
}
```

</details>

---

**Q113.** `[Normal]` Qu'est-ce qu'un Typed Client ? En quoi diffère-t-il d'un Named Client ?

<!-- EXEMPLE: Montre comment créer un client typé pour encapsuler les appels vers une API externe -->

<details>
<summary>Réponse</summary>

Un Typed Client encapsule `HttpClient` dans une classe dédiée avec des méthodes métier — plus orienté objet qu'un Named Client.

```csharp
// Typed Client
public class ExterneApiClient(HttpClient client)
{
    public async Task<ExterneDto?> GetResourceAsync(int id, CancellationToken ct)
        => await client.GetFromJsonAsync<ExterneDto>($"resources/{id}", ct);

    public async Task CreateAsync(CreateDto dto, CancellationToken ct)
        => await client.PostAsJsonAsync("resources", dto, ct);
}

// Program.cs
builder.Services.AddHttpClient<ExterneApiClient>(client =>
{
    client.BaseAddress = new Uri("https://api.externe.com/");
});

// Injection directe dans le service
public class MonService(ExterneApiClient apiClient) { ... }
```

**Named Client** → flexible, plusieurs URLs différentes. **Typed Client** → meilleure encapsulation, méthodes métier claires.

</details>

---

**Q114.** `[Difficile]` Comment gère-t-on les erreurs HTTP (5xx, timeout) lors d'appels externes ? Cite deux stratégies de résilience.

<!-- EXEMPLE: Montre comment ajouter un retry et un circuit breaker sur un client HTTP du projet courant -->

<details>
<summary>Réponse</summary>

```csharp
// 1. Vérification du statut HTTP
var response = await client.GetAsync("endpoint", ct);
response.EnsureSuccessStatusCode(); // lance HttpRequestException si 4xx/5xx

// 2. Polly — retry + circuit breaker (Microsoft.Extensions.Http.Resilience)
builder.Services.AddHttpClient<ExterneApiClient>()
    .AddStandardResilienceHandler(); // retry + circuit breaker préconfigurés

// Ou configuration manuelle avec Polly
builder.Services.AddHttpClient<ExterneApiClient>()
    .AddTransientHttpErrorPolicy(p =>
        p.WaitAndRetryAsync(3,
            retryAttempt => TimeSpan.FromSeconds(Math.Pow(2, retryAttempt))))
    .AddTransientHttpErrorPolicy(p =>
        p.CircuitBreakerAsync(5, TimeSpan.FromSeconds(30)));
```

**Retry avec backoff exponentiel** : réessaie en cas d'erreur transitoire (timeout, 503). Le délai augmente à chaque tentative pour ne pas surcharger le service distant.

**Circuit Breaker** : après N échecs consécutifs, coupe les appels pendant une durée → évite d'aggraver une panne et protège les ressources.

</details>

---

**Q115.** `[Normal]` Comment désérialise-t-on une réponse JSON depuis une API externe avec `HttpClient` ?

<!-- EXEMPLE: Montre comment récupérer et désérialiser la réponse d'une API externe dans le projet courant -->

<details>
<summary>Réponse</summary>

```csharp
// Méthode recommandée (System.Net.Http.Json — inclus dans .NET 6+)
var dto = await client.GetFromJsonAsync<ExterneDto>("endpoint", ct);

// POST avec JSON
var response = await client.PostAsJsonAsync("endpoint", payload, ct);
response.EnsureSuccessStatusCode();
var created = await response.Content.ReadFromJsonAsync<ExterneDto>(ct);

// Désérialisation manuelle (si besoin de contrôle)
var response = await client.GetAsync("endpoint", ct);
response.EnsureSuccessStatusCode();
var content = await response.Content.ReadAsStringAsync(ct);
var dto = JsonSerializer.Deserialize<ExterneDto>(content);
```

`System.Net.Http.Json` évite d'installer `Newtonsoft.Json` pour les cas courants.

</details>

### Mon suivi — Phase 18

| Date | Score | À revoir |
|------|-------|----------|
| | /5 | |

---

## PHASE 19 — Background Services

### Vocabulaire clé
| Terme | Tu sais l'expliquer ? |
|---|---|
| `IHostedService` | ⬜ |
| `BackgroundService` | ⬜ |
| `ExecuteAsync` | ⬜ |
| `stoppingToken` | ⬜ |
| Scoped service dans un Singleton | ⬜ |

### Questions

**Q116.** `[Facile]` Qu'est-ce qu'un Background Service en ASP.NET Core ? Dans quels cas l'utiliser ?

<!-- EXEMPLE: Décris un cas d'usage concret de background service pour le projet courant (ex: purge de données, notification) -->

<details>
<summary>Réponse</summary>

Un Background Service s'exécute en arrière-plan, indépendamment des requêtes HTTP.

Cas d'usage courants :
- Traitement de messages depuis une queue (RabbitMQ, Azure Service Bus)
- Nettoyage périodique (purge de logs, sessions expirées)
- Synchronisation avec une API externe
- Envoi d'emails différés

```csharp
public class PurgeService : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            await PurgeExpiredDataAsync(stoppingToken);
            await Task.Delay(TimeSpan.FromHours(1), stoppingToken);
        }
    }
}
```

</details>

---

**Q117.** `[Normal]` Quelle est la différence entre `IHostedService` et `BackgroundService` ? Quand utiliser l'un ou l'autre ?

<!-- EXEMPLE: Montre la structure de base des deux interfaces -->

<details>
<summary>Réponse</summary>

- `IHostedService` : interface bas niveau avec `StartAsync` et `StopAsync`. À implémenter directement pour un contrôle total du cycle de vie (ex : démarrer/arrêter une connexion à une queue).
- `BackgroundService` : classe abstraite qui implémente `IHostedService` et expose uniquement `ExecuteAsync`. Couvre 90% des cas — plus simple.

```csharp
// IHostedService : contrôle total
public class MonService : IHostedService
{
    public Task StartAsync(CancellationToken ct) { /* connexion */ return Task.CompletedTask; }
    public Task StopAsync(CancellationToken ct) { /* déconnexion propre */ return Task.CompletedTask; }
}

// BackgroundService : boucle principale simplifiée
public class MonService : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        // CancellationToken géré automatiquement à l'arrêt de l'app
    }
}
```

</details>

---

**Q118.** `[Difficile]` Comment utiliser un service `Scoped` (ex : `DbContext`) dans un `BackgroundService` qui est `Singleton` ?

<!-- EXEMPLE: Montre comment accéder au DbContext depuis un background service sans InvalidOperationException -->

<details>
<summary>Réponse</summary>

Un `BackgroundService` est `Singleton`. On ne peut pas injecter directement un service `Scoped` dans un Singleton — cela lève une `InvalidOperationException`.

Solution : utiliser `IServiceScopeFactory` pour créer un scope manuellement :

```csharp
public class MonBackgroundService(IServiceScopeFactory scopeFactory) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken ct)
    {
        while (!ct.IsCancellationRequested)
        {
            using var scope = scopeFactory.CreateScope();
            var dbContext = scope.ServiceProvider
                .GetRequiredService<AppDbContext>();

            await DoWorkAsync(dbContext, ct);

            await Task.Delay(TimeSpan.FromMinutes(1), ct);
        } // scope.Dispose() → dbContext.Dispose() automatique
    }
}
```

</details>

---

**Q119.** `[Normal]` Comment s'assure-t-on qu'un Background Service s'arrête proprement sans perdre de données ?

<!-- EXEMPLE: Montre la gestion du CancellationToken et des exceptions dans la boucle principale -->

<details>
<summary>Réponse</summary>

```csharp
// Program.cs
builder.Services.AddHostedService<MonBackgroundService>();

// BackgroundService : arrêt propre
protected override async Task ExecuteAsync(CancellationToken stoppingToken)
{
    while (!stoppingToken.IsCancellationRequested)
    {
        try
        {
            await DoWorkAsync(stoppingToken);
        }
        catch (OperationCanceledException)
        {
            break; // arrêt demandé → sortie propre
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erreur dans le background service");
            // Ne pas relancer l'exception : le service continuerait à tourner
        }

        await Task.Delay(TimeSpan.FromSeconds(30), stoppingToken);
    }
}
```

`stoppingToken` est annulé automatiquement quand l'application s'arrête (Ctrl+C, redémarrage). Le passer à toutes les opérations async garantit un arrêt propre.

</details>

### Mon suivi — Phase 19

| Date | Score | À revoir |
|------|-------|----------|
| | /4 | |

---

## PHASE 20 — Caching

### Vocabulaire clé
| Terme | Tu sais l'expliquer ? |
|---|---|
| `IMemoryCache` | ⬜ |
| `IDistributedCache` | ⬜ |
| Cache-Aside pattern | ⬜ |
| TTL (Time To Live) | ⬜ |
| Cache invalidation | ⬜ |

### Questions

**Q120.** `[Normal]` Qu'est-ce que `IMemoryCache` ? Comment l'utiliser avec le pattern Cache-Aside ?

<!-- EXEMPLE: Ajoute un cache mémoire sur la méthode GetById du service du projet courant -->

<details>
<summary>Réponse</summary>

`IMemoryCache` stocke des données en mémoire dans le processus courant. Le **Cache-Aside** est le pattern le plus courant : lire le cache, si absent charger depuis la source, mettre en cache.

```csharp
// Program.cs
builder.Services.AddMemoryCache();

// Service
public class MonService(IMemoryCache cache, IRepository repository)
{
    public async Task<Entity?> GetByIdAsync(int id, CancellationToken ct)
    {
        var cacheKey = $"entity:{id}";

        if (cache.TryGetValue(cacheKey, out Entity? cached))
            return cached; // cache hit

        var entity = await repository.GetByIdAsync(id, ct); // cache miss

        if (entity is not null)
            cache.Set(cacheKey, entity, TimeSpan.FromMinutes(5)); // TTL : 5 min

        return entity;
    }
}
```

</details>

---

**Q121.** `[Normal]` Quelle est la différence entre `IMemoryCache` et `IDistributedCache` ? Quand utiliser l'un ou l'autre ?

<!-- EXEMPLE: Explique pourquoi IMemoryCache ne fonctionne pas correctement derrière un load balancer avec plusieurs instances -->

<details>
<summary>Réponse</summary>

| | `IMemoryCache` | `IDistributedCache` |
|---|---|---|
| Stockage | Mémoire du processus | Externe (Redis, SQL Server) |
| Partage entre instances | Non | Oui |
| Survie au restart | Non | Oui (selon le provider) |
| Sérialisation | Non nécessaire | Obligatoire (byte[]) |

```csharp
// IDistributedCache avec Redis
builder.Services.AddStackExchangeRedisCache(options =>
    options.Configuration = config["Redis:ConnectionString"]);

// Usage
await cache.SetStringAsync("key",
    JsonSerializer.Serialize(data),
    new DistributedCacheEntryOptions
    {
        AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(5)
    }, ct);

var raw = await cache.GetStringAsync("key", ct);
var data = raw is not null ? JsonSerializer.Deserialize<MonType>(raw) : null;
```

`IMemoryCache` : application mono-instance ou données non critiques. `IDistributedCache` : application scalée avec plusieurs instances.

</details>

---

**Q122.** `[Difficile]` Qu'est-ce que la cache invalidation ? Cite deux stratégies pour garder le cache cohérent avec la BDD.

<!-- EXEMPLE: Montre comment invalider le cache lors d'une mise à jour dans le service du projet courant -->

<details>
<summary>Réponse</summary>

La cache invalidation consiste à retirer ou mettre à jour les entrées en cache quand les données sources changent.

**Stratégie 1 — Invalidation active** : supprimer l'entrée du cache lors d'une écriture.
```csharp
public async Task UpdateAsync(int id, UpdateDto dto, CancellationToken ct)
{
    await _repository.UpdateAsync(id, dto, ct);
    _cache.Remove($"entity:{id}"); // invalider immédiatement
}
```

**Stratégie 2 — TTL court** : laisser le cache expirer naturellement. Simple à implémenter, mais accepte des données potentiellement périmées pendant la durée du TTL. Adapté pour des données de référence qui changent rarement (pays, catégories…).

Règle : invalidation active pour les données qui changent fréquemment et dont la cohérence est critique. TTL seul pour les données stables ou à faible impact si périmées.

</details>

### Mon suivi — Phase 20

| Date | Score | À revoir |
|------|-------|----------|
| | /3 | |

---

## PHASE 21 — Minimal APIs

### Vocabulaire clé
| Terme | Tu sais l'expliquer ? |
|---|---|
| Minimal API | ⬜ |
| `app.MapGet` / `app.MapPost` | ⬜ |
| `RouteGroupBuilder` | ⬜ |
| `TypedResults` | ⬜ |
| Controllers vs Minimal APIs | ⬜ |

### Questions

**Q123.** `[Facile]` Qu'est-ce que les Minimal APIs en ASP.NET Core ? Quand les préférer aux Controllers ?

<!-- EXEMPLE: Réécris l'endpoint GET du projet courant en Minimal API -->

<details>
<summary>Réponse</summary>

Les Minimal APIs (ASP.NET Core 6+) définissent des endpoints directement dans `Program.cs` sans classe Controller. Moins de boilerplate, démarrage plus rapide.

```csharp
app.MapGet("/ressources/{id:int}", async (int id, IMonService service, CancellationToken ct) =>
{
    var entity = await service.GetByIdAsync(id, ct);
    return entity is null ? Results.NotFound() : Results.Ok(entity);
});

app.MapPost("/ressources", async (CreateDto dto, IMonService service, CancellationToken ct) =>
{
    var created = await service.CreateAsync(dto, ct);
    return Results.CreatedAtRoute("GetById", new { id = created.Id }, created);
});
```

**Préférer Minimal APIs** : microservices simples, APIs légères, prototypes, performance de démarrage critique.
**Préférer Controllers** : APIs complexes avec beaucoup d'endpoints, filtres/attributs, équipes habituées MVC.

</details>

---

**Q124.** `[Normal]` Comment organise-t-on les Minimal APIs pour éviter un `Program.cs` monolithique ?

<!-- EXEMPLE: Montre comment extraire les endpoints d'une ressource dans une extension dédiée -->

<details>
<summary>Réponse</summary>

```csharp
// Extension par ressource
public static class EntiteEndpoints
{
    public static RouteGroupBuilder MapEntiteEndpoints(this RouteGroupBuilder group)
    {
        group.MapGet("/", GetAll);
        group.MapGet("/{id:int}", GetById).WithName("GetById");
        group.MapPost("/", Create);
        group.MapPut("/{id:int}", Update);
        group.MapDelete("/{id:int}", Delete);
        return group;
    }

    private static async Task<IResult> GetAll(
        IMonService service, CancellationToken ct)
        => TypedResults.Ok(await service.GetAllAsync(ct));

    private static async Task<IResult> GetById(
        int id, IMonService service, CancellationToken ct)
    {
        var entity = await service.GetByIdAsync(id, ct);
        return entity is null ? TypedResults.NotFound() : TypedResults.Ok(entity);
    }
    // ...
}

// Program.cs : propre et lisible
app.MapGroup("/api/v1/entites")
    .MapEntiteEndpoints()
    .WithTags("Entites")
    .RequireAuthorization();
```

`TypedResults` (ASP.NET Core 7+) génère automatiquement la documentation OpenAPI des codes HTTP retournés, sans `[ProducesResponseType]`.

</details>

---

**Q125.** `[Normal]` Comment ajoute-t-on la validation FluentValidation sur un endpoint Minimal API ?

<!-- EXEMPLE: Montre comment valider le DTO de création dans un endpoint Minimal API -->

<details>
<summary>Réponse</summary>

Contrairement aux Controllers avec `[ApiController]`, les Minimal APIs n'ont pas de validation automatique. Il faut la déclencher manuellement ou via un filtre.

```csharp
// Option 1 : validation manuelle dans l'endpoint
app.MapPost("/ressources", async (
    CreateDto dto,
    IValidator<CreateDto> validator,
    IMonService service,
    CancellationToken ct) =>
{
    var validation = await validator.ValidateAsync(dto, ct);
    if (!validation.IsValid)
        return Results.ValidationProblem(validation.ToDictionary());

    var created = await service.CreateAsync(dto, ct);
    return Results.CreatedAtRoute("GetById", new { id = created.Id }, created);
});

// Option 2 : filtre de validation réutilisable
app.MapPost("/ressources", CreateEndpoint)
   .AddEndpointFilter<ValidationFilter<CreateDto>>();
```

`Results.ValidationProblem()` retourne un 400 au format `ProblemDetails` standard (RFC 7807).

</details>

### Mon suivi — Phase 21

| Date | Score | À revoir |
|------|-------|----------|
| | /3 | |

---

## Score — Niveau Senior+

| Phase | Questions | Score |
|---|---|---|
| Phase 18 — HttpClient | Q111 à Q115 | /5 |
| Phase 19 — Background Services | Q116 à Q119 | /4 |
| Phase 20 — Caching | Q120 à Q122 | /3 |
| Phase 21 — Minimal APIs | Q123 à Q125 | /3 |
| **Total** | | **/15** |

> **12/15 et plus** → Niveau maîtrisé
> **Moins de 12/15** → Consulte `dotnet/niveau.md` pour identifier les points à retravailler
