# Fiches de révision — Phase 17
# Niveau : Senior / Avancé

> Consulte ces fiches pour réviser un concept précis ou t'auto-évaluer.
> Pour un quiz interactif sur ton code actuel, utilise `/learn:quiz`.
>
> **Score minimum** : 4/5 pour valider le niveau

---

## PHASE 17 — Clean Architecture, CQRS, MediatR

### Vocabulaire clé
| Terme | Tu sais l'expliquer ? |
|---|---|
| Clean Architecture | ⬜ |
| Règle de dépendance | ⬜ |
| CQRS | ⬜ |
| `IRequest<T>` (MediatR) | ⬜ |
| `IRequestHandler<TRequest, TResponse>` | ⬜ |
| Couche Presentation / Application / Domain / Infrastructure | ⬜ |

### Questions

**Q89.** `[Facile]` Qu'est-ce que la Clean Architecture ? Cite ses 4 couches principales.

<!-- EXEMPLE: Compare la structure actuelle du projet courant avec les 4 couches de la Clean Architecture — qu'est-ce qui correspond ? qu'est-ce qui manque ? -->

<details>
<summary>Réponse</summary>

La Clean Architecture organise le code en **cercles concentriques** où les dépendances ne peuvent pointer que vers le centre.

Les 4 couches (de l'intérieur vers l'extérieur) :
1. **Domain** (Entities) : règles métier pures, aucune dépendance externe
2. **Application** (Use Cases) : orchestration, interfaces des dépendances
3. **Infrastructure** : implémentations concrètes (BDD, fichiers, APIs externes)
4. **Presentation** (API / UI) : controllers, DTOs, mappings

</details>

---

**Q90.** `[Normal]` Quelle est la règle de dépendance en Clean Architecture ? Dans quel sens les dépendances doivent-elles pointer ?

<!-- EXEMPLE: Identifie dans le projet courant les dépendances entre couches et vérifie si elles respectent la règle (les couches internes ne connaissent pas les externes) -->

<details>
<summary>Réponse</summary>

**Règle de dépendance** : les dépendances ne peuvent pointer que **vers l'intérieur**. Une couche externe peut dépendre d'une couche interne, jamais l'inverse.

```
Presentation → Application → Domain
Infrastructure → Application → Domain
```

- `Domain` ne connaît ni `Infrastructure` ni `Application`
- `Application` ne connaît pas `Infrastructure` ni `Presentation`
- `Infrastructure` implémente les interfaces définies dans `Application`

Cela permet de changer l'infrastructure (BDD, framework) sans toucher au domaine ou à la logique applicative.

</details>

---

**Q91.** `[Normal]` Qu'est-ce que CQRS ? Quelle séparation introduit-il par rapport à un service classique ?

<!-- EXEMPLE: Compare l'approche CQRS avec un service classique qui mélange lectures et écritures dans le même service -->

<details>
<summary>Réponse</summary>

**CQRS** (Command Query Responsibility Segregation) sépare les opérations de **lecture** (Query) et d'**écriture** (Command) :

- **Command** : modifie l'état (`CreateEntityCommand`, `DeleteEntityCommand`) — retourne un résultat minimal ou rien
- **Query** : lit l'état sans le modifier (`GetEntityQuery`, `GetAllEntitiesQuery`) — retourne des données

Par rapport à un service classique qui mélange tout, CQRS permet :
- Des modèles de lecture et d'écriture différents (optimisation)
- Une scalabilité indépendante (plus de replicas en lecture)
- Une responsabilité unique pour chaque handler

</details>

---

**Q92.** `[Difficile]` Comment MediatR implémente-t-il le pattern CQRS ? Montre la structure d'une commande et son handler.

<!-- EXEMPLE: Montre comment l'opération Create du projet courant serait réécrite avec MediatR (CreateCommand + handler) -->

<details>
<summary>Réponse</summary>

```csharp
// 1. La commande (ce qu'on veut faire)
public record CreateEntityCommand(string Title) : IRequest<EntityDto>;

// 2. Le handler (comment on le fait)
public class CreateEntityCommandHandler : IRequestHandler<CreateEntityCommand, EntityDto>
{
    private readonly IRepository _repository;

    public CreateEntityCommandHandler(IRepository repository)
    {
        _repository = repository;
    }

    public Task<EntityDto> Handle(CreateEntityCommand request, CancellationToken ct)
    {
        var entity = Entity.Create(request.Title);
        _repository.Add(entity);
        return Task.FromResult(new EntityDto(entity.Id, entity.Title));
    }
}

// 3. Le controller (dispatch via MediatR)
[HttpPost]
public async Task<IActionResult> Create([FromBody] CreateDto dto)
{
    var result = await _mediator.Send(new CreateEntityCommand(dto.Title));
    return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
}
```

MediatR fait le pont entre la commande et son handler — le controller ne connaît plus le service.

</details>

---

**Q93.** `[Difficile]` Comment identifie-t-on une violation de la règle de dépendance dans une Clean Architecture ? Donne un exemple concret.

<!-- EXEMPLE: Cherche dans le projet courant une dépendance qui violerait la règle de dépendance si on appliquait la Clean Architecture (ex: entité de domaine qui importe un namespace EF Core ou HTTP) -->

<details>
<summary>Réponse</summary>

Violations typiques de la règle de dépendance :

1. **Domain → Infrastructure** : une entité de domaine qui importe `Microsoft.EntityFrameworkCore` ou utilise des attributs EF Core (`[Column]`, `[Table]`)
2. **Application → Presentation** : un use case qui connaît `HttpContext`, `IActionResult` ou des DTOs de l'API
3. **Domain → Application** : une entité qui appelle directement un repository (au lieu que le service le fasse)

```csharp
// ❌ Violation : le domaine connaît EF Core (couche externe)
using Microsoft.EntityFrameworkCore;
public class MonEntite
{
    [Key] // Attribut EF Core dans le domaine !
    public int Id { get; private set; }
}
```

Correction : configurer EF Core dans `Infrastructure` via `IEntityTypeConfiguration<T>`, sans toucher au domaine.

</details>

### Mon suivi — Phase 17

| Date | Score | À revoir |
|------|-------|----------|
| | /5 | |

---

## Score — Niveau Senior / Avancé

| Phase | Questions | Score |
|---|---|---|
| Phase 17 — Clean Architecture / CQRS | Q89 à Q93 | /5 |
| **Total** | | **/5** |

> **4/5 et plus** → Niveau maîtrisé
> **Moins de 4/5** → Consulte `dotnet/niveau.md` pour identifier les points à retravailler
