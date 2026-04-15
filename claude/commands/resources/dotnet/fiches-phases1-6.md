# Fiches de révision — Phases 1 à 6
# Niveau : Junior+

> Consulte ces fiches pour réviser un concept précis ou t'auto-évaluer.
> Pour un quiz interactif sur ton code actuel, utilise `/learn:quiz`.
>
> **Score minimum** : 32/39 pour valider le niveau

---

## PHASE 1 — Bases ASP.NET Core Web API

### Vocabulaire clé
| Terme | Tu sais l'expliquer ? |
|---|---|
| `[ApiController]` | ⬜ |
| `[Route]` | ⬜ |
| `ActionResult<T>` | ⬜ |
| `IActionResult` | ⬜ |
| Query string | ⬜ |
| `[FromBody]` | ⬜ |
| Verbes HTTP : GET, POST, PUT, PATCH, DELETE | ⬜ |

### Questions

**Q1.** `[Normal]` Quelle est la différence entre `ActionResult<T>` et `IActionResult` ? Quand utilises-tu l'un plutôt que l'autre ?

<!-- EXEMPLE: Lis le controller principal du projet courant et montre un endpoint qui utilise ActionResult<T> (ex: GET) et un qui utilise IActionResult (ex: DELETE ou PUT) -->

<details>
<summary>Réponse</summary>

`ActionResult<T>` est utilisé quand l'endpoint retourne des données — le type `T` documente ce que l'API retourne et permet à Swagger de l'inférer.

`IActionResult` est utilisé quand on retourne uniquement un statut HTTP sans corps (ex: `NoContent()`, `NotFound()`).

Règle : si la réponse contient un body JSON → `ActionResult<T>`. Si c'est juste un code HTTP → `IActionResult`.

</details>

---

**Q2.** `[Facile]` Un endpoint retourne une collection vide. Quel code HTTP retourner ? Pourquoi ?

<!-- EXEMPLE: Vérifie dans le controller courant comment le GET de la collection gère le cas liste vide -->

<details>
<summary>Réponse</summary>

200 OK. La ressource collection existe — elle est juste vide. 404 signifie que la ressource elle-même n'existe pas, pas qu'elle est vide.

</details>

---

**Q3.** `[Normal]` À quoi sert `[ApiController]` ? Cite deux comportements qu'il active automatiquement.

<!-- EXEMPLE: Vérifie dans le controller du projet si ModelState.IsValid est écrit explicitement ou non — si absent, c'est [ApiController] qui s'en charge -->

<details>
<summary>Réponse</summary>

1. **Validation automatique du modèle** : retourne 400 si le body est invalide sans écrire `if (!ModelState.IsValid)`
2. **Binding automatique des paramètres** : `[FromBody]`, `[FromRoute]`, `[FromQuery]` sont inférés selon le contexte

</details>

---

**Q4.** `[Normal]` Comment lis-tu un paramètre depuis une route (`/ressources/{id}`) ? Et depuis une query string (`/ressources?filtre=`) ?

<!-- EXEMPLE: Lis le controller courant et montre les deux types de binding présents -->

<details>
<summary>Réponse</summary>

```csharp
// Depuis la route {id}
[HttpGet("{id}")]
public IActionResult Get(int id) { ... }

// Depuis la query string ?filtre=valeur
public IActionResult Search(string? filtre) { ... }
// Avec [ApiController], [FromQuery] est inféré automatiquement
```

Le nom du paramètre C# doit correspondre au nom dans l'URL ou la query string.

</details>

---

**Q5.** `[Facile]` À quoi sert `[FromBody]` ? Pourquoi en a-t-on besoin pour les endpoints POST et PUT ?

<!-- EXEMPLE: Montre dans le controller courant un endpoint POST qui utilise [FromBody] ou l'inférence automatique -->

<details>
<summary>Réponse</summary>

`[FromBody]` indique à ASP.NET Core de lire le paramètre depuis le corps JSON de la requête. Pour POST et PUT, les données sont dans le body et non dans l'URL. Avec `[ApiController]`, il est souvent inféré automatiquement pour les objets complexes.

</details>

---

**Q6.** `[Facile]` Cite les méthodes helper de `ControllerBase` pour les codes HTTP 200, 201, 204, 400, 404, 409.

<!-- EXEMPLE: Lis le controller courant et liste tous les return statements — associe chaque méthode à son code HTTP -->

<details>
<summary>Réponse</summary>

| Code | Méthode |
|------|---------|
| 200 OK | `Ok(data)` |
| 201 Created | `CreatedAtAction(nameof(Get), new { id }, data)` |
| 204 No Content | `NoContent()` |
| 400 Bad Request | `BadRequest(message)` |
| 404 Not Found | `NotFound(message)` |
| 409 Conflict | `Conflict(message)` |

</details>

---

**Q7.** `[Normal]` Quelle est la différence entre un paramètre de route et un paramètre de query string ? Quand utiliser l'un ou l'autre ?

<!-- EXEMPLE: Identifie dans le projet courant les endpoints qui utilisent {id} vs ?filtre= et explique le choix sémantique -->

<details>
<summary>Réponse</summary>

- **Route** `{id}` : identifie une ressource spécifique, valeur obligatoire, fait partie de l'identité. Ex: `/ressources/5`
- **Query string** `?filtre=` : filtre ou option sur une collection, valeur optionnelle. Ex: `/ressources?titre=foo`

Règle : valeur qui fait partie de l'**identité** → route. **Filtre / tri / pagination** → query string.

</details>

### Mon suivi — Phase 1

| Date | Score | À revoir |
|------|-------|----------|
| | /7 | |

---

## PHASE 2 — Architecture en couches

### Vocabulaire clé
| Terme | Tu sais l'expliquer ? |
|---|---|
| SRP (Single Responsibility Principle) | ⬜ |
| Couche Domain | ⬜ |
| Couche Repository | ⬜ |
| Couche Service | ⬜ |
| Couche API (Controller) | ⬜ |
| Séparation des responsabilités | ⬜ |

### Questions

**Q8.** `[Facile]` Explique en une phrase le rôle de chaque couche : Domain, Repository, Service, Controller.

<!-- EXEMPLE: Lis la structure du projet courant (CLAUDE.md ou l'arborescence) et associe chaque couche à ses fichiers concrets -->

<details>
<summary>Réponse</summary>

- **Domain** : modèle métier et règles intrinsèques, ne dépend de rien
- **Repository** : accès aux données (lecture/écriture), pas de logique métier
- **Service** : orchestration et règles nécessitant plusieurs ressources, ne connaît pas HTTP
- **Controller** : reçoit les requêtes HTTP, délègue au service, retourne une réponse HTTP

</details>

---

**Q9.** `[Normal]` Pourquoi le controller ne doit-il pas contenir de logique métier ? Donne une raison liée à la testabilité.

<!-- EXEMPLE: Cherche dans le controller courant s'il y a des validations ou règles métier qui devraient être dans le service -->

<details>
<summary>Réponse</summary>

Si la logique métier est dans le controller, elle est couplée à HTTP — impossible à tester sans bootstrapper toute l'application (pipeline, routing, serialisation). Dans le service, elle peut être testée unitairement avec un simple mock, sans aucun HTTP.

</details>

---

**Q10.** `[Normal]` Pourquoi le modèle de domaine ne doit-il dépendre d'aucune autre couche ?

<!-- EXEMPLE: Lis la classe de domaine principale du projet courant et vérifie ses using statements — dépend-elle d'un namespace infrastructure ou HTTP ? -->

<details>
<summary>Réponse</summary>

Le domaine représente les concepts métier purs. S'il dépend d'une couche technique (repository, HTTP), un changement technique impacte les règles métier. En le gardant indépendant, on peut changer la base de données, le protocole ou le framework sans toucher au domaine.

</details>

---

**Q11.** `[Difficile]` Identifie une violation de la séparation des couches dans une architecture en couches. Donne un exemple concret de code et son impact.

<!-- EXEMPLE: Cherche dans le projet courant un endroit où une couche accède directement à une classe d'une couche non adjacente (ex: service qui accède à une propriété statique du repository, ou controller qui valide des données métier) -->

<details>
<summary>Réponse</summary>

Violations typiques :
- **Logique métier dans le controller** : règles de validation directement dans l'action HTTP → impossible à tester sans HTTP
- **Service qui accède à une classe concrète du repository** : `Repository.StaticList.Max(...)` au lieu de passer par l'interface → couplage fort, DIP violé
- **Domaine qui connaît l'infrastructure** : entité qui importe un namespace EF Core ou HTTP

Impact : changement technique = modification du mauvais composant, tests unitaires impossibles.

</details>

---

**Q12.** `[Normal]` Explique le SRP (Single Responsibility Principle) et donne un exemple concret d'application dans une architecture en couches.

<!-- EXEMPLE: Lis la classe service du projet courant — quelle est son unique responsabilité ? Quel changement futur la forcerait à évoluer ? -->

<details>
<summary>Réponse</summary>

SRP : une classe n'a qu'une seule raison de changer.

Exemple en architecture en couches : le service a une seule raison de changer (les règles métier). Si on change le stockage → c'est le repository qui change. Si on change le format de réponse HTTP → c'est le controller qui change. Le service reste stable face à ces deux types de changements.

</details>

### Mon suivi — Phase 2

| Date | Score | À revoir |
|------|-------|----------|
| | /5 | |

---

## PHASE 3 — Interfaces et Injection de Dépendances

### Vocabulaire clé
| Terme | Tu sais l'expliquer ? |
|---|---|
| Interface | ⬜ |
| Injection par constructeur | ⬜ |
| Conteneur DI | ⬜ |
| `AddScoped` | ⬜ |
| `AddSingleton` | ⬜ |
| `AddTransient` | ⬜ |
| Couplage fort vs faible | ⬜ |

### Questions

**Q13.** `[Facile]` Quelle est la différence entre une interface et une classe concrète ? Pourquoi injecte-t-on l'interface plutôt que la classe ?

<!-- EXEMPLE: Compare l'interface repository et son implémentation concrète dans le projet courant — qu'est-ce que l'interface masque au service ? -->

<details>
<summary>Réponse</summary>

Une interface définit un **contrat** (méthodes disponibles) sans implémentation. Une classe concrète fournit l'implémentation.

On injecte l'interface parce que le consommateur ne doit pas savoir comment c'est implémenté — seulement ce qu'il peut faire. Cela permet de changer l'implémentation sans modifier les classes qui l'utilisent.

</details>

---

**Q14.** `[Normal]` Comment déclare-t-on l'injection par constructeur en C# ? Écris un exemple complet.

<!-- EXEMPLE: Lis la classe service du projet courant et montre comment ses dépendances sont déclarées dans le constructeur -->

<details>
<summary>Réponse</summary>

```csharp
public class MonService : IMonService
{
    private readonly IMonRepository _repository;

    public MonService(IMonRepository repository)
    {
        _repository = repository;
    }
}
```

ASP.NET Core résout automatiquement `IMonRepository` depuis le conteneur DI et l'injecte à la création de `MonService`.

</details>

---

**Q15.** `[Facile]` Comment enregistre-t-on un service dans le conteneur DI d'ASP.NET Core ? Écris la ligne de code.

<!-- EXEMPLE: Lis Program.cs du projet courant et liste les enregistrements de services présents -->

<details>
<summary>Réponse</summary>

```csharp
builder.Services.AddScoped<IMonService, MonService>();
```

Cela dit au conteneur : "quand quelqu'un demande `IMonService`, crée et injecte `MonService`".

</details>

---

**Q16.** `[Normal]` Quelle est la différence entre `AddScoped`, `AddSingleton` et `AddTransient` ? Donne un cas d'usage pour chacun.

<!-- EXEMPLE: Vérifie dans Program.cs du projet courant quels lifetimes sont utilisés pour chaque service et si le choix est justifié -->

<details>
<summary>Réponse</summary>

- **`AddScoped`** : une instance par requête HTTP. Partagée dans toute la requête. Choix par défaut pour les services d'une API REST.
- **`AddSingleton`** : une seule instance pour toute la durée de vie de l'application. Pour des services sans état (ex: cache global, configuration).
- **`AddTransient`** : une nouvelle instance à chaque injection. Pour des services légers et sans état (ex: utilitaires).

</details>

---

**Q17.** `[Difficile]` Dans quel cas `AddSingleton` serait-il risqué pour un repository qui maintient un état interne ? Explique le problème technique.

<!-- EXEMPLE: Regarde l'implémentation du repository du projet courant — que se passerait-il avec des requêtes concurrentes en mode singleton ? -->

<details>
<summary>Réponse</summary>

Un repository singleton partage sa même instance entre toutes les requêtes simultanées. Si cet état est mutable (liste, connexion BDD), plusieurs requêtes accèdent en lecture/écriture sans synchronisation → **race condition**.

Avec `AddScoped`, chaque requête a sa propre instance — pas de conflit. Un `DbContext` EF Core en singleton est particulièrement dangereux : il n'est pas thread-safe.

</details>

---

**Q18.** `[Normal]` Comment l'injection d'une interface repository permet-elle de remplacer l'implémentation sans toucher au service ?

<!-- EXEMPLE: Lis l'interface repository du projet courant — montre quelle unique ligne dans Program.cs il faudrait changer pour basculer vers EF Core -->

<details>
<summary>Réponse</summary>

On crée une nouvelle classe `EfRepository : IRepository` et on change une seule ligne dans `Program.cs` :

```csharp
// Avant
builder.Services.AddScoped<IRepository, InMemoryRepository>();
// Après
builder.Services.AddScoped<IRepository, EfRepository>();
```

Le service ne change pas — il dépend de `IRepository`, pas de l'implémentation concrète. C'est OCP + DIP en action.

</details>

### Mon suivi — Phase 3

| Date | Score | À revoir |
|------|-------|----------|
| | /6 | |

---

## PHASE 4 — DTOs et PATCH

### Vocabulaire clé
| Terme | Tu sais l'expliquer ? |
|---|---|
| DTO (Data Transfer Object) | ⬜ |
| PUT vs PATCH | ⬜ |
| Type nullable (`string?`, `bool?`) | ⬜ |
| `HasValue` | ⬜ |
| `.Value` | ⬜ |

### Questions

**Q19.** `[Facile]` Qu'est-ce qu'un DTO ? Pourquoi ne pas exposer directement le modèle de domaine via l'API ?

<!-- EXEMPLE: Compare la classe de domaine principale du projet avec son DTO de création — qu'est-ce que le DTO masque ou transforme ? -->

<details>
<summary>Réponse</summary>

Un DTO (Data Transfer Object) est un objet conçu uniquement pour transférer des données entre le client et l'API.

Raisons de ne pas exposer le domaine directement :
- Le client pourrait envoyer des champs générés côté serveur (ex: `Id`)
- Le modèle de domaine peut changer sans impacter le contrat de l'API
- Les opérations partielles (PATCH) nécessitent des champs optionnels que l'entité de domaine n'a pas

</details>

---

**Q20.** `[Facile]` Quelle est la différence sémantique entre PUT et PATCH ?

<!-- EXEMPLE: Lis les endpoints PUT et PATCH du controller courant et compare leurs DTOs respectifs -->

<details>
<summary>Réponse</summary>

- **PUT** : remplace la ressource entière. Tous les champs doivent être fournis. Si un champ est absent, il est écrasé par sa valeur par défaut.
- **PATCH** : mise à jour partielle. Seuls les champs fournis sont modifiés. Les champs absents restent inchangés.

</details>

---

**Q21.** `[Normal]` Pourquoi utilise-t-on `bool?` plutôt que `bool` dans un DTO de mise à jour partielle ?

<!-- EXEMPLE: Lis le DTO de PATCH du projet courant et explique pourquoi chaque champ est nullable -->

<details>
<summary>Réponse</summary>

`bool` ne peut valoir que `true` ou `false` — impossible de distinguer "le client a envoyé `false`" de "le client n'a pas envoyé ce champ".

Avec `bool?`, la valeur `null` signifie "champ non fourni" → on conserve la valeur existante. `HasValue` permet de tester si le champ a été transmis.

</details>

---

**Q22.** `[Normal]` Écris la logique de mise à jour partielle pour un champ `bool?` en utilisant `HasValue`.

<!-- EXEMPLE: Cherche dans la couche service du projet courant comment le PATCH est implémenté -->

<details>
<summary>Réponse</summary>

```csharp
if (dto.IsActive.HasValue)
    entity.IsActive = dto.IsActive.Value;
// Si IsActive est null → champ non fourni → on ne touche pas à la valeur existante
```

</details>

---

**Q23.** `[Difficile]` Pourquoi `HasValue` est-il nécessaire pour `bool?` mais pas pour `string?` ? Explique la différence de nature entre les deux types.

<!-- EXEMPLE: Aucun exemple spécifique au projet nécessaire — explique les types valeur vs référence en C# -->

<details>
<summary>Réponse</summary>

`bool` est un **type valeur** (struct) — il ne peut pas être `null` nativement. `bool?` est un `Nullable<bool>` qui encapsule un flag `HasValue` et une propriété `Value`.

`string` est un **type référence** — il peut être `null` directement. On teste avec `!= null` ou `is not null`, sans `HasValue`.

Résumé : `HasValue` est pour les types valeur rendus nullables. Pour les types référence, `null` suffit.

</details>

### Mon suivi — Phase 4

| Date | Score | À revoir |
|------|-------|----------|
| | /5 | |

---

## PHASE 5 — Gestion des erreurs

### Vocabulaire clé
| Terme | Tu sais l'expliquer ? |
|---|---|
| Exception personnalisée | ⬜ |
| Middleware | ⬜ |
| Pipeline ASP.NET Core | ⬜ |
| Mapping exception → HTTP | ⬜ |
| Court-circuit du pipeline | ⬜ |

### Questions

**Q24.** `[Facile]` Comment crée-t-on une exception personnalisée en C# ? Montre la structure minimale.

<!-- EXEMPLE: Lis une des exceptions personnalisées du projet courant -->

<details>
<summary>Réponse</summary>

```csharp
public class NotFoundException : Exception
{
    public NotFoundException(string message) : base(message) { }
}
```

Elle hérite d'`Exception` et passe le message au constructeur parent via `base(message)`.

</details>

---

**Q25.** `[Normal]` Qu'est-ce que le pipeline ASP.NET Core ? Comment un middleware s'y branche-t-il ?

<!-- EXEMPLE: Lis Program.cs du projet courant et montre l'ordre de déclaration des middlewares -->

<details>
<summary>Réponse</summary>

Le pipeline est la chaîne de middlewares que traverse une requête HTTP de son arrivée jusqu'à la réponse. Chaque middleware peut traiter la requête, la transmettre au suivant, ou court-circuiter la chaîne.

```csharp
app.UseMiddleware<MonMiddleware>(); // brancher un middleware personnalisé
```

L'ordre d'appel dans `Program.cs` définit l'ordre d'exécution.

</details>

---

**Q26.** `[Normal]` Pourquoi centralise-t-on la gestion d'erreur dans un middleware plutôt que des try/catch dans chaque controller ?

<!-- EXEMPLE: Lis le middleware d'erreur du projet courant — combien d'exceptions gère-t-il en un seul endroit ? -->

<details>
<summary>Réponse</summary>

- **Évite la duplication** : un seul endroit pour gérer toutes les exceptions
- **Réponse cohérente** : format JSON identique sur toute l'API
- **Maintenance simplifiée** : changer le format d'erreur = modifier un seul fichier
- **Controllers plus propres** : pas de try/catch, code métier uniquement

</details>

---

**Q27.** `[Facile]` Donne un exemple de mapping entre exceptions métier et codes HTTP. Cite au moins 3 paires.

<!-- EXEMPLE: Lis le middleware d'erreur du projet courant et liste tous les mappings exception → HTTP status -->

<details>
<summary>Réponse</summary>

Mappings classiques :
- `NotFoundException` → 404 Not Found
- `ConflictException` → 409 Conflict
- `ValidationException` → 400 Bad Request
- `UnauthorizedException` → 401 Unauthorized
- Exception non gérée → 500 Internal Server Error

</details>

---

**Q28.** `[Normal]` Pourquoi le middleware de gestion d'erreur doit-il être déclaré avant les routes dans le pipeline ?

<!-- EXEMPLE: Regarde l'ordre dans Program.cs du projet courant — que se passerait-il si le middleware était déclaré après MapControllers ? -->

<details>
<summary>Réponse</summary>

Le pipeline s'exécute dans l'ordre de déclaration. Déclaré en premier, le middleware "entoure" tout ce qui vient après — y compris les controllers. Toute exception levée pendant le traitement de la requête remonte jusqu'au middleware.

Inversé, le middleware ne verrait jamais les exceptions des controllers car celles-ci seraient levées après lui dans le pipeline.

</details>

---

**Q29.** `[Normal]` Que retourne ASP.NET Core si une exception non gérée est levée sans middleware d'erreur ?

<!-- EXEMPLE: Décris ce que retournerait l'API du projet courant si ExceptionMiddleware était absent -->

<details>
<summary>Réponse</summary>

ASP.NET Core retourne une réponse 500 Internal Server Error :
- En **développement** : page d'erreur HTML avec stack trace (pas JSON, pas cohérent)
- En **production** : message générique (mais potentiellement des infos techniques si mal configuré)

Problèmes : format non JSON, incohérent avec le reste de l'API, risque d'exposition d'informations internes.

</details>

### Mon suivi — Phase 5

| Date | Score | À revoir |
|------|-------|----------|
| | /6 | |

---

## PHASE 6 — Tests unitaires (xUnit + Moq)

### Vocabulaire clé
| Terme | Tu sais l'expliquer ? |
|---|---|
| Pattern AAA | ⬜ |
| Mock | ⬜ |
| `Setup` / `Returns` | ⬜ |
| `Verify` | ⬜ |
| `It.IsAny<T>()` / `It.Is<T>()` | ⬜ |
| `Assert.Throws` | ⬜ |
| `[Fact]` | ⬜ |
| Test unitaire vs test d'intégration | ⬜ |

### Questions

**Q30.** `[Facile]` Explique le pattern AAA (Arrange / Act / Assert) avec un exemple.

<!-- EXEMPLE: Lis un test unitaire du projet courant et identifie les trois parties AAA -->

<details>
<summary>Réponse</summary>

- **Arrange** : préparer les données et configurer les mocks
- **Act** : exécuter le code testé
- **Assert** : vérifier le résultat

```csharp
// Arrange
var mock = new Mock<IRepository>();
mock.Setup(r => r.GetById(1)).Returns(new Entity { Id = 1 });
var service = new MonService(mock.Object);

// Act
var result = service.GetById(1);

// Assert
Assert.Equal(1, result.Id);
```

</details>

---

**Q31.** `[Normal]` Dans les tests d'un service, pourquoi mock-t-on la dépendance (repository) et non le service lui-même ?

<!-- EXEMPLE: Lis les tests du service du projet courant et montre comment le mock est configuré et injecté -->

<details>
<summary>Réponse</summary>

On teste **le service**. Le service dépend du repository — on isole cette dépendance avec un mock pour tester uniquement la logique du service, sans effet de bord ni appel réel au stockage.

Mocker le service lui-même ne testerait rien : on remplacerait précisément ce qu'on veut tester.

</details>

---

**Q32.** `[Normal]` Quelle est la condition pour qu'un type soit mockable avec Moq ? Pourquoi ne peut-on pas mocker directement une classe concrète ?

<!-- EXEMPLE: Explique pourquoi on ne peut pas écrire new Mock<RepositoryConcret>() sans méthodes virtuelles -->

<details>
<summary>Réponse</summary>

Moq ne peut mocker que :
- Des **interfaces**
- Des **classes abstraites**
- Des classes avec des méthodes **`virtual`**

Une classe concrète sans méthodes virtuelles ne peut pas être substituée par Moq. C'est une raison concrète pour laquelle on injecte des interfaces : cela rend le code testable.

</details>

---

**Q33.** `[Normal]` Écris la configuration d'un mock qui retourne un objet quand une méthode est appelée avec un argument précis.

<!-- EXEMPLE: Montre un exemple de Setup().Returns() tiré des tests du projet courant -->

<details>
<summary>Réponse</summary>

```csharp
var entity = new Entity { Id = 1, Name = "Test" };
mockRepository.Setup(r => r.GetById(1)).Returns(entity);

// Avec n'importe quelle valeur
mockRepository.Setup(r => r.GetById(It.IsAny<int>())).Returns(entity);
```

</details>

---

**Q34.** `[Normal]` Quelle est la différence entre `It.IsAny<T>()` et `It.Is<T>(x => ...)` ? Quand utiliser l'un ou l'autre ?

<!-- EXEMPLE: Cherche dans les tests du projet courant des utilisations de It.IsAny et It.Is — compare les cas -->

<details>
<summary>Réponse</summary>

- `It.IsAny<T>()` : le mock accepte **n'importe quelle valeur** pour ce paramètre. Utilisé quand la valeur exacte ne compte pas.
- `It.Is<T>(x => x.Name == "foo")` : le mock ne s'active que si le paramètre **correspond au prédicat**. Utilisé pour vérifier les données exactes transmises.

Préférer `It.Is<T>()` dans les `Verify()` pour des assertions précises.

</details>

---

**Q35.** `[Facile]` Comment testes-tu qu'une exception est bien levée dans xUnit ?

<!-- EXEMPLE: Lis un test "NotFound" ou "Conflict" du projet courant -->

<details>
<summary>Réponse</summary>

```csharp
Assert.Throws<NotFoundException>(() => service.GetById(999));

// Ou en async
await Assert.ThrowsAsync<NotFoundException>(() => service.GetByIdAsync(999));
```

</details>

---

**Q36.** `[Normal]` Comment vérifies-tu avec Moq qu'une méthode a bien été appelée une seule fois avec des arguments précis ?

<!-- EXEMPLE: Cherche les appels à .Verify() dans les tests du projet courant -->

<details>
<summary>Réponse</summary>

```csharp
mockRepository.Verify(
    r => r.Add(It.Is<Entity>(e => e.Name == "Ma valeur")),
    Times.Once
);
```

`Times.Once`, `Times.Never`, `Times.Exactly(n)` permettent de vérifier le nombre d'appels.

</details>

---

**Q37.** `[Difficile]` Comment testes-tu le comportement d'une mise à jour partielle (PATCH) quand un champ n'est pas fourni ?

<!-- EXEMPLE: Lis le test PATCH du projet courant — si absent, décris comment tu l'écrirais avec le DTO PATCH du projet -->

<details>
<summary>Réponse</summary>

```csharp
// Arrange
var entity = new Entity { Id = 1, Name = "Original", IsActive = false };
mockRepository.Setup(r => r.GetById(1)).Returns(entity);
var dto = new PatchDto { Name = "Nouveau", IsActive = null }; // IsActive non fourni

// Act
service.Patch(1, dto);

// Assert
Assert.Equal("Nouveau", entity.Name);
Assert.False(entity.IsActive); // inchangé car null dans le DTO
```

</details>

---

**Q38.** `[Difficile]` Pour tester une méthode de mise à jour (Update), quels sont les cas types à couvrir ?

<!-- EXEMPLE: Lis les tests Update du projet courant et liste les cas couverts -->

<details>
<summary>Réponse</summary>

3 cas à couvrir systématiquement :
1. **NotFound** : l'entité avec l'`id` donné n'existe pas → exception levée
2. **Conflict** : une contrainte d'unicité est violée (ex: titre déjà pris) → exception levée
3. **OK** : l'entité existe, contraintes respectées → méthode de mise à jour du repository appelée avec les bonnes valeurs (`Verify`)

</details>

---

**Q39.** `[Facile]` Quelle est la différence entre un test unitaire et un test d'intégration ?

<!-- EXEMPLE: Classifie les tests du projet courant : sont-ils unitaires ou d'intégration ? Justifie ta réponse -->

<details>
<summary>Réponse</summary>

- **Test unitaire** : teste une unité isolée avec toutes les dépendances mockées. Rapide, déterministe, pas d'effet de bord.
- **Test d'intégration** : teste plusieurs couches ensemble (ex: controller → service → base de données réelle). Plus lent, teste le comportement réel du système.

Les tests xUnit + Moq sont des tests unitaires — les dépendances sont mockées.

</details>

### Mon suivi — Phase 6

| Date | Score | À revoir |
|------|-------|----------|
| | /10 | |

---

## Score — Niveau Junior+

| Phase | Questions | Score |
|---|---|---|
| Phase 1 — Bases | Q1 à Q7 | /7 |
| Phase 2 — Architecture | Q8 à Q12 | /5 |
| Phase 3 — DI & Interfaces | Q13 à Q18 | /6 |
| Phase 4 — DTOs/PATCH | Q19 à Q23 | /5 |
| Phase 5 — Erreurs | Q24 à Q29 | /6 |
| Phase 6 — Tests unitaires | Q30 à Q39 | /10 |
| **Total** | | **/39** |

> **32/39 et plus** → Niveau maîtrisé
> **Moins de 32/39** → Consulte `dotnet/niveau.md` pour identifier les points à retravailler

