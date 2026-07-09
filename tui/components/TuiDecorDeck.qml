import QtQuick
import ".." as Tui

Item {
    id: root

    width: 112
    height: 150

    property string appName: ""
    property url appIcon: ""

    readonly property bool flipped: appName.length > 0
    readonly property bool hovered: mouseArea.containsMouse

    // ── 3D Hover & Spin Physics for Flipped Card ──
    property real hoverSpin: 0
    
    // Max tilt angle (degrees)
    readonly property real maxTilt: 15
    
    // Target tilts calculated from mouse position on the front face
    readonly property real targetTiltX: (frontPointer.containsMouse) ? -( (frontPointer.mouseY - height/2) / (height/2) ) * maxTilt : 0
    readonly property real targetTiltY: (frontPointer.containsMouse) ? ( (frontPointer.mouseX - width/2) / (width/2) ) * maxTilt : 0
    
    property real tiltX: 0
    property real tiltY: 0
    
    Behavior on tiltX { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    Behavior on tiltY { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    
    onTargetTiltXChanged: tiltX = targetTiltX
    onTargetTiltYChanged: tiltY = targetTiltY

    // Spin animation when hovering the information card
    NumberAnimation {
        id: spinAnimation
        target: root
        property: "hoverSpin"
        from: 0
        to: 360
        duration: 750
        easing.type: Easing.OutBack // Snappy spin with slight overshoot
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }

    // Bottom Card
    Rectangle {
        x: (root.flipped || root.hovered) ? -24 : 0
        y: (root.flipped || root.hovered) ? 8 : 0
        width: parent.width; height: parent.height
        color: "transparent"
        rotation: (root.flipped || root.hovered) ? -12 : 0
        z: 1

        Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
        Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
        Behavior on rotation { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }

        Image {
            anchors.fill: parent
            source: "dog_card_back.png"
            sourceSize.width: parent.width * 2
            sourceSize.height: parent.height * 2
            smooth: true
            mipmap: true
            fillMode: Image.Stretch
        }
    }

    // Middle Card
    Rectangle {
        x: (root.flipped || root.hovered) ? 0 : 3
        y: (root.flipped || root.hovered) ? -4 : -3
        width: parent.width; height: parent.height
        color: "transparent"
        rotation: (root.flipped || root.hovered) ? -2 : 0
        z: 2

        Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
        Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
        Behavior on rotation { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }

        Image {
            anchors.fill: parent
            source: "dog_card_back.png"
            sourceSize.width: parent.width * 2
            sourceSize.height: parent.height * 2
            smooth: true
            mipmap: true
            fillMode: Image.Stretch
        }
    }

    // Top Card (Flips in 3D to show App Info)
    Rectangle {
        id: topCard
        x: (root.flipped || root.hovered) ? 24 : 6
        y: (root.flipped || root.hovered) ? -10 : -6
        width: parent.width; height: parent.height
        color: "transparent"
        rotation: (root.flipped || root.hovered) ? 10 : 0
        z: 3

        Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
        Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
        Behavior on rotation { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }

        transform: [
            Rotation {
                id: flipRotation
                origin.x: topCard.width / 2
                origin.y: topCard.height / 2
                axis { x: 0; y: 1; z: 0 } // Rotate on Y-axis
                angle: root.flipped ? 180 : 0

                Behavior on angle {
                    NumberAnimation {
                        duration: 450
                        easing.type: Easing.OutQuad
                    }
                }
            }
        ]

        // ── Card Back (visible during rotation back-facing) ──
        Image {
            anchors.fill: parent
            visible: flipRotation.angle <= 90
            source: "dog_card_back.png"
            sourceSize.width: parent.width * 2
            sourceSize.height: parent.height * 2
            smooth: true
            mipmap: true
            fillMode: Image.Stretch
        }

        // ── Card Front (visible when flipped over) ──
        Rectangle {
            id: frontFace
            anchors.fill: parent
            visible: flipRotation.angle > 90
            color: "#ffffff"
            radius: 8
            border.width: 1.5
            border.color: "#222222"

            // Combines mirror-back, hover 360-spin, and dynamic mouse tracking tilt
            transform: [
                Rotation {
                    origin.x: frontFace.width / 2
                    origin.y: frontFace.height / 2
                    axis { x: 0; y: 1; z: 0 }
                    angle: 180
                },
                Rotation {
                    origin.x: frontFace.width / 2
                    origin.y: frontFace.height / 2
                    axis { x: 0; y: 1; z: 0 }
                    angle: root.hoverSpin
                },
                Rotation {
                    origin.x: frontFace.width / 2
                    origin.y: frontFace.height / 2
                    axis { x: 1; y: 0; z: 0 }
                    angle: root.tiltX
                },
                Rotation {
                    origin.x: frontFace.width / 2
                    origin.y: frontFace.height / 2
                    axis { x: 0; y: 1; z: 0 }
                    angle: root.tiltY
                }
            ]

            // Inner border
            Rectangle {
                anchors.fill: parent
                anchors.margins: 6
                color: "transparent"
                radius: 6
                border.width: 1
                border.color: "#e5e7eb"
            }

            // Top-left marker (App Initials)
            Text {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 10
                text: root.appName ? root.appName.charAt(0).toUpperCase() : ""
                color: "#111111"
                font.family: Tui.ThemeTokens.fontFamily
                font.pixelSize: 15
                font.weight: Font.Bold
            }

            // Bottom-right marker (App Initials, inverted)
            Text {
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.margins: 10
                rotation: 180
                text: root.appName ? root.appName.charAt(0).toUpperCase() : ""
                color: "#111111"
                font.family: Tui.ThemeTokens.fontFamily
                font.pixelSize: 15
                font.weight: Font.Bold
            }

            // Center details
            Column {
                anchors.centerIn: parent
                spacing: 8
                width: parent.width - 16

                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 44
                    height: 44
                    source: root.appIcon
                    sourceSize.width: width
                    sourceSize.height: height
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                    visible: source.toString().length > 0 && status !== Image.Error
                }

                // Fallback glyph if no icon exists
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: root.appIcon.toString().length === 0
                    text: "✦"
                    color: Tui.ThemeTokens.accent
                    font.family: Tui.ThemeTokens.fontFamily
                    font.pixelSize: 32
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.appName
                    color: "#111111"
                    font.family: Tui.ThemeTokens.fontFamily
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            // Interactive mouse area for front card hover, triggers Y-axis coin spin
            MouseArea {
                id: frontPointer
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    if (root.flipped && !spinAnimation.running) {
                        spinAnimation.start();
                    }
                }
            }
        }
    }
}
