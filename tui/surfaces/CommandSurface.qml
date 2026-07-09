import QtQuick
import Quickshell
import Quickshell.Wayland
import ".." as Tui
import "../models"

PanelWindow {
    id: surface

    property bool opened: false
    property bool showCards: false
    property bool opening: false
    property var targetScreen: null
    property int currentIndex: -1
    property int hoverIndex: -1
    readonly property bool invoking: search.text.length > 0
    readonly property var currentEntry: currentIndex >= 0 && currentIndex < catalog.results.length
        ? catalog.results[currentIndex] : null
    readonly property var displayEntry: hoverIndex >= 0 && hoverIndex < catalog.results.length
        ? catalog.results[hoverIndex] : currentEntry


    screen: targetScreen
    color: "transparent"
    visible: opened && targetScreen !== null
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "omarchy-tui-command"
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    Timer {
        id: showTimer
        interval: 20
        onTriggered: surface.showCards = true
    }

    Timer {
        id: closeTimer
        interval: 300
        onTriggered: surface.opened = false
    }

    Timer {
        id: openingTimer
        interval: 1000
        onTriggered: surface.opening = false
    }

    function openApps() {
        if (opened) return;
        search.text = "";
        catalog.query = "";
        currentIndex = catalog.results.length > 0 ? 0 : -1;
        hoverIndex = -1;
        showCards = false;
        opening = true;
        opened = true;
        showTimer.start();
        openingTimer.start();
        Qt.callLater(function() { search.focusInput(); });
    }

    function close() { 
        if (!opened) return;
        showCards = false; 
        opening = false;
        openingTimer.stop();
        closeTimer.start(); 
    }
    
    function toggle() { opened ? close() : openApps(); }

    function move(step) {
        var count = catalog.results.length;
        if (count === 0) return;
        var next = currentIndex + step;
        if (next < 0) next = 0;
        if (next >= count) next = count - 1;
        currentIndex = next;
        hoverIndex = -1;
    }

    function launchCurrent() {
        if (!currentEntry) return;
        var entry = currentEntry;
        close();
        catalog.launch(entry);
    }

    function launchIndex(idx) {
        if (idx < 0 || idx >= catalog.results.length) return;
        var entry = catalog.results[idx];
        close();
        catalog.launch(entry);
    }

    ApplicationCatalog { id: catalog }

    // ── backdrop ──
    Rectangle {
        anchors.fill: parent
        color: Tui.ThemeTokens.background
        opacity: surface.showCards ? 0.82 : 0.0
        Behavior on opacity { NumberAnimation { duration: 300 } }
        MouseArea { anchors.fill: parent; onClicked: surface.close() }
    }

    // ── search bar + hints — top ──
    Column {
        id: searchCol
        anchors.top: parent.top
        anchors.topMargin: Tui.ThemeTokens.spacing * 10
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(640, parent.width - Tui.ThemeTokens.spacing * 8)
        spacing: Tui.ThemeTokens.spacing * 2
        z: 2000
        opacity: surface.showCards ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 300 } }

        Tui.TuiSearch {
            id: search
            width: parent.width
            height: Tui.ThemeTokens.fontSize + Tui.ThemeTokens.spacing * 2
            chromeVisible: false
            placeholderText: "type to summon an application"
            onTextChanged: {
                catalog.query = text;
                surface.currentIndex = catalog.results.length > 0 ? 0 : -1;
                surface.hoverIndex = -1;
            }
            onAccepted: surface.launchCurrent()
            onCancelled: surface.close()
            Keys.onUpPressed: surface.move(-1)
            Keys.onDownPressed: surface.move(1)
        }

        Rectangle {
            width: parent.width
            height: 1
            color: search.activeFocus ? Tui.ThemeTokens.accent : Tui.ThemeTokens.borderMuted
            opacity: 0.8
        }

        Text {
            width: parent.width
            text: "← →  SELECT     TYPE  SUMMON     ENTER  OPEN     ESC  CLOSE"
            color: Tui.ThemeTokens.foregroundMuted
            horizontalAlignment: Text.AlignHCenter
            font.family: Tui.ThemeTokens.fontFamily
            font.pixelSize: Math.max(8, Tui.ThemeTokens.fontSize - 2)
            font.letterSpacing: 0.5
        }
    }

    // ── app name + header (below search) ──
    Column {
        id: headerCol
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: searchCol.bottom
        anchors.topMargin: 40
        spacing: 6
        opacity: surface.showCards ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 300 } }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: surface.invoking
                ? "SUMMONING  //  " + catalog.results.length + " MATCHES"
                : "APPLICATION DECK  //  " + (surface.currentIndex + 1) + " / " + catalog.results.length
            color: Tui.ThemeTokens.foregroundMuted
            font.family: Tui.ThemeTokens.fontFamily
            font.pixelSize: Tui.ThemeTokens.fontSize
            font.letterSpacing: 2.4
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: surface.displayEntry ? surface.displayEntry.label : ""
            color: Tui.ThemeTokens.foreground
            font.family: Tui.ThemeTokens.fontFamily
            font.pixelSize: Tui.ThemeTokens.fontSize + 8
            font.weight: Font.DemiBold
        }
    }

    Tui.TuiDecorDeck {
        anchors.top: headerCol.bottom
        anchors.topMargin: 24
        anchors.horizontalCenter: parent.horizontalCenter
        appName: surface.displayEntry ? surface.displayEntry.label : ""
        appIcon: (surface.displayEntry && surface.displayEntry.icon) ? catalog.resolvedIcon(surface.displayEntry.icon) : ""
        opacity: surface.showCards ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    // ── card fan — at the bottom ──
    Item {
        id: fan
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 550

        // Card dimensions
        readonly property real cardW: 244
        readonly property real cardH: 366

        // Grip point — bottom center of the fan area.
        readonly property real pivotX: width / 2
        readonly property real pivotY: height + 320

        // Degrees between each card in the fan
        readonly property real angleStep: 12.0

        // Faint sigil behind the fan
        Tui.TuiSigil {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -40
            width: 220
            height: 220
            active: surface.visible
            opacity: surface.showCards ? 0.05 : 0.0
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }

        // ── fan of cards ──
        Repeater {
            model: catalog.results.length

            delegate: Tui.TuiOrbitCard {
                id: fanCard
                required property int index
                readonly property var entry: catalog.results[index]
                readonly property int count: catalog.results.length

                // Delta is the distance from the currently selected card
                readonly property real delta: index - surface.currentIndex

                // Is this card popped up?
                readonly property bool popped: hovered || index === surface.currentIndex

                // Only render and animate cards that are reasonably close to the center
                readonly property bool inView: Math.abs(delta) <= 15
                visible: inView

                label: entry ? entry.label : ""
                iconSource: (inView && entry && entry.icon) ? catalog.resolvedIcon(entry.icon) : ""
                selected: index === surface.currentIndex
                marker: entry && entry.label.length > 0 ? entry.label.charAt(0).toUpperCase() : "?"

                width: fan.cardW
                height: fan.cardH

                // Position relative to a visible body height of 360, leaving 100px off-screen when flat
                x: fan.pivotX - width / 2
                y: fan.height - 360 + 100

                // Pop up when hovered or selected, and drop entirely off-screen when closing.
                property real liftY: (popped ? -120 : 0) + (surface.showCards ? 0 : 500)

                // Animate card angle property
                property real cardAngle: surface.showCards ? (delta * fan.angleStep) : 0

                transform: [
                    Translate { y: fanCard.liftY },
                    Rotation {
                        origin.x: fanCard.width / 2
                        origin.y: fan.pivotY - fanCard.y
                        angle: fanCard.cardAngle
                    }
                ]

                // Z-order: popped cards on top, others ordered by distance from center
                z: popped ? 1000 : 500 - Math.abs(delta)

                opacity: {
                    if (!surface.showCards) return 0.0;
                    // Fade out cards that are too far down the sides
                    var dist = Math.abs(delta);
                    if (dist > 7) return Math.max(0, 1 - (dist - 7) * 0.4);
                    return 1;
                }

                onRequested: {
                    surface.currentIndex = index;
                    surface.hoverIndex = -1;
                }
                onActivated: surface.launchIndex(index)
                onMouseMoved: {
                    if (surface.currentIndex !== index) {
                        surface.currentIndex = index;
                    }
                }

                Behavior on liftY {
                    enabled: fanCard.inView
                    NumberAnimation { 
                        duration: 350
                        easing.type: Easing.OutQuart
                    }
                }

                Behavior on cardAngle {
                    enabled: fanCard.inView
                    SequentialAnimation {
                        PauseAnimation {
                            // Wait 150ms for cards to rise as a stacked deck, then fan out outward
                            duration: surface.opening ? (150 + Math.min(300, Math.abs(delta) * 45)) : 0
                        }
                        NumberAnimation { 
                            duration: 400
                            easing.type: Easing.OutQuart 
                        }
                    }
                }
                
                Behavior on opacity {
                    enabled: fanCard.inView
                    SequentialAnimation {
                        PauseAnimation {
                            // Delay fade-in of outer cards to match their rotation/emergence
                            duration: surface.opening ? (150 + Math.min(300, Math.abs(delta) * 45)) : 0
                        }
                        NumberAnimation { duration: 300 }
                    }
                }
            }
        }
    }
}
