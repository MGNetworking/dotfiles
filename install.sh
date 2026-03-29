#!/usr/bin/env bash
# install.sh — Installe les liens symboliques du dépôt dotfiles dans ~/.claude/

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${GREEN}[✔]${NC} $1"; }
warning() { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[✘]${NC} $1"; exit 1; }

echo ""
echo "=== Installation des dotfiles Claude Code ==="
echo "Source : $DOTFILES_DIR"
echo "Cible  : $CLAUDE_DIR"
echo ""

# Créer ~/.claude s'il n'existe pas
mkdir -p "$CLAUDE_DIR"

# Fonction pour créer un lien symbolique avec sauvegarde
# Retourne le chemin du backup dans la variable LAST_BACKUP
LAST_BACKUP=""
link() {
  local src="$1"
  local dst="$2"
  local name
  name=$(basename "$dst")
  LAST_BACKUP=""

  if [ -L "$dst" ]; then
    local current_target
    current_target=$(readlink "$dst")
    if [ "$current_target" = "$src" ]; then
      info "$name → déjà lié (aucune action)"
      return
    else
      warning "$name → lien existant vers $current_target, remplacement..."
      rm "$dst"
    fi
  elif [ -e "$dst" ]; then
    LAST_BACKUP="${dst}.backup.$(date +%Y%m%d_%H%M%S)"
    warning "$name → dossier existant, sauvegarde dans $LAST_BACKUP"
    mv "$dst" "$LAST_BACKUP"
  fi

  ln -s "$src" "$dst"
  info "$name → lié vers $src"
}

# Fonction pour analyser un backup et détecter les fichiers non présents dans le dépôt
check_backup() {
  local backup="$1"
  local src="$2"

  [ -z "$backup" ] && return
  [ ! -d "$backup" ] && return

  local only_in_backup=()
  while IFS= read -r file; do
    local name
    name=$(basename "$file")
    if [ ! -e "$src/$name" ]; then
      only_in_backup+=("$name")
    fi
  done < <(find "$backup" -maxdepth 1 -type f)

  if [ ${#only_in_backup[@]} -eq 0 ]; then
    info "Backup identique au dépôt — tu peux le supprimer en toute sécurité :"
    echo "    rm -rf \"$backup\""
  else
    warning "Le backup contient des fichiers ABSENTS du dépôt :"
    for f in "${only_in_backup[@]}"; do
      echo "    - $f"
    done
    echo ""
    warning "Ajoute ces fichiers au dépôt avant de supprimer le backup :"
    echo "    cp \"$backup/<fichier>\" \"$src/\""
    echo "    Puis : rm -rf \"$backup\""
  fi
}

# Installation des liens symboliques
link "$DOTFILES_DIR/claude/commands" "$CLAUDE_DIR/commands"
COMMANDS_BACKUP="$LAST_BACKUP"

link "$DOTFILES_DIR/claude/skills" "$CLAUDE_DIR/skills"
SKILLS_BACKUP="$LAST_BACKUP"

# Analyse des backups
echo ""
echo "=== Analyse des sauvegardes ==="
echo ""

if [ -n "$COMMANDS_BACKUP" ]; then
  echo "Backup commands : $COMMANDS_BACKUP"
  check_backup "$COMMANDS_BACKUP" "$DOTFILES_DIR/claude/commands"
  echo ""
fi

if [ -n "$SKILLS_BACKUP" ]; then
  echo "Backup skills : $SKILLS_BACKUP"
  check_backup "$SKILLS_BACKUP" "$DOTFILES_DIR/claude/skills"
  echo ""
fi

if [ -z "$COMMANDS_BACKUP" ] && [ -z "$SKILLS_BACKUP" ]; then
  info "Aucun backup créé."
  echo ""
fi

echo "=== Installation terminée ==="
echo ""
echo "Lance Claude Code pour utiliser les commandes."
