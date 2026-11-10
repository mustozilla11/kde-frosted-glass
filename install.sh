#!/usr/bin/env bash
# ==============================================================================
#  🍎 KDE Plasma 6 - Frosted Glass & Liquid Dark Installer
#  Maintained by: mustozilla11 (https://github.com/mustozilla11/kde-frosted-glass)
# ==============================================================================

set -e

# Terminal colors
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info()    { echo -e "${CYAN}${BOLD}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}${BOLD}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}${BOLD}[WARN]${NC} $1"; }
error()   { echo -e "${RED}${BOLD}[ERROR]${NC} $1"; }

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${HOME}/.kde-frosted-glass-backup/$(date +%Y%m%d_%H%M%S)"
LATEST_BACKUP_LINK="${HOME}/.kde-frosted-glass-backup/latest"

echo -e "${BLUE}${BOLD}"
echo "  ███████╗██████╗  ██████╗ ███████╗████████╗███████╗██████╗ "
echo "  ██╔════╝██╔══██╗██╔═══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗"
echo "  █████╗  ██████╔╝██║   ██║███████╗   ██║   █████╗  ██║  ██║"
echo "  ██╔══╝  ██╔══██╗██║   ██║╚════██║   ██║   ██╔══╝  ██║  ██║"
echo "  ██║     ██║  ██║╚██████╔╝███████║   ██║   ███████╗██████╔╝"
echo "  ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝   ╚══════╝╚═════╝ "
echo "        KDE Plasma 6 Frosted Glass macOS Liquid Dark        "
echo -e "${NC}"

# Check Plasma 6 environment
if ! command -v kwriteconfig6 >/dev/null 2>&1; then
    warn "kwriteconfig6 not found in PATH. Are you running KDE Plasma 6?"
    echo -n "Do you still want to proceed with file deployment? [y/N]: "
    read -r proceed
    if [[ ! "$proceed" =~ ^[Yy]$ ]]; then
        error "Installation aborted."
        exit 1
    fi
fi

# 1. Backup existing configuration
info "Creating configuration backup at: ${BACKUP_DIR}..."
mkdir -p "${BACKUP_DIR}/config" "${BACKUP_DIR}/plasma-workspace-env"

backup_file() {
    local src="$1"
    local dest="$2"
    if [ -e "$src" ]; then
        mkdir -p "$(dirname "$dest")"
        cp -a "$src" "$dest"
    fi
}

backup_file "${HOME}/.config/kwinrc" "${BACKUP_DIR}/config/kwinrc"
backup_file "${HOME}/.config/kwinrulesrc" "${BACKUP_DIR}/config/kwinrulesrc"
backup_file "${HOME}/.config/kdeglobals" "${BACKUP_DIR}/config/kdeglobals"
backup_file "${HOME}/.config/plasmarc" "${BACKUP_DIR}/config/plasmarc"
backup_file "${HOME}/.config/plasma-org.kde.plasma.desktop-appletsrc" "${BACKUP_DIR}/config/plasma-org.kde.plasma.desktop-appletsrc"
backup_file "${HOME}/.config/Kvantum" "${BACKUP_DIR}/config/Kvantum"
backup_file "${HOME}/.config/gtk-3.0" "${BACKUP_DIR}/config/gtk-3.0"
backup_file "${HOME}/.config/gtk-4.0" "${BACKUP_DIR}/config/gtk-4.0"
backup_file "${HOME}/.config/plasma-workspace/env/frosted-glass.sh" "${BACKUP_DIR}/plasma-workspace-env/frosted-glass.sh"

mkdir -p "${HOME}/.kde-frosted-glass-backup"
rm -f "${LATEST_BACKUP_LINK}"
ln -s "${BACKUP_DIR}" "${LATEST_BACKUP_LINK}"
success "Backup created successfully. You can restore anytime via ./uninstall.sh"

# 2. Deploy Plasma Desktop Theme (Custom 9-slice Apple Blue border & indicators)
info "Deploying WhiteSurLiquid-dark Plasma theme..."
mkdir -p "${HOME}/.local/share/plasma/desktoptheme"
cp -rf "${REPO_DIR}/themes/plasma/WhiteSurLiquid-dark" "${HOME}/.local/share/plasma/desktoptheme/"
success "Plasma theme installed."

# 3. Deploy Aurorae Window Decorations (macOS Traffic Light Titlebars)
info "Deploying Aurorae window decoration themes..."
mkdir -p "${HOME}/.local/share/aurorae/themes"
cp -rf "${REPO_DIR}/themes/aurorae/"* "${HOME}/.local/share/aurorae/themes/"
success "Aurorae decorations installed."

# 4. Deploy Wallpapers
info "Deploying MacSequoia-Dark wallpaper..."
mkdir -p "${HOME}/.local/share/wallpapers"
cp -rf "${REPO_DIR}/assets/wallpapers/MacSequoia-Dark" "${HOME}/.local/share/wallpapers/"
success "Wallpaper installed."

# 5. Deploy KWin Scanout Guard Effect (Prevents Wayland fullscreen direct scanout tearing/flickering)
info "Deploying KWin Frosted Scanout Guard effect..."
mkdir -p "${HOME}/.local/share/kwin/effects"
cp -rf "${REPO_DIR}/config/kwin/effects/frosted_scanout_guard" "${HOME}/.local/share/kwin/effects/"
success "Scanout Guard installed."

# 6. Deploy Plasma Workspace Environment Hook
info "Deploying Wayland environment script (KWIN_DRM_NO_DIRECT_SCANOUT=1)..."
mkdir -p "${HOME}/.config/plasma-workspace/env"
cp -f "${REPO_DIR}/config/plasma/env/frosted-glass.sh" "${HOME}/.config/plasma-workspace/env/"
chmod +x "${HOME}/.config/plasma-workspace/env/frosted-glass.sh"
success "Environment hook deployed."

# 7. Deploy Kvantum & GTK configurations
info "Deploying Kvantum & GTK styling configurations..."
mkdir -p "${HOME}/.config/Kvantum" "${HOME}/.config/gtk-3.0" "${HOME}/.config/gtk-4.0"
cp -rf "${REPO_DIR}/config/kvantum/"* "${HOME}/.config/Kvantum/"
cp -rf "${REPO_DIR}/config/gtk-3.0/"* "${HOME}/.config/gtk-3.0/"
cp -rf "${REPO_DIR}/config/gtk-4.0/"* "${HOME}/.config/gtk-4.0/"
success "Kvantum and GTK configs applied."

# 8. Configure Plasma & KWin settings
if command -v kwriteconfig6 >/dev/null 2>&1; then
    info "Configuring Plasma 6 theme and window decorations..."
    kwriteconfig6 --file plasmarc --group Theme --key name "WhiteSurLiquid-dark"
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key library "org.kde.kwin.aurorae.v2"
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme "__aurorae__svg__WhiteSurLiquid-dark"
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnRight "IAX"
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnLeft ""
    kwriteconfig6 --file kwinrc --group Plugins --key frosted_scanout_guardEnabled true
    kwriteconfig6 --file kwinrc --group Plugins --key magiclampEnabled true
    kwriteconfig6 --file kwinrc --group Plugins --key maximizeEnabled true
    kwriteconfig6 --file kwinrc --group Plugins --key fullscreenEnabled true
    kwriteconfig6 --file kwinrc --group Plugins --key sheetEnabled true
    kwriteconfig6 --file kwinrc --group Plugins --key slidebackEnabled true
    kwriteconfig6 --file kwinrc --group Plugins --key scaleEnabled true
    kwriteconfig6 --file kwinrc --group Plugins --key squashEnabled false
    kwriteconfig6 --file kwinrc --group Effect-magiclamp --key AnimationDuration 220
    kwriteconfig6 --file kwinrc --group Effect-scale --key Duration 180
    kwriteconfig6 --file kwinrc --group Effect-scale --key InScale "0.92"
    kwriteconfig6 --file kwinrc --group Effect-scale --key OutScale "0.92"
    kwriteconfig6 --file kdeglobals --group KDE --key AnimationDurationFactor "0.7071067811865475"

    # Check for better-blur-dx or fallback to native blur
    if [ -f /usr/lib/qt6/plugins/kwin/effects/plugins/better_blur_dx.so ] || pacman -Qq kwin-effects-better-blur-dx >/dev/null 2>&1; then
        info "Found better_blur_dx effect. Applying optimized macOS Sequoia Vibrancy profile..."
        kwriteconfig6 --file kwinrc --group Plugins --key better_blur_dxEnabled true
        kwriteconfig6 --file kwinrc --group Plugins --key blurEnabled false
        kwriteconfig6 --file kwinrc --group Effect-better-blur-dx --key BlitMode "RENDER_TARGET"
        kwriteconfig6 --file kwinrc --group Effect-better-blur-dx --key BlurCacheIgnore false
        kwriteconfig6 --file kwinrc --group Effect-better-blur-dx --key BlurCacheRateLimit 30
        kwriteconfig6 --file kwinrc --group Effect-better-blur-dx --key BlurDecorations true
        kwriteconfig6 --file kwinrc --group Effect-better-blur-dx --key BlurDocks true
        kwriteconfig6 --file kwinrc --group Effect-better-blur-dx --key BlurMenus true
        kwriteconfig6 --file kwinrc --group Effect-better-blur-dx --key BlurNonMatching true
        kwriteconfig6 --file kwinrc --group Effect-better-blur-dx --key BlurStrength 8
        kwriteconfig6 --file kwinrc --group Effect-better-blur-dx --key Brightness 103
        kwriteconfig6 --file kwinrc --group Effect-better-blur-dx --key Contrast 106
        kwriteconfig6 --file kwinrc --group Effect-better-blur-dx --key CornerRadius "12.0"
        kwriteconfig6 --file kwinrc --group Effect-better-blur-dx --key ForceContrastParams true
        kwriteconfig6 --file kwinrc --group Effect-better-blur-dx --key NoiseStrength 1
        kwriteconfig6 --file kwinrc --group Effect-better-blur-dx --key Saturation 165
        kwriteconfig6 --file kwinrc --group Effect-better-blur-dx --key WindowClasses $'vlc\nmpv\norg.kde.spectacle\nspectacle\nflameshot\nfirefox\nfirefox-esr\nlibrewolf\nzen\nzen-bin\nwaterfox\nbrave-browser\nchromium\ngoogle-chrome\nvivaldi-stable\nmicrosoft-edge\nsteam'
    else
        info "Configuring KDE Plasma native blur effect..."
        kwriteconfig6 --file kwinrc --group Plugins --key blurEnabled true
        kwriteconfig6 --file kwinrc --group Effect-blur --key BlurStrength 12
    fi

    # Configure KWin Rules (System-wide glass + opaque web/video protection)
    info "Applying KWin window rules for frosted glass transparency..."
    cp -f "${REPO_DIR}/config/kwin/kwinrulesrc" "${HOME}/.config/kwinrulesrc"
    success "KWin rules configured."
fi

# 9. Clean caches and reload
info "Clearing Plasma SVG and QML caches..."
rm -rf "${HOME}/.cache/plasma"* "${HOME}/.cache/kwin"* 2>/dev/null || true

info "Reloading KWin and Plasma Shell..."
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
echo -e "${GREEN}${BOLD}  ✨ Installation Complete! Frosted Glass is now active.${NC}"
echo -e "${GREEN}${BOLD}══════════════════════════════════════════════════════════════════════${NC}"
echo -e "• Dock Indicator: 24px Apple Blue pill (active) + 10px Ice-White capsule (running)"
echo -e "• Dock Border: Seamless 1px Apple System Blue (#0A84FF)"
echo -e "• Protection: Video & Browsers stay 100% opaque"
echo -e "• Restore anytime: Run ${BOLD}./uninstall.sh${NC} to revert to your previous setup."
echo ""
