import QtQuick

Item {
    id: ep
    width: 1120; height: 520

    // ----- battery card -----
    Rectangle {
        id: batCard
        anchors.left: parent.left; anchors.leftMargin: 16; y: 14
        width: Math.min(280, Math.max(200, (ep.width - 50) * 0.27))
        height: parent.height - 28; radius: 26
        color: Theme.glass; border.color: Theme.glassB; border.width: 1

        Rectangle {
            anchors.fill: parent; radius: parent.radius; color: "transparent"
            border.width: 1; border.color: Theme.alpha(Theme.ambient, 0.15)
        }

        // Battery outer shell
        Rectangle {
            id: shell
            anchors.horizontalCenter: parent.horizontalCenter
            y: Math.max(24, parent.height * 0.08)
            width: Math.min(130, parent.width * 0.58)
            height: Math.min(240, parent.height * 0.48); radius: 24
            color: Theme.alpha("#05080f", 0.7); border.color: Theme.alpha(Theme.dim, 0.6); border.width: 3

            // Terminal cap
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                y: -10; width: 40; height: 10; radius: 4
                color: Theme.dim; border.color: Theme.alpha("white", 0.2); border.width: 1
            }

            // Liquid level fill
            Rectangle {
                id: fill
                anchors.bottom: parent.bottom; anchors.bottomMargin: 6
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 12; radius: 18
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
                font.pixelSize: Math.round(Math.min(42, shell.width * 0.32)); font.weight: Font.DemiBold; color: "white"
                font.family: Theme.family
            }

            // Charge limit marker line
            Rectangle {
                x: -6; width: parent.width + 12; height: 3; color: Theme.ambient; radius: 1.5
                y: parent.height - 6 - (parent.height - 12) * Vehicle.chargeLimit / 100
            }
        }

        Text {
            anchors.top: shell.bottom; anchors.topMargin: 12
            width: parent.width; horizontalAlignment: Text.AlignHCenter
            text: Math.round(Vehicle.rangeKm * Vehicle.unitK) + " " + Vehicle.distUnit
            font.pixelSize: Math.round(Math.min(38, parent.width * 0.16)); color: Theme.text; font.weight: Font.DemiBold; font.family: Theme.family
        }
        Text {
            anchors.top: shell.bottom; anchors.topMargin: 52
            width: parent.width; horizontalAlignment: Text.AlignHCenter
            text: "estimated range"; font.pixelSize: 14; color: Theme.dim; font.family: Theme.family
        }
        Btn {
            anchors.bottom: parent.bottom; anchors.bottomMargin: 18
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 32; height: 56; fontSize: 17
            glyph: Theme.g.energy; text: Vehicle.charging ? "Stop charging" : "Start charging"
            active: Vehicle.charging; tint: Theme.ok; onClicked: Vehicle.toggleCharging()
        }
    }

    // ----- center area: power chart & stats -----
    Item {
        id: centerArea
        anchors.left: batCard.right; anchors.leftMargin: 14
        anchors.right: settingsCard.visible ? settingsCard.left : parent.right
        anchors.rightMargin: 14
        y: 14; height: parent.height - 28

        Rectangle {
            id: powerChartCard
            width: parent.width; height: Math.max(150, parent.height - 180); radius: 24
            color: Theme.glass; border.color: Theme.glassB; border.width: 1

            Rectangle {
                anchors.fill: parent; radius: parent.radius; color: "transparent"
                border.width: 1; border.color: Theme.alpha("white", 0.08)
            }

            Text {
                x: 18; y: 14; text: "POWER  (kW)"
                color: Theme.dim; font.pixelSize: 12; font.letterSpacing: 2
                font.weight: Font.DemiBold; font.family: Theme.family
            }
            Text {
                anchors.right: parent.right; anchors.rightMargin: 18; y: 10
                text: Math.round(Vehicle.power) + " kW"
                color: Vehicle.power < 0 ? Theme.ok : Theme.ambient
                font.pixelSize: 22; font.weight: Font.DemiBold; font.family: Theme.family
            }

            Canvas {
                id: chart
                x: 14; y: 44; width: parent.width - 28; height: parent.height - 56
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

                    // Soft outer halo line
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
            id: statRow
            anchors.top: powerChartCard.bottom; anchors.topMargin: 10
            width: parent.width; spacing: 10

            Rectangle {
                width: (parent.width - 20) / 3; height: 76; radius: 18
                color: Theme.glass; border.color: Theme.glassB; border.width: 1
                Column {
                    anchors.centerIn: parent; spacing: 2
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: (Vehicle.power / Math.max(20, Vehicle.speed) * 100).toFixed(1); color: Theme.text; font.pixelSize: 22; font.weight: Font.DemiBold; font.family: Theme.family }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "kWh/100 " + Vehicle.distUnit; color: Theme.dim; font.pixelSize: 11; font.family: Theme.family }
                }
            }
            Rectangle {
                width: (parent.width - 20) / 3; height: 76; radius: 18
                color: Theme.glass; border.color: Theme.glassB; border.width: 1
                Column {
                    anchors.centerIn: parent; spacing: 2
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: Vehicle.charging ? Math.round(Vehicle.chargePower) + " kW" : "\u2014"; color: Vehicle.charging ? Theme.ok : Theme.dim; font.pixelSize: 22; font.weight: Font.DemiBold; font.family: Theme.family }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "charging power"; color: Theme.dim; font.pixelSize: 11; font.family: Theme.family }
                }
            }
            Rectangle {
                width: (parent.width - 20) / 3; height: 76; radius: 18
                color: Theme.glass; border.color: Theme.glassB; border.width: 1
                Column {
                    anchors.centerIn: parent; spacing: 2
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: Math.round(Vehicle.ecoScore); color: Vehicle.ecoScore > 70 ? Theme.ok : Theme.warn; font.pixelSize: 22; font.weight: Font.DemiBold; font.family: Theme.family }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "eco score"; color: Theme.dim; font.pixelSize: 11; font.family: Theme.family }
                }
            }
        }

        Rectangle {
            anchors.top: statRow.bottom; anchors.topMargin: 10
            width: parent.width; height: 68; radius: 18
            color: Theme.glass; border.color: Theme.glassB; border.width: 1
            Row {
                anchors.centerIn: parent; spacing: 22
                Column {
                    Text { text: (Vehicle.trip * Vehicle.unitK).toFixed(1) + " " + Vehicle.distUnit; color: Theme.text; font.pixelSize: 20; font.weight: Font.DemiBold; font.family: Theme.family }
                    Text { text: "trip"; color: Theme.dim; font.pixelSize: 11; font.family: Theme.family }
                }
                Column {
                    Text { text: Math.round(Vehicle.odometer * Vehicle.unitK) + " " + Vehicle.distUnit; color: Theme.text; font.pixelSize: 20; font.weight: Font.DemiBold; font.family: Theme.family }
                    Text { text: "total"; color: Theme.dim; font.pixelSize: 11; font.family: Theme.family }
                }
                Btn { width: 110; height: 42; fontSize: 14; text: "Reset trip"; onClicked: Vehicle.trip = 0 }
            }
        }
    }

    // ----- settings column -----
    Rectangle {
        id: settingsCard
        anchors.right: parent.right; anchors.rightMargin: 16; y: 14
        width: Math.min(280, Math.max(200, (ep.width - 50) * 0.27))
        height: parent.height - 28; radius: 26
        visible: ep.width >= 820
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
            x: 16; y: 82; width: parent.width - 32; from: 50; to: 100; value: Vehicle.chargeLimit; tint: Theme.ambient
            onMoved: (val) => Vehicle.chargeLimit = Math.round(val / 5) * 5
        }
        Text {
            x: 20; y: 142; text: "Brake energy regen"
            color: Theme.text; font.pixelSize: 17; font.weight: Font.DemiBold; font.family: Theme.family
        }
        Row {
            x: 16; y: 174; spacing: 6
            Repeater {
                model: ["Low", "Std", "High"]
                Btn { width: (settingsCard.width - 44) / 3; height: 50; fontSize: 15; text: modelData; active: Vehicle.regen === index; tint: Theme.ok; onClicked: Vehicle.regen = index }
            }
        }
        Text {
            x: 20; y: 250; text: "Pre-conditioning"
            color: Theme.text; font.pixelSize: 17; font.weight: Font.DemiBold; font.family: Theme.family
        }
        Toggle { anchors.right: parent.right; anchors.rightMargin: 16; y: 242; checked: Vehicle.preconditioning; onToggled: (val) => Vehicle.preconditioning = val }

        Text {
            x: 20; y: 310; text: "ECO TIPS"
            color: Theme.dim; font.pixelSize: 12; font.letterSpacing: 2
            font.weight: Font.DemiBold; font.family: Theme.family
        }
        Text {
            x: 20; y: 338; width: parent.width - 40; wrapMode: Text.Wrap; color: Theme.text; font.pixelSize: 14
            font.family: Theme.family
            text: Vehicle.speed > 110 ? "Reduce speed to increase range." : (Vehicle.power < 0 ? "Great! Recovering kinetic energy." : "Anticipate traffic flow and coast to maximize range.")
        }
    }
}
