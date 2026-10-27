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
                width: 380; height: 100; radius: 24
                property color mcol: Vehicle.modeColor(modelData.name)
                property bool sel: Vehicle.driveMode === modelData.name

                color: sel ? Theme.alpha(mcol, 0.22) : (mma.containsMouse ? Theme.alpha(Theme.panel2, 0.8) : Theme.glass)
                border.width: sel ? 2 : 1
                border.color: sel ? mcol : Theme.glassB
                scale: mma.pressed ? 0.97 : (mma.containsMouse ? 1.01 : 1.0)
                Behavior on color { ColorAnimation { duration: 220 } }
                Behavior on scale { NumberAnimation { duration: 110; easing.type: Easing.OutCubic } }

                // Watermark glyph
                Text {
                    anchors.right: parent.right; anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.glyph; font.pixelSize: 64
                    color: Theme.alpha(mc.mcol, sel ? 0.20 : 0.08)
                }

                // Inner accent glow when selected
                Rectangle {
                    visible: mc.sel
                    anchors.fill: parent; radius: parent.radius; color: "transparent"
                    border.width: 1; border.color: Theme.alpha(mc.mcol, 0.5)
                }

                Row {
                    x: 18; anchors.verticalCenter: parent.verticalCenter; spacing: 16
                    Rectangle {
                        width: 56; height: 56; radius: 28
                        color: Theme.alpha(mc.mcol, mc.sel ? 0.35 : 0.18)
                        border.color: mc.mcol; border.width: mc.sel ? 2 : 1
                        anchors.verticalCenter: parent.verticalCenter
                        Text { anchors.centerIn: parent; text: modelData.glyph; color: mc.mcol; font.pixelSize: 28 }
                    }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter; spacing: 3
                        Text {
                            text: modelData.name
                            color: mc.sel ? "white" : Theme.text
                            font.pixelSize: 24; font.weight: Font.DemiBold; font.family: Theme.family
                        }
                        Text {
                            text: modelData.desc
                            color: Theme.dim; font.pixelSize: 13; width: 260
                            wrapMode: Text.Wrap; font.family: Theme.family
                        }
                    }
                }
                MouseArea {
                    id: mma; anchors.fill: parent; hoverEnabled: true
                    onClicked: { App.poke(); Vehicle.setMode(modelData.name) }
                }
            }
        }
    }

    // ----- driver assistance toggles -----
    Rectangle {
        x: 420; y: 14; width: 680; height: 292; radius: 24
        color: Theme.glass; border.color: Theme.glassB; border.width: 1

        Rectangle {
            anchors.fill: parent; radius: parent.radius; color: "transparent"
            border.width: 1; border.color: Theme.alpha(Theme.ambient, 0.15)
        }

        Text {
            x: 22; y: 14; text: "DRIVER ASSISTANCE"
            color: Theme.dim; font.pixelSize: 12; font.letterSpacing: 2
            font.weight: Font.DemiBold; font.family: Theme.family
        }

        Grid {
            x: 22; y: 40; columns: 2; columnSpacing: 36; rowSpacing: 8
            Repeater {
                model: [
                    { t: "Adaptive Cruise Control", k: "acc" }, { t: "Lane Keeping Assist", k: "laneAssist" },
                    { t: "Collision Warning", k: "collisionWarn" }, { t: "Blind Spot Detection", k: "blindSpot" },
                    { t: "Speed Limit Info", k: "speedInfo" }, { t: "Parking Assistant", k: "parkAssist" }
                ]
                Item {
                    width: 300; height: 50
                    Text {
                        text: modelData.t; color: Theme.text; font.pixelSize: 17
                        anchors.verticalCenter: parent.verticalCenter; font.family: Theme.family
                    }
                    Toggle {
                        anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                        checked: Vehicle[modelData.k]
                        onToggled: (val) => { Vehicle[modelData.k] = val; App.toast(modelData.t + (val ? " on" : " off"), Theme.g.drive) }
                    }
                }
            }
        }

        Rectangle {
            x: 22; y: 210; width: parent.width - 44; height: 1
            color: Theme.line; opacity: 0.6
        }

        Row {
            x: 22; y: 224; spacing: 14
            Text {
                text: "Cruise speed"; color: Theme.text; font.pixelSize: 18
                anchors.verticalCenter: parent.verticalCenter; width: 120
                font.weight: Font.DemiBold; font.family: Theme.family
            }
            Slide {
                width: 330; from: 30; to: 160; value: Vehicle.cruiseSpeed
                onMoved: (val) => Vehicle.cruiseSpeed = Math.round(val / 5) * 5
            }
            Text {
                text: Math.round(Vehicle.cruiseSpeed * Vehicle.unitK) + " " + Vehicle.speedUnit
                color: Theme.ambient; font.pixelSize: 22; anchors.verticalCenter: parent.verticalCenter
                font.weight: Font.DemiBold; font.family: Theme.family
            }
        }
    }

    // ----- drive simulator -----
    Rectangle {
        x: 420; y: 318; width: 680; height: 188; radius: 24
        color: Theme.glass; border.color: Theme.glassB; border.width: 1

        Rectangle {
            anchors.fill: parent; radius: parent.radius; color: "transparent"
            border.width: 1; border.color: Theme.alpha(Theme.ambient, 0.12)
        }

        Text {
            x: 22; y: 12
            text: "DRIVE SIMULATOR   (keys: W accelerate \u00B7 S brake \u00B7 Z/X indicators)"
            color: Theme.dim; font.pixelSize: 12; font.letterSpacing: 1
            font.weight: Font.DemiBold; font.family: Theme.family
        }

        Row {
            x: 22; y: 38; spacing: 8
            Repeater {
                model: ["P", "R", "N", "D"]
                Btn { width: 70; height: 60; text: modelData; fontSize: 26; active: Vehicle.gear === modelData; onClicked: Vehicle.setGear(modelData) }
            }
            Item { width: 14; height: 1 }
            Btn {
                width: 186; height: 60; fontSize: 16
                text: Vehicle.autoDrive ? "Auto-drive: ON" : "Auto-drive: OFF"
                active: Vehicle.autoDrive; tint: Theme.ok
                onClicked: { if (Vehicle.autoDrive) { Vehicle.stopAutoDrive() } else Vehicle.startAutoDrive() }
            }
            Btn {
                width: 150; height: 60; fontSize: 16
                text: "Manual: " + (Vehicle.manual ? "ON" : "OFF")
                active: Vehicle.manual; tint: Theme.ambient
                onClicked: { Vehicle.manual = !Vehicle.manual; if (Vehicle.manual) Vehicle.autoDrive = false }
            }
        }

        Row {
            x: 22; y: 110; spacing: 12
            Btn {
                id: gas; width: 190; height: 64; text: "ACCELERATE"; fontSize: 16; tint: Theme.ok; active: pressed
                onPressedChanged: { if (pressed) { Vehicle.manual = true; Vehicle.autoDrive = false; if (Vehicle.gear === "P") Vehicle.setGear("D"); Vehicle.throttle = 1 } else Vehicle.throttle = 0 }
            }
            Btn {
                id: brk; width: 190; height: 64; text: "BRAKE"; fontSize: 16; tint: Theme.danger; active: pressed
                onPressedChanged: { if (pressed) { Vehicle.manual = true; Vehicle.autoDrive = false; Vehicle.brake = 1 } else Vehicle.brake = 0 }
            }
            Column {
                spacing: 4; anchors.verticalCenter: parent.verticalCenter
                Text { text: "Regen"; color: Theme.dim; font.pixelSize: 12; font.family: Theme.family }
                Row {
                    spacing: 6
                    Repeater {
                        model: ["Low", "Std", "High"]
                        Btn { width: 70; height: 42; fontSize: 14; text: modelData; active: Vehicle.regen === index; tint: Theme.ok; onClicked: Vehicle.regen = index }
                    }
                }
            }
        }
    }
}
