# Fiches de révision — Phases 14 à 16
# Niveau : Senior junior

> Consulte ces fiches pour réviser un concept précis ou t'auto-évaluer.
> Pour un quiz interactif sur ton code actuel, utilise `/learn:quiz`.
>
> **Score minimum** : 11/13 pour valider le niveau

---

## PHASE 14 — Authentification et Autorisation (JWT)

### Vocabulaire clé
| Terme | Tu sais l'expliquer ? |
|---|---|
| Authentification vs Autorisation | ⬜ |
| JWT (JSON Web Token) | ⬜ |
| Header / Payload / Signature | ⬜ |
| `[Authorize]` | ⬜ |
| Claims | ⬜ |
| Access Token / Refresh Token | ⬜ |

### Questions

**Q76.** `[Facile]` Quelle est la différence entre authentification et autorisation ?

<!-- EXEMPLE: Aucun exemple spécifique au projet nécessaire — explique les deux concepts avec un exemple concret -->

<details>
<summary>Réponse</summary>

- **Authentification** : *"Qui es-tu ?"* — vérifier l'identité (login/mot de passe, token)
- **Autorisation** : *"Qu'as-tu le droit de faire ?"* — vérifier les permissions une fois l'identité connue

Exemple : se connecter à une application (authentification) puis accéder à une page admin (autorisation).

</details>

---

**Q77.** `[Normal]` Quelle est la structure d'un JWT ? Que contient chaque partie ?

<!-- EXEMPLE: Décode un token JWT exemple sur jwt.io et identifie les 3 parties -->

<details>
<summary>Réponse</summary>

Un JWT est composé de 3 parties séparées par des points : `header.payload.signature`

- **Header** (Base64) : algorithme de signature (`alg: "HS256"`) et type (`typ: "JWT"`)
- **Payload** (Base64) : claims (données) — ex: `sub`, `name`, `role`, `exp`
- **Signature** : HMAC du header + payload avec la clé secrète — garantit l'intégrité

Le payload est **encodé, pas chiffré** — ne pas y mettre de données sensibles.

</details>

---

**Q78.** `[Normal]` Comment configure-t-on l'authentification JWT dans `Program.cs` ?

<!-- EXEMPLE: Montre la configuration minimale pour sécuriser les endpoints du projet courant avec JWT -->

<details>
<summary>Réponse</summary>

```csharp
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]!))
        };
    });

// Dans le pipeline
app.UseAuthentication(); // Avant UseAuthorization
app.UseAuthorization();
```

</details>

---

**Q79.** `[Normal]` Comment protège-t-on des endpoints avec `[Authorize]` ? Comment autorise-t-on un rôle précis ?

<!-- EXEMPLE: Montre comment sécuriser un endpoint du controller du projet courant avec [Authorize] et un rôle Admin -->

<details>
<summary>Réponse</summary>

```csharp
[ApiController]
[Authorize] // Tous les endpoints nécessitent une authentification
public class MonController : ControllerBase
{
    [HttpGet]
    public IActionResult GetAll() => Ok(); // Authentifié requis

    [HttpDelete("{id}")]
    [Authorize(Roles = "Admin")] // Rôle Admin requis
    public IActionResult Delete(int id) => NoContent();

    [HttpGet("public")]
    [AllowAnonymous] // Exception : accessible sans token
    public IActionResult GetPublic() => Ok();
}
```

</details>

---

**Q80.** `[Difficile]` Quelle est la différence entre un Access Token et un Refresh Token ? Pourquoi l'API ne stocke-t-elle pas le token côté serveur ?

<!-- EXEMPLE: Explique la stratégie de renouvellement de token applicable au projet courant -->

<details>
<summary>Réponse</summary>

- **Access Token** : courte durée de vie (15min–1h), transmis dans chaque requête (`Authorization: Bearer ...`). Utilisé pour accéder aux ressources protégées.
- **Refresh Token** : longue durée de vie (jours/semaines), stocké côté client de manière sécurisée. Utilisé uniquement pour obtenir un nouvel Access Token quand celui-ci expire.

**Pourquoi pas de stockage côté serveur ?**
JWT est **stateless** — toutes les informations nécessaires sont dans le token. Stocker les tokens côté serveur nécessiterait une session partagée entre instances (scalabilité perdue). Le serveur valide la signature et l'expiration, c'est suffisant.

</details>

### Mon suivi — Phase 14

| Date | Score | À revoir |
|------|-------|----------|
| | /5 | |

---

## PHASE 15 — Versioning d'API

### Vocabulaire clé
| Terme | Tu sais l'expliquer ? |
|---|---|
| Versioning par URL | ⬜ |
| Versioning par header | ⬜ |
| Versioning par query string | ⬜ |
| Dépréciation d'une version | ⬜ |
| `Asp.Versioning.Mvc` | ⬜ |

### Questions

**Q81.** `[Facile]` Pourquoi versionne-t-on une API ? Quel problème cela résout-il ?

<!-- EXEMPLE: Imagine que tu modifies le contrat de l'API du projet courant (ex: changer le format d'un DTO) — quel impact sans versioning ? -->

<details>
<summary>Réponse</summary>

Sans versioning, modifier le contrat d'une API (changer le format d'une réponse, supprimer un champ) **casse les clients existants** sans préavis.

Le versioning permet :
- Publier une nouvelle version avec un contrat modifié
- Maintenir l'ancienne version le temps que les clients migrent
- Déprécier progressivement les anciennes versions

</details>

---

**Q82.** `[Normal]` Cite 3 stratégies de versioning d'API et compare leurs avantages/inconvénients.

<!-- EXEMPLE: Aucun exemple spécifique au projet nécessaire — compare les approches en termes d'URL, headers et lisibilité -->

<details>
<summary>Réponse</summary>

| Stratégie | Exemple | Avantages | Inconvénients |
|---|---|---|---|
| URL | `/api/v1/ressources` | Visible, facile à tester, bookmarkable | "Pollue" l'URL, pas REST pur |
| Header | `Api-Version: 1.0` | URL propre, REST pur | Moins visible, moins cacheable |
| Query string | `/ressources?version=1` | Facile à tester | Mélange paramètres fonctionnels et techniques |

Le versioning par URL est le plus courant et le plus lisible.

</details>

---

**Q83.** `[Normal]` Comment configure-t-on le versioning par URL dans ASP.NET Core avec `Asp.Versioning.Mvc` ?

<!-- EXEMPLE: Montre comment ajouter une v2 du controller principal du projet courant avec un contrat légèrement modifié -->

<details>
<summary>Réponse</summary>

```csharp
// Program.cs
builder.Services.AddApiVersioning(options =>
{
    options.DefaultApiVersion = new ApiVersion(1, 0);
    options.AssumeDefaultVersionWhenUnspecified = true;
    options.ReportApiVersions = true;
});

// Controller
[ApiController]
[Route("api/v{version:apiVersion}/ressources")]
[ApiVersion("1.0")]
public class RessourcesV1Controller : ControllerBase { ... }

[ApiController]
[Route("api/v{version:apiVersion}/ressources")]
[ApiVersion("2.0")]
public class RessourcesV2Controller : ControllerBase { ... }
```

</details>

---

**Q84.** `[Difficile]` Comment gère-t-on la dépréciation d'une version d'API sans casser les clients existants ?

<!-- EXEMPLE: Imagine comment déprécier v1 de l'API du projet courant au profit d'une v2 avec un contrat amélioré -->

<details>
<summary>Réponse</summary>

Stratégie progressive :
1. **Annoncer** : ajouter le header `Deprecation: true` et `Sunset: {date}` dans les réponses v1
2. **Marquer dans le code** : `[ApiVersion("1.0", Deprecated = true)]`
3. **Logger** les appels à la version dépréciée pour mesurer l'adoption de v2
4. **Documenter** la migration dans Swagger (v1 marquée deprecated)
5. **Supprimer** après la date de sunset annoncée

```csharp
[ApiVersion("1.0", Deprecated = true)]
[ApiVersion("2.0")]
public class RessourcesController : ControllerBase { ... }
```

</details>

### Mon suivi — Phase 15

| Date | Score | À revoir |
|------|-------|----------|
| | /4 | |

---

## PHASE 16 — Documentation avec Swagger / OpenAPI

### Vocabulaire clé
| Terme | Tu sais l'expliquer ? |
|---|---|
| Swagger UI | ⬜ |
| OpenAPI | ⬜ |
| `[ProducesResponseType]` | ⬜ |
| Commentaires XML | ⬜ |
| Swagger + JWT | ⬜ |

### Questions

**Q85.** `[Facile]` Qu'est-ce que Swagger / OpenAPI ? Quel est l'intérêt pour une API REST ?

<!-- EXEMPLE: Accède à la page Swagger du projet courant si disponible et décris ce qu'elle expose -->

<details>
<summary>Réponse</summary>

**OpenAPI** est un standard de description d'API REST (format JSON/YAML). **Swagger UI** est une interface graphique qui lit la spécification OpenAPI et génère une documentation interactive.

Intérêts :
- Documentation auto-générée depuis le code
- Interface de test intégrée (sans Postman)
- Génération automatique de clients (TypeScript, Python...)
- Contrat de l'API versionné et partageable

</details>

---

**Q86.** `[Normal]` Comment configure-t-on Swagger dans ASP.NET Core ? Cite les lignes essentielles dans `Program.cs`.

<!-- EXEMPLE: Vérifie si Swagger est configuré dans le projet courant et montre la configuration minimale -->

<details>
<summary>Réponse</summary>

```csharp
// Program.cs
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Mon API",
        Version = "v1"
    });
});

// Dans le pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
```

Accessible sur `/swagger` en développement.

</details>

---

**Q87.** `[Normal]` Comment utilise-t-on `[ProducesResponseType]` pour documenter les codes HTTP possibles d'un endpoint ?

<!-- EXEMPLE: Ajoute les annotations ProducesResponseType sur un endpoint du controller du projet courant -->

<details>
<summary>Réponse</summary>

```csharp
[HttpGet("{id}")]
[ProducesResponseType(typeof(MonDto), StatusCodes.Status200OK)]
[ProducesResponseType(StatusCodes.Status404NotFound)]
public ActionResult<MonDto> GetById(int id)
{
    // ...
}

[HttpPost]
[ProducesResponseType(typeof(MonDto), StatusCodes.Status201Created)]
[ProducesResponseType(StatusCodes.Status400BadRequest)]
[ProducesResponseType(StatusCodes.Status409Conflict)]
public IActionResult Create([FromBody] CreateDto dto)
{
    // ...
}
```

Swagger affiche alors tous les codes HTTP possibles avec leurs types de réponse.

</details>

---

**Q88.** `[Difficile]` Comment ajoute-t-on l'authentification JWT dans l'interface Swagger pour pouvoir tester les endpoints protégés ?

<!-- EXEMPLE: Montre la configuration Swagger JWT à ajouter dans Program.cs du projet courant -->

<details>
<summary>Réponse</summary>

```csharp
builder.Services.AddSwaggerGen(options =>
{
    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Entrez votre token JWT"
    });

    options.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});
```

Un bouton "Authorize" apparaît dans Swagger UI pour saisir le token.

</details>

### Mon suivi — Phase 16

| Date | Score | À revoir |
|------|-------|----------|
| | /4 | |

---

## Score — Niveau Senior junior

| Phase | Questions | Score |
|---|---|---|
| Phase 14 — JWT | Q76 à Q80 | /5 |
| Phase 15 — Versioning | Q81 à Q84 | /4 |
| Phase 16 — Swagger | Q85 à Q88 | /4 |
| **Total** | | **/13** |

> **11/13 et plus** → Niveau maîtrisé
> **Moins de 11/13** → Consulte `dotnet/niveau.md` pour identifier les points à retravailler
