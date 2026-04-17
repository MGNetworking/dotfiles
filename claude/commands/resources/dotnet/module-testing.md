# Module — Tests unitaires .NET

> Niveau : **Junior → Mid**
> Outils : xUnit, Moq

---

## Vocabulaire clé

| Terme | Tu sais l'expliquer ? |
|---|---|
| Arrange / Act / Assert | ⬜ |
| `[Fact]` vs `[Theory]` | ⬜ |
| `[InlineData]` / `[MemberData]` / `[ClassData]` | ⬜ |
| Mock / `Mock<T>` | ⬜ |
| `Setup` / `Verify` | ⬜ |
| `ActionResult<T>` vs `IActionResult` | ⬜ |
| `.Result` vs `.Value` | ⬜ |

---

## Questions

**Q1.** `[Facile]` Qu'est-ce que le pattern **Arrange / Act / Assert** ? Donne un exemple complet.

<details>
<summary>Réponse</summary>

Chaque test suit trois étapes :

```csharp
[Fact]
public void ChangePriority_ShouldUpdatePriority()
{
    // Arrange — préparer les données
    var ticket = new Ticket(new TicketTitle("Fix login bug"), "desc", Priority.Medium, Category.Bug);

    // Act — exécuter l'action testée
    ticket.ChangePriority(Priority.Critical);

    // Assert — vérifier le résultat
    Assert.Equal(Priority.Critical, ticket.Priority);
}
```

</details>

---

**Q2.** `[Facile]` Quelle est la convention de nommage des tests ? Pourquoi est-elle importante ?

<details>
<summary>Réponse</summary>

Convention : `Methode_Comportement_Condition`

```
UpdateTitle_ShouldThrowValidationException_WhenTitleIsTooShort
Constructor_WithValidData_SetsStatusToOpen
Transition_ShouldThrow_WhenTransitionIsForbidden
```

**Pourquoi :** le nom doit permettre de comprendre l'échec **sans lire le code**. Quand un test passe au rouge en CI, le nom seul doit indiquer ce qui est cassé.

</details>

---

**Q3.** `[Normal]` Quelle est la différence entre `[Fact]` et `[Theory]` ? Quand utiliser l'un ou l'autre ?

<details>
<summary>Réponse</summary>

- **`[Fact]`** : test fixe, sans paramètre — un seul cas testé
- **`[Theory]`** : test paramétré, exécuté une fois par jeu de données — plusieurs cas en un seul test

```csharp
// [Fact] — un seul cas
[Fact]
public void Constructor_WithValidTitle_SetsTitle() { ... }

// [Theory] — plusieurs cas invalides testés séparément
[Theory]
[InlineData("")]
[InlineData("   ")]
[InlineData("ab")]
public void Constructor_ShouldThrow_WhenTitleIsInvalid(string title)
{
    Assert.Throws<ValidationException>(() => new TicketTitle(title));
}
```

Le runner affiche une ligne par `[InlineData]` — si un cas échoue, tu sais exactement lequel.

Règle : si tu as plusieurs cas similaires avec des valeurs différentes → `[Theory]`. Sinon → `[Fact]`.

</details>

---

**Q4.** `[Normal]` Quand utiliser `[InlineData]`, `[MemberData]` et `[ClassData]` ?

<details>
<summary>Réponse</summary>

| Attribut | Quand l'utiliser | Limite |
|---|---|---|
| `[InlineData]` | Valeurs simples (`string`, `int`, `bool`) | Types constants seulement |
| `[MemberData]` | Objets complexes, réutilisation partielle | Propriété/méthode statique dans la même classe |
| `[ClassData]` | Génération complexe, réutilisation entre plusieurs classes | Plus verbeux |

```csharp
// MemberData — objets complexes
public static IEnumerable<object[]> TitresValides =>
[
    [new TicketTitle("Fix login bug")],
    [new TicketTitle("Add dark mode")]
];

[Theory]
[MemberData(nameof(TitresValides))]
public void UpdateTitle_ShouldUpdate(TicketTitle title) { ... }
```

</details>

---

**Q5.** `[Normal]` Comment tester qu'une exception est levée ? Et qu'aucune exception n'est levée ?

<details>
<summary>Réponse</summary>

```csharp
// Vérifier qu'une exception est levée
Assert.Throws<ValidationException>(() => new TicketTitle("ab"));

// Vérifier aussi le message
var ex = Assert.Throws<ValidationException>(() => new TicketTitle("ab"));
Assert.Contains("3 characters", ex.Message);

// Vérifier qu'aucune exception n'est levée
var ex = Record.Exception(() => new TicketTitle("Titre valide"));
Assert.Null(ex);
```

`Record.Exception` capture l'exception si elle existe, ou retourne `null`. `Assert.Null(ex)` confirme qu'aucune exception n'a été lancée.

</details>

---

**Q6.** `[Normal]` À quoi sert **Moq** ? Montre le pattern de base avec Setup et Verify.

<details>
<summary>Réponse</summary>

Moq permet de simuler des dépendances (repository, service, API externe) pour tester le code en isolation.

```csharp
// 1. Créer le mock
var mockRepo = new Mock<ITicketRepository>();

// 2. Injecter dans le code testé
var service = new TicketService(mockRepo.Object);

// 3. Configurer le comportement simulé
mockRepo.Setup(r => r.GetById(1))
        .Returns(new Ticket(new TicketTitle("Fix login bug"), "desc", Priority.Medium, Category.Bug));

// 4. Vérifier qu'une méthode a bien été appelée
mockRepo.Verify(r => r.Update(It.IsAny<Ticket>()), Times.Once);
```

Règle : ne mock que les **dépendances externes** (BD, HTTP, fichiers). Ne jamais mocker le code que tu testes.

</details>

---

**Q7.** `[Normal]` Quelle est la différence entre `ActionResult<T>` et `IActionResult` dans un controller ? Comment asserter dans chaque cas ?

<details>
<summary>Réponse</summary>

- **`ActionResult<T>`** : endpoints GET/POST qui retournent un corps (données + code HTTP)
- **`IActionResult`** : endpoints PUT/PATCH/DELETE sans corps

```csharp
// ActionResult<T> — naviguer via .Result
var result = _controller.GetAll(null, null, null); // ActionResult<IEnumerable<TicketDto>>
var ok = Assert.IsType<OkObjectResult>(result.Result);

// IActionResult — asserter directement sur result
var result = _controller.Delete(1); // IActionResult
Assert.IsType<NoContentResult>(result);
```

</details>

---

**Q8.** `[Difficile]` Pourquoi utilise-t-on `.Result` et non `.Value` pour asserter sur un `ActionResult<T>` quand le controller utilise `Ok()` ?

<details>
<summary>Réponse</summary>

`ActionResult<T>` est un wrapper double :
- `.Result` → contient l'objet HTTP (`OkObjectResult`, `NotFoundResult`…) — quand le controller appelle `Ok()`, `NotFound()`…
- `.Value` → contient la valeur brute `T` — uniquement quand le controller retourne la valeur directement sans helper HTTP (cas rare)

```csharp
// Controller : return Ok(tickets) → stocké dans .Result
var result = _controller.GetAll(null, null, null);

// ✅ Correct
var ok = Assert.IsType<OkObjectResult>(result.Result);

// ❌ Null — result.Value est vide quand Ok() est utilisé
var data = result.Value;
```

</details>

---

**Q9.** `[Normal]` Cite les codes HTTP testables en tests unitaires et leur classe .NET correspondante.

<details>
<summary>Réponse</summary>

| Méthode controller | Classe .NET | Code |
|---|---|---|
| `Ok(data)` | `OkObjectResult` | 200 |
| `NoContent()` | `NoContentResult` | 204 |
| `BadRequest(obj)` | `BadRequestObjectResult` | 400 |
| `NotFound()` | `NotFoundResult` | 404 |
| `CreatedAtAction(...)` | `CreatedAtActionResult` | 201 |
| `Conflict()` | `ConflictResult` | 409 |
| `UnprocessableEntity()` | `UnprocessableEntityResult` | 422 |

</details>

---

**Q10.** `[Difficile]` Pourquoi les cas d'erreur (`404`, `409`, `422`…) ne sont-ils **pas testables** en tests unitaires du controller ? Où doivent-ils être testés ?

<details>
<summary>Réponse</summary>

Dans les tests unitaires, le controller est instancié directement — le pipeline ASP.NET Core (middleware, routing) ne s'exécute pas. `ExceptionMiddleware`, qui convertit les exceptions en codes HTTP, n'intervient donc jamais.

```
Tests unitaires :  _controller.Delete(1)  →  NoContentResult  ✅
                   NotFoundException levée → non capturée → test plante ❌

Tests d'intégration : GET /tickets/99  →  ExceptionMiddleware  →  404  ✅
```

**Où tester chaque responsabilité :**

| Comportement | Où tester |
|---|---|
| Exceptions métier (`ValidationException`, `NotFoundException`) | Tests du service |
| Conversion exception → code HTTP | Tests d'intégration (`WebApplicationFactory`) |
| Routing (`/tickets` → `GetAll`) | Tests d'intégration |
| Le controller délègue bien au service | Tests unitaires du controller |

</details>

---

## Score — Module Tests unitaires

| Thème | Questions | Score |
|---|---|---|
| Pattern AAA & nommage | Q1, Q2 | /2 |
| Fact, Theory & sources de données | Q3, Q4 | /2 |
| Assertions & exceptions | Q5 | /1 |
| Moq | Q6 | /1 |
| Tests controller | Q7, Q8, Q9, Q10 | /4 |
| **Total** | | **/10** |

> **8/10 et plus** → Module maîtrisé
> **Moins de 8/10** → Relis `docs/reference/unit-tests-xunit.md` et `docs/reference/unit-tests-controllers.md`

### Mon suivi

| Date | Score | À revoir |
|------|-------|----------|
| | /10 | |
