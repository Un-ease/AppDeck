import QtQuick
import ".." as Tui

Rectangle {
    id: panel

    default property alias contentData: content.data
    property int padding: Tui.ThemeTokens.spacing * 2

    implicitWidth: Math.max(1, content.childrenRect.width + padding * 2)
    implicitHeight: Math.max(1, content.childrenRect.height + padding * 2)
    color: Tui.ThemeTokens.surface
    radius: Tui.ThemeTokens.radius
    border.width: 1
    border.color: Tui.ThemeTokens.border
    clip: true

    Item {
        id: content
        anchors.fill: parent
        anchors.margins: panel.padding
    }
}
