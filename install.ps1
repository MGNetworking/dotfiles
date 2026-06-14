#Requires -RunAsAdministrator
# install.ps1 — Installe les liens symboliques du dépôt dotfiles dans ~/.claude/

$DOTFILES_DIR = $PSScriptRoot
$CLAUDE_DIR = "$env:USERPROFILE\.claude"

function Write-Info    { param($msg) Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Warning2 { param($msg) Write-Host "[!]  $msg" -ForegroundColor Yellow }

Write-Host ""
Write-Host "=== Installation des dotfiles Claude Code ===" -ForegroundColor Cyan
Write-Host "Source : $DOTFILES_DIR"
Write-Host "Cible  : $CLAUDE_DIR"
Write-Host ""

if (-not (Test-Path $CLAUDE_DIR)) {
    New-Item -ItemType Directory -Path $CLAUDE_DIR | Out-Null
}

$script:LastBackup = ""

function New-Link {
    param([string]$Src, [string]$Dst)

    $script:LastBackup = ""
    $name = Split-Path $Dst -Leaf

    if (Test-Path $Dst) {
        $item = Get-Item $Dst -Force
        if ($item.LinkType -eq "SymbolicLink") {
            if ($item.Target -eq $Src) {
                Write-Info "$name => deja lie (aucune action)"
                return
            }
            Write-Warning2 "$name => lien existant, remplacement..."
            Remove-Item $Dst -Force
        } else {
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $backup = "${Dst}.backup.$timestamp"
            Write-Warning2 "$name => dossier existant, sauvegarde dans $backup"
            Move-Item $Dst $backup
            $script:LastBackup = $backup
        }
    }

    New-Item -ItemType SymbolicLink -Path $Dst -Target $Src | Out-Null
    Write-Info "$name => lie vers $Src"
}

function Check-Backup {
    param([string]$Backup, [string]$Src)

    if (-not $Backup) { return }
    if (-not (Test-Path $Backup)) { return }

    $files = Get-ChildItem $Backup -File
    $onlyInBackup = @()
    foreach ($f in $files) {
        $target = Join-Path $Src $f.Name
        if (-not (Test-Path $target)) {
            $onlyInBackup += $f.Name
        }
    }

    if ($onlyInBackup.Count -eq 0) {
        Write-Info "Backup identique au depot - tu peux le supprimer :"
        Write-Host "    Remove-Item -Recurse -Force `"$Backup`""
    } else {
        Write-Warning2 "Le backup contient des fichiers absents du depot :"
        foreach ($f in $onlyInBackup) {
            Write-Host "    - $f"
        }
        Write-Warning2 "Ajoute ces fichiers au depot avant de supprimer le backup."
    }
}

New-Link "$DOTFILES_DIR\claude\commands" "$CLAUDE_DIR\commands"
$CommandsBackup = $script:LastBackup

New-Link "$DOTFILES_DIR\claude\skills" "$CLAUDE_DIR\skills"
$SkillsBackup = $script:LastBackup

Write-Host ""
Write-Host "=== Analyse des sauvegardes ===" -ForegroundColor Cyan
Write-Host ""

if ($CommandsBackup) {
    Write-Host "Backup commands : $CommandsBackup"
    Check-Backup $CommandsBackup "$DOTFILES_DIR\claude\commands"
    Write-Host ""
}

if ($SkillsBackup) {
    Write-Host "Backup skills : $SkillsBackup"
    Check-Backup $SkillsBackup "$DOTFILES_DIR\claude\skills"
    Write-Host ""
}

if (-not $CommandsBackup -and -not $SkillsBackup) {
    Write-Info "Aucun backup cree."
    Write-Host ""
}

Write-Host "=== Installation terminee ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Lance Claude Code pour utiliser les commandes."
