import QtQuick
import ".." as Tui

Item {
    id: sigil

    property bool active: true
    property real phase: 0

    implicitWidth: 56
    implicitHeight: 56

    NumberAnimation on phase {
        from: 0
        to: 360
        duration: 18000
        loops: Animation.Infinite
        running: sigil.active && sigil.visible
    }

    Canvas {
        id: glyph
        anchors.fill: parent
        rotation: sigil.phase
        opacity: 0.9

        onPaint: {
            const context = getContext("2d");
            const centerX = width / 2;
            const centerY = height / 2;
            const outerRadius = Math.min(width, height) * 0.43;
            const innerRadius = outerRadius * 0.55;

            context.clearRect(0, 0, width, height);
            context.lineCap = "round";
            context.strokeStyle = Tui.ThemeTokens.accent.toString();
            context.lineWidth = 1.2;

            context.beginPath();
            context.arc(centerX, centerY, outerRadius, 0, Math.PI * 2);
            context.stroke();

            context.globalAlpha = 0.55;
            context.beginPath();
            context.arc(centerX, centerY, innerRadius, 0, Math.PI * 2);
            context.stroke();

            context.globalAlpha = 0.8;
            for (let index = 0; index < 8; index++) {
                const angle = index * Math.PI / 4;
                const start = outerRadius + 2;
                const end = outerRadius + (index % 2 === 0 ? 7 : 5);
                context.beginPath();
                context.moveTo(centerX + Math.cos(angle) * start, centerY + Math.sin(angle) * start);
                context.lineTo(centerX + Math.cos(angle) * end, centerY + Math.sin(angle) * end);
                context.stroke();
            }

            context.globalAlpha = 0.72;
            context.beginPath();
            for (let index = 0; index < 3; index++) {
                const angle = -Math.PI / 2 + index * Math.PI * 2 / 3;
                const x = centerX + Math.cos(angle) * innerRadius;
                const y = centerY + Math.sin(angle) * innerRadius;
                if (index === 0) context.moveTo(x, y);
                else context.lineTo(x, y);
            }
            context.closePath();
            context.stroke();

            context.globalAlpha = 1;
            context.save();
            context.translate(centerX, centerY);
            context.rotate(Math.PI / 4);
            context.strokeRect(-4, -4, 8, 8);
            context.restore();
        }

        Connections {
            target: Tui.ThemeTokens
            function onAccentChanged() { glyph.requestPaint(); }
        }

        Component.onCompleted: requestPaint()
    }

    Rectangle {
        anchors.centerIn: parent
        width: 5
        height: 5
        rotation: 45
        color: Tui.ThemeTokens.accent
    }
}
