# Module — Entity Framework Core avancé

> Niveau : **Intermédiaire (Mid)**
> Prérequis : connaître les bases EF Core (DbContext, DbSet, migrations simples)

---

## Vocabulaire clé

| Terme | Tu sais l'expliquer ? |
|---|---|
| Provider EF Core | ⬜ |
| `IQueryable<T>` | ⬜ |
| `IEnumerable<T>` | ⬜ |
| Exécution différée *(deferred execution)* | ⬜ |
| Méthode terminale | ⬜ |
| Anti-pattern N+1 | ⬜ |
| `.ToQueryString()` | ⬜ |

---

## Questions

**Q1.** `[Facile]` Qu'est-ce qu'un **provider EF Core** ? Cite 4 providers courants et leur base de données cible.

<details>
<summary>Réponse</summary>

Un provider est le connecteur qui traduit les requêtes LINQ en SQL **spécifique à un moteur de base de données**. Chaque base a son propre dialecte SQL, donc son propre provider.

| Provider (package NuGet) | Base de données |
|---|---|
| `Microsoft.EntityFrameworkCore.Sqlite` | SQLite |
| `Microsoft.EntityFrameworkCore.SqlServer` | SQL Server |
| `Npgsql.EntityFrameworkCore.PostgreSQL` | PostgreSQL |
| `Pomelo.EntityFrameworkCore.MySql` | MySQL |

C'est le provider déclaré dans `Program.cs` via `UseSqlite(...)` / `UseNpgsql(...)` etc. qui détermine quel SQL est généré.

</details>

---

**Q2.** `[Normal]` Pourquoi les migrations générées sont-elles **spécifiques au provider** ? Que faut-il faire si on change de base de données ?

<details>
<summary>Réponse</summary>

Chaque provider génère du SQL adapté à son moteur. Les types de colonnes, la syntaxe et les contraintes diffèrent :

```sql
-- SQLite
CREATE TABLE "Tickets" ("Id" INTEGER PRIMARY KEY AUTOINCREMENT ...)

-- SQL Server
CREATE TABLE [Tickets] ([Id] int IDENTITY(1,1) PRIMARY KEY ...)
```

Les migrations existantes sont donc incompatibles si on change de provider. Il faut les régénérer :

```bash
dotnet ef migrations remove --project tasks  # répéter jusqu'à zéro
dotnet ef migrations add InitialCreate --project tasks
```

`AppDbContext`, les entités et toute la logique métier restent **inchangés** — seul le provider change.

</details>

---

**Q3.** `[Facile]` Quelle est la différence fondamentale entre `IQueryable<T>` et `IEnumerable<T>` dans le contexte d'EF Core ?

<details>
<summary>Réponse</summary>

| | `IQueryable<T>` | `IEnumerable<T>` |
|---|---|---|
| Contient | Une description de requête | Des objets C# en mémoire |
| SQL envoyé ? | Non — pas encore | Oui — déjà exécuté |
| Filtre côté | Base de données | Serveur applicatif |
| EF Core peut traduire ? | Oui | Non |

```csharp
// IQueryable — description, aucun SQL parti
var query = _context.Tickets.Where(t => t.Status == "Open");

// IEnumerable — SQL parti, données en mémoire
var list = query.ToList();
list.Where(t => t.Title.Length > 5); // filtre C# pur
```

</details>

---

**Q4.** `[Normal]` Qu'est-ce que l'**exécution différée** *(deferred execution)* ? Cite 4 méthodes qui la déclenchent.

<details>
<summary>Réponse</summary>

L'exécution différée signifie que la requête SQL n'est **pas envoyée** au moment où tu la décris avec LINQ, mais uniquement quand tu demandes un résultat concret.

```csharp
var query = _context.Tickets        // IQueryable — rien envoyé
    .Where(t => t.Status == "Open") // accumule WHERE
    .OrderBy(t => t.Title);         // accumule ORDER BY

var result = query.ToList();        // ← SQL envoyé ICI
```

Méthodes qui déclenchent l'exécution (méthodes terminales) :

| Méthode | SQL généré |
|---|---|
| `.ToList()` | `SELECT * FROM ...` |
| `.FirstOrDefault()` | `SELECT * FROM ... LIMIT 1` |
| `.Any()` | `SELECT CASE WHEN EXISTS(...) THEN 1 ELSE 0 END` |
| `.Count()` | `SELECT COUNT(*) FROM ...` |

</details>

---

**Q5.** `[Normal]` Où se situe la **frontière** entre `IQueryable` et `IEnumerable` ? Quel est l'impact sur le SQL généré ?

<details>
<summary>Réponse</summary>

La frontière est la méthode terminale (le plus souvent `ToList()`). Tout ce qui est **avant** devient du SQL. Tout ce qui est **après** tourne en C#.

```csharp
_context.Tickets
    .Where(t => t.Status == "Open")     // ← SQL : WHERE Status = 'Open'
    .OrderBy(t => t.Title)              // ← SQL : ORDER BY Title
    .ToList()                           // ← FRONTIÈRE — SQL exécuté ici
    .Where(t => t.Title.Length > 5)     // ← C# en mémoire
    .Select(ToDto)                      // ← C# en mémoire
```

Placer un filtre **avant** `ToList()` = la base de données filtre (efficace).
Placer un filtre **après** `ToList()` = toutes les lignes sont chargées, puis filtrées en RAM (coûteux).

</details>

---

**Q6.** `[Difficile]` Pourquoi un **Repository ne doit-il pas retourner `IQueryable<T>`** ? Qu'est-ce qui se passe si c'est le cas ?

<details>
<summary>Réponse</summary>

Si le Repository retourne `IQueryable`, la requête SQL peut être déclenchée n'importe où dans les couches supérieures, brisant la règle que **seule l'Infrastructure parle à la base de données**.

```csharp
// Repository retourne IQueryable — dangereux
public IQueryable<Ticket> GetAll() => _context.Tickets;

// Service — SQL déclenché hors du Repository
public List<TicketDto> GetAll()
{
    return _repository.GetAll()
        .Where(t => t.Status == "Open")  // SQL construit dans le Service
        .ToList()                        // SQL exécuté dans le Service ← fuite
        .Select(ToDto).ToList();
}

// Pire — SQL déclenché dans le Controller
var tickets = _service.GetAll();   // IQueryable encore
var count = tickets.Count();       // SELECT COUNT(*) depuis le Controller !
```

La règle : le Repository **termine toujours** la requête avant de retourner.

```
Infrastructure (Repository)  → seul responsable du SQL     ✅
Application (Service)        → logique métier sur objets C# ✅
API (Controller)             → ne sait pas qu'il y a une BD ✅
```

</details>

---

**Q7.** `[Normal]` Pourquoi utiliser `.ToLower()` plutôt que `StringComparison.OrdinalIgnoreCase` dans une requête EF Core ? Dans quel contexte utiliser l'un ou l'autre ?

<details>
<summary>Réponse</summary>

`StringComparison.OrdinalIgnoreCase` n'est pas traduisible par tous les providers SQL. EF Core peut lever une exception ou ignorer silencieusement l'argument.

`.ToLower()` est traduit par le provider en fonction SQL native :
```csharp
.Where(t => t.Title.Value.ToLower() == title.ToLower())
// SQLite génère : WHERE lower(Title) = lower(@title)
```

| Contexte | À utiliser |
|---|---|
| Comparaison en mémoire C# | `StringComparison.OrdinalIgnoreCase` — invariant, pas de piège culturel |
| Requête EF Core → SQL | `.ToLower()` — traduisible par tous les providers |

Pourquoi éviter `.ToLower()` en C# pur ? Sur un système avec locale turque, `"I".ToLower()` donne `"ı"` (i sans point) — comparaisons incorrectes.

</details>

---

**Q8.** `[Facile]` Comment **vérifier le SQL exact** généré par une requête EF Core avant de l'exécuter ?

<details>
<summary>Réponse</summary>

La méthode `.ToQueryString()` affiche le SQL que le provider va envoyer, sans l'exécuter :

```csharp
var query = _context.Tickets
    .Where(t => t.Title.Value.ToLower() == "login");

Console.WriteLine(query.ToQueryString());
// Output : SELECT * FROM "Tickets" WHERE lower("Title") = lower('login')
```

Utile pour :
- Vérifier qu'un filtre est bien appliqué côté SQL (et non en mémoire)
- Diagnostiquer un comportement inattendu
- Optimiser une requête lente

</details>

---

**Q9.** `[Difficile]` Qu'est-ce que l'**anti-pattern N+1** en EF Core ? Donne un exemple concret et explique la correction.

<details>
<summary>Réponse</summary>

Le N+1 se produit quand on charge toutes les données en mémoire pour n'en utiliser qu'une partie — généralement pour vérifier une condition.

```csharp
// Anti-pattern — charge TOUS les tickets pour vérifier un doublon
if (_repository.GetAll().Any(t => t.Title == dto.Title))
    throw new ConflictException(...);
// Sur 1 000 000 tickets → 1 000 000 lignes chargées en RAM
```

**Correction** : déléguer le filtre au SQL via une méthode dédiée dans le Repository :

```csharp
// ITicketRepository
bool ExistsByTitle(string title, int? excludeId = null);

// TicketRepository
public bool ExistsByTitle(string title, int? excludeId = null)
{
    return _context.Tickets
        .Where(t => t.Title.Value.ToLower() == title.ToLower())
        .Where(t => excludeId == null || t.Id != excludeId)
        .Any(); // SQL : SELECT 1 FROM Tickets WHERE ... LIMIT 1
}
```

EF Core traduit `Any()` en `SELECT 1 ... LIMIT 1` — **une seule ligne lue**, quelle que soit la taille de la table.

`excludeId` permet de réutiliser la même méthode pour `Create` (sans exclusion) et `Update`/`Patch` (on s'exclut soi-même).

</details>

---

**Q10.** `[Normal]` Quels sont les **3 éléments qui changent** quand on change de base de données dans un projet EF Core ? Qu'est-ce qui ne change pas ?

<details>
<summary>Réponse</summary>

**Ce qui change :**

1. **Package NuGet** — désinstaller l'ancien provider, installer le nouveau
2. **`Program.cs`** — changer `UseSqlite(...)` par `UseNpgsql(...)` ou `UseSqlServer(...)`
3. **Migrations** — les régénérer entièrement (SQL spécifique au provider)

```csharp
// SQLite → PostgreSQL : une seule ligne change dans Program.cs
options.UseNpgsql("Host=localhost;Database=tasks;Username=postgres;Password=...");
```

**Ce qui ne change pas :**

```
ITicketRepository     → aucun changement
TicketRepository      → aucun changement
AppDbContext          → aucun changement
Configurations        → aucun changement
Toute la logique métier → aucun changement
```

C'est l'intérêt fondamental d'EF Core : le code applicatif est **découplé** du moteur de base de données.

</details>

---

## Score — Module EF Core avancé

| Thème | Questions | Score |
|---|---|---|
| Providers | Q1, Q2 | /2 |
| IQueryable vs IEnumerable | Q3, Q4, Q5 | /3 |
| Architecture & Repository | Q6 | /1 |
| LINQ et compatibilité providers | Q7, Q8 | /2 |
| Anti-patterns & changement de BD | Q9, Q10 | /2 |
| **Total** | | **/10** |

> **8/10 et plus** → Module maîtrisé
> **Moins de 8/10** → Relis `docs/reference/efcore-setup.md` dans le projet courant

### Mon suivi

| Date | Score | À revoir |
|------|-------|----------|
| | /10 | |
