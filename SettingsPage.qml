import QtQuick

Item {
    id: sp
    width: 1120; height: 520
    property int tab: 0

    component Row2: Item {
        id: r2
        property string label: ""
        property string hint: ""
        default property alias content: slot.data
        width: 760; height: 68
        Column {
            anchors.verticalCenter: parent.verticalCenter; spacing: 2
            Text { text: r2.label; color: Theme.text; font.pixelSize: 20; font.weight: Font.DemiBold; font.family: Theme.family }
            Text { visible: r2.hint !== ""; text: r2.hint; color: Theme.dim; font.pixelSize: 13; font.family: Theme.family }
        }
        Item { id: slot; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; width: 380; height: 50 }
        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.line; opacity: 0.5 }
    }

    Column {
        x: 20; y: 16; spacing: 10
        Repeater {
            model: ["Display", "Sound", "Connectivity", "System", "About"]
            Btn { width: 220; height: 76; text: modelData; active: sp.tab === index; onClicked: sp.tab = index }
        }
    }

    Item {
        x: 280; y: 10; width: 800; height: 500

        // ---------- display ----------
        Column {
            visible: sp.tab === 0; width: 760
            Row2 {
                label: "Brightness"
                Slide { anchors.right: parent.right; width: 300; from: 0.25; to: 1; value: Vehicle.brightness; onMoved: (v) => Vehicle.brightness = v }
            }
            Row2 {
                label: "Day / Night theme"; hint: "Applies to cluster, map and central display"
                Row {
                    anchors.right: parent.right; spacing: 8
                    Btn { width: 120; height: 50; fontSize: 17; text: "Night"; active: Theme.night; onClicked: Theme.night = true }
                    Btn { width: 120; height: 50; fontSize: 17; text: "Day"; active: !Theme.night; onClicked: Theme.night = false }
                }
            }
            Row2 {
                label: "Ambient light colour"; hint: "Also synchronizes with the selected drive mode"
                Row {
                    anchors.right: parent.right; spacing: 10
                    Repeater {
                        model: ["#00a8ff", "#2563eb", "#10b981", "#ff3355", "#8b5cf6", "#f97316", "#06b6d4", "#ec4899"]
                        Rectangle {
                            property bool isSel: Theme.ambient.toString() === Qt.color(modelData).toString()
                            width: 38; height: 38; radius: 19; color: modelData
                            anchors.verticalCenter: parent.verticalCenter
                            border.width: isSel ? 3 : 1
                            border.color: isSel ? "white" : Theme.line
                            scale: cma.pressed ? 0.88 : (cma.containsMouse ? 1.08 : 1.0)
                            Behavior on scale { NumberAnimation { duration: 90 } }

                            // Outer halo
                            Rectangle {
                                visible: parent.isSel
                                anchors.fill: parent; anchors.margins: -4; radius: 23
                                color: "transparent"; border.width: 1.5; border.color: Theme.alpha(modelData, 0.6)
                            }
                            MouseArea { id: cma; anchors.fill: parent; hoverEnabled: true; onClicked: { App.poke(); Theme.ambient = modelData } }
                        }
                    }
                }
            }
            Row2 {
                label: "Screen saver"; hint: "Return to the ambient attract animation when idle"
                Toggle { anchors.right: parent.right; checked: App.screensaver; onToggled: (v) => App.screensaver = v }
            }
            Row2 {
                label: "Idle time before screen saver"
                Row {
                    anchors.right: parent.right; spacing: 8
                    Repeater {
                        model: [15, 30, 60, 120]
                        Btn { width: 80; height: 50; fontSize: 16; text: modelData + "s"; active: App.idleSeconds === modelData; onClicked: App.idleSeconds = modelData }
                    }
                }
            }
            Row2 {
                label: "Demo auto-drive"; hint: "Start simulated driving when the system wakes"
                Toggle { anchors.right: parent.right; checked: Vehicle.demoAuto; onToggled: (v) => Vehicle.demoAuto = v }
            }
        }

        // ---------- sound ----------
        Column {
            visible: sp.tab === 1; width: 760
            Row2 { label: "Volume"; Slide { anchors.right: parent.right; width: 300; value: Vehicle.volume; onMoved: (v) => { Vehicle.volume = v; Vehicle.muted = false } } }
            Row2 { label: "Bass"; Slide { anchors.right: parent.right; width: 300; value: Vehicle.bass; onMoved: (v) => Vehicle.bass = v } }
            Row2 { label: "Treble"; Slide { anchors.right: parent.right; width: 300; value: Vehicle.treble; onMoved: (v) => Vehicle.treble = v } }
            Row2 { label: "Balance"; hint: "left \u2194 right"; Slide { anchors.right: parent.right; width: 300; value: Vehicle.balance; onMoved: (v) => Vehicle.balance = v } }
            Row2 { label: "Fader"; hint: "front \u2194 rear"; Slide { anchors.right: parent.right; width: 300; value: Vehicle.fader; onMoved: (v) => Vehicle.fader = v } }
            Row2 { label: "Loudness"; Toggle { anchors.right: parent.right; checked: Vehicle.loudness; onToggled: (v) => Vehicle.loudness = v } }
            Row2 {
                label: "Sound profile"
                Row {
                    anchors.right: parent.right; spacing: 8
                    Btn { width: 90; height: 50; fontSize: 15; text: "Flat"; onClicked: { Vehicle.bass = 0.5; Vehicle.treble = 0.5 } }
                    Btn { width: 100; height: 50; fontSize: 15; text: "Concert"; onClicked: { Vehicle.bass = 0.7; Vehicle.treble = 0.65 } }
                    Btn { width: 90; height: 50; fontSize: 15; text: "Voice"; onClicked: { Vehicle.bass = 0.3; Vehicle.treble = 0.7 } }
                }
            }
        }

        // ---------- connectivity ----------
        Column {
            visible: sp.tab === 2; width: 760
            Row2 {
                label: "Bluetooth"; hint: Vehicle.deviceName + (Vehicle.phoneConnected ? " connected" : "")
                Toggle { anchors.right: parent.right; checked: Vehicle.phoneConnected; onToggled: (v) => Vehicle.phoneConnected = v }
            }
            Row2 { id: wifiRow; label: "Wi-Fi"; Toggle { id: wifiT; anchors.right: parent.right; checked: true; onToggled: (v) => wifiT.checked = v } }
            Row2 {
                label: "In-car hotspot"; hint: "Share 5G high-speed connectivity with passengers"
                Toggle { id: hotT; anchors.right: parent.right; checked: false; onToggled: (v) => { hotT.checked = v; App.toast("Hotspot " + (v ? "on" : "off"), "\u2248") } }
            }
            Row2 {
                label: "Over-the-air updates"; hint: "Software version 1.0.0 is up to date"
                Btn { anchors.right: parent.right; width: 200; height: 50; fontSize: 16; text: "Check for updates"; onClicked: App.toast("Software is up to date", "\u2713") }
            }
            Row2 {
                label: "Paired devices"; hint: "My Phone \u00B7 Tablet \u00B7 Smartwatch"
                Btn { anchors.right: parent.right; width: 200; height: 50; fontSize: 16; text: "Pair new device"; onClicked: App.toast("Pairing mode active\u2026", Theme.g.phone) }
            }
        }

        // ---------- system ----------
        Column {
            visible: sp.tab === 3; width: 760
            Row2 {
                label: "Distance & speed units"
                Row {
                    anchors.right: parent.right; spacing: 8
                    Btn { width: 140; height: 50; fontSize: 17; text: "km  km/h"; active: !Vehicle.useMiles; onClicked: Vehicle.useMiles = false }
                    Btn { width: 140; height: 50; fontSize: 17; text: "mi  mph"; active: Vehicle.useMiles; onClicked: Vehicle.useMiles = true }
                }
            }
            Row2 {
                label: "Time format"
                Row {
                    anchors.right: parent.right; spacing: 8
                    Btn { width: 120; height: 50; fontSize: 17; text: "24 h"; active: Vehicle.use24h; onClicked: Vehicle.use24h = true }
                    Btn { width: 120; height: 50; fontSize: 17; text: "12 h"; active: !Vehicle.use24h; onClicked: Vehicle.use24h = false }
                }
            }
            Row2 {
                label: "Language"; hint: "UI labels are English in this demo"
                Row {
                    anchors.right: parent.right; spacing: 6
                    Repeater {
                        model: ["EN", "DE", "ES", "FR", "JA", "HI"]
                        Btn { width: 56; height: 50; fontSize: 15; text: modelData; active: index === 0; onClicked: App.toast("Language: " + modelData + " (demo)", "\u2713") }
                    }
                }
            }
            Row2 {
                label: "Replay welcome screen"
                Btn { anchors.right: parent.right; width: 200; height: 50; fontSize: 16; text: "Sleep now"; onClicked: App.sleepRequested() }
            }
            Row2 {
                label: "Reset to defaults"
                Btn {
                    anchors.right: parent.right; width: 200; height: 50; fontSize: 16; text: "Reset"; tint: Theme.danger
                    onClicked: {
                        Vehicle.brightness = 0.9; Vehicle.volume = 0.55; Vehicle.bass = 0.5; Vehicle.treble = 0.5; Vehicle.useMiles = false
                        Theme.night = true; Theme.ambient = Vehicle.modeColor(Vehicle.driveMode); App.toast("Settings reset", "\u2713")
                    }
                }
            }
        }

        // ---------- about ----------
        Column {
            visible: sp.tab === 4; width: 760; spacing: 16
            Rectangle {
                width: parent.width; height: 110; radius: 24
                color: Theme.glass; border.color: Theme.glassB; border.width: 1
                Column {
                    anchors.centerIn: parent; spacing: 4
                    Text { text: "Drive HMI 1.0"; color: Theme.text; font.pixelSize: 34; font.weight: Font.DemiBold; font.family: Theme.family }
                    Text { text: "High-Performance Qt Quick / QML Automotive Infotainment & Digital Cluster"; color: Theme.dim; font.pixelSize: 16; font.family: Theme.family }
                }
            }
            Rectangle {
                width: parent.width; height: 260; radius: 24
                color: Theme.glass; border.color: Theme.glassB; border.width: 1
                Column {
                    anchors.fill: parent; anchors.margins: 20; spacing: 10
                    Text { text: "HARDWARE & KEYBOARD CONTROLS (iDrive emulation)"; color: Theme.dim; font.pixelSize: 13; font.letterSpacing: 2; font.weight: Font.DemiBold; font.family: Theme.family }
                    Grid {
                        columns: 2; columnSpacing: 40; rowSpacing: 8
                        Repeater {
                            model: [
                                { k: "Arrows / Enter", a: "Navigate focus & select" },
                                { k: "Esc / Backspace", a: "Back to previous page" },
                                { k: "Space bar", a: "Activate voice assistant" },
                                { k: "H key", a: "Go to Home dashboard" },
                                { k: "N / M / P / C / D", a: "Quick-jump: Nav, Media, Phone, Climate, Drive" },
                                { k: "W / S keys", a: "Manual throttle / brake simulator pedals" },
                                { k: "Z / X keys", a: "Left / right turn indicators" },
                                { k: "F11 key", a: "Toggle fullscreen cockpit mode" }
                            ]
                            Row {
                                spacing: 12
                                Rectangle { width: 140; height: 28; radius: 6; color: Theme.alpha(Theme.panel2, 0.8); border.color: Theme.line; border.width: 1
                                    Text { anchors.centerIn: parent; text: modelData.k; color: Theme.ambient; font.pixelSize: 13; font.weight: Font.DemiBold; font.family: Theme.familyMono } }
                                Text { anchors.verticalCenter: parent.verticalCenter; text: modelData.a; color: Theme.text; font.pixelSize: 14; font.family: Theme.family }
                            }
                        }
                    }
                }
            }
        }
    }
}
