pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "Palette.js" as Palette

Item {
    id: tokens

    readonly property string colorsPath: Quickshell.env("HOME")
        + "/.config/omarchy/current/theme/colors.toml"
    readonly property string themeNamePath: Quickshell.env("HOME")
        + "/.config/omarchy/current/theme.name"

    property var _derived: null

    readonly property color background: colorOrTransparent("background")
    readonly property color backgroundAlt: colorOrTransparent("backgroundAlt")
    readonly property color surface: colorOrTransparent("surface")
    readonly property color surfaceTranslucent: Qt.rgba(
        surface.r, surface.g, surface.b, _derived ? 0.92 : 0
    )
    readonly property color foreground: colorOrTransparent("foreground")
    readonly property color foregroundMuted: colorOrTransparent("foregroundMuted")
    readonly property color border: colorOrTransparent("border")
    readonly property color borderMuted: colorOrTransparent("borderMuted")
    readonly property color selectedBackground: colorOrTransparent("selectedBackground")
    readonly property color selectedForeground: colorOrTransparent("selectedForeground")
    readonly property color accent: colorOrTransparent("accent")
    readonly property color accentMuted: Qt.rgba(accent.r, accent.g, accent.b, _derived ? 0.34 : 0)
    readonly property color danger: colorOrTransparent("danger")
    readonly property color warning: colorOrTransparent("warning")
    readonly property color success: colorOrTransparent("success")
    readonly property color shadow: Qt.rgba(
        colorOrTransparent("shadow").r,
        colorOrTransparent("shadow").g,
        colorOrTransparent("shadow").b,
        _derived ? 0.46 : 0
    )

    readonly property int radius: 6
    readonly property int spacing: 6
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 12

    function colorOrTransparent(name) {
        return _derived && Palette.validColor(_derived[name])
            ? _derived[name]
            : Qt.rgba(0, 0, 0, 0);
    }

    function applyText(text) {
        const next = Palette.derive(Palette.parse(text));
        if (next) _derived = next;
    }

    function reload() {
        paletteFile.reload();
    }

    FileView {
        id: paletteFile
        path: tokens.colorsPath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: tokens.applyText(text())
    }

    // Omarchy swaps current/theme atomically. Watching theme.name as well makes
    // reload survive replacement of the watched colors.toml inode.
    FileView {
        id: themeNameFile
        path: tokens.themeNamePath
        watchChanges: true
        onFileChanged: paletteFile.reload()
    }

    Component.onCompleted: paletteFile.reload()
}
