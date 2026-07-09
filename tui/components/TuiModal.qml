import QtQuick
import ".." as Tui

FocusScope {
    id: modal

    default property alias contentData: panel.contentData
    property bool shown: false
    property int modalWidth: 640
    property int modalHeight: 480
    property alias panel: panel
    signal dismissed()

    visible: shown
    focus: shown
    Keys.onEscapePressed: dismiss()

    function dismiss() {
        dismissed();
    }

    onShownChanged: {
        if (shown) forceActiveFocus();
    }

    Rectangle {
        anchors.fill: parent
        color: Tui.ThemeTokens.shadow

        MouseArea {
            anchors.fill: parent
            onClicked: modal.dismiss()
        }
    }

    Tui.TuiPanel {
        id: panel
        anchors.centerIn: parent
        width: Math.min(modal.modalWidth, modal.width - Tui.ThemeTokens.spacing * 4)
        height: Math.min(modal.modalHeight, modal.height - Tui.ThemeTokens.spacing * 4)
    }
}
