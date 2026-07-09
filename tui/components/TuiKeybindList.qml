import QtQuick
import ".." as Tui

FocusScope {
    id: viewer

    property var model: []
    property string keyRole: "key"
    property string actionRole: "action"
    property alias currentIndex: list.currentIndex
    signal activated(int index, var entry)

    implicitWidth: 720
    implicitHeight: Math.min(list.contentHeight, 520)
    activeFocusOnTab: true

    function role(entry, name) {
        if (!entry || entry[name] === undefined) return "";
        return String(entry[name]);
    }

    ListView {
        id: list
        anchors.fill: parent
        model: viewer.model
        clip: true
        focus: true
        keyNavigationWraps: true
        spacing: 1

        Keys.onReturnPressed: {
            if (currentItem) currentItem.activate();
        }
        Keys.onEnterPressed: {
            if (currentItem) currentItem.activate();
        }
        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Home) {
                currentIndex = count > 0 ? 0 : -1;
                event.accepted = true;
            } else if (event.key === Qt.Key_End) {
                currentIndex = count > 0 ? count - 1 : -1;
                event.accepted = true;
            }
        }

        delegate: FocusScope {
            id: keybindRow
            required property int index
            required property var modelData
            readonly property var entry: modelData

            width: ListView.view.width
            height: Tui.ThemeTokens.fontSize + Tui.ThemeTokens.spacing * 3
            activeFocusOnTab: true

            function activate() {
                viewer.activated(index, entry);
            }

            Keys.onReturnPressed: activate()
            Keys.onEnterPressed: activate()
            Keys.onUpPressed: {
                list.decrementCurrentIndex();
                list.forceActiveFocus();
            }
            Keys.onDownPressed: {
                list.incrementCurrentIndex();
                list.forceActiveFocus();
            }

            Rectangle {
                anchors.fill: parent
                radius: Tui.ThemeTokens.radius
                color: keybindRow.ListView.isCurrentItem
                    ? Tui.ThemeTokens.selectedBackground
                    : pointer.containsMouse || keybindRow.activeFocus
                        ? Tui.ThemeTokens.backgroundAlt
                        : "transparent"
            }

            Text {
                width: Math.round(parent.width * 0.38)
                anchors.left: parent.left
                anchors.leftMargin: Tui.ThemeTokens.spacing * 2
                anchors.verticalCenter: parent.verticalCenter
                text: viewer.role(keybindRow.entry, viewer.keyRole)
                color: keybindRow.ListView.isCurrentItem
                    ? Tui.ThemeTokens.selectedForeground
                    : Tui.ThemeTokens.accent
                font.family: Tui.ThemeTokens.fontFamily
                font.pixelSize: Tui.ThemeTokens.fontSize
                elide: Text.ElideRight
            }

            Text {
                width: Math.round(parent.width * 0.58)
                anchors.right: parent.right
                anchors.rightMargin: Tui.ThemeTokens.spacing * 2
                anchors.verticalCenter: parent.verticalCenter
                text: viewer.role(keybindRow.entry, viewer.actionRole)
                color: keybindRow.ListView.isCurrentItem
                    ? Tui.ThemeTokens.selectedForeground
                    : Tui.ThemeTokens.foreground
                font.family: Tui.ThemeTokens.fontFamily
                font.pixelSize: Tui.ThemeTokens.fontSize
                elide: Text.ElideRight
            }

            MouseArea {
                id: pointer
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    list.currentIndex = keybindRow.index;
                    keybindRow.forceActiveFocus();
                    keybindRow.activate();
                }
            }
        }
    }
}
