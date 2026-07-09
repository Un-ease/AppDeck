import QtQuick
import ".." as Tui

FocusScope {
    id: preview

    property string themeName: ""
    property color previewBackground: Tui.ThemeTokens.background
    property color previewForeground: Tui.ThemeTokens.foreground
    property color previewAccent: Tui.ThemeTokens.accent
    property color previewDanger: Tui.ThemeTokens.danger
    property color previewWarning: Tui.ThemeTokens.warning
    property color previewSuccess: Tui.ThemeTokens.success
    property bool selected: false
    signal activated()

    implicitWidth: 220
    implicitHeight: 112
    activeFocusOnTab: true
    Keys.onReturnPressed: activated()
    Keys.onEnterPressed: activated()
    Keys.onSpacePressed: activated()

    Rectangle {
        anchors.fill: parent
        color: preview.previewBackground
        radius: Tui.ThemeTokens.radius
        border.width: preview.selected || preview.activeFocus ? 2 : 1
        border.color: preview.selected || preview.activeFocus
            ? preview.previewAccent
            : Tui.ThemeTokens.border
    }

    Text {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Tui.ThemeTokens.spacing * 2
        text: preview.themeName
        color: preview.previewForeground
        font.family: Tui.ThemeTokens.fontFamily
        font.pixelSize: Tui.ThemeTokens.fontSize
        font.weight: Font.DemiBold
        elide: Text.ElideRight
    }

    Row {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: Tui.ThemeTokens.spacing * 2
        spacing: Tui.ThemeTokens.spacing

        Repeater {
            model: [
                preview.previewAccent,
                preview.previewSuccess,
                preview.previewWarning,
                preview.previewDanger
            ]

            Rectangle {
                required property color modelData
                width: 24
                height: 24
                radius: Math.min(Tui.ThemeTokens.radius, width / 2)
                color: modelData
                border.width: 1
                border.color: preview.previewForeground
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            preview.forceActiveFocus();
            preview.activated();
        }
    }
}
