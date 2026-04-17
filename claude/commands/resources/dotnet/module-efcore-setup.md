# Module — Entity Framework Core — Setup et configuration

> Niveau : **Mid**
> Prérequis : connaître les bases de l'injection de dépendances et de la DI dans ASP.NET Core

---

## Vocabulaire clé

| Terme | Tu sais l'expliquer ? |
|---|---|
| Provider EF Core | ⬜ |
| `DbContext` | ⬜ |
| `DbSet<T>` | ⬜ |
| `IEntityTypeConfiguration<T>` | ⬜ |
| `ValueConverter` | ⬜ |
| `AppDbContextFactory` | ⬜ |
| `dotnet ef migrations add` | ⬜ |
| `db.Database.Migrate()` | ⬜ |
| `__EFMigrationsHistory` | ⬜ |

---

## Questions

**Q1.** `[Facile]` Quels sont les **3 packages NuGet** nécessaires pour EF Core dans un projet principal ? Quel est le rôle de chacun ?

<details>
<summary>Réponse</summary>

| Package | Rôle |
|---|---|
| Provider (`Sqlite`, `SqlServer`...) | Traduit LINQ en SQL spécifique au moteur |
| `Microsoft.EntityFrameworkCore.Design` | Analyse les classes C# et génère les migrations |
| `Microsoft.EntityFrameworkCore.Tools` | Fournit les commandes `dotnet ef` et `Add-Migration` |

```
Add-Migration (Tools)
      ↓
Analyse des classes C# (Design)
      ↓
Génération du fichier de migration
      ↓
Exécution du SQL (Provider) ← le provider intervient ici seulement
```

Dans le projet de tests, **seul le provider** est nécessaire — les tests ne génèrent jamais de migrations.

</details>

---

**Q2.** `[Normal]` Quel est le rôle du `AppDbContext` ? Que contient-il obligatoirement ?

<details>
<summary>Réponse</summary>

`AppDbContext` est le **pont entre les classes C# et la base de données**. Il centralise :
- La déclaration des tables via `DbSet<T>`
- La configuration du mapping via `OnModelCreating`

```csharp
public class AppDbContext : DbContext
{
    public DbSet<Ticket> Tickets => Set<Ticket>();

    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly);
    }
}
```

`ApplyConfigurationsFromAssembly` scanne l'assembly pour trouver toutes les classes `IEntityTypeConfiguration<T>` et les applique automatiquement.

</details>

---

**Q3.** `[Normal]` Pourquoi a-t-on besoin de `IEntityTypeConfiguration<T>` ? Qu'est-ce qu'un `ValueConverter` ?

<details>
<summary>Réponse</summary>

EF Core sait mapper les types primitifs (`int`, `string`, `bool`) automatiquement. Mais un **Value Object** (ex: `TicketTitle`) est un type C# personnalisé — EF Core ne sait pas comment le stocker sans instruction explicite.

Un `ValueConverter` définit la conversion dans les deux sens :

```csharp
var titleConverter = new ValueConverter<TicketTitle, string>(
    v => v.Value,         // TicketTitle → string  (écriture en BD)
    v => new TicketTitle(v) // string → TicketTitle  (lecture depuis BD)
);

entity.Property(t => t.Title)
    .HasConversion(titleConverter)
    .IsRequired();
```

Règle : une classe `IEntityTypeConfiguration<T>` par entité, tous les Value Objects configurés dedans.

</details>

---

**Q4.** `[Normal]` Qu'est-ce que `AppDbContextFactory` ? Pourquoi est-elle nécessaire ?

<details>
<summary>Réponse</summary>

`AppDbContextFactory` permet aux **outils EF Core** (`dotnet ef migrations add`) de créer une instance de `AppDbContext` sans démarrer toute l'application.

Sans elle, `dotnet ef` tente d'exécuter `Program.cs`. Si l'application ne démarre pas (BD absente, config manquante), les outils échouent.

```csharp
public class AppDbContextFactory : IDesignTimeDbContextFactory<AppDbContext>
{
    public AppDbContext CreateDbContext(string[] args)
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseSqlite("Data Source=app.db")
            .Options;
        return new AppDbContext(options);
    }
}
```

EF Core trouve cette classe **automatiquement**. Elle n'est **jamais** utilisée à l'exécution — uniquement par les outils de migration.

</details>

---

**Q5.** `[Facile]` Comment enregistre-t-on `AppDbContext` dans `Program.cs` ? Quelle est la durée de vie d'une instance ?

<details>
<summary>Réponse</summary>

```csharp
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlite("Data Source=app.db"));
```

`AddDbContext` enregistre le contexte avec une durée de vie **`Scoped`** — une instance créée par requête HTTP, détruite à la fin de la requête.

> `AddDbContext` enregistre la configuration mais ne crée pas encore l'objet. L'instance est créée par .NET uniquement quand une requête HTTP en a besoin.

</details>

---

**Q6.** `[Difficile]` Quelle est la différence entre `dotnet ef migrations add` et `db.Database.Migrate()` ? L'un touche-t-il à la base de données ?

<details>
<summary>Réponse</summary>

Ce sont deux opérations distinctes souvent confondues :

| | `dotnet ef migrations add` | `db.Database.Migrate()` |
|---|---|---|
| **Quand** | Pendant le développement | Au démarrage de l'API |
| **Ce que ça fait** | Génère des fichiers C# | Synchronise le schéma de la BD |
| **Touche à la BD** | **Non** | Oui, si nécessaire |
| **Remet la BD à zéro** | **Non** | **Non** |
| **Conserve les données** | Sans objet | **Oui, toujours** |

```csharp
// Program.cs — appliquer les migrations au démarrage
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    db.Database.Migrate();
}
```

`Migrate()` compare les fichiers dans `Migrations/` avec `__EFMigrationsHistory` dans la BD et n'applique que ce qui manque.

</details>

---

**Q7.** `[Normal]` Qu'est-ce que la table `__EFMigrationsHistory` ? Quel est son rôle ?

<details>
<summary>Réponse</summary>

Table créée automatiquement par EF Core dans la base de données. Elle enregistre quels fichiers de migration ont déjà été appliqués.

```
__EFMigrationsHistory
  ┌──────────────────────────────────┬────────────────┐
  │ MigrationId                      │ ProductVersion │
  ├──────────────────────────────────┼────────────────┤
  │ 20260414120000_InitialCreate     │ 10.0.0         │
  │ 20260415090000_AjouterDeadline   │ 10.0.0         │
  └──────────────────────────────────┴────────────────┘
```

Au démarrage, `Migrate()` lit cette table, compare avec les fichiers dans `Migrations/`, et applique uniquement ce qui est absent. C'est l'équivalent de **git pour le schéma de base de données**.

Existe dans tous les providers (SQLite, PostgreSQL, SQL Server) — toujours le même nom.

</details>

---

**Q8.** `[Normal]` Quels sont les **3 éléments qui changent** quand on change de base de données ? Que faut-il faire pour les migrations ?

<details>
<summary>Réponse</summary>

1. **Package NuGet** — désinstaller l'ancien provider, installer le nouveau
2. **`Program.cs`** — changer `UseSqlite(...)` par `UseNpgsql(...)` ou `UseSqlServer(...)`
3. **`AppDbContextFactory`** — mettre à jour la chaîne de connexion

Les migrations sont **spécifiques au provider** → les régénérer entièrement :

```bash
dotnet ef migrations remove --project tasks  # répéter jusqu'à zéro
dotnet ef migrations add InitialCreate --project tasks
```

`AppDbContext`, les entités, les configurations, et toute la logique métier restent **inchangés**.

</details>

---

## Score — Module EF Core Setup

| Thème | Questions | Score |
|---|---|---|
| Packages NuGet | Q1 | /1 |
| AppDbContext & DbSet | Q2 | /1 |
| ValueConverter & IEntityTypeConfiguration | Q3 | /1 |
| AppDbContextFactory | Q4 | /1 |
| Enregistrement DI | Q5 | /1 |
| Migrations | Q6, Q7 | /2 |
| Changer de BD | Q8 | /1 |
| **Total** | | **/8** |

> **7/8 et plus** → Module maîtrisé
> **Moins de 7/8** → Relis le code de `Infrastructure/Persistence/` dans le projet courant

### Mon suivi

| Date | Score | À revoir |
|------|-------|----------|
| | /8 | |
