import QtQuick

Item {
    id: cp
    implicitWidth: 1120; implicitHeight: 520

    Flickable {
        anchors.fill: parent
        contentHeight: Math.max(cp.height, 510)
        contentWidth: width
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        component TempDial: Item {
            id: dial
            property real value: 21
            property string label: ""
            signal changed(real v)
            width: cp.width < 750 ? 190 : 240; height: 330
            Canvas {
                id: dc
                anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter
                width: dial.width; height: dial.width
                property real v: dial.value
                onVChanged: requestPaint()
                Connections { target: Theme; function onAmbientChanged() { dc.requestPaint() } }
                onPaint: {
                    var ctx = getContext("2d"); ctx.reset()
                    var a0 = Math.PI * 0.75, span = Math.PI * 1.5
                    var f = (dial.value - 16) / 12
                    var cx = width / 2, cy = height / 2, r = cx - 18
                    ctx.lineCap = "round"; ctx.lineWidth = Math.max(8, r * 0.12)
                    // track
                    ctx.strokeStyle = Theme.css(Theme.line, 1)
                    ctx.beginPath(); ctx.arc(cx, cy, r, a0, a0 + span); ctx.stroke()
                    // temp gradient arc
                    var g = ctx.createLinearGradient(0, height, width, 0)
                    g.addColorStop(0, "#3bb0ff"); g.addColorStop(0.45, "#ffffff"); g.addColorStop(1, "#ff6a3d")
                    ctx.strokeStyle = g
                    ctx.beginPath(); ctx.arc(cx, cy, r, a0, a0 + span * f); ctx.stroke()
                    // needle tip dot
                    var tipAngle = a0 + span * f
                    ctx.fillStyle = "white"
                    ctx.beginPath(); ctx.arc(cx + Math.cos(tipAngle) * r, cy + Math.sin(tipAngle) * r, 6, 0, Math.PI * 2); ctx.fill()
                }
            }
            Text {
                anchors.horizontalCenter: dc.horizontalCenter; y: dc.height * 0.32
                text: dial.value.toFixed(1) + "\u00B0"
                font.pixelSize: cp.width < 750 ? 50 : 62; font.weight: Font.Thin; color: Theme.text
            }
            Text {
                anchors.horizontalCenter: dc.horizontalCenter; y: dc.height * 0.65
                text: dial.label
                font.pixelSize: 13; color: Theme.dim
                font.letterSpacing: 2.5; font.weight: Font.Medium
            }
            Row {
                anchors.bottom: parent.bottom; anchors.bottomMargin: 6
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 12
                Btn { width: dial.width * 0.44; height: 52; text: "\u2212"; fontSize: 26; onClicked: dial.changed(dial.value - 0.5) }
                Btn { width: dial.width * 0.44; height: 52; text: "+"; fontSize: 26; onClicked: dial.changed(dial.value + 0.5) }
            }
        }

        TempDial {
            anchors.left: parent.left; anchors.leftMargin: Math.max(12, cp.width * 0.02)
            y: 14; value: Vehicle.driverTemp; label: "DRIVER"
            onChanged: (v) => Vehicle.setDriverTemp(v)
        }

        TempDial {
            anchors.right: parent.right; anchors.rightMargin: Math.max(12, cp.width * 0.02)
            y: 14; value: Vehicle.passTemp; label: "PASSENGER"
            visible: cp.width >= 580
            onChanged: (v) => Vehicle.setPassTemp(v)
        }

        // ----- top-down car + airflow -----
        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 0; width: Math.min(500, Math.max(260, parent.width - (cp.width >= 580 ? 460 : 240))); height: 340
            Canvas {
                id: flow
                anchors.fill: parent
                property var parts: []
                Component.onCompleted: { var a = []; for (var i = 0; i < 46; i++) a.push({ x: Math.random(), y: Math.random(), s: 0.4 + Math.random() }); parts = a }
                FrameAnimation {
                    running: cp.visible && App.page === "climate" && Vehicle.fan > 0
                    onTriggered: {
                        var p = flow.parts, sp = (Vehicle.fan / 7) * 0.9 * frameTime
                        for (var i = 0; i < p.length; i++) { p[i].y += sp * p[i].s * 0.6; if (p[i].y > 1) { p[i].y = 0.12; p[i].x = Math.random() } }
                        flow.requestPaint()
                    }
                }
                onPaint: {
                    var ctx = getContext("2d"); ctx.reset()
                    var w = width, h = height
                    // car body (top view)
                    ctx.fillStyle = Theme.css(Theme.panel2, 1); ctx.strokeStyle = Theme.css(Theme.dim, 0.7); ctx.lineWidth = 2
                    ctx.beginPath(); ctx.roundedRect(w / 2 - 80, 20, 160, 290, 60, 60); ctx.fill(); ctx.stroke()
                    ctx.fillStyle = Theme.css(Theme.bg, 0.6)
                    ctx.beginPath(); ctx.roundedRect(w / 2 - 62, 85, 124, 65, 20, 20); ctx.fill()
                    ctx.beginPath(); ctx.roundedRect(w / 2 - 62, 220, 124, 48, 18, 18); ctx.fill()
                    // seats
                    var seats = [[w / 2 - 46, 165, Vehicle.seatHeatL], [w / 2 + 10, 165, Vehicle.seatHeatR]]
                    for (var s = 0; s < 2; s++) {
                        ctx.fillStyle = seats[s][2] > 0 ? Theme.css(Theme.heat, 0.35 + seats[s][2] * 0.2) : Theme.css(Theme.line, 1)
                        ctx.beginPath(); ctx.roundedRect(seats[s][0], seats[s][1], 36, 44, 9, 9); ctx.fill()
                    }
                    // particles
                    var cold = (Vehicle.driverTemp < 20.5), warm = (Vehicle.driverTemp > 23.5)
                    var col = Vehicle.defrostFront ? "#ff7849" : (cold ? "#38bdf8" : (warm ? "#ff5733" : "#cfe3ff"))
                    var p = flow.parts
                    for (var i = 0; i < p.length; i++) {
                        var px = w / 2 - 55 + p[i].x * 110, py = 20 + p[i].y * 260
                        ctx.strokeStyle = Theme.css(col, Vehicle.fan > 0 ? 0.7 * (1 - p[i].y) + 0.1 : 0.05)
                        ctx.lineWidth = 2
                        ctx.beginPath(); ctx.moveTo(px, py); ctx.lineTo(px + (p[i].x - 0.5) * 6, py + 14 * p[i].s); ctx.stroke()
                    }
                }
            }
            Text { x: 0; y: 6; width: parent.width; horizontalAlignment: Text.AlignHCenter; text: "Cabin " + Vehicle.cabinTemp.toFixed(1) + "\u00B0C"; color: Theme.dim; font.pixelSize: 17 }

            // fan slider
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 330; spacing: 6
                Text { text: Theme.g.fan; color: Theme.ambient; font.pixelSize: 24; anchors.verticalCenter: parent.verticalCenter; width: 36
                    RotationAnimator on rotation { from: 0; to: 360; duration: Math.max(400, 3200 - Vehicle.fan * 400); loops: Animation.Infinite; running: Vehicle.fan > 0 } }
                Repeater {
                    model: 8
                    Rectangle {
                        width: Math.min(38, Math.max(20, (parent.parent.width - 60) / 9)); height: 14 + index * 2.5; radius: 4; anchors.bottom: parent.bottom
                        color: index <= Vehicle.fan && Vehicle.fan > 0 && index > 0 || (index === 0 && Vehicle.fan === 0) ? Theme.ambient : Theme.panel2
                        border.color: Theme.line
                        MouseArea { anchors.fill: parent; anchors.margins: -4; onClicked: { App.poke(); Vehicle.fan = index } }
                    }
                }
            }
        }

        // ----- controls -----
        Flow {
            anchors.left: parent.left; anchors.leftMargin: Math.max(14, cp.width * 0.02)
            anchors.right: parent.right; anchors.rightMargin: Math.max(14, cp.width * 0.02)
            y: 368; spacing: 8
            Btn { width: 120; height: 56; text: "AUTO"; active: Vehicle.autoClimate; onClicked: Vehicle.autoClimate = !Vehicle.autoClimate }
            Btn { width: 120; height: 56; text: "A/C"; active: Vehicle.acOn; onClicked: Vehicle.acOn = !Vehicle.acOn }
            Btn { width: 120; height: 56; text: "SYNC"; active: Vehicle.sync; onClicked: { Vehicle.sync = !Vehicle.sync; if (Vehicle.sync) Vehicle.passTemp = Vehicle.driverTemp } }
            Btn { width: 120; height: 56; text: "Recirc"; active: Vehicle.recirc; onClicked: Vehicle.recirc = !Vehicle.recirc }
            Btn { width: 120; height: 56; text: "Defrost"; active: Vehicle.defrostFront; tint: Theme.heat; onClicked: Vehicle.defrostFront = !Vehicle.defrostFront }
            Btn { width: 120; height: 56; text: "Rear"; active: Vehicle.defrostRear; tint: Theme.heat; onClicked: Vehicle.defrostRear = !Vehicle.defrostRear }
            Btn { width: 128; height: 56; text: "Wheel heat"; fontSize: 16; active: Vehicle.steeringHeat; tint: Theme.heat; onClicked: Vehicle.steeringHeat = !Vehicle.steeringHeat }
            Btn { width: 120; height: 56; text: "Ionizer"; active: Vehicle.ionizer; onClicked: Vehicle.ionizer = !Vehicle.ionizer }
            Btn { width: 180; height: 56; text: "Seat L: " + (Vehicle.seatHeatL ? Vehicle.seatHeatL : "off"); active: Vehicle.seatHeatL > 0; tint: Theme.heat; onClicked: Vehicle.seatHeatL = (Vehicle.seatHeatL + 1) % 4 }
            Btn { width: 180; height: 56; text: "Seat R: " + (Vehicle.seatHeatR ? Vehicle.seatHeatR : "off"); active: Vehicle.seatHeatR > 0; tint: Theme.heat; onClicked: Vehicle.seatHeatR = (Vehicle.seatHeatR + 1) % 4 }
            Btn { width: 180; height: 56; text: "Pre-condition"; active: Vehicle.preconditioning; onClicked: { Vehicle.preconditioning = !Vehicle.preconditioning; if (Vehicle.preconditioning) { Vehicle.setDriverTemp(21); Vehicle.fan = 5 } } }
        }
    }
}
