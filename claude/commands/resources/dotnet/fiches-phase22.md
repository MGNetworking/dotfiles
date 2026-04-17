# Fiches de révision — Phase 22
# Niveau : Senior+

> Consulte ces fiches pour réviser un concept précis ou t'auto-évaluer.
> Pour un quiz interactif sur ton code actuel, utilise `/learn:quiz`.
>
> **Score minimum** : 3/4 pour valider le niveau

---

## PHASE 22 — Multi-tenancy

### Vocabulaire clé
| Terme | Tu sais l'expliquer ? |
|---|---|
| Multi-tenancy | ⬜ |
| Row-level security | ⬜ |
| `HasQueryFilter()` (EF Core) | ⬜ |
| `ITenantResolver` | ⬜ |
| Tenant isolation | ⬜ |

### Questions

**Q126.** `[Normal]` Qu'est-ce que le multi-tenancy ? Cite et compare les 3 stratégies d'isolation des données.

<!-- EXEMPLE: Décris quelle stratégie serait adaptée à un SaaS avec des clients de tailles très différentes -->

<details>
<summary>Réponse</summary>

Le multi-tenancy permet à une seule application de servir plusieurs clients (tenants) en isolant leurs données.

| Stratégie | Description | Avantages | Inconvénients |
|---|---|---|---|
| **Row-level** | Colonne `TenantId` dans chaque table | Simple, peu coûteux, bonne densité | Risque de fuite si filtre oublié |
| **Schéma par tenant** | Un schéma SQL par client (`client1.Orders`, `client2.Orders`) | Isolation forte, migrations ciblées | Plus complexe à gérer |
| **Base par tenant** | Une base de données par client | Isolation maximale, RGPD simplifié | Coûteux, opérations multiplées |

En pratique : **row-level** pour les SaaS à fort volume, **base par tenant** pour les grands clients avec exigences de sécurité strictes.

</details>

---

**Q127.** `[Normal]` Comment résout-on le tenant courant dans ASP.NET Core ? Montre un `ITenantResolver` basé sur le JWT.

<!-- EXEMPLE: Montre comment extraire le TenantId depuis un claim JWT et le rendre disponible dans toute la requête -->

<details>
<summary>Réponse</summary>

```csharp
// 1. Interface de résolution du tenant
public interface ITenantResolver
{
    Guid GetCurrentTenantId();
}

// 2. Implémentation basée sur le JWT
public class JwtTenantResolver(IHttpContextAccessor accessor) : ITenantResolver
{
    public Guid GetCurrentTenantId()
    {
        var claim = accessor.HttpContext?.User
            .FindFirst("tenant_id")?.Value;

        if (claim is null || !Guid.TryParse(claim, out var tenantId))
            throw new UnauthorizedAccessException("TenantId manquant ou invalide");

        return tenantId;
    }
}

// 3. Enregistrement
builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<ITenantResolver, JwtTenantResolver>();

// 4. Usage dans un service
public class OrderService(ITenantResolver tenantResolver, AppDbContext context)
{
    public async Task<List<Order>> GetAllAsync(CancellationToken ct)
    {
        var tenantId = tenantResolver.GetCurrentTenantId();
        return await context.Orders
            .Where(o => o.TenantId == tenantId)
            .ToListAsync(ct);
    }
}
```

</details>

---

**Q128.** `[Difficile]` Comment utilise-t-on `HasQueryFilter()` dans EF Core pour filtrer automatiquement par tenant sans l'écrire dans chaque requête ?

<!-- EXEMPLE: Montre comment configurer un filtre global sur l'entité Order pour ne retourner que les données du tenant courant -->

<details>
<summary>Réponse</summary>

`HasQueryFilter()` applique un filtre automatiquement sur **toutes** les requêtes EF Core pour une entité — plus besoin de filtrer manuellement dans chaque repository.

```csharp
public class AppDbContext(
    DbContextOptions<AppDbContext> options,
    ITenantResolver tenantResolver) : DbContext(options)
{
    public DbSet<Order> Orders { get; set; }

    protected override void OnModelCreating(ModelBuilder builder)
    {
        // Filtre global : toutes les requêtes sur Orders incluent automatiquement
        // WHERE TenantId = @currentTenantId
        builder.Entity<Order>()
            .HasQueryFilter(o => o.TenantId == tenantResolver.GetCurrentTenantId());
    }
}

// Usage : le filtre est appliqué implicitement
var orders = await _context.Orders.ToListAsync(); // WHERE TenantId = 'abc...'
var order = await _context.Orders.FindAsync(id);  // + WHERE TenantId = 'abc...'

// Désactiver le filtre ponctuellement (admin uniquement)
var allOrders = await _context.Orders
    .IgnoreQueryFilters()
    .ToListAsync();
```

⚠️ S'assurer que `ITenantResolver` est `Scoped` et que le `DbContext` l'est aussi — sinon le filtre résout le mauvais tenant.

</details>

---

**Q129.** `[Difficile]` Quels sont les risques de fuite de données entre tenants ? Cite 3 points de vigilance.

<!-- EXEMPLE: Identifie dans une architecture REST classique les endroits où un TenantId pourrait être ignoré -->

<details>
<summary>Réponse</summary>

**1. Oubli du filtre dans une requête directe**
```csharp
// ❌ Sans HasQueryFilter ni filtre explicite
var order = await _context.Orders.FindAsync(id);
// Retourne l'order même s'il appartient à un autre tenant !

// ✅ Avec HasQueryFilter configuré : le filtre est automatique
// OU vérification explicite :
var order = await _context.Orders
    .FirstOrDefaultAsync(o => o.Id == id && o.TenantId == currentTenantId);
if (order is null) throw new NotFoundException();
```

**2. Background service sans contexte HTTP**
Un `BackgroundService` n'a pas de requête HTTP → `IHttpContextAccessor` retourne `null` → le `TenantResolver` échoue. Il faut une stratégie dédiée (ex : passer le `TenantId` explicitement dans le message de queue).

**3. Cache partagé entre tenants**
```csharp
// ❌ Clé de cache sans TenantId : un tenant voit les données d'un autre
cache.Set("orders", data);

// ✅ Clé de cache incluant le TenantId
cache.Set($"orders:{tenantId}", data);
```

Règle générale : **toute clé de cache, tout log structuré et toute requête BDD doivent inclure le `TenantId`**.

</details>

### Mon suivi — Phase 22

| Date | Score | À revoir |
|------|-------|----------|
| | /4 | |

---

## Score — Phase 22

| Phase | Questions | Score |
|---|---|---|
| Phase 22 — Multi-tenancy | Q126 à Q129 | /4 |

> **3/4 et plus** → Niveau maîtrisé
> **Moins de 3/4** → Consulte `dotnet/niveau.md` pour identifier les points à retravailler
