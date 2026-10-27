import QtQuick
import QtQuick.Shapes

Item {
    id: r
    implicitWidth: 440; implicitHeight: 440

    readonly property real sFactor: Math.min(width, height) / 440
    readonly property real cx: width / 2
    readonly property real cy: height / 2
    readonly property real rOuter: 204 * sFactor
    readonly property real rPower: 186 * sFactor

    property real shown: Math.min(1, Math.max(Vehicle.speed / Vehicle.maxSpeed, Vehicle.bootSweep))
    property real pf: Vehicle.bootSweep > 0 ? Vehicle.bootSweep * 0.7
                                            : Math.max(-1, Math.min(1, Vehicle.power / 220))
    readonly property bool over: Vehicle.speedInfo && Vehicle.speed > Vehicle.speedLimit + 5
    readonly property color arcColor: over ? Theme.danger : Theme.ambient

    // Static tracks & ticks: painted once and cached in GPU layer
    Canvas {
        id: staticBg
        anchors.fill: parent
        layer.enabled: true

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        Connections { target: Vehicle; function onUseMilesChanged() { staticBg.requestPaint() } }
        Connections { target: Theme; function onNightChanged() { staticBg.requestPaint() } }

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            var cx = r.cx, cy = r.cy, sf = r.sFactor
            var a0 = Math.PI * 0.75, span = Math.PI * 1.5
            ctx.lineCap = "round"

            // outer track
            ctx.lineWidth = Math.max(3, 12 * sf)
            ctx.strokeStyle = Theme.css(Theme.line, 1)
            ctx.beginPath(); ctx.arc(cx, cy, r.rOuter, a0, a0 + span); ctx.stroke()

            // power track
            ctx.lineWidth = Math.max(2, 5 * sf)
            ctx.strokeStyle = Theme.css(Theme.line, 1)
            ctx.beginPath(); ctx.arc(cx, cy, r.rPower, a0, a0 + span); ctx.stroke()

            // ticks + labels
            for (var i = 0; i <= 13; i++) {
                var ang = a0 + span * (i / 13)
                var major = (i % 2 === 0)
                var r1 = 168 * sf, r2 = (major ? 150 : 158) * sf
                ctx.lineWidth = Math.max(1, (major ? 3 : 2) * sf)
                ctx.strokeStyle = Theme.css(Theme.dim, major ? 0.9 : 0.45)
                ctx.beginPath()
                ctx.moveTo(cx + Math.cos(ang) * r1, cy + Math.sin(ang) * r1)
                ctx.lineTo(cx + Math.cos(ang) * r2, cy + Math.sin(ang) * r2)
                ctx.stroke()
                if (major) {
                    ctx.fillStyle = Theme.css(Theme.dim, 1)
                    ctx.font = Math.round(Math.max(9, 14 * sf)) + "px sans-serif"
                    ctx.textAlign = "center"
                    ctx.textBaseline = "middle"
                    ctx.fillText(Math.round(i * 20 * Vehicle.unitK), cx + Math.cos(ang) * 132 * sf, cy + Math.sin(ang) * 132 * sf)
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
            strokeWidth: Math.max(4, 20 * r.sFactor)
            strokeColor: Theme.alpha(r.arcColor, 0.28)
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: r.cx; centerY: r.cy
                radiusX: r.rOuter; radiusY: r.rOuter
                startAngle: 135
                sweepAngle: 270 * r.shown
            }
        }

        // Sharp arc
        ShapePath {
            strokeWidth: Math.max(3, 12 * r.sFactor)
            strokeColor: r.arcColor
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: r.cx; centerY: r.cy
                radiusX: r.rOuter; radiusY: r.rOuter
                startAngle: 135
                sweepAngle: 270 * r.shown
            }
        }
    }

    // Needle tip dot
    Rectangle {
        visible: r.shown > 0.002
        width: Math.max(6, 10 * r.sFactor); height: width; radius: width / 2
        color: "white"
        property real endRad: (135 + 270 * r.shown) * Math.PI / 180
        x: r.cx + Math.cos(endRad) * r.rOuter - width / 2
        y: r.cy + Math.sin(endRad) * r.rOuter - height / 2
    }

    // Dynamic Power / Regen arc (GPU rendered)
    Shape {
        anchors.fill: parent
        visible: Math.abs(r.pf) > 0.003

        ShapePath {
            strokeWidth: Math.max(2, 5 * r.sFactor)
            strokeColor: r.pf >= 0 ? Theme.ambient : Theme.ok
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: r.cx; centerY: r.cy
                radiusX: r.rPower; radiusY: r.rPower
                startAngle: 135
                sweepAngle: 270 * Math.abs(r.pf)
            }
        }
    }

    // digital speed
    Text {
        id: spd
        anchors.horizontalCenter: parent.horizontalCenter
        y: r.cy - (115 * r.sFactor)
        text: Math.round(Vehicle.speed * Vehicle.unitK)
        font.pixelSize: Math.round(138 * r.sFactor)
        font.weight: Font.Thin
        font.family: Theme.family
        color: r.over ? Theme.danger : Theme.text
        Behavior on color { ColorAnimation { duration: 300 } }
    }
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: r.cy + (12 * r.sFactor)
        text: Vehicle.speedUnit
        font.pixelSize: Math.round(Math.max(11, 18 * r.sFactor))
        color: Theme.dim
        font.letterSpacing: 3
        font.weight: Font.Medium
    }

    // nav turn OR power readout
    Item {
        anchors.horizontalCenter: parent.horizontalCenter
        y: r.cy + (46 * r.sFactor)
        width: 220 * r.sFactor; height: 56 * r.sFactor

        Row {
            visible: Vehicle.navActive
            anchors.centerIn: parent
            spacing: 12 * r.sFactor
            Text {
                text: Vehicle.turnDir === "left" ? "\u2B05" : (Vehicle.turnDir === "right" ? "\u27A1" : (Vehicle.turnDir === "arrive" ? "\u2691" : "\u2B06"))
                font.pixelSize: Math.round(40 * r.sFactor); color: Theme.ambient
                anchors.verticalCenter: parent.verticalCenter
            }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    text: Vehicle.turnDist >= 1000 ? (Vehicle.turnDist / 1000 * Vehicle.unitK).toFixed(1) + " " + Vehicle.distUnit
                                                   : Math.round(Vehicle.turnDist * (Vehicle.useMiles ? 3.28084 : 1) / 10) * 10 + (Vehicle.useMiles ? " ft" : " m")
                    font.pixelSize: Math.round(24 * r.sFactor); color: Theme.text
                }
                Text { text: Vehicle.turnStreet; font.pixelSize: Math.round(Math.max(9, 13 * r.sFactor)); color: Theme.dim; elide: Text.ElideRight; width: 130 * r.sFactor }
            }
        }
        Row {
            visible: !Vehicle.navActive
            anchors.centerIn: parent
            spacing: 8 * r.sFactor
            Text { text: "\u26A1\uFE0E"; font.pixelSize: Math.round(26 * r.sFactor); color: Vehicle.power < 0 ? Theme.ok : Theme.ambient; anchors.verticalCenter: parent.verticalCenter }
            Text { text: Math.round(Vehicle.power) + " kW"; font.pixelSize: Math.round(26 * r.sFactor); color: Theme.text; anchors.verticalCenter: parent.verticalCenter }
        }
    }

    // gear
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: r.cy + (112 * r.sFactor)
        text: Vehicle.gear
        font.pixelSize: Math.round(60 * r.sFactor)
        font.weight: Font.DemiBold
        color: Theme.ambient
        Behavior on color { ColorAnimation { duration: 400 } }
    }
}
