# 🍎 KDE Plasma 6 — Frosted Glass & Liquid Dark Rice

[![KDE Plasma 6](https://img.shields.io/badge/KDE_Plasma-6.0%2B-3298dc?logo=kde&logoColor=white)](https://kde.org/plasma-desktop/)
[![Wayland Ready](https://img.shields.io/badge/Display_Server-Wayland-informational?logo=wayland&logoColor=white)](https://wayland.freedesktop.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Distro-Arch%20%7C%20CachyOS%20%7C%20Fedora%20%7C%20openSUSE-black)](https://archlinux.org/)

A precision-engineered, macOS-inspired **Liquid Dark & Frosted Glass** desktop setup for **KDE Plasma 6 (Wayland)**. 

Built with 100% native KDE Plasma 6 components, zero unmaintained dependencies, GPU scanout protection against flickering, custom Qt 9-slice SVG dock mathematics, and hand-crafted task manager indicators.

---

## ✨ Key Features & Technical Highlights

### 1. 🛡️ Zero-Flicker Wayland Scanout Guard (`frosted_scanout_guard`)
On Wayland, compositors try to bypass composition (Direct Scanout) for fullscreen transparent or unredirected windows, leading to black screen flickers and visual tearing on AMD/Intel/NVIDIA drivers.
- **The Solution:** We packaged a dedicated KWin shader guard coupled with `KWIN_DRM_NO_DIRECT_SCANOUT=1` inside `~/.config/plasma-workspace/env/frosted-glass.sh`. Fullscreen windows and blur effects remain silky smooth at your monitor's native refresh rate.

### 2. 📐 Custom 9-Slice SVG Dock Mathematics
Plasma panel themes use a 9-slice grid (`center`, `north`, `south`, `east`, `west`, and 4 corner caps). Standard themes often stretch borders unevenly or glitch corners when scaled.
- **The Solution:** We hand-tuned `panel-background.svgz` and `translucentbackground.svg` with exact SVG paths and a unified **Apple System Blue (`#0A84FF`)** 1px boundary. The dock scales dynamically from 40px to 64px with zero distortion and zero red/pink artifacts.

### 3. 🎯 Hand-Crafted macOS Dock Indicators (`tasks.svgz`)
Standard KDE task managers use subtle bottom dots that make it difficult to distinguish between active and background apps:
- **Active App:** A **24px Apple System Blue (`#0A84FF`)** pill indicator paired with a soft frosted glass background plaque.
- **Running App (Unfocused):** A **10px Ice-White (`#FFFFFF` @ 80%)** capsule.
- High contrast, immediately recognizable at a glance.

### 4. 🔋 Maximum Battery Life & Native Stability
- **Zero Latte Dock:** Latte Dock is dead and unmaintained for Plasma 6.
- **Zero Polling Daemons:** Everything runs natively inside Plasma's Wayland compositor pipeline. No Python watchers, no extra RAM usage, minimal battery consumption.

### 5. 🧠 Smart Opacity Rules (`kwinrulesrc`)
- Windows enjoy modern 68% / 60% liquid glass translucency with background blur.
- **Critical Content Protection:** Web browsers (*Firefox, Zen, Chrome, Brave, Chromium, Librewolf*) and Media Players (*VLC, MPV, Spectacle*) are automatically forced to **100% opacity**. Web text stays crisp and movies retain 100% color accuracy.

---

## 🚀 Quick Start (One-Liner Install)

### Prerequisites
Make sure you have KDE Plasma 6 and Kvantum installed:

```bash
# Arch Linux / CachyOS / Manjaro
sudo pacman -S kvantum qt6-svg git spectacle

# Optional: Ultra-rich refraction blur (AUR)
paru -S kwin-effects-better-blur-dx-git
```

### Installation
Clone the repository and run the automated installer:

```bash
git clone https://github.com/mustozilla11/kde-frosted-glass.git
cd kde-frosted-glass
chmod +x install.sh
./install.sh
```

The script will:
1. 📦 **Safely back up** your existing KWin, Plasma, and Kvantum configurations to `~/.kde-frosted-glass-backup/`.
2. 🎨 Deploy the custom `WhiteSurLiquid-dark` desktop theme and Aurorae window decorations.
3. 🖼️ Deploy the macOS Sequoia Dark 4K wallpaper.
4. ⚙️ Apply scanout protection and optimal blur parameters.
5. 🔄 Clean Plasma SVG caches and reload the desktop seamlessly.

---

## 🔄 Reverting / Uninstallation

Don't like the look or want to return to your previous setup? The uninstaller restores your pre-installation backup in one command:

```bash
cd kde-frosted-glass
./uninstall.sh
```

---

## 🗂️ Repository Structure

```text
kde-frosted-glass/
├── assets/
│   └── wallpapers/               # macOS Sequoia Dark wallpaper
├── config/
│   ├── gtk-3.0/ & gtk-4.0/       # GTK dark styling matching Kvantum
│   ├── kvantum/                  # Kvantum liquid glass profiles
│   ├── kwin/
│   │   ├── effects/              # frosted_scanout_guard KWin effect
│   │   ├── kwinrc                # KWin blur and decoration settings
│   │   └── kwinrulesrc           # Intelligent opacity and browser bypass rules
│   └── plasma/
│       ├── env/                  # Direct scanout Wayland bypass environment script
│       ├── kdeglobals            # System color scheme
│       └── desktop-appletsrc     # Dock geometry reference configuration
├── themes/
│   ├── aurorae/                  # WhiteSurLiquid-dark titlebars (traffic lights)
│   └── plasma/
│       └── WhiteSurLiquid-dark/  # Custom 9-slice Apple Blue dock & task indicators
├── install.sh                    # Turnkey automated installer
├── uninstall.sh                  # Turnkey 1-click restore script
├── LICENSE                       # MIT License
└── README.md                     # Documentation
```

---

## 🇹🇷 Türkçe Özet & İlham Notları

Bu masaüstü yapılandırması (rice), KDE Plasma 6 (Wayland) üzerinde macOS benzeri **Liquid Dark & Frosted Glass (Buzlu Cam)** deneyimini hem görsel mükemmellikle hem de sistem kararlılığıyla sunmak için geliştirilmiştir.

### Neden Farklı?
1. **Sıfır Titreme (Scanout Guard):** Wayland üzerinde tam ekran şeffaf pencerelerde yaşanan siyah ekran kırpışmalarını KWin shader guard ve DRM env değişkeni ile çözdük.
2. **Özel 9-Slice Apple Blue Dock:** KDE'nin alt panel kenarlıklarındaki simetri ve renk bozulmalarını SVG 9-slice gridini Apple mavisi (`#0A84FF`) ve kusursuz 22px köşe kavisleriyle sıfırdan düzenleyerek giderdik.
3. **Sezgisel Görev Yöneticisi:** Açık olan uygulamalar beyaz kapsül (10px), aktif odaklanılan uygulama ise Apple Blue hap (24px) ve buzlu kart efekti ile belirginleştirildi.
4. **Tarayıcı ve Video Koruması:** Web tarayıcıları ve video oynatıcılar (Firefox, Chrome, VLC, MPV) otomatik olarak %100 opak tutulur; okunabilirlik ve renk kalitesinden taviz verilmez.
5. **Pil Dostu:** Harici dock motorları (Latte Dock vb.) yerine %100 yerel Plasma 6 bileşenleri kullanıldığı için arka planda fazladan işlemci tüketimi veya pil drenajı oluşturmaz.

---

## 📜 Credits & Acknowledgments
- Upstream base inspiration: [vinceliuice/WhiteSur-kde](https://github.com/vinceliuice/WhiteSur-kde)
- Blur enhancements: [kwin-effects-better-blur-dx](https://github.com/xarblu/kwin-effects-better-blur-dx)
- Plasma 6 & KWin by the [KDE Community](https://kde.org/)

---

## 📄 License
This project is licensed under the [MIT License](LICENSE).
Feel free to fork, adapt, and share!
