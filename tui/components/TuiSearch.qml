import QtQuick
import ".." as Tui

FocusScope {
    id: search

    property alias text: input.text
    property alias input: input
    property string placeholderText: "Search"
    property bool chromeVisible: true
    signal accepted(string text)
    signal cancelled()

    implicitWidth: 320
    implicitHeight: Tui.ThemeTokens.fontSize + Tui.ThemeTokens.spacing * 3
    activeFocusOnTab: true

    function clear() {
        input.clear();
    }

    function focusInput() {
        input.forceActiveFocus();
    }

    onActiveFocusChanged: {
        if (activeFocus && !input.activeFocus) input.forceActiveFocus();
    }

    Rectangle {
        anchors.fill: parent
        visible: search.chromeVisible
        color: Tui.ThemeTokens.backgroundAlt
        radius: Tui.ThemeTokens.radius
        border.width: 1
        border.color: search.activeFocus ? Tui.ThemeTokens.accent : Tui.ThemeTokens.borderMuted
    }

    TextInput {
        id: input
        anchors.fill: parent
        anchors.leftMargin: search.chromeVisible ? Tui.ThemeTokens.spacing * 2 : 0
        anchors.rightMargin: search.chromeVisible ? Tui.ThemeTokens.spacing * 2 : 0
        verticalAlignment: TextInput.AlignVCenter
        color: Tui.ThemeTokens.foreground
        selectionColor: Tui.ThemeTokens.selectedBackground
        selectedTextColor: Tui.ThemeTokens.selectedForeground
        font.family: Tui.ThemeTokens.fontFamily
        font.pixelSize: Tui.ThemeTokens.fontSize
        clip: true
        selectByMouse: true
        Keys.onEscapePressed: search.cancelled()
        Keys.onReturnPressed: search.accepted(text)
        Keys.onEnterPressed: search.accepted(text)
    }

    Text {
        anchors.fill: input
        verticalAlignment: Text.AlignVCenter
        text: search.placeholderText
        visible: input.text.length === 0
        color: Tui.ThemeTokens.foregroundMuted
        font: input.font
    }

}
