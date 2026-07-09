import QtQuick
import ".." as Tui

Item {
    id: card

    property string label: "Application"
    property url iconSource: ""
    property bool selected: false
    property string marker: "A"
    
    readonly property bool hovered: pointer.containsMouse
    readonly property bool emphasized: selected || hovered

    signal activated()
    signal requested()
    signal mouseMoved()

    // Max tilt angle (degrees)
    readonly property real maxTilt: 12
    
    // Target tilts calculated from mouse position (only applied when emphasized and hovered)
    readonly property real targetTiltX: (card.emphasized && card.hovered) ? -( (pointer.mouseY - height/2) / (height/2) ) * maxTilt : 0
    readonly property real targetTiltY: (card.emphasized && card.hovered) ? ( (pointer.mouseX - width/2) / (width/2) ) * maxTilt : 0
    
    // Smoothed tilts for the physics feel
    property real tiltX: 0
    property real tiltY: 0
    
    Behavior on tiltX { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    Behavior on tiltY { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    
    // Update the smoothed values to track the targets
    onTargetTiltXChanged: tiltX = targetTiltX
    onTargetTiltYChanged: tiltY = targetTiltY

    implicitWidth: 240
    implicitHeight: 360

    // Drop shadow
    Rectangle {
        x: 4
        y: 6
        width: parent.width
        height: parent.height
        radius: Tui.ThemeTokens.radius + 6
        color: Tui.ThemeTokens.shadow
        opacity: card.emphasized ? 0.7 : 0.4
    }

    // Card face
    Rectangle {
        id: frame
        anchors.fill: parent
        color: card.emphasized ? "#ffffff" : "#f5f6f8"
        radius: Tui.ThemeTokens.radius + 6
        
        // Border transitions to active theme accent on selection/hover
        border.width: card.emphasized ? 2.5 : 1.5
        border.color: card.emphasized ? Tui.ThemeTokens.accent : "#222222"

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }

        // Apply 3D rotation based on mouse tracking
        transform: [
            Rotation {
                origin.x: frame.width / 2
                origin.y: frame.height / 2
                axis { x: 1; y: 0; z: 0 }
                angle: card.tiltX
            },
            Rotation {
                origin.x: frame.width / 2
                origin.y: frame.height / 2
                axis { x: 0; y: 1; z: 0 }
                angle: card.tiltY
            }
        ]

        // Inner decorative border
        Rectangle {
            anchors.fill: parent
            anchors.margins: 10
            color: "transparent"
            radius: Math.max(0, parent.radius - 5)
            border.width: 1
            border.color: card.emphasized ? Tui.ThemeTokens.accentMuted : "#e5e7eb"
            opacity: card.emphasized ? 0.9 : 0.4

            // Base parallax
            transform: Translate { x: card.tiltY * 0.5; y: -card.tiltX * 0.5 }
        }

        // Top-left marker
        Column {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 16
            spacing: 6
            width: 32

            // High parallax for corners
            transform: Translate { x: card.tiltY * 0.8; y: -card.tiltX * 0.8 }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: card.marker
                color: card.emphasized ? "#111111" : "#555555" // High-contrast crisp black/grey
                font.family: Tui.ThemeTokens.fontFamily
                font.pixelSize: 28
                font.weight: Font.Bold
            }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 20
                height: 20
                source: card.iconSource
                sourceSize.width: width
                sourceSize.height: height
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                visible: String(card.iconSource).length > 0 && status !== Image.Error
            }
        }

        // Bottom-right marker (rotated 180° like real playing cards)
        Column {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 16
            spacing: 6
            width: 32
            rotation: 180

            // High parallax for corners
            transform: Translate { x: card.tiltY * 0.8; y: -card.tiltX * 0.8 }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: card.marker
                color: card.emphasized ? "#111111" : "#555555"
                font.family: Tui.ThemeTokens.fontFamily
                font.pixelSize: 28
                font.weight: Font.Bold
            }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 20
                height: 20
                source: card.iconSource
                sourceSize.width: width
                sourceSize.height: height
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                visible: String(card.iconSource).length > 0 && status !== Image.Error
            }
        }

        // Center icon
        Image {
            id: centerIcon
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -15 // Nudge icon up slightly to make room for label text
            width: card.emphasized ? 110 : 80
            height: width
            source: card.iconSource
            sourceSize.width: width
            sourceSize.height: height
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
            visible: String(card.iconSource).length > 0 && status !== Image.Error

            // Max parallax for center icon so it floats high
            transform: Translate { x: card.tiltY * 1.5; y: -card.tiltX * 1.5 }

            Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        }

        // Card application title/label
        Text {
            id: cardLabel
            anchors.top: centerIcon.bottom
            anchors.topMargin: 12
            anchors.horizontalCenter: parent.horizontalCenter
            text: card.label
            color: card.emphasized ? "#111111" : "#555555"
            font.family: Tui.ThemeTokens.fontFamily
            font.pixelSize: 14
            font.weight: Font.DemiBold
            elide: Text.ElideRight
            width: parent.width - 40
            horizontalAlignment: Text.AlignHCenter

            // Medium parallax for label text
            transform: Translate { x: card.tiltY * 1.1; y: -card.tiltX * 1.1 }
        }

        // Fallback glyph
        Text {
            anchors.centerIn: parent
            visible: String(card.iconSource).length === 0
            text: "✦"
            color: Tui.ThemeTokens.accent
            font.family: Tui.ThemeTokens.fontFamily
            font.pixelSize: card.emphasized ? 80 : 60
            
            transform: Translate { x: card.tiltY * 1.5; y: -card.tiltX * 1.5 }
        }
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPositionChanged: (mouse) => { card.mouseMoved() }
        onClicked: card.emphasized ? card.activated() : card.requested()
    }
}
