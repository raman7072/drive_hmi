import QtQuick

Item {
    id: vp
    implicitWidth: 1120; implicitHeight: 520
    width: parent ? parent.width : implicitWidth
    height: parent ? parent.height : implicitHeight

    function pressText(i) {
        var b = Vehicle.tires[i]
        return Vehicle.useMiles ? (b * 14.5038).toFixed(0) + " psi" : b.toFixed(1) + " bar"
    }

    readonly property bool isStacked: width < 840

    Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: width
        contentHeight: vp.isStacked ? (stackedCol.height + 40) : Math.max(height, 520)
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        // ================= WIDE / DUAL COLUMN VIEW =================
        Item {
            visible: !vp.isStacked
            anchors.fill: parent

            // ----- Left: Top-down car view -----
            Item {
                id: carView
                x: 10; y: 10
                width: Math.max(280, Math.min(360, vp.width * 0.34))
                height: 500

                property real cx: width / 2

                Glow { anchors.centerIn: body; width: 380; height: 500; color: Theme.ambient; strength: 0.16 }

                // Headlight projection beams (forward light cones)
                Item {
                    visible: Vehicle.lowBeamOn
                    x: carView.cx - 90; y: -36; width: 180; height: 80
                    Rectangle {
                        x: 18; y: 0; width: 44; height: 70; rotation: -6
                        gradient: Gradient {
                            GradientStop { position: 0; color: Theme.alpha("#b8dcff", 0.0) }
                            GradientStop { position: 1; color: Theme.alpha("#e8f3ff", 0.45) }
                        }
                    }
                    Rectangle {
                        x: 118; y: 0; width: 44; height: 70; rotation: 6
                        gradient: Gradient {
                            GradientStop { position: 0; color: Theme.alpha("#b8dcff", 0.0) }
                            GradientStop { position: 1; color: Theme.alpha("#e8f3ff", 0.45) }
                        }
                    }
                }

                // Car chassis body
                Rectangle {
                    id: body
                    x: carView.cx - 90; y: 20; width: 180; height: 460; radius: 80
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#1c2534" }
                        GradientStop { position: 0.5; color: "#131b26" }
                        GradientStop { position: 1.0; color: "#0c121b" }
                    }
                    border.color: Theme.alpha(Theme.ambient, 0.35); border.width: 2

                    // Windshields
                    Rectangle { x: 22; y: 110; width: 136; height: 70; radius: 26; color: Theme.alpha(Theme.ambient, 0.22); border.color: Theme.alpha(Theme.ambient, 0.3); border.width: 1 }
                    Rectangle { x: 22; y: 300; width: 136; height: 60; radius: 22; color: Theme.alpha(Theme.ambient, 0.16); border.color: Theme.alpha(Theme.ambient, 0.25); border.width: 1 }
                    Rectangle { x: 38; y: 195; width: 104; height: 90; radius: 12; color: Theme.alpha(Theme.line, 0.35) }

                    // Headlights / taillights
                    Rectangle { x: 26; y: 40; width: 36; height: 8; radius: 4; color: Vehicle.lowBeamOn ? "#e8f3ff" : Theme.dimmer }
                    Rectangle { x: 118; y: 40; width: 36; height: 8; radius: 4; color: Vehicle.lowBeamOn ? "#e8f3ff" : Theme.dimmer }
                    Rectangle { x: 26; y: 410; width: 36; height: 8; radius: 4; color: Vehicle.brake > 0.1 ? "#ff2a2a" : "#7a1717" }
                    Rectangle { x: 118; y: 410; width: 36; height: 8; radius: 4; color: Vehicle.brake > 0.1 ? "#ff2a2a" : "#7a1717" }

                    // Hood / trunk highlight
                    Rectangle { x: 40; y: 60; width: 100; height: 40; radius: 14; color: Vehicle.doors.hood ? Theme.alpha(Theme.warn, 0.4) : "transparent"; border.color: Vehicle.doors.hood ? Theme.warn : "transparent"; border.width: 1.5 }
                    Rectangle { x: 40; y: 370; width: 100; height: 34; radius: 14; color: Vehicle.doors.trunk ? Theme.alpha(Theme.warn, 0.4) : "transparent"; border.color: Vehicle.doors.trunk ? Theme.warn : "transparent"; border.width: 1.5 }
                }

                // Wheels + Pressure badges
                Repeater {
                    model: [
                        { ox: -128, y: 90, i: 0, isLeft: true },
                        { ox: 78, y: 90, i: 1, isLeft: false },
                        { ox: -128, y: 330, i: 2, isLeft: true },
                        { ox: 78, y: 330, i: 3, isLeft: false }
                    ]
                    Item {
                        x: carView.cx + modelData.ox; y: modelData.y; width: 50; height: 92
                        property bool low: Vehicle.tires[modelData.i] < 2.0
                        Rectangle {
                            anchors.fill: parent; radius: 12
                            color: "#151b26"; border.width: 2
                            border.color: parent.low ? Theme.danger : Theme.alpha(Theme.ok, 0.4)
                        }
                        // Pressure badge
                        Rectangle {
                            x: modelData.isLeft ? (carView.width < 320 ? -4 : -68) : (carView.width < 320 ? -24 : 44)
                            y: modelData.isLeft && carView.width < 320 ? -32 : 28
                            width: 68; height: 32; radius: 8
                            color: Theme.glass; border.color: parent.low ? Theme.danger : Theme.glassB; border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: vp.pressText(modelData.i)
                                font.pixelSize: 12; font.weight: Font.DemiBold; font.family: Theme.family
                                color: parent.parent.low ? Theme.danger : Theme.ok
                            }
                        }
                    }
                }

                // Doors: hinged at front edge, swing outward
                Repeater {
                    model: [
                        { k: "fl", ox: -90, y: 190, side: -1 },
                        { ox: 90, k: "fr", y: 190, side: 1 },
                        { k: "rl", ox: -90, y: 300, side: -1 },
                        { ox: 90, k: "rr", y: 300, side: 1 }
                    ]
                    Item {
                        x: carView.cx + modelData.ox; y: modelData.y; width: 5; height: 100
                        transformOrigin: Item.Top
                        rotation: Vehicle.doors[modelData.k] ? modelData.side * -1 * 32 : 0
                        Behavior on rotation { NumberAnimation { duration: 450; easing.type: Easing.OutBack } }
                        Rectangle {
                            anchors.fill: parent; radius: 2.5
                            color: Vehicle.doors[modelData.k] ? Theme.warn : Theme.dimmer
                        }
                        MouseArea {
                            x: -20; width: 44; height: parent.height
                            onClicked: { App.poke(); Vehicle.toggleDoor(modelData.k) }
                        }
                    }
                }

                Btn { x: carView.cx - 55; y: 12; width: 110; height: 36; fontSize: 13; text: "Hood"; active: Vehicle.doors.hood; tint: Theme.warn; onClicked: Vehicle.toggleDoor("hood") }
                Btn { x: carView.cx - 55; y: 455; width: 110; height: 36; fontSize: 13; text: "Tailgate"; active: Vehicle.doors.trunk; tint: Theme.warn; onClicked: Vehicle.toggleDoor("trunk") }
            }

            // ----- Right: Controls column -----
            Column {
                id: rightCol
                anchors.left: carView.right; anchors.leftMargin: 16
                anchors.right: parent.right; anchors.rightMargin: 20
                y: 12; spacing: 10

                Row {
                    width: parent.width; spacing: 10
                    Btn {
                        width: (parent.width - 10) / 2; height: 68
                        glyph: Vehicle.locked ? "\u26BF" : "\u25CE"
                        text: Vehicle.locked ? "Locked \u2013 tap to unlock" : "Unlocked \u2013 tap to lock"
                        fontSize: 16; active: Vehicle.locked; tint: Theme.ok
                        onClicked: Vehicle.locked = !Vehicle.locked
                    }
                    Btn {
                        width: (parent.width - 10) / 2; height: 68
                        text: "Lights: " + Vehicle.lightsMode; fontSize: 16
                        onClicked: Vehicle.lightsMode = Vehicle.lightsMode === "Auto" ? "Low" : (Vehicle.lightsMode === "Low" ? "Off" : "Auto")
                    }
                }

                Row {
                    width: parent.width; spacing: 10
                    Btn { width: (parent.width - 20) / 3; height: 56; text: "High beam"; fontSize: 15; active: Vehicle.highBeam; onClicked: Vehicle.highBeam = !Vehicle.highBeam }
                    Btn { width: (parent.width - 20) / 3; height: 56; text: "Fog lights"; fontSize: 15; active: Vehicle.fogLight; onClicked: Vehicle.fogLight = !Vehicle.fogLight }
                    Btn { width: (parent.width - 20) / 3; height: 56; text: "Hazard"; fontSize: 15; active: Vehicle.hazard; tint: Theme.danger; onClicked: Vehicle.hazard = !Vehicle.hazard }
                }

                // Power windows panel
                Rectangle {
                    width: parent.width; height: 124; radius: 22
                    color: Theme.glass; border.color: Theme.glassB; border.width: 1

                    Text {
                        x: 18; y: 10; text: "POWER WINDOWS"
                        color: Theme.dim; font.pixelSize: 12; font.letterSpacing: 2
                        font.weight: Font.DemiBold; font.family: Theme.family
                    }
                    Grid {
                        id: winGrid
                        x: 18; y: 32; width: parent.width - 36
                        columns: width > 520 ? 2 : 1
                        spacing: 6; columnSpacing: 24
                        Repeater {
                            model: ["Front left", "Front right", "Rear left", "Rear right"]
                            Row {
                                width: (winGrid.width - (winGrid.columns - 1) * winGrid.columnSpacing) / winGrid.columns
                                spacing: 8
                                Text { text: modelData; color: Theme.text; font.pixelSize: 13; width: 74; anchors.verticalCenter: parent.verticalCenter; font.family: Theme.family; elide: Text.ElideRight }
                                Slide {
                                    width: Math.max(90, parent.width - 120)
                                    height: 32; value: Vehicle.windows[index]
                                    onMoved: (val) => Vehicle.setWindow(index, val)
                                }
                                Text { text: Math.round(Vehicle.windows[index] * 100) + "%"; color: Theme.dim; font.pixelSize: 12; width: 36; anchors.verticalCenter: parent.verticalCenter; font.family: Theme.family }
                            }
                        }
                    }
                }

                // Service diagnostics
                Row {
                    width: parent.width; spacing: 10
                    Rectangle {
                        width: (parent.width - 20) / 3; height: 92; radius: 18
                        color: Theme.glass; border.color: Theme.glassB; border.width: 1
                        Column {
                            anchors.centerIn: parent; spacing: 2
                            Text { anchors.horizontalCenter: parent.horizontalCenter; text: Vehicle.serviceDays + " days"; color: Theme.text; font.pixelSize: 22; font.weight: Font.DemiBold; font.family: Theme.family }
                            Text { anchors.horizontalCenter: parent.horizontalCenter; text: "next service \u00B7 " + Math.round(Vehicle.serviceKm * Vehicle.unitK) + " " + Vehicle.distUnit; color: Theme.dim; font.pixelSize: 11; font.family: Theme.family }
                        }
                    }
                    Rectangle {
                        width: (parent.width - 20) / 3; height: 92; radius: 18
                        color: Theme.glass; border.color: Theme.glassB; border.width: 1
                        Column {
                            anchors.centerIn: parent; spacing: 4
                            Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Brake pads " + Vehicle.brakePads + "%"; color: Theme.text; font.pixelSize: 15; font.weight: Font.DemiBold; font.family: Theme.family }
                            Rectangle {
                                width: Math.min(130, parent.parent.width - 30); height: 8; radius: 4; color: Theme.alpha(Theme.bg, 0.8)
                                Rectangle { width: parent.width * Vehicle.brakePads / 100; height: parent.height; radius: 4; color: Vehicle.brakePads < 25 ? Theme.danger : Theme.ok }
                            }
                            Text { anchors.horizontalCenter: parent.horizontalCenter; text: Vehicle.washerOk ? "Washer fluid OK" : "Washer fluid low"; color: Vehicle.washerOk ? Theme.dim : Theme.warn; font.pixelSize: 11; font.family: Theme.family }
                        }
                    }
                    Rectangle {
                        width: (parent.width - 20) / 3; height: 92; radius: 18
                        color: Theme.glass; border.width: 1
                        border.color: Vehicle.alerts[0] === "All systems OK" ? Theme.glassB : Theme.warn
                        Column {
                            anchors.centerIn: parent; width: parent.width - 20; spacing: 2
                            Text { text: "CHECK CONTROL"; color: Theme.dim; font.pixelSize: 10; font.letterSpacing: 2; font.weight: Font.DemiBold; font.family: Theme.family }
                            Repeater {
                                model: Vehicle.alerts.slice(0, 2)
                                Text { text: (modelData === "All systems OK" ? "\u2713 " : "\u26A0 ") + modelData; color: modelData === "All systems OK" ? Theme.ok : Theme.warn; font.pixelSize: 12; width: parent.width; elide: Text.ElideRight; font.family: Theme.family }
                            }
                        }
                    }
                }

                // Calibration row
                Row {
                    width: parent.width; spacing: 10
                    Btn { width: (parent.width - 10) / 2; height: 50; text: "Tire pressure calibrate"; fontSize: 14; onClicked: { Vehicle.tires = [2.4, 2.4, 2.5, 2.5]; App.toast("Tire pressures calibrated", Theme.g.vehicle) } }
                    Btn { width: (parent.width - 10) / 2; height: 50; text: "Simulate low tire (RL)"; fontSize: 14; tint: Theme.warn; onClicked: { Vehicle.tires = [2.4, 2.4, 1.8, 2.5]; App.toast("Tire pressure low: rear left", "\u26A0") } }
                }
            }
        }

        // ================= STACKED / NARROW VIEW =================
        Column {
            id: stackedCol
            visible: vp.isStacked
            x: 20; y: 12
            width: vp.width - 40
            spacing: 16

            // Top-down Car Silhouette
            Item {
                width: parent.width; height: 480
                property real cx: width / 2

                Rectangle {
                    x: parent.cx - 85; y: 15; width: 170; height: 440; radius: 75
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#1c2534" }
                        GradientStop { position: 0.5; color: "#131b26" }
                        GradientStop { position: 1.0; color: "#0c121b" }
                    }
                    border.color: Theme.alpha(Theme.ambient, 0.35); border.width: 2

                    Rectangle { x: 20; y: 105; width: 130; height: 65; radius: 24; color: Theme.alpha(Theme.ambient, 0.22); border.color: Theme.alpha(Theme.ambient, 0.3); border.width: 1 }
                    Rectangle { x: 20; y: 290; width: 130; height: 55; radius: 20; color: Theme.alpha(Theme.ambient, 0.16); border.color: Theme.alpha(Theme.ambient, 0.25); border.width: 1 }
                }

                // Wheels + Badges
                Repeater {
                    model: [
                        { ox: -120, y: 80, i: 0 },
                        { ox: 75, y: 80, i: 1 },
                        { ox: -120, y: 310, i: 2 },
                        { ox: 75, y: 310, i: 3 }
                    ]
                    Item {
                        x: parent.cx + modelData.ox; y: modelData.y; width: 45; height: 86
                        property bool low: Vehicle.tires[modelData.i] < 2.0
                        Rectangle { anchors.fill: parent; radius: 10; color: "#151b26"; border.width: 2; border.color: parent.low ? Theme.danger : Theme.alpha(Theme.ok, 0.4) }
                        Rectangle {
                            x: -10; y: 24; width: 65; height: 30; radius: 8; color: Theme.glass; border.color: parent.low ? Theme.danger : Theme.glassB; border.width: 1
                            Text { anchors.centerIn: parent; text: vp.pressText(modelData.i); font.pixelSize: 11; font.weight: Font.DemiBold; color: parent.parent.low ? Theme.danger : Theme.ok; font.family: Theme.family }
                        }
                    }
                }

                Btn { x: parent.cx - 50; y: 10; width: 100; height: 34; fontSize: 13; text: "Hood"; active: Vehicle.doors.hood; tint: Theme.warn; onClicked: Vehicle.toggleDoor("hood") }
                Btn { x: parent.cx - 50; y: 430; width: 100; height: 34; fontSize: 13; text: "Tailgate"; active: Vehicle.doors.trunk; tint: Theme.warn; onClicked: Vehicle.toggleDoor("trunk") }
            }

            // Controls
            Row {
                width: parent.width; spacing: 10
                Btn { width: (parent.width - 10) / 2; height: 60; text: Vehicle.locked ? "Locked" : "Unlocked"; fontSize: 15; active: Vehicle.locked; tint: Theme.ok; onClicked: Vehicle.locked = !Vehicle.locked }
                Btn { width: (parent.width - 10) / 2; height: 60; text: "Lights: " + Vehicle.lightsMode; fontSize: 15; onClicked: Vehicle.lightsMode = Vehicle.lightsMode === "Auto" ? "Low" : (Vehicle.lightsMode === "Low" ? "Off" : "Auto") }
            }

            Row {
                width: parent.width; spacing: 8
                Btn { width: (parent.width - 16) / 3; height: 50; text: "High beam"; fontSize: 14; active: Vehicle.highBeam; onClicked: Vehicle.highBeam = !Vehicle.highBeam }
                Btn { width: (parent.width - 16) / 3; height: 50; text: "Fog lights"; fontSize: 14; active: Vehicle.fogLight; onClicked: Vehicle.fogLight = !Vehicle.fogLight }
                Btn { width: (parent.width - 16) / 3; height: 50; text: "Hazard"; fontSize: 14; active: Vehicle.hazard; tint: Theme.danger; onClicked: Vehicle.hazard = !Vehicle.hazard }
            }

            // Windows
            Rectangle {
                width: parent.width; height: 180; radius: 22
                color: Theme.glass; border.color: Theme.glassB; border.width: 1
                Text { x: 18; y: 10; text: "POWER WINDOWS"; color: Theme.dim; font.pixelSize: 12; font.letterSpacing: 2; font.weight: Font.DemiBold; font.family: Theme.family }
                Column {
                    x: 18; y: 34; width: parent.width - 36; spacing: 6
                    Repeater {
                        model: ["Front left", "Front right", "Rear left", "Rear right"]
                        Row {
                            width: parent.width; spacing: 8
                            Text { text: modelData; color: Theme.text; font.pixelSize: 13; width: 75; anchors.verticalCenter: parent.verticalCenter; font.family: Theme.family }
                            Slide { width: Math.max(90, parent.width - 120); height: 30; value: Vehicle.windows[index]; onMoved: (val) => Vehicle.setWindow(index, val) }
                            Text { text: Math.round(Vehicle.windows[index] * 100) + "%"; color: Theme.dim; font.pixelSize: 12; width: 35; anchors.verticalCenter: parent.verticalCenter; font.family: Theme.family }
                        }
                    }
                }
            }

            // Diagnostics & Calibration
            Row {
                width: parent.width; spacing: 10
                Btn { width: (parent.width - 10) / 2; height: 50; text: "Calibrate tires"; fontSize: 14; onClicked: { Vehicle.tires = [2.4, 2.4, 2.5, 2.5]; App.toast("Tires calibrated", Theme.g.vehicle) } }
                Btn { width: (parent.width - 10) / 2; height: 50; text: "Simulate low (RL)"; fontSize: 14; tint: Theme.warn; onClicked: { Vehicle.tires = [2.4, 2.4, 1.8, 2.5]; App.toast("Low tire: rear left", "\u26A0") } }
            }
        }
    }
}
