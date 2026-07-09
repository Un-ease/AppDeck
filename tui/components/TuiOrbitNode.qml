import QtQuick
import ".." as Tui

Item {
    id: node

    property string label: "Application"
    property url iconSource: ""
    property bool selected: false
    property bool subdued: false

    signal activated()
    signal requested()

    implicitWidth: selected ? 86 : 58
    implicitHeight: implicitWidth

    Rectangle {
        anchors.centerIn: parent
        width: parent.width
        height: width
        radius: width / 2
        color: Tui.ThemeTokens.surfaceTranslucent
        border.width: node.selected ? 2 : 1
        border.color: node.selected ? Tui.ThemeTokens.accent : Tui.ThemeTokens.borderMuted

        Rectangle {
            anchors.fill: parent
            anchors.margins: node.selected ? 7 : 5
            radius: width / 2
            color: "transparent"
            border.width: 1
            border.color: node.selected ? Tui.ThemeTokens.accentMuted : Tui.ThemeTokens.borderMuted
            opacity: node.selected ? 0.9 : 0.45
        }

        Image {
            anchors.centerIn: parent
            width: parent.width * (node.selected ? 0.58 : 0.54)
            height: width
            source: node.iconSource
            sourceSize.width: width
            sourceSize.height: height
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
            visible: String(node.iconSource).length > 0 && status !== Image.Error
        }

        Text {
            anchors.centerIn: parent
            visible: String(node.iconSource).length === 0
            text: "✦"
            color: Tui.ThemeTokens.accent
            font.family: Tui.ThemeTokens.fontFamily
            font.pixelSize: parent.width * 0.42
        }
    }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.bottom
        anchors.topMargin: 6
        width: 7
        height: 7
        rotation: 45
        color: node.selected ? Tui.ThemeTokens.accent : "transparent"
        border.width: node.selected ? 0 : 1
        border.color: Tui.ThemeTokens.borderMuted
        opacity: node.selected ? 1 : 0.3
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: node.selected ? node.activated() : node.requested()
    }
}
