---
name: sandbox-status
description: Afficher le statut du sandbox natif, sa configuration et les violations récentes
---

# Commande Statut du Sandbox

Inspecter l'état du sandbox natif de Claude Code, la configuration active et les événements de sécurité.

## Utilisation

```
/sandbox-status
```

## Ce que ça fait

1. **Vérifier la disponibilité du sandbox**
   - Vérifier que les primitives OS sont installées (bubblewrap sur Linux, Seatbelt sur macOS)
   - Afficher le statut de support de la plateforme

2. **Afficher la configuration active**
   - Mode sandbox (Auto-allow vs permissions régulières)
   - Politiques de système de fichiers (écritures autorisées, lectures refusées)
   - Politiques réseau (liste blanche/noire de domaines)
   - Commandes exclues

3. **Lister les violations récentes du sandbox**
   - Tentatives d'accès au système de fichiers bloquées
   - Connexions réseau bloquées
   - Invocations de la trappe d'échappement (`dangerouslyDisableSandbox`)

## Implémentation

```bash
#!/bin/bash

echo "=== Native Sandbox Status ==="
echo

# 1. Vérification de la plateforme
echo "Platform:"
case "$OSTYPE" in
  darwin*)
    echo "  ✅ macOS (Seatbelt built-in)"
    ;;
  linux*)
    if which bubblewrap >/dev/null 2>&1; then
      echo "  ✅ Linux (bubblewrap installed)"
      bubblewrap --version 2>/dev/null | head -1
    else
      echo "  ❌ Linux (bubblewrap NOT installed)"
      echo "     Install: sudo apt-get install bubblewrap socat"
    fi
    if which socat >/dev/null 2>&1; then
      echo "  ✅ socat installed"
    else
      echo "  ❌ socat NOT installed"
    fi
    ;;
  *)
    echo "  ❌ Unsupported platform: $OSTYPE"
    ;;
esac
echo

# 2. Configuration
echo "Configuration (from settings.json):"
if [ -f .claude/settings.json ]; then
  CONFIG=".claude/settings.json"
elif [ -f ~/.claude/settings.json ]; then
  CONFIG="~/.claude/settings.json"
else
  echo "  ⚠️  No settings.json found"
  CONFIG=""
fi

if [ -n "$CONFIG" ]; then
  echo "  Source: $CONFIG"

  # Mode auto-allow
  AUTO_ALLOW=$(jq -r '.sandbox.autoAllowMode // "not set"' "$CONFIG" 2>/dev/null)
  echo "  Auto-allow: $AUTO_ALLOW"

  # Chemins d'écriture autorisés
  WRITE_PATHS=$(jq -r '.sandbox.filesystem.allowedWritePaths[]? // empty' "$CONFIG" 2>/dev/null | tr '\n' ', ')
  echo "  Allowed writes: ${WRITE_PATHS:-not set}"

  # Chemins de lecture refusés
  DENIED_READS=$(jq -r '.sandbox.filesystem.deniedReadPaths[]? // empty' "$CONFIG" 2>/dev/null | tr '\n' ', ')
  echo "  Denied reads: ${DENIED_READS:-not set}"

  # Politique réseau
  NET_POLICY=$(jq -r '.sandbox.network.policy // "not set"' "$CONFIG" 2>/dev/null)
  echo "  Network policy: $NET_POLICY"

  # Domaines autorisés
  DOMAINS=$(jq -r '.sandbox.network.allowedDomains[]? // empty' "$CONFIG" 2>/dev/null | head -3 | tr '\n' ', ')
  DOMAINS_COUNT=$(jq -r '.sandbox.network.allowedDomains | length' "$CONFIG" 2>/dev/null)
  if [ -n "$DOMAINS" ]; then
    echo "  Allowed domains: $DOMAINS... ($DOMAINS_COUNT total)"
  else
    echo "  Allowed domains: not set"
  fi

  # Commandes exclues
  EXCLUDED=$(jq -r '.sandbox.excludedCommands[]? // empty' "$CONFIG" 2>/dev/null | tr '\n' ', ')
  echo "  Excluded commands: ${EXCLUDED:-not set}"
fi
echo

# 3. Violations récentes (placeholder - l'implémentation réelle lirait les logs Claude Code)
echo "Recent sandbox violations:"
echo "  ℹ️  Log inspection not yet implemented"
echo "  Tip: Check Claude Code session logs for sandbox violation notifications"
echo

# 4. Runtime open source
echo "Open-Source Runtime:"
if which npx >/dev/null 2>&1; then
  echo "  ✅ npx available - can use @anthropic-ai/sandbox-runtime"
  echo "  Usage: npx @anthropic-ai/sandbox-runtime <command>"
else
  echo "  ⚠️  npx not found (install Node.js)"
fi
echo

# 5. Documentation
echo "Documentation:"
echo "  Guide: guide/sandbox-native.md"
echo "  Official: https://code.claude.com/docs/en/sandboxing"
echo "  Runtime: https://github.com/anthropic-experimental/sandbox-runtime"
```

## Exemple de sortie

```
=== Native Sandbox Status ===

Platform:
  ✅ macOS (Seatbelt built-in)

Configuration (from settings.json):
  Source: .claude/settings.json
  Auto-allow: true
  Allowed writes: ${CWD}, /tmp
  Denied reads: ${HOME}/.ssh, ${HOME}/.aws, ${HOME}/.kube
  Network policy: deny
  Allowed domains: api.anthropic.com, registry.npmjs.com, github.com... (9 total)
  Excluded commands: docker, kubectl, podman

Recent sandbox violations:
  ℹ️  Log inspection not yet implemented
  Tip: Check Claude Code session logs for sandbox violation notifications

Open-Source Runtime:
  ✅ npx available - can use @anthropic-ai/sandbox-runtime
  Usage: npx @anthropic-ai/sandbox-runtime <command>

Documentation:
  Guide: guide/sandbox-native.md
  Official: https://code.claude.com/docs/en/sandboxing
  Runtime: https://github.com/anthropic-experimental/sandbox-runtime
```

## Cas d'usage

- **Pré-déploiement** : Vérifier la configuration du sandbox avant de lancer des workflows autonomes
- **Débogage** : Comprendre pourquoi certaines commandes sont bloquées
- **Audit de sécurité** : Passer en revue les domaines autorisés et les accès au système de fichiers
- **Onboarding** : Aider les nouveaux membres de l'équipe à comprendre la politique sandbox du projet

## Voir aussi

- [Guide du sandbox natif](../../guide/sandbox-native.md) - Référence technique complète
- [Hook de validation du sandbox](../hooks/bash/sandbox-validation.sh) - Validation pré-commande
- [Exemple de config sandbox](../config/sandbox-native.json) - Configuration prête pour la production
