---
name: security-checklist
description: Checklist de sécurité complet pour les applications web
effort: medium
---

# Checklist de sécurité

## Audit de sécurité rapide

### Authentification

- [ ] Les mots de passe sont hashés avec bcrypt/argon2 (facteur de coût >= 10)
- [ ] Les tokens de session sont aléatoires de manière cryptographique
- [ ] Les tokens JWT ont une expiration courte (15min accès, 7j refresh)
- [ ] Limitation de taux sur les endpoints de connexion
- [ ] Blocage de compte après plusieurs tentatives échouées

### Autorisation

- [ ] Chaque endpoint API vérifie les permissions
- [ ] Aucun IDOR (Insecure Direct Object References)
- [ ] Contrôle d’accès basé sur les rôles implémenté
- [ ] Les opérations sensibles nécessitent une ré-authentification

### Validation des entrées

- [ ] Toutes les entrées utilisateur sont validées côté serveur
- [ ] Les uploads de fichiers sont restreints (type et taille)
- [ ] Les requêtes SQL utilisent des paramètres
- [ ] Le HTML est encodé pour éviter les XSS

### Protection des données

- [ ] Les données sensibles sont chiffrées au repos
- [ ] HTTPS est forcé partout
- [ ] Cookies sécurisés (HttpOnly, Secure, SameSite)
- [ ] Aucune donnée sensible dans les URLs ou logs

### Headers & CORS

- [ ] Header Content-Security-Policy défini
- [ ] X-Content-Type-Options: nosniff
- [ ] X-Frame-Options: DENY (ou SAMEORIGIN)
- [ ] Strict-Transport-Security activé
- [ ] CORS correctement restreint

## Patterns de code

### SQL Injection Prevention

```javascript
// VULNERABLE
db.query(`SELECT * FROM users WHERE id = ${userId}`);

// SECURE
db.query("SELECT * FROM users WHERE id = $1", [userId]);
```

### XSS Prevention

```javascript
// VULNERABLE
element.innerHTML = userInput;

// SECURE
element.textContent = userInput;

// SECURE (with sanitization)
element.innerHTML = DOMPurify.sanitize(userInput);
```

### CSRF Protection

```javascript
// Generate token
const csrfToken = crypto.randomBytes(32).toString("hex");
session.csrfToken = csrfToken;

// Validate on POST
if (req.body.csrf !== session.csrfToken) {
  throw new ForbiddenError("Invalid CSRF token");
}
```

### Secrets Management

```javascript
// NEVER in code
const API_KEY = "sk-abc123...";

// Environment variables
const API_KEY = process.env.API_KEY;

// Secrets manager (production)
const secret = await secretsManager.getSecret("api-key");
```

## Exemple de headers de sécurité

```javascript
// Express middleware
app.use((req, res, next) => {
  res.setHeader("X-Content-Type-Options", "nosniff");
  res.setHeader("X-Frame-Options", "DENY");
  res.setHeader("X-XSS-Protection", "1; mode=block");
  res.setHeader(
    "Strict-Transport-Security",
    "max-age=31536000; includeSubDomains",
  );
  res.setHeader("Content-Security-Policy", "default-src 'self'");
  next();
});
```

## Sécurité des dépendances

```bash
# Check for vulnerabilities
npm audit

# Auto-fix what's possible
npm audit fix

# Check outdated packages
npm outdated

# Update dependencies
npm update
```

## Journalisation des événements de sécurité

```javascript
// Events to log
logger.security({
  event: "login_failed",
  ip: req.ip,
  email: req.body.email,
  reason: "invalid_password",
  timestamp: new Date().toISOString(),
});

// Never log
// - Passwords
// - Full credit card numbers
// - Session tokens
// - Personal data (in production)
```

## Checklist avant déploiement

1. [ ] Exécuter `npm audit` - aucune vulnérabilité critique
2. [ ] Tous les secrets sont dans des variables d’environnement
3. [ ] Mode debug désactivé
4. [ ] Les messages d’erreur n’exposent pas d’informations internes
5. [ ] HTTPS uniquement (redirection HTTP → HTTPS)
6. [ ] Les identifiants de base de données sont renouvelés
7. [ ] Logging configuré (aucune donnée sensible)
8. [ ] Stratégie de sauvegarde testée
