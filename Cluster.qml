import QtQuick

Item {
    id: cl
    width: 720; height: 680

    Glow { anchors.centerIn: ring; width: 720; height: 720; color: Theme.ambient; strength: 0.20 }

    // ---------- top row ----------
    Row {
        x: 30; y: 20; spacing: 16
        Repeater {
            model: ["P", "R", "N", "D"]
            Text {
                text: modelData
                font.pixelSize: 26
                font.bold: Vehicle.gear === modelData
                color: Vehicle.gear === modelData ? Theme.ambient : Theme.dim
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
        anchors.right: parent.right; anchors.rightMargin: 30
        y: 18
        text: Vehicle.timeText
        font.pixelSize: 28; color: Theme.text
    }

    // ---------- turn signals ----------
    Text {
        x: 44; y: 74; text: "\u2B05"; font.pixelSize: 52
        color: Theme.ok
        opacity: (Vehicle.leftSignal || Vehicle.hazard) ? (Vehicle.blink ? 1 : 0.12) : 0.07
    }
    Text {
        x: 624; y: 74; text: "\u27A1"; font.pixelSize: 52
        color: Theme.ok
        opacity: (Vehicle.rightSignal || Vehicle.hazard) ? (Vehicle.blink ? 1 : 0.12) : 0.07
    }

    // ---------- ring ----------
    SpeedRing { id: ring; x: 140; y: 50 }

    // ---------- speed limit ----------
    Rectangle {
        visible: Vehicle.speedInfo
        x: 568; y: 118; width: 76; height: 76; radius: 38
        color: "white"; border.width: 7; border.color: "#e0231b"
        opacity: ring.over && blinkSign.on ? 0.35 : 1
        Text { anchors.centerIn: parent; text: Vehicle.speedLimit * 1; font.pixelSize: 30; font.bold: true; color: "#111" }
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }
    QtObject { id: blinkSign; property bool on: false }
    Timer { interval: 400; repeat: true; running: ring.over; onTriggered: blinkSign.on = !blinkSign.on; onRunningChanged: blinkSign.on = false }

    // ---------- ACC chip ----------
    Rectangle {
        visible: Vehicle.acc
        x: 74; y: 130; width: 70; height: 56; radius: 14
        color: Theme.alpha(Theme.ok, 0.18); border.color: Theme.ok
        Column {
            anchors.centerIn: parent
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: "ACC"; color: Theme.ok; font.pixelSize: 14; font.bold: true }
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: Math.round(Vehicle.cruiseSpeed * Vehicle.unitK); color: Theme.text; font.pixelSize: 20 }
        }
    }

    // ---------- left column ----------
    Column {
        x: 22; y: 260; spacing: 14; width: 120
        Column {
            Text { text: "OUTSIDE"; color: Theme.dim; font.pixelSize: 12; font.letterSpacing: 2 }
            Text { text: Vehicle.outsideTemp.toFixed(1) + "\u00B0C"; color: Theme.text; font.pixelSize: 26 }
        }
        Column {
            Text { text: "TRIP"; color: Theme.dim; font.pixelSize: 12; font.letterSpacing: 2 }
            Text { text: (Vehicle.trip * Vehicle.unitK).toFixed(1) + " " + Vehicle.distUnit; color: Theme.text; font.pixelSize: 22 }
        }
        Column {
            Text { text: "ODOMETER"; color: Theme.dim; font.pixelSize: 12; font.letterSpacing: 2 }
            Text { text: Math.round(Vehicle.odometer * Vehicle.unitK) + " " + Vehicle.distUnit; color: Theme.text; font.pixelSize: 18 }
        }
    }

    // ---------- right column: battery ----------
    Item {
        x: 598; y: 260; width: 110; height: 200
        Rectangle {
            id: batBar
            x: 62; y: 0; width: 26; height: 170; radius: 8
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
        Text { x: 0; y: 0; width: 56; horizontalAlignment: Text.AlignRight; text: Math.round(Vehicle.battery) + "%"; color: Theme.text; font.pixelSize: 24 }
        Text { x: 0; y: 34; width: 56; horizontalAlignment: Text.AlignRight; text: Math.round(Vehicle.rangeKm * Vehicle.unitK) + "\n" + Vehicle.distUnit; color: Theme.dim; font.pixelSize: 14; lineHeight: 0.9 }
        Text { x: 0; y: 180; width: 90; horizontalAlignment: Text.AlignRight; text: Vehicle.charging ? "\u26A1\uFE0E CHARGING" : "RANGE"; color: Vehicle.charging ? Theme.ok : Theme.dim; font.pixelSize: 11; font.letterSpacing: 2 }
    }

    // ---------- ADAS road view ----------
    Canvas {
        id: road
        x: 110; y: 495; width: 500; height: 145
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
        anchors.horizontalCenter: parent.horizontalCenter
        y: 648; spacing: 22
        Text { text: "\u25D0"; font.pixelSize: 22; color: Vehicle.lowBeamOn ? Theme.ok : Theme.line }
        Text { text: "\u25D1"; font.pixelSize: 22; color: Vehicle.highBeam ? "#4aa3ff" : Theme.line }
        Text { text: "\u2263"; font.pixelSize: 22; color: Vehicle.fogLight ? Theme.ok : Theme.line }
        Text { text: "\u26A0"; font.pixelSize: 22; color: Vehicle.hazard ? (Vehicle.blink ? Theme.danger : Theme.line) : Theme.line }
        Text { text: "\u26BF"; font.pixelSize: 22; color: Vehicle.locked ? Theme.dim : Theme.warn }
        Text { text: "\u2B58"; font.pixelSize: 22; color: Vehicle.alerts[0] === "All systems OK" ? Theme.line : Theme.warn }
        Text { text: "\u25CB"; font.pixelSize: 22; color: (Vehicle.tires[0] < 2.0 || Vehicle.tires[1] < 2.0 || Vehicle.tires[2] < 2.0 || Vehicle.tires[3] < 2.0) ? Theme.warn : Theme.line }
    }
}
