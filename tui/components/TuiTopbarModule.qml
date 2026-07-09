import QtQuick
import ".." as Tui

FocusScope {
    id: module

    property string icon: ""
    property string text: ""
    property string badge: ""
    property bool active: false
    property bool interactive: true
    signal activated()

    implicitWidth: content.implicitWidth + Tui.ThemeTokens.spacing * 3
    implicitHeight: Tui.ThemeTokens.fontSize + Tui.ThemeTokens.spacing * 2
    activeFocusOnTab: interactive
    opacity: interactive ? 1 : 0.55

    Keys.onReturnPressed: activate()
    Keys.onEnterPressed: activate()
    Keys.onSpacePressed: activate()

    function activate() {
        if (interactive) activated();
    }

    Rectangle {
        anchors.fill: parent
        radius: Tui.ThemeTokens.radius
        color: module.active
            ? Tui.ThemeTokens.accentMuted
            : pointer.containsMouse || module.activeFocus
                ? Tui.ThemeTokens.backgroundAlt
                : "transparent"
        border.width: module.active || module.activeFocus ? 1 : 0
        border.color: module.active ? Tui.ThemeTokens.accent : Tui.ThemeTokens.border
    }

    Row {
        id: content
        anchors.centerIn: parent
        spacing: Tui.ThemeTokens.spacing

        Text {
            text: module.icon
            visible: text.length > 0
            color: module.active ? Tui.ThemeTokens.accent : Tui.ThemeTokens.foreground
            font.family: Tui.ThemeTokens.fontFamily
            font.pixelSize: Tui.ThemeTokens.fontSize
        }

        Text {
            text: module.text
            visible: text.length > 0
            color: Tui.ThemeTokens.foreground
            font.family: Tui.ThemeTokens.fontFamily
            font.pixelSize: Tui.ThemeTokens.fontSize
        }

        Text {
            text: module.badge
            visible: text.length > 0
            color: Tui.ThemeTokens.accent
            font.family: Tui.ThemeTokens.fontFamily
            font.pixelSize: Math.max(8, Tui.ThemeTokens.fontSize - 2)
        }
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        enabled: module.interactive
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            module.forceActiveFocus();
            module.activated();
        }
    }
}
