# Fiches de révision — Phases 7 à 10
# Niveau : Intermédiaire

> Consulte ces fiches pour réviser un concept précis ou t'auto-évaluer.
> Pour un quiz interactif sur ton code actuel, utilise `/learn:quiz`.
>
> **Score minimum** : 17/21 pour valider le niveau

---

## PHASE 7 — Principes SOLID

### Vocabulaire clé
| Terme | Tu sais l'expliquer ? |
|---|---|
| SRP — Single Responsibility Principle | ⬜ |
| OCP — Open/Closed Principle | ⬜ |
| LSP — Liskov Substitution Principle | ⬜ |
| ISP — Interface Segregation Principle | ⬜ |
| DIP — Dependency Inversion Principle | ⬜ |
| Module haut niveau / bas niveau | ⬜ |

### Questions

**Q40.** `[Facile]` Développe l'acronyme SOLID et nomme les 5 principes.

<!-- EXEMPLE: Aucun exemple spécifique au projet nécessaire — c'est une question de mémorisation -->

<details>
<summary>Réponse</summary>

- **S** — Single Responsibility Principle (Responsabilité Unique)
- **O** — Open/Closed Principle (Ouvert/Fermé)
- **L** — Liskov Substitution Principle (Substitution de Liskov)
- **I** — Interface Segregation Principle (Ségrégation des Interfaces)
- **D** — Dependency Inversion Principle (Inversion des Dépendances)

</details>

---

**Q41.** `[Normal]` Explique OCP (Open/Closed Principle). Comment une interface repository illustre-t-elle ce principe ?

<!-- EXEMPLE: Lis l'interface repository et son implémentation dans le projet courant — montre comment une nouvelle implémentation (ex: EF Core) pourrait être ajoutée sans modifier le service -->

<details>
<summary>Réponse</summary>

OCP : le code doit être **ouvert à l'extension** mais **fermé à la modification**.

Via une interface repository, on peut créer une nouvelle implémentation (ex: `EfRepository`) sans modifier le service. Le service est fermé à la modification — il n'a pas besoin de savoir que l'implémentation du stockage a changé.

</details>

---

**Q42.** `[Normal]` Explique LSP (Liskov Substitution Principle). Donne un exemple de violation.

<!-- EXEMPLE: Imagine une implémentation de l'interface repository du projet courant qui lancerait NotImplementedException sur une méthode — explique l'impact sur le service -->

<details>
<summary>Réponse</summary>

LSP : toute implémentation d'une interface doit pouvoir remplacer cette interface sans altérer le comportement attendu.

Violation : une implémentation de `IRepository` qui lance `NotImplementedException` sur `GetById`. Le service s'attend à recevoir un objet ou `null`, pas une exception non déclarée dans le contrat → comportement imprévisible, LSP violé.

</details>

---

**Q43.** `[Normal]` Explique ISP (Interface Segregation Principle). Pourquoi ne pas ajouter une méthode sans rapport dans une interface existante ?

<!-- EXEMPLE: Lis l'interface repository du projet courant — quelle méthode serait hors-sujet si on l'y ajoutait ? (ex: une méthode de reporting, d'export...) -->

<details>
<summary>Réponse</summary>

ISP : les interfaces doivent être petites et ciblées. Un consommateur ne doit pas être forcé de dépendre de méthodes qu'il n'utilise pas.

Si on ajoute `GenerateReport()` à une interface repository, toutes ses implémentations sont forcées de l'implémenter — même celles qui n'ont rien à voir avec le reporting. Il faudrait une interface séparée `IReportRepository`.

</details>

---

**Q44.** `[Difficile]` Explique DIP (Dependency Inversion Principle). Identifie une violation DIP typique dans une couche service.

<!-- EXEMPLE: Cherche dans la couche service du projet courant un accès direct à une classe concrète (ex: appel à une propriété statique du repository, ou instanciation directe d'une dépendance) -->

<details>
<summary>Réponse</summary>

DIP : les modules de haut niveau ne dépendent pas des modules de bas niveau — les deux dépendent d'abstractions.

Violation typique dans un service :
```csharp
// ❌ DIP violé : le service (haut niveau) accède directement à la classe concrète (bas niveau)
entity.Id = ConcreteRepository.StaticList.Max(e => e.Id) + 1;
```

Correction : tout passe par l'interface — le service n'accède jamais à la classe concrète directement.

</details>

---

**Q45.** `[Normal]` Quelle est la différence entre un module "haut niveau" et un module "bas niveau" ?

<!-- EXEMPLE: Classe les principaux fichiers du projet courant en haut/bas niveau et explique pourquoi -->

<details>
<summary>Réponse</summary>

- **Haut niveau** : exprime la logique métier ou orchestre des opérations (Service, Controller). Plus proche de l'utilisateur et des règles métier.
- **Bas niveau** : réalise le travail technique concret (Repository, accès BDD, fichiers). Plus proche du stockage et des détails d'implémentation.

DIP : le haut niveau ne doit pas instancier ni importer directement le bas niveau — les deux passent par une abstraction (interface).

</details>

### Mon suivi — Phase 7

| Date | Score | À revoir |
|------|-------|----------|
| | /6 | |

---

## PHASE 8 — Domain-Driven Design (DDD)

### Vocabulaire clé
| Terme | Tu sais l'expliquer ? |
|---|---|
| Modèle anémique | ⬜ |
| Aggregate Root | ⬜ |
| Value Object | ⬜ |
| Application Service | ⬜ |
| Domain Service | ⬜ |
| Setter privé | ⬜ |

### Questions

**Q46.** `[Normal]` Qu'est-ce qu'un modèle anémique ? Pourquoi est-ce un anti-pattern en DDD ?

<!-- EXEMPLE: Montre comment la classe de domaine principale du projet ressemblait AVANT le refactoring DDD (setters publics, pas de méthodes métier) et compare avec l'état actuel -->

<details>
<summary>Réponse</summary>

Un modèle anémique est une classe qui ne contient que des données (propriétés publiques) sans comportement. Toute la logique métier vit dans le service.

Anti-pattern car :
- N'importe qui peut modifier l'état sans validation (`entity.Name = ""`)
- La règle "titre non vide" n'est pas garantie par le type lui-même
- Logique métier éparpillée dans les services, difficile à trouver et tester

</details>

---

**Q47.** `[Normal]` Qu'est-ce qu'un Aggregate Root ? Quelles sont ses deux caractéristiques principales ?

<!-- EXEMPLE: Lis la classe de domaine principale du projet courant — identifie les setters privés et les méthodes métier -->

<details>
<summary>Réponse</summary>

Un Aggregate Root est une entité qui :
1. **Contrôle l'accès à ses données** via des setters privés — impossible de modifier ses propriétés directement depuis l'extérieur
2. **Encapsule ses règles métier** dans des méthodes — toute modification passe par une méthode qui garantit la cohérence

```csharp
public class Entity {
    public string Name { get; private set; }

    public void UpdateName(string name) {
        if (string.IsNullOrWhiteSpace(name))
            throw new ValidationException("Name is required");
        Name = name;
    }
}
```

</details>

---

**Q48.** `[Normal]` Quelle est la règle pour décider si une règle métier appartient à l'entité ou au service applicatif ?

<!-- EXEMPLE: Compare une règle dans la classe de domaine du projet (validation intrinsèque) vs une règle dans le service (contrainte nécessitant le repository) et explique pourquoi chacune est à sa place -->

<details>
<summary>Réponse</summary>

- Règle ne nécessitant que les **données de l'entité** → elle appartient à **l'entité** (ex: "le nom ne peut pas être vide")
- Règle nécessitant d'**interroger d'autres ressources** → elle reste dans le **service** (ex: "le nom doit être unique" → nécessite une requête au repository)

</details>

---

**Q49.** `[Normal]` Qu'est-ce qu'un Value Object ? En quoi diffère-t-il d'une entité ?

<!-- EXEMPLE: Lis le Value Object du projet courant — qu'est-ce qui le rend immuable ? Comment l'égalité est-elle définie ? -->

<details>
<summary>Réponse</summary>

Un Value Object est un type **immuable** défini par sa valeur, pas par une identité. Deux Value Objects avec la même valeur sont égaux.

Différence avec une entité : une entité a une identité unique (`Id`). Deux entités avec le même nom restent distinctes. Deux Value Objects avec la même valeur sont identiques.

Avantage : les règles de validité sont définies une seule fois dans le Value Object — garanties partout où il est utilisé.

</details>

---

**Q50.** `[Difficile]` Quel est le rôle d'un Application Service dans une architecture DDD ? Comment différencier orchestration et règle métier ?

<!-- EXEMPLE: Lis la classe service du projet courant — liste les appels qu'il délègue à l'entité de domaine vs les opérations qu'il garde pour lui (vérification d'unicité, appels repository) -->

<details>
<summary>Réponse</summary>

L'Application Service **orchestre** le domaine : il coordonne les appels entre entités et repository, mais ne contient pas de règles métier pures.

- **Orchestration (service)** : récupérer l'entité via le repository, vérifier l'unicité via une requête, appeler la méthode métier, persister
- **Règle métier (entité)** : validation des invariants qui ne nécessitent que les données de l'entité

Avant DDD : le service contient tout. Après DDD : le service délègue les règles à l'entité (`entity.UpdateName(...)`) et garde uniquement ce qui nécessite un accès aux données.

</details>

### Mon suivi — Phase 8

| Date | Score | À revoir |
|------|-------|----------|
| 2026-04-13 | 3.5/5 | Modèle anémique, Aggregate Root (setters privés), Value Object (immuabilité) |

---

## PHASE 9 — Entity Framework Core

### Vocabulaire clé
| Terme | Tu sais l'expliquer ? |
|---|---|
| ORM | ⬜ |
| `DbContext` | ⬜ |
| `DbSet<T>` | ⬜ |
| Migration | ⬜ |
| LINQ avec EF Core | ⬜ |
| `SaveChanges` | ⬜ |

### Questions

**Q51.** `[Facile]` Qu'est-ce qu'un ORM ? Quel problème résout-il ?

<!-- EXEMPLE: Explique comment un repository mémoire serait remplacé par EF Core dans le projet courant -->

<details>
<summary>Réponse</summary>

Un ORM (Object-Relational Mapper) fait le pont entre le monde objet (C#) et le monde relationnel (SQL). Il génère automatiquement les requêtes SQL à partir des opérations sur les objets C#.

Problème résolu : plus besoin d'écrire du SQL manuel, la persistence des objets est transparente, et le changement de base de données (SQLite → SQL Server) ne nécessite qu'un changement de configuration.

</details>

---

**Q52.** `[Normal]` Qu'est-ce qu'un `DbContext` ? Quel est son rôle dans EF Core ?

<!-- EXEMPLE: Montre la structure d'un DbContext pour le projet courant avec les DbSet correspondant aux entités de domaine -->

<details>
<summary>Réponse</summary>

Le `DbContext` est la classe centrale d'EF Core. Il représente une session avec la base de données et contient :
- Les `DbSet<T>` : tables accessibles via LINQ
- La configuration des entités (relations, contraintes)
- La gestion du cycle de vie des entités (suivi des modifications)

```csharp
public class AppDbContext : DbContext
{
    public DbSet<MonEntite> Entites { get; set; }

    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }
}
```

</details>

---

**Q53.** `[Normal]` Qu'est-ce qu'une migration EF Core ? Cite les deux commandes CLI pour créer et appliquer une migration.

<!-- EXEMPLE: Montre comment créer une migration InitialCreate pour ajouter la table correspondant à l'entité principale du projet -->

<details>
<summary>Réponse</summary>

Une migration est un fichier C# généré automatiquement qui décrit les changements de schéma de la base de données (création de table, ajout de colonne...).

```bash
dotnet ef migrations add NomDeLaMigration   # Générer la migration
dotnet ef database update                    # Appliquer à la base de données
```

</details>

---

**Q54.** `[Normal]` Comment réécrit-on les opérations CRUD d'un repository mémoire en repository EF Core ?

<!-- EXEMPLE: Compare l'implémentation actuelle du repository du projet (liste statique) avec son équivalent EF Core pour les opérations Add, GetById, GetAll, Remove -->

<details>
<summary>Réponse</summary>

```csharp
public class EfRepository : IRepository
{
    private readonly AppDbContext _context;
    public EfRepository(AppDbContext context) => _context = context;

    public Entity GetById(int id) => _context.Entities.Find(id);
    public IEnumerable<Entity> GetAll() => _context.Entities.ToList();
    public void Add(Entity entity) { _context.Entities.Add(entity); _context.SaveChanges(); }
    public void Remove(Entity entity) { _context.Entities.Remove(entity); _context.SaveChanges(); }
}
```

</details>

---

**Q55.** `[Difficile]` Pourquoi est-il important d'enregistrer le `DbContext` avec `AddDbContext` et non `AddSingleton` ?

<!-- EXEMPLE: Explique l'impact si le DbContext était singleton (état partagé entre requêtes simultanées) -->

<details>
<summary>Réponse</summary>

`DbContext` n'est **pas thread-safe** et maintient un état interne (suivi des entités). En singleton :
- Plusieurs requêtes simultanées partagent la même instance → race conditions
- Les entités trackées d'une requête contaminent les autres
- Les transactions se mélangent

`AddDbContext` enregistre le DbContext en **Scoped** par défaut (une instance par requête HTTP) — comportement correct et sûr.

</details>

---

**Q56.** `[Normal]` Écris une requête LINQ pour filtrer des entités par propriété avec EF Core. Quelle est la différence entre `FirstOrDefault` et `Where` ?

<!-- EXEMPLE: Montre comment une méthode de recherche par titre/nom serait implémentée avec EF Core dans le repository du projet courant -->

<details>
<summary>Réponse</summary>

```csharp
// Filtrer une collection
var results = _context.Entities
    .Where(e => e.Name.Contains(searchTerm))
    .ToList();

// Récupérer un seul élément (null si absent)
var entity = _context.Entities
    .FirstOrDefault(e => e.Id == id);
```

- `Where` : retourne une collection filtrée
- `FirstOrDefault` : retourne le premier élément correspondant ou `null`

</details>

### Mon suivi — Phase 9

| Date | Score | À revoir |
|------|-------|----------|
| | /6 | |

---

## PHASE 10 — Tests d'intégration

### Vocabulaire clé
| Terme | Tu sais l'expliquer ? |
|---|---|
| `WebApplicationFactory<T>` | ⬜ |
| Base de données en mémoire | ⬜ |
| `HttpClient` de test | ⬜ |
| Isolation des tests | ⬜ |

### Questions

**Q57.** `[Normal]` À quoi sert `WebApplicationFactory<T>` dans les tests d'intégration ASP.NET Core ?

<!-- EXEMPLE: Montre comment bootstrapper l'API du projet courant (en utilisant la classe Program) dans un test d'intégration -->

<details>
<summary>Réponse</summary>

`WebApplicationFactory<T>` démarre l'application entière en mémoire pour les tests. Elle permet d'envoyer de vraies requêtes HTTP à l'API sans démarrer un serveur réel.

```csharp
public class ApiTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;

    public ApiTests(WebApplicationFactory<Program> factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task GetAll_Returns200()
    {
        var response = await _client.GetAsync("/ressources");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }
}
```

</details>

---

**Q58.** `[Normal]` Comment remplace-t-on la base de données réelle par une base en mémoire dans les tests d'intégration ?

<!-- EXEMPLE: Montre la configuration UseInMemoryDatabase en overridant le DbContext dans WebApplicationFactory -->

<details>
<summary>Réponse</summary>

```csharp
var factory = new WebApplicationFactory<Program>()
    .WithWebHostBuilder(builder =>
    {
        builder.ConfigureServices(services =>
        {
            // Supprimer la vraie base de données
            var descriptor = services.SingleOrDefault(
                d => d.ServiceType == typeof(DbContextOptions<AppDbContext>));
            services.Remove(descriptor);

            // Ajouter la base en mémoire
            services.AddDbContext<AppDbContext>(options =>
                options.UseInMemoryDatabase("TestDb"));
        });
    });
```

</details>

---

**Q59.** `[Difficile]` Comment isoles-tu chaque test d'intégration pour éviter les interférences entre tests ?

<!-- EXEMPLE: Décris la stratégie à adopter pour que chaque test parte d'un état propre (base vide, données contrôlées) -->

<details>
<summary>Réponse</summary>

Stratégies d'isolation :

1. **Base de données unique par test** : utiliser un nom de base unique par test (`Guid.NewGuid().ToString()`)
2. **Nettoyage via `IAsyncLifetime`** : supprimer/recréer la base dans `InitializeAsync` et `DisposeAsync`
3. **Transaction par test** : démarrer une transaction, ne jamais la committer → rollback automatique à la fin du test

```csharp
public async Task InitializeAsync()
{
    var scope = _factory.Services.CreateScope();
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    await db.Database.EnsureDeletedAsync();
    await db.Database.EnsureCreatedAsync();
}
```

</details>

---

**Q60.** `[Normal]` Quelle est la différence entre tester un endpoint avec un test d'intégration et mocker le service dans un test unitaire du controller ?

<!-- EXEMPLE: Compare un test unitaire du controller du projet (mock IService) avec un test d'intégration qui appelle un endpoint HTTP en utilisant WebApplicationFactory -->

<details>
<summary>Réponse</summary>

| | Test unitaire controller | Test d'intégration |
|---|---|---|
| Service | Mocké | Réel |
| Repository | Mocké | Réel (ou en mémoire) |
| HTTP | Simulé | Réel (HttpClient) |
| Vitesse | Rapide | Lent |
| Ce qu'il teste | Logique du controller seul | Flux complet controller → service → BDD |

Les deux sont complémentaires : unitaire pour la logique fine, intégration pour valider le flux end-to-end.

</details>

### Mon suivi — Phase 10

| Date | Score | À revoir |
|------|-------|----------|
| | /4 | |

---

## Score — Niveau Intermédiaire

| Phase | Questions | Score |
|---|---|---|
| Phase 7 — SOLID | Q40 à Q45 | /6 |
| Phase 8 — DDD | Q46 à Q50 | /5 |
| Phase 9 — EF Core | Q51 à Q56 | /6 |
| Phase 10 — Tests intégration | Q57 à Q60 | /4 |
| **Total** | | **/21** |

> **17/21 et plus** → Niveau maîtrisé
> **Moins de 17/21** → Consulte `dotnet/niveau.md` pour identifier les points à retravailler
