import QtQuick
import ".." as Tui

Item {
    id: card

    property string label: "Application"
    property string description: ""
    property url iconSource: ""
    property bool selected: false
    property bool interactive: true
    property real floatOffset: 0

    signal activated()
    signal requested()

    implicitWidth: 248
    implicitHeight: 336

    SequentialAnimation on floatOffset {
        running: card.selected && card.visible
        loops: Animation.Infinite
        NumberAnimation { to: -5; duration: 1400; easing.type: Easing.InOutSine }
        NumberAnimation { to: 5; duration: 1400; easing.type: Easing.InOutSine }
    }

    Rectangle {
        id: aura
        anchors.fill: frame
        anchors.margins: -8
        radius: frame.radius + 8
        color: "transparent"
        border.width: card.selected ? 2 : 0
        border.color: Tui.ThemeTokens.accentMuted
        opacity: card.selected ? 0.75 : 0
    }

    Rectangle {
        id: frame
        anchors.fill: parent
        color: card.selected ? Tui.ThemeTokens.surface : Tui.ThemeTokens.surfaceTranslucent
        radius: Tui.ThemeTokens.radius * 2
        border.width: card.selected ? 2 : 1
        border.color: card.selected ? Tui.ThemeTokens.accent : Tui.ThemeTokens.borderMuted

        Rectangle {
            anchors.fill: parent
            anchors.margins: Tui.ThemeTokens.spacing
            color: "transparent"
            radius: Math.max(0, parent.radius - Tui.ThemeTokens.spacing)
            border.width: 1
            border.color: card.selected ? Tui.ThemeTokens.accentMuted : Tui.ThemeTokens.borderMuted
            opacity: card.selected ? 0.7 : 0.35
        }

        Tui.TuiSigil {
            anchors.centerIn: parent
            width: Math.min(parent.width, parent.height) * 0.76
            height: width
            active: card.selected
            opacity: card.selected ? 0.13 : 0.05
        }

        Text {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: Tui.ThemeTokens.spacing * 3
            text: card.selected ? "ACTIVE // 01" : "AETHER NODE"
            color: card.selected ? Tui.ThemeTokens.accent : Tui.ThemeTokens.foregroundMuted
            font.family: Tui.ThemeTokens.fontFamily
            font.pixelSize: Math.max(8, Tui.ThemeTokens.fontSize - 3)
            font.letterSpacing: 1.5
        }

        Item {
            anchors.centerIn: parent
            width: card.selected ? 112 : 84
            height: width

            Image {
                anchors.fill: parent
                source: card.iconSource
                sourceSize.width: width
                sourceSize.height: height
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                visible: String(card.iconSource).length > 0 && status !== Image.Error
            }

            Text {
                anchors.centerIn: parent
                visible: String(card.iconSource).length === 0
                text: "✦"
                color: Tui.ThemeTokens.accent
                font.family: Tui.ThemeTokens.fontFamily
                font.pixelSize: parent.width * 0.62
            }
        }

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: Tui.ThemeTokens.spacing * 3
            spacing: Tui.ThemeTokens.spacing

            Rectangle {
                width: parent.width
                height: 1
                color: card.selected ? Tui.ThemeTokens.accentMuted : Tui.ThemeTokens.borderMuted
            }

            Text {
                width: parent.width
                text: card.label
                color: Tui.ThemeTokens.foreground
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                font.family: Tui.ThemeTokens.fontFamily
                font.pixelSize: card.selected ? Tui.ThemeTokens.fontSize + 3 : Tui.ThemeTokens.fontSize
                font.weight: card.selected ? Font.DemiBold : Font.Normal
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: card.interactive
        cursorShape: Qt.PointingHandCursor
        onClicked: card.selected ? card.activated() : card.requested()
    }
}
