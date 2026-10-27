import QtQuick

Item {
    id: dp
    implicitWidth: 1120; implicitHeight: 520
    width: parent ? parent.width : implicitWidth
    height: parent ? parent.height : implicitHeight

    readonly property var modes: [
        { name: "Eco Pro", desc: "Efficiency first \u00B7 soft throttle \u00B7 +8% range", glyph: "\u2766" },
        { name: "Comfort", desc: "Balanced response \u00B7 relaxed suspension", glyph: "\u25C9" },
        { name: "Sport", desc: "Sharp throttle \u00B7 firm damping \u00B7 red cluster", glyph: "\u26A1\uFE0E" },
        { name: "Individual", desc: "Your own mix of steering, damping and sound", glyph: "\u2726" }
    ]

    readonly property bool isStacked: width < 840

    Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: width
        contentHeight: dp.isStacked ? (stackedCol.height + 40) : Math.max(height, 530)
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        // ================= WIDE / DUAL COLUMN LAYOUT =================
        Item {
            visible: !dp.isStacked
            anchors.fill: parent

            // ----- Left: Drive modes column -----
            Column {
                id: modesCol
                x: 20; y: 14
                width: Math.max(280, Math.min(380, dp.width * 0.35))
                spacing: 10

                Repeater {
                    model: dp.modes
                    Rectangle {
                        id: mc
                        width: modesCol.width; height: Math.min(106, Math.max(88, (dp.height - 60) / 4)); radius: 22
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
                            text: modelData.glyph; font.pixelSize: mc.height > 95 ? 64 : 48
                            color: Theme.alpha(mc.mcol, sel ? 0.20 : 0.08)
                        }

                        // Inner accent glow when selected
                        Rectangle {
                            visible: mc.sel
                            anchors.fill: parent; radius: parent.radius; color: "transparent"
                            border.width: 1; border.color: Theme.alpha(mc.mcol, 0.5)
                        }

                        Row {
                            x: 16; anchors.verticalCenter: parent.verticalCenter; spacing: 14
                            Rectangle {
                                width: mc.height > 95 ? 54 : 46; height: width; radius: width / 2
                                color: Theme.alpha(mc.mcol, mc.sel ? 0.35 : 0.18)
                                border.color: mc.mcol; border.width: mc.sel ? 2 : 1
                                anchors.verticalCenter: parent.verticalCenter
                                Text { anchors.centerIn: parent; text: modelData.glyph; color: mc.mcol; font.pixelSize: mc.height > 95 ? 26 : 22 }
                            }
                            Column {
                                anchors.verticalCenter: parent.verticalCenter; spacing: 2
                                width: mc.width - 90
                                Text {
                                    text: modelData.name
                                    color: mc.sel ? "white" : Theme.text
                                    font.pixelSize: mc.height > 95 ? 23 : 20; font.weight: Font.DemiBold; font.family: Theme.family
                                }
                                Text {
                                    text: modelData.desc
                                    color: Theme.dim; font.pixelSize: mc.height > 95 ? 12 : 11; width: parent.width - 20
                                    elide: Text.ElideRight; maximumLineCount: 2; wrapMode: Text.Wrap; font.family: Theme.family
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

            // ----- Right: Assistance + Simulator -----
            Item {
                id: rightArea
                anchors.left: modesCol.right; anchors.leftMargin: 18
                anchors.right: parent.right; anchors.rightMargin: 20
                y: 14; height: Math.max(490, dp.height - 28)

                // Top: Driver assistance
                Rectangle {
                    id: assistCard
                    width: parent.width; height: Math.max(270, parent.height * 0.57); radius: 24
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
                        id: assistGrid
                        x: 22; y: 38
                        width: parent.width - 44
                        columns: width > 520 ? 2 : 1
                        columnSpacing: 24; rowSpacing: 6
                        Repeater {
                            model: [
                                { t: "Adaptive Cruise Control", k: "acc" }, { t: "Lane Keeping Assist", k: "laneAssist" },
                                { t: "Collision Warning", k: "collisionWarn" }, { t: "Blind Spot Detection", k: "blindSpot" },
                                { t: "Speed Limit Info", k: "speedInfo" }, { t: "Parking Assistant", k: "parkAssist" }
                            ]
                            Item {
                                width: (assistGrid.width - (assistGrid.columns - 1) * assistGrid.columnSpacing) / assistGrid.columns
                                height: 44
                                Text {
                                    text: modelData.t; color: Theme.text; font.pixelSize: 15
                                    anchors.left: parent.left; anchors.right: tgl.left; anchors.rightMargin: 10
                                    anchors.verticalCenter: parent.verticalCenter; font.family: Theme.family
                                    elide: Text.ElideRight
                                }
                                Toggle {
                                    id: tgl
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    checked: Vehicle[modelData.k]
                                    onToggled: (val) => { Vehicle[modelData.k] = val; App.toast(modelData.t + (val ? " on" : " off"), Theme.g.drive) }
                                }
                            }
                        }
                    }

                    Rectangle {
                        anchors.bottom: cruiseRow.top; anchors.bottomMargin: 10
                        x: 22; width: parent.width - 44; height: 1
                        color: Theme.line; opacity: 0.5
                    }

                    Row {
                        id: cruiseRow
                        x: 22; anchors.bottom: parent.bottom; anchors.bottomMargin: 14; spacing: 14
                        width: parent.width - 44
                        Text {
                            text: "Cruise speed"; color: Theme.text; font.pixelSize: 16
                            anchors.verticalCenter: parent.verticalCenter; width: 110
                            font.weight: Font.DemiBold; font.family: Theme.family
                        }
                        Slide {
                            width: Math.max(120, Math.min(320, parent.width - 240))
                            anchors.verticalCenter: parent.verticalCenter
                            from: 30; to: 160; value: Vehicle.cruiseSpeed
                            onMoved: (val) => Vehicle.cruiseSpeed = Math.round(val / 5) * 5
                        }
                        Text {
                            text: Math.round(Vehicle.cruiseSpeed * Vehicle.unitK) + " " + Vehicle.speedUnit
                            color: Theme.ambient; font.pixelSize: 20; anchors.verticalCenter: parent.verticalCenter
                            font.weight: Font.DemiBold; font.family: Theme.family
                        }
                    }
                }

                // Bottom: Drive simulator
                Rectangle {
                    id: simCard
                    width: parent.width
                    anchors.top: assistCard.bottom; anchors.topMargin: 12
                    anchors.bottom: parent.bottom; radius: 24
                    color: Theme.glass; border.color: Theme.glassB; border.width: 1

                    Rectangle {
                        anchors.fill: parent; radius: parent.radius; color: "transparent"
                        border.width: 1; border.color: Theme.alpha(Theme.ambient, 0.12)
                    }

                    Text {
                        x: 22; y: 10
                        text: "DRIVE SIMULATOR   (keys: W accelerate \u00B7 S brake \u00B7 Z/X indicators)"
                        color: Theme.dim; font.pixelSize: 11; font.letterSpacing: 1
                        font.weight: Font.DemiBold; font.family: Theme.family
                    }

                    Flow {
                        x: 22; y: 32; width: parent.width - 44; spacing: 8
                        Row {
                            spacing: 6
                            Repeater {
                                model: ["P", "R", "N", "D"]
                                Btn { width: 58; height: 48; text: modelData; fontSize: 22; active: Vehicle.gear === modelData; onClicked: Vehicle.setGear(modelData) }
                            }
                        }
                        Btn {
                            width: 160; height: 48; fontSize: 14
                            text: Vehicle.autoDrive ? "Auto-drive: ON" : "Auto-drive: OFF"
                            active: Vehicle.autoDrive; tint: Theme.ok
                            onClicked: { if (Vehicle.autoDrive) { Vehicle.stopAutoDrive() } else Vehicle.startAutoDrive() }
                        }
                        Btn {
                            width: 135; height: 48; fontSize: 14
                            text: "Manual: " + (Vehicle.manual ? "ON" : "OFF")
                            active: Vehicle.manual; tint: Theme.ambient
                            onClicked: { Vehicle.manual = !Vehicle.manual; if (Vehicle.manual) Vehicle.autoDrive = false }
                        }
                    }

                    Flow {
                        x: 22; anchors.bottom: parent.bottom; anchors.bottomMargin: 10
                        width: parent.width - 44; spacing: 10
                        Btn {
                            width: Math.max(120, Math.min(180, (parent.width - 240) / 2))
                            height: 52; text: "ACCELERATE"; fontSize: 15; tint: Theme.ok; active: pressed
                            onPressedChanged: { if (pressed) { Vehicle.manual = true; Vehicle.autoDrive = false; if (Vehicle.gear === "P") Vehicle.setGear("D"); Vehicle.throttle = 1 } else Vehicle.throttle = 0 }
                        }
                        Btn {
                            width: Math.max(120, Math.min(180, (parent.width - 240) / 2))
                            height: 52; text: "BRAKE"; fontSize: 15; tint: Theme.danger; active: pressed
                            onPressedChanged: { if (pressed) { Vehicle.manual = true; Vehicle.autoDrive = false; Vehicle.brake = 1 } else Vehicle.brake = 0 }
                        }
                        Item {
                            width: regenRow.width; height: 52
                            Row {
                                id: regenRow
                                spacing: 6; anchors.verticalCenter: parent.verticalCenter
                                Text { text: "Regen:"; color: Theme.dim; font.pixelSize: 12; font.family: Theme.family; anchors.verticalCenter: parent.verticalCenter }
                                Repeater {
                                    model: ["Low", "Std", "High"]
                                    Btn { width: 56; height: 38; fontSize: 13; text: modelData; active: Vehicle.regen === index; tint: Theme.ok; onClicked: Vehicle.regen = index }
                                }
                            }
                        }
                    }
                }
            }
        }

        // ================= STACKED / NARROW VIEW =================
        Column {
            id: stackedCol
            visible: dp.isStacked
            x: 20; y: 14
            width: dp.width - 40
            spacing: 16

            // Modes Grid
            Grid {
                width: parent.width
                columns: width > 520 ? 2 : 1
                columnSpacing: 12; rowSpacing: 10
                Repeater {
                    model: dp.modes
                    Rectangle {
                        id: sModeCard
                        width: (parent.width - (parent.columns - 1) * 12) / parent.columns
                        height: 84; radius: 20
                        property color mcol: Vehicle.modeColor(modelData.name)
                        property bool sel: Vehicle.driveMode === modelData.name

                        color: sel ? Theme.alpha(mcol, 0.22) : Theme.glass
                        border.width: sel ? 2 : 1
                        border.color: sel ? mcol : Theme.glassB

                        Row {
                            x: 14; anchors.verticalCenter: parent.verticalCenter; spacing: 12
                            Rectangle {
                                width: 44; height: 44; radius: 22
                                color: Theme.alpha(sModeCard.mcol, sModeCard.sel ? 0.35 : 0.18)
                                border.color: sModeCard.mcol; border.width: sModeCard.sel ? 2 : 1
                                anchors.verticalCenter: parent.verticalCenter
                                Text { anchors.centerIn: parent; text: modelData.glyph; color: sModeCard.mcol; font.pixelSize: 22 }
                            }
                            Column {
                                anchors.verticalCenter: parent.verticalCenter; spacing: 2
                                width: sModeCard.width - 76
                                Text { text: modelData.name; color: sModeCard.sel ? "white" : Theme.text; font.pixelSize: 20; font.weight: Font.DemiBold; font.family: Theme.family }
                                Text { text: modelData.desc; color: Theme.dim; font.pixelSize: 11; width: parent.width; elide: Text.ElideRight; font.family: Theme.family }
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: { App.poke(); Vehicle.setMode(modelData.name) }
                        }
                    }
                }
            }

            // Driver assistance
            Rectangle {
                width: parent.width; height: 320; radius: 24
                color: Theme.glass; border.color: Theme.glassB; border.width: 1

                Text {
                    x: 20; y: 12; text: "DRIVER ASSISTANCE"
                    color: Theme.dim; font.pixelSize: 12; font.letterSpacing: 2
                    font.weight: Font.DemiBold; font.family: Theme.family
                }

                Grid {
                    id: sAssistGrid
                    x: 20; y: 36; width: parent.width - 40
                    columns: width > 520 ? 2 : 1
                    columnSpacing: 20; rowSpacing: 6
                    Repeater {
                        model: [
                            { t: "Adaptive Cruise Control", k: "acc" }, { t: "Lane Keeping Assist", k: "laneAssist" },
                            { t: "Collision Warning", k: "collisionWarn" }, { t: "Blind Spot Detection", k: "blindSpot" },
                            { t: "Speed Limit Info", k: "speedInfo" }, { t: "Parking Assistant", k: "parkAssist" }
                        ]
                        Item {
                            width: (sAssistGrid.width - (sAssistGrid.columns - 1) * sAssistGrid.columnSpacing) / sAssistGrid.columns
                            height: 42
                            Text { text: modelData.t; color: Theme.text; font.pixelSize: 14; anchors.verticalCenter: parent.verticalCenter; font.family: Theme.family }
                            Toggle {
                                anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                checked: Vehicle[modelData.k]
                                onToggled: (val) => { Vehicle[modelData.k] = val; App.toast(modelData.t + (val ? " on" : " off"), Theme.g.drive) }
                            }
                        }
                    }
                }

                Row {
                    x: 20; anchors.bottom: parent.bottom; anchors.bottomMargin: 14; spacing: 12
                    width: parent.width - 40
                    Text { text: "Cruise"; color: Theme.text; font.pixelSize: 15; anchors.verticalCenter: parent.verticalCenter; font.family: Theme.family }
                    Slide {
                        width: Math.max(100, parent.width - 150)
                        anchors.verticalCenter: parent.verticalCenter
                        from: 30; to: 160; value: Vehicle.cruiseSpeed
                        onMoved: (val) => Vehicle.cruiseSpeed = Math.round(val / 5) * 5
                    }
                    Text {
                        text: Math.round(Vehicle.cruiseSpeed * Vehicle.unitK) + " " + Vehicle.speedUnit
                        color: Theme.ambient; font.pixelSize: 18; anchors.verticalCenter: parent.verticalCenter; font.family: Theme.family
                    }
                }
            }

            // Simulator
            Rectangle {
                width: parent.width; height: 180; radius: 24
                color: Theme.glass; border.color: Theme.glassB; border.width: 1

                Text {
                    x: 20; y: 10; text: "DRIVE SIMULATOR"
                    color: Theme.dim; font.pixelSize: 12; font.letterSpacing: 2
                    font.weight: Font.DemiBold; font.family: Theme.family
                }

                Flow {
                    x: 20; y: 32; width: parent.width - 40; spacing: 8
                    Row {
                        spacing: 6
                        Repeater {
                            model: ["P", "R", "N", "D"]
                            Btn { width: 54; height: 46; text: modelData; fontSize: 20; active: Vehicle.gear === modelData; onClicked: Vehicle.setGear(modelData) }
                        }
                    }
                    Btn {
                        width: 150; height: 46; fontSize: 13
                        text: Vehicle.autoDrive ? "Auto-drive: ON" : "Auto-drive: OFF"
                        active: Vehicle.autoDrive; tint: Theme.ok
                        onClicked: { if (Vehicle.autoDrive) { Vehicle.stopAutoDrive() } else Vehicle.startAutoDrive() }
                    }
                }

                Row {
                    x: 20; anchors.bottom: parent.bottom; anchors.bottomMargin: 12
                    width: parent.width - 40; spacing: 10
                    Btn {
                        width: (parent.width - 10) / 2; height: 50; text: "ACCELERATE"; fontSize: 15; tint: Theme.ok; active: pressed
                        onPressedChanged: { if (pressed) { Vehicle.manual = true; Vehicle.autoDrive = false; if (Vehicle.gear === "P") Vehicle.setGear("D"); Vehicle.throttle = 1 } else Vehicle.throttle = 0 }
                    }
                    Btn {
                        width: (parent.width - 10) / 2; height: 50; text: "BRAKE"; fontSize: 15; tint: Theme.danger; active: pressed
                        onPressedChanged: { if (pressed) { Vehicle.manual = true; Vehicle.autoDrive = false; Vehicle.brake = 1 } else Vehicle.brake = 0 }
                    }
                }
            }
        }
    }
}
