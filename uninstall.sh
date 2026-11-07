#!/usr/bin/env bash
# ==============================================================================
#  🍎 KDE Plasma 6 - Frosted Glass & Liquid Dark Uninstaller / Restore Tool
#  Maintained by: mustozilla11 (https://github.com/mustozilla11/kde-frosted-glass)
# ==============================================================================

set -e

BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()    { echo -e "${CYAN}${BOLD}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}${BOLD}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}${BOLD}[WARN]${NC} $1"; }
error()   { echo -e "${RED}${BOLD}[ERROR]${NC} $1"; }

TARGET_BACKUP="${1:-${HOME}/.kde-frosted-glass-backup/latest}"

if [ ! -d "$TARGET_BACKUP" ]; then
    error "Backup directory not found: $TARGET_BACKUP"
    echo "Available backups in ~/.kde-frosted-glass-backup/:"
    ls -l "${HOME}/.kde-frosted-glass-backup" 2>/dev/null || true
    exit 1
fi

info "Restoring configuration from: $(readlink -f "$TARGET_BACKUP" 2>/dev/null || echo "$TARGET_BACKUP")..."

restore_file() {
    local src="$1"
    local dest="$2"
    if [ -e "$src" ]; then
        mkdir -p "$(dirname "$dest")"
        cp -a "$src" "$dest"
        success "Restored $(basename "$dest")"
    fi
}

# Restore backed-up configs
restore_file "${TARGET_BACKUP}/config/kwinrc" "${HOME}/.config/kwinrc"
restore_file "${TARGET_BACKUP}/config/kwinrulesrc" "${HOME}/.config/kwinrulesrc"
restore_file "${TARGET_BACKUP}/config/kdeglobals" "${HOME}/.config/kdeglobals"
restore_file "${TARGET_BACKUP}/config/plasmarc" "${HOME}/.config/plasmarc"
restore_file "${TARGET_BACKUP}/config/plasma-org.kde.plasma.desktop-appletsrc" "${HOME}/.config/plasma-org.kde.plasma.desktop-appletsrc"
restore_file "${TARGET_BACKUP}/config/Kvantum" "${HOME}/.config/Kvantum"
restore_file "${TARGET_BACKUP}/config/gtk-3.0" "${HOME}/.config/gtk-3.0"
restore_file "${TARGET_BACKUP}/config/gtk-4.0" "${HOME}/.config/gtk-4.0"
restore_file "${TARGET_BACKUP}/plasma-workspace-env/frosted-glass.sh" "${HOME}/.config/plasma-workspace/env/frosted-glass.sh"

# Clear caches
info "Clearing Plasma SVG & QML caches..."
rm -rf "${HOME}/.cache/plasma"* "${HOME}/.cache/kwin"* 2>/dev/null || true

# Reload KWin & Plasma
info "Reloading KWin and Plasma..."
if command -v qdbus >/dev/null 2>&1; then
    qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true
fi

if systemctl --user is-active --quiet plasma-plasmashell.service 2>/dev/null; then
    systemctl --user restart plasma-plasmashell.service 2>/dev/null || true
elif command -v kquitapp6 >/dev/null 2>&1; then
    kquitapp6 plasmashell 2>/dev/null || true
    kstart plasmashell >/dev/null 2>&1 &
fi

echo ""
echo -e "${GREEN}${BOLD}══════════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}  ✨ Restoration Complete! Previous desktop state restored.${NC}"
echo -e "${GREEN}${BOLD}══════════════════════════════════════════════════════════════════════${NC}"
echo ""
