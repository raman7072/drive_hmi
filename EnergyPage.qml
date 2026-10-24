import QtQuick

Item {
    id: ep
    width: 1120; height: 520

    // ----- battery -----
    Rectangle {
        x: 20; y: 14; width: 300; height: 492; radius: 26; color: Theme.panel2; border.color: Theme.line
        Rectangle {
            id: shell
            x: 90; y: 40; width: 120; height: 250; radius: 24
            color: "transparent"; border.color: Theme.dim; border.width: 3
            Rectangle { x: 40; y: -12; width: 40; height: 12; radius: 4; color: Theme.dim }
            Rectangle {
                id: fill
                anchors.bottom: parent.bottom; anchors.bottomMargin: 6; anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 12; radius: 18
                height: (parent.height - 12) * Vehicle.battery / 100
                Behavior on height { NumberAnimation { duration: 400 } }
                gradient: Gradient {
                    GradientStop { position: 0; color: Vehicle.battery < 20 ? Theme.danger : Theme.ok }
                    GradientStop { position: 1; color: Theme.alpha(Vehicle.battery < 20 ? Theme.danger : Theme.ok, 0.45) }
                }
                SequentialAnimation on opacity {
                    running: Vehicle.charging; loops: Animation.Infinite
                    NumberAnimation { to: 0.5; duration: 800 } NumberAnimation { to: 1; duration: 800 }
                }
                Rectangle {   // shimmer
                    width: parent.width; height: 26; radius: 12; color: "white"; opacity: 0.18
                    visible: Vehicle.charging
                    SequentialAnimation on y { running: Vehicle.charging; loops: Animation.Infinite
                        NumberAnimation { from: fill.height; to: -26; duration: 1400; easing.type: Easing.InOutSine } }
                }
            }
            Text { anchors.centerIn: parent; text: Math.round(Vehicle.battery) + "%"; font.pixelSize: 44; font.bold: true; color: "white" }
            // charge limit marker
            Rectangle { x: -10; width: parent.width + 20; height: 3; color: Theme.warn
                y: parent.height - 6 - (parent.height - 12) * Vehicle.chargeLimit / 100 }
        }
        Text { x: 0; y: 310; width: parent.width; horizontalAlignment: Text.AlignHCenter; text: Math.round(Vehicle.rangeKm * Vehicle.unitK) + " " + Vehicle.distUnit; font.pixelSize: 44; color: Theme.text; font.weight: Font.Light }
        Text { x: 0; y: 366; width: parent.width; horizontalAlignment: Text.AlignHCenter; text: "estimated range"; font.pixelSize: 15; color: Theme.dim }
        Btn { x: 30; y: 410; width: 240; height: 64; fontSize: 20
              glyph: Theme.g.energy; text: Vehicle.charging ? "Stop charging" : "Start charging"
              active: Vehicle.charging; tint: Theme.ok; onClicked: Vehicle.toggleCharging() }
    }

    // ----- power chart -----
    Rectangle {
        x: 340; y: 14; width: 440; height: 300; radius: 26; color: Theme.panel2; border.color: Theme.line
        Text { x: 20; y: 12; text: "POWER  (kW)"; color: Theme.dim; font.pixelSize: 13; font.letterSpacing: 2 }
        Text { anchors.right: parent.right; anchors.rightMargin: 20; y: 8; text: Math.round(Vehicle.power) + " kW"; color: Vehicle.power < 0 ? Theme.ok : Theme.ambient; font.pixelSize: 24 }
        Canvas {
            id: chart
            x: 16; y: 48; width: parent.width - 32; height: parent.height - 64
            property var hist: Vehicle.powerHist
            onHistChanged: requestPaint()
            onPaint: {
                var ctx = getContext("2d"); ctx.reset()
                var w = width, h = height
                var maxP = 160, minP = -60
                function Y(p) { return h - (p - minP) / (maxP - minP) * h }
                ctx.strokeStyle = Theme.css(Theme.line, 1); ctx.lineWidth = 1
                ctx.beginPath(); ctx.moveTo(0, Y(0)); ctx.lineTo(w, Y(0)); ctx.stroke()
                var d = hist
                if (!d || d.length < 2) return
                var step = w / 79
                var x0 = w - (d.length - 1) * step
                var g = ctx.createLinearGradient(0, 0, 0, h)
                g.addColorStop(0, Theme.css(Theme.ambient, 0.35)); g.addColorStop(1, Theme.css(Theme.ambient, 0))
                ctx.beginPath(); ctx.moveTo(x0, Y(0))
                for (var i = 0; i < d.length; i++) ctx.lineTo(x0 + i * step, Y(Math.max(-60, Math.min(160, d[i]))))
                ctx.lineTo(w, Y(0)); ctx.closePath(); ctx.fillStyle = g; ctx.fill()
                ctx.lineWidth = 3; ctx.lineJoin = "round"; ctx.strokeStyle = Theme.css(Theme.ambient, 1)
                ctx.shadowColor = Theme.css(Theme.ambient, 0.9); ctx.shadowBlur = 10
                ctx.beginPath()
                for (var j = 0; j < d.length; j++) {
                    var px = x0 + j * step, py = Y(Math.max(-60, Math.min(160, d[j])))
                    if (j === 0) ctx.moveTo(px, py); else ctx.lineTo(px, py)
                }
                ctx.stroke()
            }
        }
    }

    // ----- stat cards -----
    Row {
        x: 340; y: 326; spacing: 12
        Rectangle { width: 138; height: 90; radius: 20; color: Theme.panel2; border.color: Theme.line
            Column { anchors.centerIn: parent; Text { anchors.horizontalCenter: parent.horizontalCenter; text: (Vehicle.power / Math.max(20, Vehicle.speed) * 100).toFixed(1); color: Theme.text; font.pixelSize: 26 }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: "kWh/100 " + Vehicle.distUnit; color: Theme.dim; font.pixelSize: 12 } } }
        Rectangle { width: 138; height: 90; radius: 20; color: Theme.panel2; border.color: Theme.line
            Column { anchors.centerIn: parent; Text { anchors.horizontalCenter: parent.horizontalCenter; text: Vehicle.charging ? Math.round(Vehicle.chargePower) + " kW" : "\u2014"; color: Vehicle.charging ? Theme.ok : Theme.dim; font.pixelSize: 26 }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: "charging power"; color: Theme.dim; font.pixelSize: 12 } } }
        Rectangle { width: 138; height: 90; radius: 20; color: Theme.panel2; border.color: Theme.line
            Column { anchors.centerIn: parent; Text { anchors.horizontalCenter: parent.horizontalCenter; text: Math.round(Vehicle.ecoScore); color: Vehicle.ecoScore > 70 ? Theme.ok : Theme.warn; font.pixelSize: 26 }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: "eco score"; color: Theme.dim; font.pixelSize: 12 } } }
    }
    Rectangle {
        x: 340; y: 428; width: 440; height: 78; radius: 20; color: Theme.panel2; border.color: Theme.line
        Row { anchors.centerIn: parent; spacing: 22
            Column { Text { text: (Vehicle.trip * Vehicle.unitK).toFixed(1) + " " + Vehicle.distUnit; color: Theme.text; font.pixelSize: 22 } Text { text: "trip"; color: Theme.dim; font.pixelSize: 12 } }
            Column { Text { text: Math.round(Vehicle.odometer * Vehicle.unitK) + " " + Vehicle.distUnit; color: Theme.text; font.pixelSize: 22 } Text { text: "total"; color: Theme.dim; font.pixelSize: 12 } }
            Btn { width: 120; height: 46; fontSize: 15; text: "Reset trip"; onClicked: Vehicle.trip = 0 }
        }
    }

    // ----- settings column -----
    Rectangle {
        x: 800; y: 14; width: 300; height: 492; radius: 26; color: Theme.panel2; border.color: Theme.line
        Text { x: 20; y: 14; text: "CHARGING & REGEN"; color: Theme.dim; font.pixelSize: 13; font.letterSpacing: 2 }
        Text { x: 20; y: 52; text: "Charge limit  " + Math.round(Vehicle.chargeLimit) + "%"; color: Theme.text; font.pixelSize: 18 }
        Slide { x: 16; y: 84; width: 268; from: 50; to: 100; value: Vehicle.chargeLimit; tint: Theme.warn; onMoved: (val) => Vehicle.chargeLimit = Math.round(val / 5) * 5 }
        Text { x: 20; y: 144; text: "Brake energy regeneration"; color: Theme.text; font.pixelSize: 18 }
        Row { x: 16; y: 176; spacing: 8
            Repeater { model: ["Low", "Std", "High"]
                Btn { width: 84; height: 52; fontSize: 17; text: modelData; active: Vehicle.regen === index; tint: Theme.ok; onClicked: Vehicle.regen = index } } }
        Text { x: 20; y: 252; text: "Pre-conditioning"; color: Theme.text; font.pixelSize: 18 }
        Toggle { x: 206; y: 244; checked: Vehicle.preconditioning; onToggled: (val) => Vehicle.preconditioning = val }
        Text { x: 20; y: 312; text: "Eco tips"; color: Theme.dim; font.pixelSize: 13; font.letterSpacing: 2 }
        Text { x: 20; y: 340; width: 260; wrapMode: Text.Wrap; color: Theme.text; font.pixelSize: 16
               text: Vehicle.speed > 110 ? "Reduce speed to increase range." : (Vehicle.power < 0 ? "Great! Recovering energy." : "Anticipate traffic and coast to recover energy.") }
    }
}
