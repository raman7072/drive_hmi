import QtQuick
import QtQuick.Shapes

Item {
    id: r
    width: 440; height: 440

    property real shown: Math.min(1, Math.max(Vehicle.speed / Vehicle.maxSpeed, Vehicle.bootSweep))
    property real pf: Vehicle.bootSweep > 0 ? Vehicle.bootSweep * 0.7
                                            : Math.max(-1, Math.min(1, Vehicle.power / 220))
    readonly property bool over: Vehicle.speedInfo && Vehicle.speed > Vehicle.speedLimit + 5
    readonly property color arcColor: over ? Theme.warn : Theme.ambient

    // Static tracks & ticks: painted once and cached in GPU layer
    Canvas {
        id: staticBg
        anchors.fill: parent
        layer.enabled: true

        Connections { target: Vehicle; function onUseMilesChanged() { staticBg.requestPaint() } }
        Connections { target: Theme; function onNightChanged() { staticBg.requestPaint() } }

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            var cx = width / 2, cy = height / 2
            var a0 = Math.PI * 0.75, span = Math.PI * 1.5
            ctx.lineCap = "round"

            // outer track
            ctx.lineWidth = 12
            ctx.strokeStyle = Theme.css(Theme.line, 1)
            ctx.beginPath(); ctx.arc(cx, cy, 204, a0, a0 + span); ctx.stroke()

            // power track
            ctx.lineWidth = 5
            ctx.strokeStyle = Theme.css(Theme.line, 1)
            ctx.beginPath(); ctx.arc(cx, cy, 186, a0, a0 + span); ctx.stroke()

            // ticks + labels
            for (var i = 0; i <= 13; i++) {
                var ang = a0 + span * (i / 13)
                var major = (i % 2 === 0)
                var r1 = 168, r2 = major ? 150 : 158
                ctx.lineWidth = major ? 3 : 2
                ctx.strokeStyle = Theme.css(Theme.dim, major ? 0.9 : 0.45)
                ctx.beginPath()
                ctx.moveTo(cx + Math.cos(ang) * r1, cy + Math.sin(ang) * r1)
                ctx.lineTo(cx + Math.cos(ang) * r2, cy + Math.sin(ang) * r2)
                ctx.stroke()
                if (major) {
                    ctx.fillStyle = Theme.css(Theme.dim, 1)
                    ctx.font = "14px sans-serif"
                    ctx.textAlign = "center"
                    ctx.textBaseline = "middle"
                    ctx.fillText(Math.round(i * 20 * Vehicle.unitK), cx + Math.cos(ang) * 132, cy + Math.sin(ang) * 132)
                }
            }
        }
    }

    // Dynamic Speed Arc (GPU rendered)
    Shape {
        anchors.fill: parent
        visible: r.shown > 0.002

        // Outer glow path
        ShapePath {
            strokeWidth: 20
            strokeColor: Theme.alpha(r.arcColor, 0.28)
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: 220; centerY: 220
                radiusX: 204; radiusY: 204
                startAngle: 135
                sweepAngle: 270 * r.shown
            }
        }

        // Sharp arc
        ShapePath {
            strokeWidth: 12
            strokeColor: r.arcColor
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: 220; centerY: 220
                radiusX: 204; radiusY: 204
                startAngle: 135
                sweepAngle: 270 * r.shown
            }
        }
    }

    // Needle tip dot
    Rectangle {
        visible: r.shown > 0.002
        width: 10; height: 10; radius: 5
        color: "white"
        property real endRad: (135 + 270 * r.shown) * Math.PI / 180
        x: 220 + Math.cos(endRad) * 204 - 5
        y: 220 + Math.sin(endRad) * 204 - 5
    }

    // Dynamic Power / Regen arc (GPU rendered)
    Shape {
        anchors.fill: parent
        visible: Math.abs(r.pf) > 0.003

        ShapePath {
            strokeWidth: 5
            strokeColor: r.pf >= 0 ? Theme.ambient : Theme.ok
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: 220; centerY: 220
                radiusX: 186; radiusY: 186
                startAngle: 135
                sweepAngle: 270 * Math.abs(r.pf)
            }
        }
    }

    // digital speed
    Text {
        id: spd
        anchors.horizontalCenter: parent.horizontalCenter
        y: 58
        text: Math.round(Vehicle.speed * Vehicle.unitK)
        font.pixelSize: 132
        font.weight: Font.Light
        font.family: Theme.family
        color: r.over ? Theme.warn : Theme.text
    }
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 200
        text: Vehicle.speedUnit
        font.pixelSize: 20
        color: Theme.dim
        font.letterSpacing: 2
    }

    // nav turn OR power readout
    Item {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 240
        width: 220; height: 56

        Row {
            visible: Vehicle.navActive
            anchors.centerIn: parent
            spacing: 12
            Text {
                text: Vehicle.turnDir === "left" ? "\u2B05" : (Vehicle.turnDir === "right" ? "\u27A1" : (Vehicle.turnDir === "arrive" ? "\u2691" : "\u2B06"))
                font.pixelSize: 40; color: Theme.ambient
                anchors.verticalCenter: parent.verticalCenter
            }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    text: Vehicle.turnDist >= 1000 ? (Vehicle.turnDist / 1000 * Vehicle.unitK).toFixed(1) + " " + Vehicle.distUnit
                                                   : Math.round(Vehicle.turnDist * (Vehicle.useMiles ? 3.28084 : 1) / 10) * 10 + (Vehicle.useMiles ? " ft" : " m")
                    font.pixelSize: 24; color: Theme.text
                }
                Text { text: Vehicle.turnStreet; font.pixelSize: 13; color: Theme.dim; elide: Text.ElideRight; width: 130 }
            }
        }
        Row {
            visible: !Vehicle.navActive
            anchors.centerIn: parent
            spacing: 8
            Text { text: "\u26A1\uFE0E"; font.pixelSize: 26; color: Vehicle.power < 0 ? Theme.ok : Theme.ambient; anchors.verticalCenter: parent.verticalCenter }
            Text { text: Math.round(Vehicle.power) + " kW"; font.pixelSize: 26; color: Theme.text; anchors.verticalCenter: parent.verticalCenter }
        }
    }

    // gear
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 322
        text: Vehicle.gear
        font.pixelSize: 54
        font.weight: Font.DemiBold
        color: Theme.ambient
    }
}
