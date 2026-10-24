import QtQuick

Item {
    id: cp
    width: 1120; height: 520

    component TempDial: Item {
        id: dial
        property real value: 21
        property string label: ""
        signal changed(real v)
        width: 250; height: 330
        Canvas {
            id: dc
            x: 0; y: 0; width: 250; height: 250
            property real v: dial.value
            onVChanged: requestPaint()
            Connections { target: Theme; function onAmbientChanged() { dc.requestPaint() } }
            onPaint: {
                var ctx = getContext("2d"); ctx.reset()
                var a0 = Math.PI * 0.75, span = Math.PI * 1.5
                var f = (dial.value - 16) / 12
                ctx.lineCap = "round"; ctx.lineWidth = 14
                ctx.strokeStyle = Theme.css(Theme.line, 1)
                ctx.beginPath(); ctx.arc(125, 125, 105, a0, a0 + span); ctx.stroke()
                var g = ctx.createLinearGradient(0, 250, 250, 0)
                g.addColorStop(0, "#2d9cdb"); g.addColorStop(0.5, "#ffffff"); g.addColorStop(1, "#ff7a45")
                ctx.strokeStyle = g
                ctx.beginPath(); ctx.arc(125, 125, 105, a0, a0 + span * f); ctx.stroke()
            }
        }
        Text { anchors.horizontalCenter: dc.horizontalCenter; y: 84; text: dial.value.toFixed(1) + "\u00B0"; font.pixelSize: 62; font.weight: Font.Light; color: Theme.text }
        Text { anchors.horizontalCenter: dc.horizontalCenter; y: 160; text: dial.label; font.pixelSize: 16; color: Theme.dim; font.letterSpacing: 2 }
        Btn { x: 20; y: 262; width: 100; height: 58; text: "\u2212"; fontSize: 30; onClicked: dial.changed(dial.value - 0.5) }
        Btn { x: 130; y: 262; width: 100; height: 58; text: "+"; fontSize: 30; onClicked: dial.changed(dial.value + 0.5) }
    }

    TempDial { x: 20; y: 14; value: Vehicle.driverTemp; label: "DRIVER"; onChanged: (v) => Vehicle.setDriverTemp(v) }
    TempDial { x: 850; y: 14; value: Vehicle.passTemp; label: "PASSENGER"; onChanged: (v) => Vehicle.setPassTemp(v) }

    // ----- top-down car + airflow -----
    Item {
        x: 300; y: 0; width: 520; height: 340
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
                ctx.beginPath(); ctx.roundedRect(w / 2 - 90, 20, 180, 300, 70, 70); ctx.fill(); ctx.stroke()
                ctx.fillStyle = Theme.css(Theme.bg, 0.6)
                ctx.beginPath(); ctx.roundedRect(w / 2 - 70, 90, 140, 70, 24, 24); ctx.fill()
                ctx.beginPath(); ctx.roundedRect(w / 2 - 70, 230, 140, 50, 20, 20); ctx.fill()
                // seats
                var seats = [[w / 2 - 50, 170, Vehicle.seatHeatL], [w / 2 + 12, 170, Vehicle.seatHeatR]]
                for (var s = 0; s < 2; s++) {
                    ctx.fillStyle = seats[s][2] > 0 ? Theme.css(Theme.warn, 0.25 + seats[s][2] * 0.2) : Theme.css(Theme.line, 1)
                    ctx.beginPath(); ctx.roundedRect(seats[s][0], seats[s][1], 38, 46, 10, 10); ctx.fill()
                }
                // particles
                var cold = (Vehicle.driverTemp < 20.5), warm = (Vehicle.driverTemp > 23.5)
                var col = Vehicle.defrostFront ? "#ffb26b" : (cold ? "#5ec3ff" : (warm ? "#ff8a5b" : "#cfe3ff"))
                var p = flow.parts
                for (var i = 0; i < p.length; i++) {
                    var px = w / 2 - 65 + p[i].x * 130, py = 20 + p[i].y * 270
                    ctx.strokeStyle = Theme.css(col, Vehicle.fan > 0 ? 0.7 * (1 - p[i].y) + 0.1 : 0.05)
                    ctx.lineWidth = 2
                    ctx.beginPath(); ctx.moveTo(px, py); ctx.lineTo(px + (p[i].x - 0.5) * 6, py + 14 * p[i].s); ctx.stroke()
                }
            }
        }
        Text { x: 0; y: 6; width: parent.width; horizontalAlignment: Text.AlignHCenter; text: "Cabin " + Vehicle.cabinTemp.toFixed(1) + "\u00B0C"; color: Theme.dim; font.pixelSize: 18 }
        // fan slider
        Row {
            x: 60; y: 335; spacing: 6
            Text { text: Theme.g.fan; color: Theme.ambient; font.pixelSize: 26; anchors.verticalCenter: parent.verticalCenter; width: 40
                RotationAnimator on rotation { from: 0; to: 360; duration: Math.max(400, 3200 - Vehicle.fan * 400); loops: Animation.Infinite; running: Vehicle.fan > 0 } }
            Repeater {
                model: 8
                Rectangle {
                    width: 44; height: 14 + index * 3; radius: 4; anchors.bottom: parent.bottom
                    color: index <= Vehicle.fan && Vehicle.fan > 0 && index > 0 || (index === 0 && Vehicle.fan === 0) ? Theme.ambient : Theme.panel2
                    border.color: Theme.line
                    MouseArea { anchors.fill: parent; anchors.margins: -4; onClicked: { App.poke(); Vehicle.fan = index } }
                }
            }
        }
    }

    // ----- controls -----
    Flow {
        x: 20; y: 360; width: 1080; spacing: 10
        Btn { width: 134; height: 64; text: "AUTO"; active: Vehicle.autoClimate; onClicked: Vehicle.autoClimate = !Vehicle.autoClimate }
        Btn { width: 134; height: 64; text: "A/C"; active: Vehicle.acOn; onClicked: Vehicle.acOn = !Vehicle.acOn }
        Btn { width: 134; height: 64; text: "SYNC"; active: Vehicle.sync; onClicked: { Vehicle.sync = !Vehicle.sync; if (Vehicle.sync) Vehicle.passTemp = Vehicle.driverTemp } }
        Btn { width: 134; height: 64; text: "Recirc"; active: Vehicle.recirc; onClicked: Vehicle.recirc = !Vehicle.recirc }
        Btn { width: 134; height: 64; text: "Defrost"; active: Vehicle.defrostFront; tint: Theme.warn; onClicked: Vehicle.defrostFront = !Vehicle.defrostFront }
        Btn { width: 134; height: 64; text: "Rear"; active: Vehicle.defrostRear; tint: Theme.warn; onClicked: Vehicle.defrostRear = !Vehicle.defrostRear }
        Btn { width: 134; height: 64; text: "Wheel heat"; fontSize: 18; active: Vehicle.steeringHeat; tint: Theme.warn; onClicked: Vehicle.steeringHeat = !Vehicle.steeringHeat }
        Btn { width: 134; height: 64; text: "Ionizer"; active: Vehicle.ionizer; onClicked: Vehicle.ionizer = !Vehicle.ionizer }
        Btn { width: 220; height: 64; text: "Seat L: " + (Vehicle.seatHeatL ? Vehicle.seatHeatL : "off"); active: Vehicle.seatHeatL > 0; tint: Theme.warn; onClicked: Vehicle.seatHeatL = (Vehicle.seatHeatL + 1) % 4 }
        Btn { width: 220; height: 64; text: "Seat R: " + (Vehicle.seatHeatR ? Vehicle.seatHeatR : "off"); active: Vehicle.seatHeatR > 0; tint: Theme.warn; onClicked: Vehicle.seatHeatR = (Vehicle.seatHeatR + 1) % 4 }
        Btn { width: 220; height: 64; text: "Pre-condition"; active: Vehicle.preconditioning; onClicked: { Vehicle.preconditioning = !Vehicle.preconditioning; if (Vehicle.preconditioning) { Vehicle.setDriverTemp(21); Vehicle.fan = 5 } } }
    }
}
