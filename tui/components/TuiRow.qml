import QtQuick
import ".." as Tui

FocusScope {
    id: row

    property string leadingText: ""
    property url iconSource: ""
    property string primaryText: ""
    property string secondaryText: ""
    property string trailingText: ""
    property bool selected: false
    property bool interactive: true
    readonly property bool hovered: pointer.containsMouse
    signal activated()

    implicitWidth: 420
    implicitHeight: Math.max(
        Tui.ThemeTokens.fontSize + Tui.ThemeTokens.spacing * 3,
        labels.implicitHeight + Tui.ThemeTokens.spacing * 2
    )
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
        color: row.selected
            ? Tui.ThemeTokens.accentMuted
            : row.hovered || row.activeFocus
                ? Tui.ThemeTokens.backgroundAlt
                : "transparent"
        border.width: row.selected || row.activeFocus ? 1 : 0
        border.color: Tui.ThemeTokens.accent
    }

    Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: 1
        anchors.verticalCenter: parent.verticalCenter
        width: 2
        height: parent.height - Tui.ThemeTokens.spacing * 2
        radius: 1
        visible: row.selected
        color: Tui.ThemeTokens.accent
    }

    Image {
        id: icon
        anchors.left: parent.left
        anchors.leftMargin: Tui.ThemeTokens.spacing * 2
        anchors.verticalCenter: parent.verticalCenter
        width: 24
        height: 24
        source: row.iconSource
        visible: row.iconSource.toString().length > 0
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        mipmap: true
    }

    Text {
        id: leading
        anchors.left: icon.visible ? icon.right : parent.left
        anchors.leftMargin: Tui.ThemeTokens.spacing * 2
        anchors.verticalCenter: parent.verticalCenter
        text: row.leadingText
        visible: !icon.visible && text.length > 0
        color: Tui.ThemeTokens.accent
        font.family: Tui.ThemeTokens.fontFamily
        font.pixelSize: Tui.ThemeTokens.fontSize
    }

    Column {
        id: labels
        anchors.left: icon.visible ? icon.right : leading.visible ? leading.right : parent.left
        anchors.leftMargin: Tui.ThemeTokens.spacing * 2
        anchors.right: trailing.visible ? trailing.left : parent.right
        anchors.rightMargin: Tui.ThemeTokens.spacing * 2
        anchors.verticalCenter: parent.verticalCenter
        spacing: Math.max(1, Math.round(Tui.ThemeTokens.spacing / 2))

        Text {
            width: parent.width
            text: row.primaryText
            color: Tui.ThemeTokens.foreground
            font.family: Tui.ThemeTokens.fontFamily
            font.pixelSize: Tui.ThemeTokens.fontSize
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            text: row.secondaryText
            visible: text.length > 0
            color: row.selected ? Tui.ThemeTokens.foreground : Tui.ThemeTokens.foregroundMuted
            font.family: Tui.ThemeTokens.fontFamily
            font.pixelSize: Math.max(8, Tui.ThemeTokens.fontSize - 2)
            elide: Text.ElideRight
        }
    }

    Text {
        id: trailing
        anchors.right: parent.right
        anchors.rightMargin: Tui.ThemeTokens.spacing * 2
        anchors.verticalCenter: parent.verticalCenter
        text: row.trailingText
        visible: text.length > 0
        color: row.selected ? Tui.ThemeTokens.foreground : Tui.ThemeTokens.foregroundMuted
        font.family: Tui.ThemeTokens.fontFamily
        font.pixelSize: Math.max(8, Tui.ThemeTokens.fontSize - 1)
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        enabled: row.interactive
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            row.forceActiveFocus();
            row.activated();
        }
    }
}
