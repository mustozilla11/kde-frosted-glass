/*global effects, set, cancel, complete, Effect */
"use strict";

// Frosted Scanout & Transform Guard for KWin 6.8 + Better Blur DX:
// 1. Keeps a completed 1ms no-op AnimationEffect entry ONLY on the desktop
//    window (never on client windows, avoiding PAINT_WINDOW_TRANSFORMED).
// 2. Sets Effect.WindowForceBlurRole = true on all non-excluded client windows
//    so Better Blur DX never drops or fades out blur after 250ms of dragging,
//    moving, resizing, maximizing, or fullscreening.
// 3. Triggers w.addRepaintFull() on geometry/move/maximize/fullscreen changes
//    so Better Blur DX's offscreen FBOs always blit the complete backgroundRect
//    instead of partial-damage rects over black-cleared textures.
var frostedScanoutGuard = {
    guardedDesktop: null,
    animId: null,
    excludedClasses: {
        "vlc": true,
        "mpv": true,
        "spectacle": true,
        "org.kde.spectacle": true,
        "flameshot": true
    },

    isExcluded: function (w) {
        if (!w || w.deleted || w.desktopWindow || w.dock) {
            return true;
        }
        const cls = String(w.resourceClass || "").toLowerCase();
        const name = String(w.resourceName || "").toLowerCase();
        return Boolean(frostedScanoutGuard.excludedClasses[cls] || frostedScanoutGuard.excludedClasses[name]);
    },

    syncWindowForceBlur: function (w) {
        if (!w || w.deleted || Effect.WindowForceBlurRole === undefined) {
            return;
        }
        if (frostedScanoutGuard.isExcluded(w)) {
            return;
        }
        const shouldForce = !w.minimized && !effects.hasActiveFullScreenEffect;
        w.setData(Effect.WindowForceBlurRole, shouldForce);
    },

    syncAllWindowsForceBlur: function () {
        const windows = effects.stackingOrder;
        for (let i = 0; i < windows.length; ++i) {
            frostedScanoutGuard.syncWindowForceBlur(windows[i]);
        }
    },

    repaintWindowFull: function (w) {
        if (!w || w.deleted || w.minimized || frostedScanoutGuard.isExcluded(w)) {
            return;
        }
        frostedScanoutGuard.syncWindowForceBlur(w);
        if (typeof w.addRepaintFull === "function") {
            w.addRepaintFull();
        }
    },

    releaseDesktopGuard: function () {
        if (frostedScanoutGuard.animId !== null) {
            cancel(frostedScanoutGuard.animId);
            frostedScanoutGuard.animId = null;
        }
        frostedScanoutGuard.guardedDesktop = null;
    },

    ensureDesktopGuard: function () {
        if (frostedScanoutGuard.guardedDesktop !== null && !frostedScanoutGuard.guardedDesktop.deleted) {
            return;
        }
        frostedScanoutGuard.releaseDesktopGuard();

        const windows = effects.stackingOrder;
        for (let i = 0; i < windows.length; ++i) {
            const w = windows[i];
            if (!w.deleted && w.desktopWindow) {
                const id = set({
                    window: w,
                    duration: 1,
                    keepAlive: false,
                    animations: [{
                        type: Effect.Opacity,
                        from: 1.0,
                        to: 1.0
                    }]
                });
                complete(id);
                frostedScanoutGuard.guardedDesktop = w;
                frostedScanoutGuard.animId = id;
                return;
            }
        }
    },

    attachWindow: function (w) {
        if (!w || w.deleted) {
            return;
        }
        if (w.desktopWindow) {
            frostedScanoutGuard.ensureDesktopGuard();
            return;
        }
        if (frostedScanoutGuard.isExcluded(w)) {
            return;
        }

        frostedScanoutGuard.syncWindowForceBlur(w);

        w.minimizedChanged.connect(function () {
            frostedScanoutGuard.syncWindowForceBlur(w);
            frostedScanoutGuard.repaintWindowFull(w);
        });
        w.windowFrameGeometryChanged.connect(function () {
            frostedScanoutGuard.repaintWindowFull(w);
        });
        w.windowFinishUserMovedResized.connect(function () {
            frostedScanoutGuard.repaintWindowFull(w);
        });
        w.windowMaximizedStateChanged.connect(function () {
            frostedScanoutGuard.repaintWindowFull(w);
        });
        w.windowFullScreenChanged.connect(function () {
            frostedScanoutGuard.repaintWindowFull(w);
        });
    },

    onWindowAdded: function (w) {
        frostedScanoutGuard.attachWindow(w);
        frostedScanoutGuard.repaintWindowFull(w);
    },

    onWindowClosed: function (w) {
        if (w === frostedScanoutGuard.guardedDesktop) {
            frostedScanoutGuard.releaseDesktopGuard();
            frostedScanoutGuard.ensureDesktopGuard();
        }
    },

    repaintAllWindows: function () {
        frostedScanoutGuard.ensureDesktopGuard();
        const windows = effects.stackingOrder;
        for (let i = 0; i < windows.length; ++i) {
            frostedScanoutGuard.repaintWindowFull(windows[i]);
        }
    },

    init: function () {
        effects.windowAdded.connect(frostedScanoutGuard.onWindowAdded);
        effects.windowClosed.connect(frostedScanoutGuard.onWindowClosed);
        if (effects.activeFullScreenEffectChanged) {
            effects.activeFullScreenEffectChanged.connect(frostedScanoutGuard.syncAllWindowsForceBlur);
        }
        if (effects.screenLockingChanged) {
            effects.screenLockingChanged.connect(function (locked) {
                if (!locked) {
                    frostedScanoutGuard.repaintAllWindows();
                }
            });
        }

        const windows = effects.stackingOrder;
        for (let i = 0; i < windows.length; ++i) {
            frostedScanoutGuard.attachWindow(windows[i]);
        }
        frostedScanoutGuard.repaintAllWindows();
    }
};

frostedScanoutGuard.init();
