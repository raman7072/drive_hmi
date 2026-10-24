import QtQuick

Item {
    id: dp
    width: 1120; height: 520

    readonly property var modes: [
        { name: "Eco Pro", desc: "Efficiency first \u00B7 soft throttle \u00B7 +8% range", glyph: "\u2766" },
        { name: "Comfort", desc: "Balanced response \u00B7 relaxed suspension", glyph: "\u25C9" },
        { name: "Sport", desc: "Sharp throttle \u00B7 firm damping \u00B7 red cluster", glyph: "\u26A1\uFE0E" },
        { name: "Individual", desc: "Your own mix of steering, damping and sound", glyph: "\u2726" }
    ]

    // ----- drive modes -----
    Column {
        x: 20; y: 14; spacing: 10
        Repeater {
            model: dp.modes
            Rectangle {
                id: mc
                width: 380; height: 100; radius: 22
                property color mcol: Vehicle.modeColor(modelData.name)
                property bool sel: Vehicle.driveMode === modelData.name
                color: sel ? Theme.alpha(mcol, 0.22) : Theme.panel2
                border.width: sel ? 2 : 1; border.color: sel ? mcol : Theme.line
                scale: mma.pressed ? 0.97 : 1
                Behavior on color { ColorAnimation { duration: 250 } }
                Behavior on scale { NumberAnimation { duration: 100 } }
                Row {
                    x: 20; anchors.verticalCenter: parent.verticalCenter; spacing: 18
                    Rectangle { width: 56; height: 56; radius: 28; color: Theme.alpha(mc.mcol, 0.25); border.color: mc.mcol; anchors.verticalCenter: parent.verticalCenter
                        Text { anchors.centerIn: parent; text: modelData.glyph; color: mc.mcol; font.pixelSize: 28 } }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter; spacing: 3
                        Text { text: modelData.name; color: Theme.text; font.pixelSize: 26 }
                        Text { text: modelData.desc; color: Theme.dim; font.pixelSize: 13; width: 270; wrapMode: Text.Wrap }
                    }
                }
                MouseArea { id: mma; anchors.fill: parent; onClicked: { App.poke(); Vehicle.setMode(modelData.name) } }
            }
        }
    }

    // ----- driver assistance toggles -----
    Rectangle {
        x: 420; y: 14; width: 680; height: 292; radius: 22; color: Theme.panel2; border.color: Theme.line
        Text { x: 20; y: 12; text: "DRIVER ASSISTANCE"; color: Theme.dim; font.pixelSize: 13; font.letterSpacing: 2 }
        Grid {
            x: 20; y: 40; columns: 2; columnSpacing: 36; rowSpacing: 8
            Repeater {
                model: [
                    { t: "Adaptive Cruise Control", k: "acc" }, { t: "Lane Keeping Assist", k: "laneAssist" },
                    { t: "Collision Warning", k: "collisionWarn" }, { t: "Blind Spot Detection", k: "blindSpot" },
                    { t: "Speed Limit Info", k: "speedInfo" }, { t: "Parking Assistant", k: "parkAssist" }
                ]
                Item {
                    width: 308; height: 52
                    Text { text: modelData.t; color: Theme.text; font.pixelSize: 18; anchors.verticalCenter: parent.verticalCenter }
                    Toggle { anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                             checked: Vehicle[modelData.k]
                             onToggled: (val) => { Vehicle[modelData.k] = val; App.toast(modelData.t + (val ? " on" : " off"), Theme.g.drive) } }
                }
            }
        }
        Row {
            x: 20; y: 222; spacing: 14
            Text { text: "Cruise speed"; color: Theme.text; font.pixelSize: 18; anchors.verticalCenter: parent.verticalCenter; width: 120 }
            Slide { width: 340; from: 30; to: 160; value: Vehicle.cruiseSpeed; onMoved: (val) => Vehicle.cruiseSpeed = Math.round(val / 5) * 5 }
            Text { text: Math.round(Vehicle.cruiseSpeed * Vehicle.unitK) + " " + Vehicle.speedUnit; color: Theme.ambient; font.pixelSize: 22; anchors.verticalCenter: parent.verticalCenter }
        }
    }

    // ----- drive simulator -----
    Rectangle {
        x: 420; y: 318; width: 680; height: 188; radius: 22; color: Theme.panel2; border.color: Theme.line
        Text { x: 20; y: 10; text: "DRIVE SIMULATOR   (keys: W accelerate \u00B7 S brake \u00B7 Z/X indicators)"; color: Theme.dim; font.pixelSize: 13; font.letterSpacing: 1 }
        Row {
            x: 20; y: 38; spacing: 8
            Repeater {
                model: ["P", "R", "N", "D"]
                Btn { width: 70; height: 60; text: modelData; fontSize: 28; active: Vehicle.gear === modelData; onClicked: Vehicle.setGear(modelData) }
            }
            Item { width: 14; height: 1 }
            Btn { width: 186; height: 60; fontSize: 16; text: Vehicle.autoDrive ? "Auto-drive: ON" : "Auto-drive: OFF"; active: Vehicle.autoDrive; tint: Theme.ok
                  onClicked: { if (Vehicle.autoDrive) { Vehicle.stopAutoDrive() } else Vehicle.startAutoDrive() } }
            Btn { width: 150; height: 60; fontSize: 16; text: "Manual: " + (Vehicle.manual ? "ON" : "OFF"); active: Vehicle.manual; tint: Theme.warn
                  onClicked: { Vehicle.manual = !Vehicle.manual; if (Vehicle.manual) Vehicle.autoDrive = false } }
        }
        Row {
            x: 20; y: 112; spacing: 10
            Btn { id: gas; width: 190; height: 64; text: "ACCELERATE"; fontSize: 15; tint: Theme.ok; active: pressed
                  onPressedChanged: { if (pressed) { Vehicle.manual = true; Vehicle.autoDrive = false; if (Vehicle.gear === "P") Vehicle.setGear("D"); Vehicle.throttle = 1 } else Vehicle.throttle = 0 } }
            Btn { id: brk; width: 190; height: 64; text: "BRAKE"; fontSize: 15; tint: Theme.danger; active: pressed
                  onPressedChanged: { if (pressed) { Vehicle.manual = true; Vehicle.autoDrive = false; Vehicle.brake = 1 } else Vehicle.brake = 0 } }
            Column {
                spacing: 4; anchors.verticalCenter: parent.verticalCenter
                Text { text: "Regen"; color: Theme.dim; font.pixelSize: 12 }
                Row { spacing: 6
                    Repeater { model: ["Low", "Std", "High"]
                        Btn { width: 70; height: 40; fontSize: 14; text: modelData; active: Vehicle.regen === index; tint: Theme.ok; onClicked: Vehicle.regen = index } } }
            }
        }
    }
}
