# Fiches de révision — Phases 11 à 13
# Niveau : Intermédiaire confirmé

> Consulte ces fiches pour réviser un concept précis ou t'auto-évaluer.
> Pour un quiz interactif sur ton code actuel, utilise `/learn:quiz`.
>
> **Score minimum** : 12/15 pour valider le niveau

---

## PHASE 11 — Validation avec FluentValidation

### Vocabulaire clé
| Terme | Tu sais l'expliquer ? |
|---|---|
| `AbstractValidator<T>` | ⬜ |
| `.NotEmpty()` / `.MaximumLength()` | ⬜ |
| `.Must(predicate)` | ⬜ |
| Validation automatique (400) | ⬜ |
| Règle chaînée | ⬜ |

### Questions

**Q61.** `[Facile]` Qu'est-ce que FluentValidation ? Quelle limitation des DataAnnotations résout-il ?

<!-- EXEMPLE: Compare comment la validation du titre était faite dans le projet courant (exception dans le service ou domaine) avec ce que FluentValidation permettrait -->

<details>
<summary>Réponse</summary>

FluentValidation est une librairie de validation qui définit les règles dans des classes dédiées (`AbstractValidator<T>`), séparées du modèle et du service.

Limites de DataAnnotations résolues :
- Règles complexes impossibles à exprimer avec de simples attributs
- Validation mélangée avec le modèle (couplage)
- Tests unitaires des validateurs difficiles avec DataAnnotations

</details>

---

**Q62.** `[Normal]` Comment crée-t-on un validateur FluentValidation ? Montre la structure de base avec deux règles.

<!-- EXEMPLE: Montre un validateur pour le DTO de création du projet courant (ex: titre obligatoire, longueur max) -->

<details>
<summary>Réponse</summary>

```csharp
public class CreateDtoValidator : AbstractValidator<CreateDto>
{
    public CreateDtoValidator()
    {
        RuleFor(x => x.Title)
            .NotEmpty().WithMessage("Le titre est obligatoire")
            .MaximumLength(100).WithMessage("Le titre ne dépasse pas 100 caractères");

        RuleFor(x => x.Description)
            .MaximumLength(500);
    }
}
```

</details>

---

**Q63.** `[Normal]` Cite 3 règles de validation FluentValidation et leur signification.

<!-- EXEMPLE: Aucun exemple spécifique au projet nécessaire — liste les règles les plus courantes -->

<details>
<summary>Réponse</summary>

| Règle | Signification |
|---|---|
| `.NotEmpty()` | Non null et non vide (string/collection) |
| `.NotNull()` | Non null |
| `.MaximumLength(n)` | Longueur max pour une string |
| `.MinimumLength(n)` | Longueur min pour une string |
| `.GreaterThan(n)` | Valeur numérique > n |
| `.EmailAddress()` | Format email valide |
| `.Must(x => ...)` | Règle personnalisée via prédicat |

</details>

---

**Q64.** `[Normal]` Comment enregistre-t-on FluentValidation dans ASP.NET Core pour qu'il retourne automatiquement un 400 si la validation échoue ?

<!-- EXEMPLE: Montre les lignes à ajouter dans Program.cs du projet courant pour activer la validation automatique -->

<details>
<summary>Réponse</summary>

```csharp
// Program.cs
builder.Services.AddControllers()
    .AddFluentValidation(fv =>
        fv.RegisterValidatorsFromAssemblyContaining<CreateDtoValidator>());
```

Avec cette configuration, si le body entrant ne passe pas la validation, ASP.NET Core retourne automatiquement un 400 avec le détail des erreurs — sans code dans le controller.

</details>

---

**Q65.** `[Difficile]` Comment écrit-on une règle de validation personnalisée avec `.Must(...)` ? Dans quel cas est-ce nécessaire ?

<!-- EXEMPLE: Montre une règle .Must() qui vérifierait une contrainte spécifique au projet courant (ex: format de titre particulier) -->

<details>
<summary>Réponse</summary>

`.Must()` s'utilise quand les règles standards ne suffisent pas :

```csharp
RuleFor(x => x.Title)
    .Must(title => !title.StartsWith(" "))
    .WithMessage("Le titre ne doit pas commencer par un espace");

// Avec accès à l'objet entier
RuleFor(x => x.EndDate)
    .Must((dto, endDate) => endDate > dto.StartDate)
    .WithMessage("La date de fin doit être après la date de début");
```

Cas d'usage : validation croisée entre plusieurs champs, règles métier ne pouvant pas s'exprimer avec les règles standard.

</details>

### Mon suivi — Phase 11

| Date | Score | À revoir |
|------|-------|----------|
| | /5 | |

---

## PHASE 12 — Logging

### Vocabulaire clé
| Terme | Tu sais l'expliquer ? |
|---|---|
| `ILogger<T>` | ⬜ |
| Niveaux de log | ⬜ |
| Logging structuré | ⬜ |
| Serilog | ⬜ |
| `appsettings.json` (log config) | ⬜ |

### Questions

**Q66.** `[Facile]` Cite les niveaux de log ASP.NET Core du moins sévère au plus sévère.

<!-- EXEMPLE: Aucun exemple spécifique au projet nécessaire — c'est une question de mémorisation -->

<details>
<summary>Réponse</summary>

Dans l'ordre croissant de sévérité :
1. `Trace` — détails très fins (débogage profond)
2. `Debug` — informations de débogage
3. `Information` — flux normal de l'application
4. `Warning` — situation anormale mais récupérable
5. `Error` — erreur, une opération a échoué
6. `Critical` — défaillance grave, arrêt possible de l'application

</details>

---

**Q67.** `[Normal]` Comment injecte-t-on `ILogger<T>` dans un service ? Montre un exemple de log structuré.

<!-- EXEMPLE: Montre comment ajouter du logging dans le service du projet courant pour tracer les opérations importantes -->

<details>
<summary>Réponse</summary>

```csharp
public class MonService
{
    private readonly ILogger<MonService> _logger;

    public MonService(ILogger<MonService> logger)
    {
        _logger = logger;
    }

    public void Create(CreateDto dto)
    {
        _logger.LogInformation("Creating entity with title {Title}", dto.Title);
        // ...
        _logger.LogInformation("Entity {Id} created successfully", entity.Id);
    }
}
```

Le logging structuré (`{Title}`, `{Id}`) permet à des outils comme Seq ou Elasticsearch d'indexer les propriétés et de les filtrer.

</details>

---

**Q68.** `[Normal]` Comment configure-t-on les niveaux de log dans `appsettings.json` ?

<!-- EXEMPLE: Montre la configuration de logging adaptée au projet courant (moins verbeux en prod, plus en dev) -->

<details>
<summary>Réponse</summary>

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning",
      "MonNamespace.Services": "Debug"
    }
  }
}
```

- `Default` : niveau par défaut pour tous les namespaces non listés
- Les namespaces plus spécifiques ont priorité sur `Default`
- `appsettings.Development.json` peut surcharger avec des niveaux plus verbeux

</details>

---

**Q69.** `[Difficile]` Quelle est la différence entre `ILogger` natif et Serilog ? Dans quel cas migrer vers Serilog ?

<!-- EXEMPLE: Évalue si le projet courant bénéficierait de Serilog (ex: besoin d'écrire dans un fichier, besoin de formatage JSON) -->

<details>
<summary>Réponse</summary>

| | ILogger natif | Serilog |
|---|---|---|
| Sortie | Console, EventLog | Console, fichier, BDD, Seq, Elasticsearch... |
| Format | Texte basique | JSON structuré, templates personnalisables |
| Configuration | appsettings.json | Code + appsettings |
| Performance | Bon | Très bon (async sinks) |

Migrer vers Serilog si : besoin d'écrire dans un fichier, besoin de format JSON pour un agrégateur de logs (Grafana, ELK), ou besoin de plusieurs destinations simultanées.

</details>

---

**Q70.** `[Normal]` Pourquoi utilise-t-on le logging structuré (`_logger.LogInformation("Entity {Id}", id)`) plutôt que la concaténation de strings ?

<!-- EXEMPLE: Montre la différence entre les deux approches pour logger une opération du projet courant -->

<details>
<summary>Réponse</summary>

```csharp
// ❌ Concaténation : perd la structure, coûteux si log désactivé
_logger.LogInformation("Entity " + id + " created by " + user);

// ✅ Structuré : les propriétés sont indexables
_logger.LogInformation("Entity {EntityId} created by {UserId}", id, user);
```

Avantages du structuré :
- Les propriétés (`EntityId`, `UserId`) sont indexées séparément → recherche filtrée possible
- Si le niveau est désactivé, les paramètres ne sont pas évalués → performance
- Les outils d'agrégation (Seq, ELK) peuvent filtrer sur `EntityId = 5`

</details>

### Mon suivi — Phase 12

| Date | Score | À revoir |
|------|-------|----------|
| | /5 | |

---

## PHASE 13 — Configuration et Options Pattern

### Vocabulaire clé
| Terme | Tu sais l'expliquer ? |
|---|---|
| `IConfiguration` | ⬜ |
| Options Pattern | ⬜ |
| `IOptions<T>` | ⬜ |
| `IOptionsSnapshot<T>` | ⬜ |
| `dotnet user-secrets` | ⬜ |
| Variables d'environnement | ⬜ |

### Questions

**Q71.** `[Facile]` Comment lit-on une valeur depuis `appsettings.json` avec `IConfiguration` ?

<!-- EXEMPLE: Montre comment lire une valeur de configuration utile dans le projet courant (ex: connection string, limite de pagination) -->

<details>
<summary>Réponse</summary>

```json
// appsettings.json
{
  "App": {
    "MaxPageSize": 50
  }
}
```

```csharp
// Injection directe
public class MonService
{
    public MonService(IConfiguration config)
    {
        var maxSize = config.GetValue<int>("App:MaxPageSize");
        // ou
        var maxSize = config["App:MaxPageSize"];
    }
}
```

</details>

---

**Q72.** `[Normal]` Comment lie-t-on une section JSON à une classe typée avec l'Options Pattern ?

<!-- EXEMPLE: Montre comment créer une classe de configuration pour le projet courant et l'enregistrer dans Program.cs -->

<details>
<summary>Réponse</summary>

```csharp
// Classe de configuration
public class AppSettings
{
    public int MaxPageSize { get; set; }
    public string ApiVersion { get; set; } = string.Empty;
}

// Program.cs
builder.Services.Configure<AppSettings>(
    builder.Configuration.GetSection("App"));

// Utilisation
public class MonService
{
    private readonly AppSettings _settings;

    public MonService(IOptions<AppSettings> options)
    {
        _settings = options.Value;
    }
}
```

</details>

---

**Q73.** `[Normal]` Quelle est la priorité de résolution des sources de configuration dans ASP.NET Core ? (de la moins prioritaire à la plus prioritaire)

<!-- EXEMPLE: Montre comment les variables d'environnement pourraient surcharger la configuration du projet courant en production -->

<details>
<summary>Réponse</summary>

De la moins à la plus prioritaire :
1. `appsettings.json`
2. `appsettings.{Environment}.json` (ex: `appsettings.Production.json`)
3. Variables d'environnement
4. Arguments de ligne de commande
5. `dotnet user-secrets` (développement uniquement)

Les sources de droite écrasent les sources de gauche pour la même clé.

</details>

---

**Q74.** `[Difficile]` Quelle est la différence entre `IOptions<T>`, `IOptionsSnapshot<T>` et `IOptionsMonitor<T>` ?

<!-- EXEMPLE: Aucun exemple spécifique au projet nécessaire — explique les cas d'usage de chaque interface -->

<details>
<summary>Réponse</summary>

| Interface | Lifetime | Rechargement à chaud | Cas d'usage |
|---|---|---|---|
| `IOptions<T>` | Singleton | Non | Configuration statique, ne change pas |
| `IOptionsSnapshot<T>` | Scoped | Oui (par requête) | Config qui peut changer, services Scoped |
| `IOptionsMonitor<T>` | Singleton | Oui (en temps réel) | Config qui change, services Singleton |

En pratique : `IOptions<T>` pour 90% des cas. `IOptionsSnapshot` si la config doit être rechargée sans redémarrage.

</details>

---

**Q75.** `[Normal]` Comment utilise-t-on `dotnet user-secrets` pour ne pas commiter des secrets ? Dans quel contexte est-ce adapté ?

<!-- EXEMPLE: Montre comment stocker une connection string sensible hors du repo pour le projet courant -->

<details>
<summary>Réponse</summary>

```bash
# Initialiser les secrets pour le projet
dotnet user-secrets init

# Ajouter un secret
dotnet user-secrets set "ConnectionStrings:Default" "Server=...;Password=secret"

# Les secrets sont stockés dans ~/.microsoft/usersecrets/{guid}/secrets.json
# Jamais dans le repo git
```

Contexte adapté : **développement local uniquement**. En production, utiliser les variables d'environnement ou un service comme Azure Key Vault / AWS Secrets Manager.

</details>

### Mon suivi — Phase 13

| Date | Score | À revoir |
|------|-------|----------|
| | /5 | |

---

## Score — Niveau Intermédiaire confirmé

| Phase | Questions | Score |
|---|---|---|
| Phase 11 — FluentValidation | Q61 à Q65 | /5 |
| Phase 12 — Logging | Q66 à Q70 | /5 |
| Phase 13 — Configuration | Q71 à Q75 | /5 |
| **Total** | | **/15** |

> **12/15 et plus** → Niveau maîtrisé
> **Moins de 12/15** → Consulte `dotnet/niveau.md` pour identifier les points à retravailler
