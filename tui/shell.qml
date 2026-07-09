//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "surfaces"

ShellRoot {
    id: root

    readonly property var activeScreen: {
        const monitor = Hyprland.focusedMonitor;
        const monitorName = monitor ? monitor.name : "";

        for (let i = 0; i < Quickshell.screens.length; i++) {
            const candidate = Quickshell.screens[i];
            if (candidate.name === monitorName && candidate.width > 0 && candidate.height > 0) {
                return candidate;
            }
        }

        for (let j = 0; j < Quickshell.screens.length; j++) {
            const fallback = Quickshell.screens[j];
            if (fallback.name !== "" && fallback.width > 0 && fallback.height > 0) {
                return fallback;
            }
        }

        return null;
    }

    CommandSurface {
        id: commandSurface
        targetScreen: root.activeScreen
    }

    IpcHandler {
        target: "command"
        function toggle(): void { commandSurface.toggle(); }
        function apps(): void { commandSurface.openApps(); }
        function close(): void { commandSurface.close(); }
    }
}
