import QtQuick

Item {
    id: cl
    implicitWidth: 720; implicitHeight: 680

    Glow { anchors.centerIn: ring; width: ring.width * 1.5; height: width; color: Theme.ambient; strength: 0.20 }

    // ---------- top row: gear selector ----------
    Row {
        anchors.left: parent.left; anchors.leftMargin: Math.max(16, cl.width * 0.035)
        y: 20; spacing: 8
        Repeater {
            model: ["P", "R", "N", "D"]
            Rectangle {
                width: 36; height: 36; radius: 10
                color: Vehicle.gear === modelData ? Theme.alpha(Theme.ambient, 0.22) : "transparent"
                border.color: Vehicle.gear === modelData ? Theme.ambient : "transparent"
                border.width: 1
                Text {
                    anchors.centerIn: parent
                    text: modelData
                    font.pixelSize: 20
                    font.weight: Vehicle.gear === modelData ? Font.Bold : Font.Normal
                    color: Vehicle.gear === modelData ? Theme.ambient : Theme.dim
                    Behavior on color { ColorAnimation { duration: 200 } }
                }
                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }
    }
    Text {
        visible: Vehicle.callState === "idle"
        anchors.horizontalCenter: parent.horizontalCenter
        y: 22
        text: Vehicle.driveMode.toUpperCase()
        font.pixelSize: 18; font.letterSpacing: 4
        color: Theme.ambient
    }
    Rectangle {
        visible: Vehicle.callState !== "idle"
        anchors.horizontalCenter: parent.horizontalCenter
        y: 14; height: 38; width: callTxt.width + 40; radius: 19
        color: Theme.alpha(Theme.ok, 0.22); border.color: Theme.ok
        Text {
            id: callTxt
            anchors.centerIn: parent
            text: "\u2706  " + Vehicle.callName + (Vehicle.callState === "active" ? "  " + Vehicle.fmt(Vehicle.callSecs)
                  : (Vehicle.callState === "incoming" ? "  incoming\u2026" : "  calling\u2026"))
            color: Theme.ok; font.pixelSize: 17
        }
    }
    Text {
        anchors.right: parent.right; anchors.rightMargin: Math.max(16, cl.width * 0.035)
        y: 18
        text: Vehicle.timeText
        font.pixelSize: 26; color: Theme.text
    }

    // ---------- ring ----------
    SpeedRing {
        id: ring
        anchors.horizontalCenter: parent.horizontalCenter
        y: cl.height > 580 ? 50 : (cl.height > 420 ? 30 : 15)
        width: Math.min(cl.width - (cl.width > 540 ? 180 : 40), cl.height - (cl.height > 550 ? 210 : 120), 440)
        height: width
    }

    // ---------- turn signals ----------
    Text {
        x: Math.max(16, ring.x - 56)
        y: ring.y + ring.height * 0.12
        text: "\u2B05"; font.pixelSize: Math.round(Math.min(54, cl.width * 0.08))
        color: Theme.ok
        opacity: (Vehicle.leftSignal || Vehicle.hazard) ? (Vehicle.blink ? 1 : 0.10) : 0.06
        Behavior on opacity { NumberAnimation { duration: 80 } }
        layer.enabled: (Vehicle.leftSignal || Vehicle.hazard) && Vehicle.blink
    }
    Text {
        x: Math.min(parent.width - 56, ring.x + ring.width + 12)
        y: ring.y + ring.height * 0.12
        text: "\u27A1"; font.pixelSize: Math.round(Math.min(54, cl.width * 0.08))
        color: Theme.ok
        opacity: (Vehicle.rightSignal || Vehicle.hazard) ? (Vehicle.blink ? 1 : 0.10) : 0.06
        Behavior on opacity { NumberAnimation { duration: 80 } }
        layer.enabled: (Vehicle.rightSignal || Vehicle.hazard) && Vehicle.blink
    }

    // ---------- speed limit ----------
    Rectangle {
        visible: Vehicle.speedInfo && cl.width >= 420
        x: Math.min(parent.width - 80, ring.x + ring.width + 10)
        y: ring.y + ring.height * 0.28
        width: 68; height: 68; radius: 34
        color: "white"; border.width: 6; border.color: "#e0231b"
        opacity: ring.over && blinkSign.on ? 0.35 : 1
        Text { anchors.centerIn: parent; text: Vehicle.speedLimit * 1; font.pixelSize: 26; font.bold: true; color: "#111" }
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }
    QtObject { id: blinkSign; property bool on: false }
    Timer { interval: 400; repeat: true; running: ring.over; onTriggered: blinkSign.on = !blinkSign.on; onRunningChanged: blinkSign.on = false }

    // ---------- ACC chip ----------
    Rectangle {
        visible: Vehicle.acc && cl.width >= 420
        x: Math.max(16, ring.x - 76)
        y: ring.y + ring.height * 0.28
        width: 68; height: 56; radius: Theme.radiusSm
        color: Theme.alpha(Theme.ok, 0.15); border.color: Theme.ok; border.width: 1
        Column {
            anchors.centerIn: parent; spacing: 2
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: "ACC"; color: Theme.ok; font.pixelSize: 12; font.weight: Font.Bold; font.letterSpacing: 1.5 }
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: Math.round(Vehicle.cruiseSpeed * Vehicle.unitK); color: Theme.text; font.pixelSize: 20; font.weight: Font.Medium }
        }
    }

    // ---------- left column ----------
    Column {
        anchors.left: parent.left; anchors.leftMargin: Math.max(16, cl.width * 0.035)
        y: Math.min(cl.height * 0.44, ring.y + ring.height * 0.46)
        spacing: 12; width: 110
        visible: cl.width >= 440
        Column {
            Text { text: "OUTSIDE"; color: Theme.dim; font.pixelSize: 11; font.letterSpacing: 2 }
            Text { text: Vehicle.outsideTemp.toFixed(1) + "\u00B0C"; color: Theme.text; font.pixelSize: 24 }
        }
        Column {
            Text { text: "TRIP"; color: Theme.dim; font.pixelSize: 11; font.letterSpacing: 2 }
            Text { text: (Vehicle.trip * Vehicle.unitK).toFixed(1) + " " + Vehicle.distUnit; color: Theme.text; font.pixelSize: 20 }
        }
        Column {
            Text { text: "ODOMETER"; color: Theme.dim; font.pixelSize: 11; font.letterSpacing: 2 }
            Text { text: Math.round(Vehicle.odometer * Vehicle.unitK) + " " + Vehicle.distUnit; color: Theme.text; font.pixelSize: 16 }
        }
    }

    // ---------- right column: battery ----------
    Item {
        anchors.right: parent.right; anchors.rightMargin: Math.max(16, cl.width * 0.035)
        y: Math.min(cl.height * 0.44, ring.y + ring.height * 0.46)
        width: 110; height: 190
        visible: cl.width >= 440
        Rectangle {
            id: batBar
            x: 64; y: 0; width: 24; height: 150; radius: 8
            color: Theme.panel2; border.color: Theme.line
            Rectangle {
                anchors.bottom: parent.bottom; anchors.bottomMargin: 3
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 6; radius: 6
                height: (parent.height - 6) * Vehicle.battery / 100
                color: Vehicle.battery < 15 ? Theme.danger : (Vehicle.battery < 30 ? Theme.warn : Theme.ok)
                Behavior on height { NumberAnimation { duration: 300 } }
                SequentialAnimation on opacity {
                    running: Vehicle.charging; loops: Animation.Infinite
                    NumberAnimation { to: 0.45; duration: 700 } NumberAnimation { to: 1; duration: 700 }
                }
            }
        }
        Text { x: 0; y: 0; width: 58; horizontalAlignment: Text.AlignRight; text: Math.round(Vehicle.battery) + "%"; color: Theme.text; font.pixelSize: 22 }
        Text { x: 0; y: 30; width: 58; horizontalAlignment: Text.AlignRight; text: Math.round(Vehicle.rangeKm * Vehicle.unitK) + "\n" + Vehicle.distUnit; color: Theme.dim; font.pixelSize: 13; lineHeight: 0.9 }
        Text { x: 0; y: 160; width: 92; horizontalAlignment: Text.AlignRight; text: Vehicle.charging ? "\u26A1\uFE0E CHARGING" : "RANGE"; color: Vehicle.charging ? Theme.ok : Theme.dim; font.pixelSize: 10; font.letterSpacing: 2 }
    }

    // ---------- ADAS road view ----------
    Canvas {
        id: road
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: telltalesRow.top
        anchors.bottomMargin: 8
        width: Math.min(cl.width - 32, 520)
        height: Math.max(65, Math.min(145, cl.height - ring.y - ring.height - 55))
        visible: height >= 65 && cl.height >= 380
        property real phase: 0
        FrameAnimation {
            running: App.awake && Vehicle.speed > 0.5
            onTriggered: { road.phase = (road.phase + Vehicle.speed * 0.012 * frameTime) % 1; road.requestPaint() }
        }
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            var w = width, h = height, hz = 4
            function X(l, t) { return w / 2 + l * w * 0.30 * (0.12 + 0.88 * t) }
            function Y(t) { return hz + (h - hz) * t }

            var g = ctx.createLinearGradient(0, 0, 0, h)
            g.addColorStop(0, Theme.css(Theme.ambient, 0))
            g.addColorStop(1, Theme.css(Theme.ambient, 0.18))
            ctx.fillStyle = g
            ctx.beginPath()
            ctx.moveTo(X(-1.5, 0), Y(0)); ctx.lineTo(X(1.5, 0), Y(0))
            ctx.lineTo(X(1.5, 1), Y(1)); ctx.lineTo(X(-1.5, 1), Y(1))
            ctx.closePath(); ctx.fill()

            var edge = Vehicle.laneAssist ? Theme.ok : Theme.dim
            var edges = [-1.5, 1.5]
            for (var e = 0; e < 2; e++) {
                ctx.lineWidth = 3
                ctx.strokeStyle = Theme.css(edge, 0.85)
                ctx.beginPath(); ctx.moveTo(X(edges[e], 0), Y(0)); ctx.lineTo(X(edges[e], 1), Y(1)); ctx.stroke()
            }
            var N = 9
            var dl = [-0.5, 0.5]
            for (var d = 0; d < 2; d++) {
                for (var k = 0; k < N; k++) {
                    var z0 = ((k + road.phase) % N) / N
                    var z1 = z0 + 0.045
                    var t0 = z0 * z0, t1 = Math.min(1, z1 * z1)
                    ctx.lineWidth = 1 + 4 * t0
                    ctx.strokeStyle = Theme.css(Theme.text, 0.15 + 0.7 * t0)
                    ctx.beginPath(); ctx.moveTo(X(dl[d], t0), Y(t0)); ctx.lineTo(X(dl[d], t1), Y(t1)); ctx.stroke()
                }
            }

            // lead vehicle
            if (Vehicle.speed > 5 && (Vehicle.acc || Vehicle.collisionWarn)) {
                var t = 1 - Vehicle.leadGap * 0.9
                var sc = 0.25 + 0.75 * Math.pow(t, 1.2)
                var lw = 64 * sc, lh = 36 * sc
                var lx = X(0, t) - lw / 2, ly = Y(t) - lh
                var alertOn = Vehicle.collisionAlert
                ctx.fillStyle = alertOn ? Theme.css(Theme.danger, 0.9) : Theme.css(Theme.dim, 0.9)
                ctx.beginPath(); ctx.roundedRect(lx, ly, lw, lh, 6 * sc, 6 * sc); ctx.fill()
                ctx.fillStyle = Theme.css(Theme.danger, 0.95)
                ctx.fillRect(lx + 3 * sc, ly + lh - 8 * sc, 12 * sc, 5 * sc)
                ctx.fillRect(lx + lw - 15 * sc, ly + lh - 8 * sc, 12 * sc, 5 * sc)
            }

            // ego vehicle
            var cw = 64, ch = 38, cx = w / 2 - cw / 2, cy = h - ch - 4
            var cg = ctx.createLinearGradient(cx, cy, cx, cy + ch)
            cg.addColorStop(0, Theme.css(Theme.ambient, 1))
            cg.addColorStop(1, Theme.css(Theme.ambient, 0.35))
            ctx.fillStyle = cg
            ctx.beginPath(); ctx.roundedRect(cx, cy, cw, ch, 9, 9); ctx.fill()
            ctx.fillStyle = Vehicle.brake > 0.1 ? "#ff2a2a" : "#a01818"
            ctx.fillRect(cx + 5, cy + ch - 10, 14, 5)
            ctx.fillRect(cx + cw - 19, cy + ch - 10, 14, 5)
            ctx.fillStyle = Theme.css(Theme.bg, 0.55)
            ctx.beginPath(); ctx.roundedRect(cx + 10, cy + 6, cw - 20, 12, 4, 4); ctx.fill()

            // blind-spot hints
            if (Vehicle.blindSpot && Vehicle.speed > 30 && Math.sin(Vehicle.leadPhase * 0.7) > 0.93) {
                ctx.fillStyle = Theme.css(Theme.warn, 0.7)
                ctx.fillRect(X(-1.5, 0.9) - 6, Y(0.55), 6, 50)
            }
        }
    }

    // ---------- telltales ----------
    Row {
        id: telltalesRow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom; anchors.bottomMargin: 14
        spacing: Math.min(20, Math.max(6, (cl.width - 240) / 7))
        Repeater {
            model: [
                { g: "\u25D0", active: Vehicle.lowBeamOn,  col: Theme.ok },
                { g: "\u25D1", active: Vehicle.highBeam,   col: "#4aa3ff" },
                { g: "\u2263", active: Vehicle.fogLight,   col: Theme.ok },
                { g: "\u26A0", active: Vehicle.hazard && Vehicle.blink, col: Theme.danger },
                { g: "\u26BF", active: !Vehicle.locked,    col: Theme.warn },
                { g: "\u2B58", active: Vehicle.alerts[0] !== "All systems OK", col: Theme.warn },
                { g: "\u25CB", active: (Vehicle.tires[0] < 2.0 || Vehicle.tires[1] < 2.0 || Vehicle.tires[2] < 2.0 || Vehicle.tires[3] < 2.0), col: Theme.warn }
            ]
            Text {
                required property var modelData
                text: modelData.g; font.pixelSize: Math.round(Math.min(22, cl.width * 0.04))
                color: modelData.active ? modelData.col : Theme.line
                opacity: modelData.active ? 1 : 0.4
                Behavior on color { ColorAnimation { duration: 200 } }
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
        }
    }
}
