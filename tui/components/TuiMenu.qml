import QtQuick
import ".." as Tui

FocusScope {
    id: menu

    property var model: []
    property string labelRole: "label"
    property string descriptionRole: "description"
    property string leadingRole: "icon"
    property string iconRole: "iconSource"
    property string trailingRole: "key"
    property string enabledRole: "enabled"
    property alias currentIndex: list.currentIndex
    property alias listView: list
    signal activated(int index, var entry)

    implicitWidth: 420
    implicitHeight: Math.min(list.contentHeight, 480)
    activeFocusOnTab: true

    function role(entry, name, fallback) {
        if (entry === undefined || entry === null) return fallback;
        if (typeof entry === "string") return name === labelRole ? entry : fallback;
        return entry[name] === undefined ? fallback : entry[name];
    }

    function activateCurrent() {
        if (list.currentIndex < 0 || !list.currentItem) return;
        list.currentItem.activate();
    }

    ListView {
        id: list
        anchors.fill: parent
        model: menu.model
        clip: true
        focus: true
        keyNavigationWraps: true
        highlightMoveDuration: 80

        Keys.onReturnPressed: menu.activateCurrent()
        Keys.onEnterPressed: menu.activateCurrent()
        Keys.onSpacePressed: menu.activateCurrent()
        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Home) {
                currentIndex = count > 0 ? 0 : -1;
                event.accepted = true;
            } else if (event.key === Qt.Key_End) {
                currentIndex = count > 0 ? count - 1 : -1;
                event.accepted = true;
            }
        }

        delegate: Tui.TuiRow {
            required property int index
            required property var modelData
            readonly property var entry: modelData

            width: ListView.view.width
            primaryText: String(menu.role(entry, menu.labelRole, ""))
            secondaryText: String(menu.role(entry, menu.descriptionRole, ""))
            leadingText: String(menu.role(entry, menu.leadingRole, ""))
            iconSource: String(menu.role(entry, menu.iconRole, ""))
            trailingText: String(menu.role(entry, menu.trailingRole, ""))
            interactive: Boolean(menu.role(entry, menu.enabledRole, true))
            selected: ListView.isCurrentItem
            Keys.onUpPressed: {
                menu.listView.decrementCurrentIndex();
                menu.listView.forceActiveFocus();
            }
            Keys.onDownPressed: {
                menu.listView.incrementCurrentIndex();
                menu.listView.forceActiveFocus();
            }
            onActiveFocusChanged: {
                if (activeFocus) menu.listView.currentIndex = index;
            }
            onActivated: {
                menu.listView.currentIndex = index;
                menu.activated(index, entry);
            }
        }
    }
}
