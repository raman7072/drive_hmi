import QtQuick

Item {
    id: vp
    width: 1120; height: 520

    function pressText(i) {
        var b = Vehicle.tires[i]
        return Vehicle.useMiles ? (b * 14.5038).toFixed(0) + " psi" : b.toFixed(1) + " bar"
    }

    // ----- top-down car -----
    Item {
        id: carView
        x: 40; y: 10; width: 360; height: 500

        Glow { anchors.centerIn: body; width: 420; height: 520; color: Theme.ambient; strength: 0.18 }

        // wheels
        Repeater {
            model: [ { x: 52, y: 90, i: 0 }, { x: 258, y: 90, i: 1 }, { x: 52, y: 330, i: 2 }, { x: 258, y: 330, i: 3 } ]
            Item {
                x: modelData.x; y: modelData.y; width: 50; height: 92
                Rectangle { anchors.fill: parent; radius: 12; color: Theme.panel2; border.width: 2; border.color: Vehicle.tires[modelData.i] < 2.0 ? Theme.danger : Theme.dim }
                Text { x: modelData.x < 150 ? -78 : 62; y: 34; width: 70; horizontalAlignment: modelData.x < 150 ? Text.AlignRight : Text.AlignLeft
                       text: vp.pressText(modelData.i); font.pixelSize: 15; color: Vehicle.tires[modelData.i] < 2.0 ? Theme.danger : Theme.ok }
            }
        }
        Rectangle {
            id: body
            x: 90; y: 20; width: 180; height: 460; radius: 80
            color: Theme.panel2; border.color: Theme.dim; border.width: 2
            gradient: Gradient { GradientStop { position: 0; color: Theme.panel2 } GradientStop { position: 1; color: Theme.panel } }
            // windshields
            Rectangle { x: 22; y: 110; width: 136; height: 70; radius: 26; color: Theme.alpha(Theme.ambient, 0.18) }
            Rectangle { x: 22; y: 300; width: 136; height: 60; radius: 22; color: Theme.alpha(Theme.ambient, 0.12) }
            Rectangle { x: 38; y: 195; width: 104; height: 90; radius: 12; color: Theme.alpha(Theme.line, 0.5) }
            // headlights / taillights
            Rectangle { x: 26; y: 40; width: 36; height: 8; radius: 4; color: Vehicle.lowBeamOn ? "#e8f3ff" : Theme.dim }
            Rectangle { x: 118; y: 40; width: 36; height: 8; radius: 4; color: Vehicle.lowBeamOn ? "#e8f3ff" : Theme.dim }
            Rectangle { x: 26; y: 410; width: 36; height: 8; radius: 4; color: Vehicle.brake > 0.1 ? "#ff2a2a" : "#7a1717" }
            Rectangle { x: 118; y: 410; width: 36; height: 8; radius: 4; color: Vehicle.brake > 0.1 ? "#ff2a2a" : "#7a1717" }
            // hood / trunk highlight
            Rectangle { x: 40; y: 60; width: 100; height: 40; radius: 14; color: Vehicle.doors.hood ? Theme.alpha(Theme.warn, 0.5) : "transparent"; border.color: Vehicle.doors.hood ? Theme.warn : "transparent" }
            Rectangle { x: 40; y: 370; width: 100; height: 34; radius: 14; color: Vehicle.doors.trunk ? Theme.alpha(Theme.warn, 0.5) : "transparent"; border.color: Vehicle.doors.trunk ? Theme.warn : "transparent" }
        }

        // doors: hinged at front edge, swing outward
        Repeater {
            model: [ { k: "fl", x: 90, y: 190, side: -1 }, { k: "fr", x: 270, y: 190, side: 1 },
                     { k: "rl", x: 90, y: 300, side: -1 }, { k: "rr", x: 270, y: 300, side: 1 } ]
            Item {
                x: modelData.x; y: modelData.y; width: 4; height: 100
                transformOrigin: Item.Top
                rotation: Vehicle.doors[modelData.k] ? modelData.side * -1 * 32 : 0
                Behavior on rotation { NumberAnimation { duration: 450; easing.type: Easing.OutBack } }
                Rectangle { anchors.fill: parent; radius: 2; color: Vehicle.doors[modelData.k] ? Theme.warn : Theme.dim }
                MouseArea { x: -20; width: 44; height: parent.height; onClicked: { App.poke(); Vehicle.toggleDoor(modelData.k) } }
            }
        }
        Btn { x: 120; y: 12; width: 120; height: 40; fontSize: 14; text: "Hood"; active: Vehicle.doors.hood; tint: Theme.warn; onClicked: Vehicle.toggleDoor("hood") }
        Btn { x: 120; y: 455; width: 120; height: 40; fontSize: 14; text: "Tailgate"; active: Vehicle.doors.trunk; tint: Theme.warn; onClicked: Vehicle.toggleDoor("trunk") }
    }

    // ----- right: controls -----
    Column {
        x: 440; y: 14; spacing: 12; width: 650

        Row {
            spacing: 12
            Btn { width: 316; height: 76; glyph: "\u26BF"; text: Vehicle.locked ? "Locked \u2013 tap to unlock" : "Unlocked \u2013 tap to lock"; fontSize: 18
                  active: Vehicle.locked; tint: Theme.ok; onClicked: Vehicle.locked = !Vehicle.locked }
            Btn { width: 316; height: 76; text: "Lights: " + Vehicle.lightsMode; fontSize: 18
                  onClicked: Vehicle.lightsMode = Vehicle.lightsMode === "Auto" ? "Low" : (Vehicle.lightsMode === "Low" ? "Off" : "Auto") }
        }
        Row {
            spacing: 12
            Btn { width: 205; height: 64; text: "High beam"; fontSize: 18; active: Vehicle.highBeam; onClicked: Vehicle.highBeam = !Vehicle.highBeam }
            Btn { width: 205; height: 64; text: "Fog lights"; fontSize: 18; active: Vehicle.fogLight; onClicked: Vehicle.fogLight = !Vehicle.fogLight }
            Btn { width: 206; height: 64; text: "Hazard"; fontSize: 18; active: Vehicle.hazard; tint: Theme.danger; onClicked: Vehicle.hazard = !Vehicle.hazard }
        }

        // windows
        Rectangle {
            width: 650; height: 130; radius: 20; color: Theme.panel2; border.color: Theme.line
            Text { x: 18; y: 10; text: "WINDOWS"; color: Theme.dim; font.pixelSize: 13; font.letterSpacing: 2 }
            Grid {
                x: 18; y: 34; columns: 2; spacing: 8; columnSpacing: 30
                Repeater {
                    model: ["Front left", "Front right", "Rear left", "Rear right"]
                    Row {
                        spacing: 10
                        Text { text: modelData; color: Theme.text; font.pixelSize: 14; width: 80; anchors.verticalCenter: parent.verticalCenter }
                        Slide { width: 180; height: 34; value: Vehicle.windows[index]; onMoved: (val) => Vehicle.setWindow(index, val) }
                        Text { text: Math.round(Vehicle.windows[index] * 100) + "%"; color: Theme.dim; font.pixelSize: 13; width: 40; anchors.verticalCenter: parent.verticalCenter }
                    }
                }
            }
        }

        // service
        Row {
            spacing: 12
            Rectangle {
                width: 205; height: 100; radius: 18; color: Theme.panel2; border.color: Theme.line
                Column { anchors.centerIn: parent; spacing: 2
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: Vehicle.serviceDays + " days"; color: Theme.text; font.pixelSize: 26 }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "next service \u00B7 " + Math.round(Vehicle.serviceKm * Vehicle.unitK) + " " + Vehicle.distUnit; color: Theme.dim; font.pixelSize: 12 } }
            }
            Rectangle {
                width: 205; height: 100; radius: 18; color: Theme.panel2; border.color: Theme.line
                Column { anchors.centerIn: parent; spacing: 6
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Brake pads " + Vehicle.brakePads + "%"; color: Theme.text; font.pixelSize: 16 }
                    Rectangle { width: 150; height: 10; radius: 5; color: Theme.bg
                        Rectangle { width: parent.width * Vehicle.brakePads / 100; height: 10; radius: 5; color: Vehicle.brakePads < 25 ? Theme.danger : Theme.ok } }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: Vehicle.washerOk ? "Washer fluid OK" : "Washer fluid low"; color: Vehicle.washerOk ? Theme.dim : Theme.warn; font.pixelSize: 12 } }
            }
            Rectangle {
                width: 206; height: 100; radius: 18; color: Theme.panel2; border.color: Vehicle.alerts[0] === "All systems OK" ? Theme.line : Theme.warn
                Column { anchors.centerIn: parent; width: parent.width - 20; spacing: 4
                    Text { text: "CHECK CONTROL"; color: Theme.dim; font.pixelSize: 11; font.letterSpacing: 2 }
                    Repeater { model: Vehicle.alerts.slice(0, 3)
                        Text { text: (modelData === "All systems OK" ? "\u2713 " : "\u26A0 ") + modelData; color: modelData === "All systems OK" ? Theme.ok : Theme.warn; font.pixelSize: 13; width: parent.width; elide: Text.ElideRight } } }
            }
        }
        Row {
            spacing: 12
            Btn { width: 316; height: 56; text: "Tire pressure reset"; fontSize: 16; onClicked: { Vehicle.tires = [2.4, 2.4, 2.5, 2.5]; App.toast("Tire pressures calibrated", Theme.g.vehicle) } }
            Btn { width: 316; height: 56; text: "Simulate low tire (RL)"; fontSize: 16; tint: Theme.warn; onClicked: { Vehicle.tires = [2.4, 2.4, 1.8, 2.5]; App.toast("Tire pressure low: rear left", "\u26A0") } }
        }
    }
}
