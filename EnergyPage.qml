import QtQuick

Item {
    id: ep
    width: 1120; height: 520

    // ----- battery card -----
    Rectangle {
        x: 20; y: 14; width: 300; height: 492; radius: 26
        color: Theme.glass; border.color: Theme.glassB; border.width: 1

        Rectangle {
            anchors.fill: parent; radius: parent.radius; color: "transparent"
            border.width: 1; border.color: Theme.alpha(Theme.ambient, 0.15)
        }

        // Battery outer shell
        Rectangle {
            id: shell
            x: 85; y: 38; width: 130; height: 250; radius: 26
            color: Theme.alpha("#05080f", 0.7); border.color: Theme.alpha(Theme.dim, 0.6); border.width: 3

            // Terminal cap
            Rectangle {
                x: 43; y: -12; width: 44; height: 12; radius: 4
                color: Theme.dim; border.color: Theme.alpha("white", 0.2); border.width: 1
            }

            // Liquid level fill
            Rectangle {
                id: fill
                anchors.bottom: parent.bottom; anchors.bottomMargin: 6
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 12; radius: 20
                height: Math.max(12, (parent.height - 12) * Vehicle.battery / 100)
                Behavior on height { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }

                gradient: Gradient {
                    GradientStop { position: 0; color: Vehicle.battery < 20 ? Theme.danger : Theme.ok }
                    GradientStop { position: 1; color: Theme.alpha(Vehicle.battery < 20 ? Theme.danger : Theme.ok, 0.40) }
                }

                SequentialAnimation on opacity {
                    running: Vehicle.charging; loops: Animation.Infinite
                    NumberAnimation { to: 0.6; duration: 800; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutSine }
                }

                // Shimmer glow wave when charging
                Rectangle {
                    width: parent.width; height: 26; radius: 12; color: "white"; opacity: 0.22
                    visible: Vehicle.charging
                    SequentialAnimation on y {
                        running: Vehicle.charging; loops: Animation.Infinite
                        NumberAnimation { from: fill.height; to: -26; duration: 1400; easing.type: Easing.InOutSine }
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: Math.round(Vehicle.battery) + "%"
                font.pixelSize: 44; font.weight: Font.DemiBold; color: "white"
                font.family: Theme.family
            }

            // Charge limit marker line
            Rectangle {
                x: -8; width: parent.width + 16; height: 3; color: Theme.ambient; radius: 1.5
                y: parent.height - 6 - (parent.height - 12) * Vehicle.chargeLimit / 100
            }
        }

        Text {
            x: 0; y: 310; width: parent.width; horizontalAlignment: Text.AlignHCenter
            text: Math.round(Vehicle.rangeKm * Vehicle.unitK) + " " + Vehicle.distUnit
            font.pixelSize: 42; color: Theme.text; font.weight: Font.DemiBold; font.family: Theme.family
        }
        Text {
            x: 0; y: 366; width: parent.width; horizontalAlignment: Text.AlignHCenter
            text: "estimated range"; font.pixelSize: 15; color: Theme.dim; font.family: Theme.family
        }
        Btn {
            x: 28; y: 412; width: 244; height: 62; fontSize: 19
            glyph: Theme.g.energy; text: Vehicle.charging ? "Stop charging" : "Start charging"
            active: Vehicle.charging; tint: Theme.ok; onClicked: Vehicle.toggleCharging()
        }
    }

    // ----- power chart -----
    Rectangle {
        x: 340; y: 14; width: 440; height: 300; radius: 26
        color: Theme.glass; border.color: Theme.glassB; border.width: 1

        Rectangle {
            anchors.fill: parent; radius: parent.radius; color: "transparent"
            border.width: 1; border.color: Theme.alpha("white", 0.08)
        }

        Text {
            x: 20; y: 14; text: "POWER  (kW)"
            color: Theme.dim; font.pixelSize: 12; font.letterSpacing: 2
            font.weight: Font.DemiBold; font.family: Theme.family
        }
        Text {
            anchors.right: parent.right; anchors.rightMargin: 20; y: 10
            text: Math.round(Vehicle.power) + " kW"
            color: Vehicle.power < 0 ? Theme.ok : Theme.ambient
            font.pixelSize: 24; font.weight: Font.DemiBold; font.family: Theme.family
        }

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

                // zero line
                ctx.strokeStyle = Theme.css(Theme.line, 0.8); ctx.lineWidth = 1
                ctx.beginPath(); ctx.moveTo(0, Y(0)); ctx.lineTo(w, Y(0)); ctx.stroke()

                var d = hist
                if (!d || d.length < 2) return
                var step = w / 79
                var x0 = w - (d.length - 1) * step

                // Area fill under curve
                var g = ctx.createLinearGradient(0, 0, 0, h)
                g.addColorStop(0, Theme.css(Theme.ambient, 0.35))
                g.addColorStop(1, Theme.css(Theme.ambient, 0.0))
                ctx.beginPath(); ctx.moveTo(x0, Y(0))
                for (var i = 0; i < d.length; i++) ctx.lineTo(x0 + i * step, Y(Math.max(-60, Math.min(160, d[i]))))
                ctx.lineTo(w, Y(0)); ctx.closePath(); ctx.fillStyle = g; ctx.fill()

                // Soft outer halo line (anti-aliased glow replacement without shadowBlur)
                ctx.lineWidth = 5; ctx.lineJoin = "round"; ctx.strokeStyle = Theme.css(Theme.ambient, 0.35)
                ctx.beginPath()
                for (var j = 0; j < d.length; j++) {
                    var px = x0 + j * step, py = Y(Math.max(-60, Math.min(160, d[j])))
                    if (j === 0) ctx.moveTo(px, py); else ctx.lineTo(px, py)
                }
                ctx.stroke()

                // Sharp luminous center stroke
                ctx.lineWidth = 2.5; ctx.lineJoin = "round"; ctx.strokeStyle = Theme.css(Theme.ambient, 1.0)
                ctx.beginPath()
                for (var k = 0; k < d.length; k++) {
                    var qx = x0 + k * step, qy = Y(Math.max(-60, Math.min(160, d[k])))
                    if (k === 0) ctx.moveTo(qx, qy); else ctx.lineTo(qx, qy)
                }
                ctx.stroke()
            }
        }
    }

    // ----- stat cards -----
    Row {
        x: 340; y: 326; spacing: 12
        Rectangle {
            width: 138; height: 90; radius: 20
            color: Theme.glass; border.color: Theme.glassB; border.width: 1
            Column {
                anchors.centerIn: parent; spacing: 3
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: (Vehicle.power / Math.max(20, Vehicle.speed) * 100).toFixed(1); color: Theme.text; font.pixelSize: 26; font.weight: Font.DemiBold; font.family: Theme.family }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: "kWh/100 " + Vehicle.distUnit; color: Theme.dim; font.pixelSize: 12; font.family: Theme.family }
            }
        }
        Rectangle {
            width: 138; height: 90; radius: 20
            color: Theme.glass; border.color: Theme.glassB; border.width: 1
            Column {
                anchors.centerIn: parent; spacing: 3
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: Vehicle.charging ? Math.round(Vehicle.chargePower) + " kW" : "\u2014"; color: Vehicle.charging ? Theme.ok : Theme.dim; font.pixelSize: 26; font.weight: Font.DemiBold; font.family: Theme.family }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: "charging power"; color: Theme.dim; font.pixelSize: 12; font.family: Theme.family }
            }
        }
        Rectangle {
            width: 138; height: 90; radius: 20
            color: Theme.glass; border.color: Theme.glassB; border.width: 1
            Column {
                anchors.centerIn: parent; spacing: 3
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: Math.round(Vehicle.ecoScore); color: Vehicle.ecoScore > 70 ? Theme.ok : Theme.warn; font.pixelSize: 26; font.weight: Font.DemiBold; font.family: Theme.family }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: "eco score"; color: Theme.dim; font.pixelSize: 12; font.family: Theme.family }
            }
        }
    }

    Rectangle {
        x: 340; y: 428; width: 440; height: 78; radius: 20
        color: Theme.glass; border.color: Theme.glassB; border.width: 1
        Row {
            anchors.centerIn: parent; spacing: 26
            Column {
                Text { text: (Vehicle.trip * Vehicle.unitK).toFixed(1) + " " + Vehicle.distUnit; color: Theme.text; font.pixelSize: 22; font.weight: Font.DemiBold; font.family: Theme.family }
                Text { text: "trip"; color: Theme.dim; font.pixelSize: 12; font.family: Theme.family }
            }
            Column {
                Text { text: Math.round(Vehicle.odometer * Vehicle.unitK) + " " + Vehicle.distUnit; color: Theme.text; font.pixelSize: 22; font.weight: Font.DemiBold; font.family: Theme.family }
                Text { text: "total"; color: Theme.dim; font.pixelSize: 12; font.family: Theme.family }
            }
            Btn { width: 120; height: 46; fontSize: 15; text: "Reset trip"; onClicked: Vehicle.trip = 0 }
        }
    }

    // ----- settings column -----
    Rectangle {
        x: 800; y: 14; width: 300; height: 492; radius: 26
        color: Theme.glass; border.color: Theme.glassB; border.width: 1

        Rectangle {
            anchors.fill: parent; radius: parent.radius; color: "transparent"
            border.width: 1; border.color: Theme.alpha(Theme.ambient, 0.15)
        }

        Text {
            x: 20; y: 14; text: "CHARGING & REGEN"
            color: Theme.dim; font.pixelSize: 12; font.letterSpacing: 2
            font.weight: Font.DemiBold; font.family: Theme.family
        }
        Text {
            x: 20; y: 50; text: "Charge limit  " + Math.round(Vehicle.chargeLimit) + "%"
            color: Theme.text; font.pixelSize: 18; font.weight: Font.DemiBold; font.family: Theme.family
        }
        Slide {
            x: 16; y: 82; width: 268; from: 50; to: 100; value: Vehicle.chargeLimit; tint: Theme.ambient
            onMoved: (val) => Vehicle.chargeLimit = Math.round(val / 5) * 5
        }
        Text {
            x: 20; y: 142; text: "Brake energy regeneration"
            color: Theme.text; font.pixelSize: 18; font.weight: Font.DemiBold; font.family: Theme.family
        }
        Row {
            x: 16; y: 174; spacing: 8
            Repeater {
                model: ["Low", "Std", "High"]
                Btn { width: 84; height: 52; fontSize: 16; text: modelData; active: Vehicle.regen === index; tint: Theme.ok; onClicked: Vehicle.regen = index }
            }
        }
        Text {
            x: 20; y: 250; text: "Pre-conditioning"
            color: Theme.text; font.pixelSize: 18; font.weight: Font.DemiBold; font.family: Theme.family
        }
        Toggle { x: 206; y: 242; checked: Vehicle.preconditioning; onToggled: (val) => Vehicle.preconditioning = val }

        Text {
            x: 20; y: 310; text: "ECO TIPS"
            color: Theme.dim; font.pixelSize: 12; font.letterSpacing: 2
            font.weight: Font.DemiBold; font.family: Theme.family
        }
        Text {
            x: 20; y: 338; width: 260; wrapMode: Text.Wrap; color: Theme.text; font.pixelSize: 15
            font.family: Theme.family; lineEdge: Text.Leading
            text: Vehicle.speed > 110 ? "Reduce speed to increase range." : (Vehicle.power < 0 ? "Great! Recovering kinetic energy." : "Anticipate traffic flow and coast to maximize range.")
        }
    }
}
