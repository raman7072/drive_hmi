import QtQuick

Item {
    id: sp
    implicitWidth: 1120; implicitHeight: 520
    width: parent ? parent.width : implicitWidth
    height: parent ? parent.height : implicitHeight

    property int tab: 0
    readonly property bool isCompact: width < 750

    component Row2: Item {
        id: r2
        property string label: ""
        property string hint: ""
        default property alias content: slot.data
        width: parent ? parent.width : 760; height: 68
        Column {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: slot.left
            anchors.rightMargin: 12
            spacing: 2
            Text { text: r2.label; color: Theme.text; font.pixelSize: 18; font.weight: Font.DemiBold; font.family: Theme.family; elide: Text.ElideRight }
            Text { visible: r2.hint !== ""; text: r2.hint; color: Theme.dim; font.pixelSize: 12; font.family: Theme.family; elide: Text.ElideRight }
        }
        Item { id: slot; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; height: 50; width: childrenRect.width }
        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.line; opacity: 0.5 }
    }

    // ================= TABS =================
    // Top horizontal tabs for compact screens
    Flickable {
        id: topTabs
        visible: sp.isCompact
        x: 16; y: 10; width: parent.width - 32; height: 54
        contentWidth: tabsRow.width
        clip: true; boundsBehavior: Flickable.StopAtBounds
        Row {
            id: tabsRow
            spacing: 8
            Repeater {
                model: ["Display", "Sound", "Connectivity", "System", "About"]
                Btn {
                    height: 48; text: modelData; fontSize: 15
                    active: sp.tab === index; onClicked: sp.tab = index
                }
            }
        }
    }

    // Left vertical tabs for wide screens
    Column {
        id: leftTabs
        visible: !sp.isCompact
        x: 20; y: 16; spacing: 10
        width: Math.min(220, Math.max(160, sp.width * 0.20))
        Repeater {
            model: ["Display", "Sound", "Connectivity", "System", "About"]
            Btn {
                width: leftTabs.width; height: Math.min(76, Math.max(54, (sp.height - 80) / 5))
                text: modelData; fontSize: 17
                active: sp.tab === index; onClicked: sp.tab = index
            }
        }
    }

    // ================= CONTENT CONTAINER =================
    Flickable {
        id: contentFlick
        anchors.top: sp.isCompact ? topTabs.bottom : parent.top
        anchors.topMargin: sp.isCompact ? 10 : 16
        anchors.left: sp.isCompact ? parent.left : leftTabs.right
        anchors.leftMargin: sp.isCompact ? 16 : 24
        anchors.right: parent.right
        anchors.rightMargin: sp.isCompact ? 16 : 24
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 14
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        contentWidth: width
        contentHeight: currentCol ? currentCol.height + 24 : 500

        property Item currentCol: {
            switch (sp.tab) {
            case 0: return colDisplay
            case 1: return colSound
            case 2: return colConnect
            case 3: return colSystem
            case 4: return colAbout
            default: return null
            }
        }

        // ---------- display ----------
        Column {
            id: colDisplay
            visible: sp.tab === 0
            width: contentFlick.width
            Row2 {
                label: "Brightness"
                Slide { width: Math.min(280, contentFlick.width * 0.45); from: 0.25; to: 1; value: Vehicle.brightness; onMoved: (v) => Vehicle.brightness = v }
            }
            Row2 {
                label: "Day / Night theme"; hint: "Applies to cluster, map and central display"
                Row {
                    spacing: 8
                    Btn { width: 110; height: 46; fontSize: 15; text: "Night"; active: Theme.night; onClicked: Theme.night = true }
                    Btn { width: 110; height: 46; fontSize: 15; text: "Day"; active: !Theme.night; onClicked: Theme.night = false }
                }
            }
            Row2 {
                label: "Ambient light colour"; hint: "Also synchronizes with the selected drive mode"
                Row {
                    spacing: 8
                    Repeater {
                        model: ["#00a8ff", "#2563eb", "#10b981", "#ff3355", "#8b5cf6", "#f97316", "#06b6d4", "#ec4899"]
                        Rectangle {
                            property bool isSel: Theme.ambient.toString() === Qt.color(modelData).toString()
                            width: 34; height: 34; radius: 17; color: modelData
                            anchors.verticalCenter: parent.verticalCenter
                            border.width: isSel ? 3 : 1
                            border.color: isSel ? "white" : Theme.line
                            scale: cma.pressed ? 0.88 : (cma.containsMouse ? 1.08 : 1.0)
                            Behavior on scale { NumberAnimation { duration: 90 } }

                            Rectangle {
                                visible: parent.isSel
                                anchors.fill: parent; anchors.margins: -4; radius: 21
                                color: "transparent"; border.width: 1.5; border.color: Theme.alpha(modelData, 0.6)
                            }
                            MouseArea { id: cma; anchors.fill: parent; hoverEnabled: true; onClicked: { App.poke(); Theme.ambient = modelData } }
                        }
                    }
                }
            }
            Row2 {
                label: "Screen saver"; hint: "Return to the ambient attract animation when idle"
                Toggle { checked: App.screensaver; onToggled: (v) => App.screensaver = v }
            }
            Row2 {
                label: "Idle time before screen saver"
                Row {
                    spacing: 8
                    Repeater {
                        model: [15, 30, 60, 120]
                        Btn { width: 68; height: 46; fontSize: 15; text: modelData + "s"; active: App.idleSeconds === modelData; onClicked: App.idleSeconds = modelData }
                    }
                }
            }
            Row2 {
                label: "Demo auto-drive"; hint: "Start simulated driving when the system wakes"
                Toggle { checked: Vehicle.demoAuto; onToggled: (v) => Vehicle.demoAuto = v }
            }
        }

        // ---------- sound ----------
        Column {
            id: colSound
            visible: sp.tab === 1
            width: contentFlick.width
            Row2 { label: "Volume"; Slide { width: Math.min(280, contentFlick.width * 0.45); value: Vehicle.volume; onMoved: (v) => { Vehicle.volume = v; Vehicle.muted = false } } }
            Row2 { label: "Bass"; Slide { width: Math.min(280, contentFlick.width * 0.45); value: Vehicle.bass; onMoved: (v) => Vehicle.bass = v } }
            Row2 { label: "Treble"; Slide { width: Math.min(280, contentFlick.width * 0.45); value: Vehicle.treble; onMoved: (v) => Vehicle.treble = v } }
            Row2 { label: "Balance"; hint: "left \u2194 right"; Slide { width: Math.min(280, contentFlick.width * 0.45); value: Vehicle.balance; onMoved: (v) => Vehicle.balance = v } }
            Row2 { label: "Fader"; hint: "front \u2194 rear"; Slide { width: Math.min(280, contentFlick.width * 0.45); value: Vehicle.fader; onMoved: (v) => Vehicle.fader = v } }
            Row2 { label: "Loudness"; Toggle { checked: Vehicle.loudness; onToggled: (v) => Vehicle.loudness = v } }
            Row2 {
                label: "Sound profile"
                Row {
                    spacing: 8
                    Btn { width: 84; height: 46; fontSize: 14; text: "Flat"; onClicked: { Vehicle.bass = 0.5; Vehicle.treble = 0.5 } }
                    Btn { width: 92; height: 46; fontSize: 14; text: "Concert"; onClicked: { Vehicle.bass = 0.7; Vehicle.treble = 0.65 } }
                    Btn { width: 84; height: 46; fontSize: 14; text: "Voice"; onClicked: { Vehicle.bass = 0.3; Vehicle.treble = 0.7 } }
                }
            }
        }

        // ---------- connectivity ----------
        Column {
            id: colConnect
            visible: sp.tab === 2
            width: contentFlick.width
            Row2 {
                label: "Bluetooth"; hint: Vehicle.deviceName + (Vehicle.phoneConnected ? " connected" : "")
                Toggle { checked: Vehicle.phoneConnected; onToggled: (v) => Vehicle.phoneConnected = v }
            }
            Row2 { id: wifiRow; label: "Wi-Fi"; Toggle { id: wifiT; checked: true; onToggled: (v) => wifiT.checked = v } }
            Row2 {
                label: "In-car hotspot"; hint: "Share 5G high-speed connectivity with passengers"
                Toggle { id: hotT; checked: false; onToggled: (v) => { hotT.checked = v; App.toast("Hotspot " + (v ? "on" : "off"), "\u2248") } }
            }
            Row2 {
                label: "Over-the-air updates"; hint: "Software version 1.0.0 is up to date"
                Btn { width: 180; height: 46; fontSize: 15; text: "Check updates"; onClicked: App.toast("Software is up to date", "\u2713") }
            }
            Row2 {
                label: "Paired devices"; hint: "My Phone \u00B7 Tablet \u00B7 Smartwatch"
                Btn { width: 180; height: 46; fontSize: 15; text: "Pair new device"; onClicked: App.toast("Pairing mode active\u2026", Theme.g.phone) }
            }
        }

        // ---------- system ----------
        Column {
            id: colSystem
            visible: sp.tab === 3
            width: contentFlick.width
            Row2 {
                label: "Distance & speed units"
                Row {
                    spacing: 8
                    Btn { width: 120; height: 46; fontSize: 15; text: "km  km/h"; active: !Vehicle.useMiles; onClicked: Vehicle.useMiles = false }
                    Btn { width: 120; height: 46; fontSize: 15; text: "mi  mph"; active: Vehicle.useMiles; onClicked: Vehicle.useMiles = true }
                }
            }
            Row2 {
                label: "Time format"
                Row {
                    spacing: 8
                    Btn { width: 100; height: 46; fontSize: 15; text: "24 h"; active: Vehicle.use24h; onClicked: Vehicle.use24h = true }
                    Btn { width: 100; height: 46; fontSize: 15; text: "12 h"; active: !Vehicle.use24h; onClicked: Vehicle.use24h = false }
                }
            }
            Row2 {
                label: "Language"; hint: "UI labels are English in this demo"
                Row {
                    spacing: 6
                    Repeater {
                        model: ["EN", "DE", "ES", "FR", "JA", "HI"]
                        Btn { width: 48; height: 46; fontSize: 14; text: modelData; active: index === 0; onClicked: App.toast("Language: " + modelData + " (demo)", "\u2713") }
                    }
                }
            }
            Row2 {
                label: "Replay welcome screen"
                Btn { width: 180; height: 46; fontSize: 15; text: "Sleep now"; onClicked: App.sleepRequested() }
            }
            Row2 {
                label: "Reset to defaults"
                Btn {
                    width: 180; height: 46; fontSize: 15; text: "Reset"; tint: Theme.danger
                    onClicked: {
                        Vehicle.brightness = 0.9; Vehicle.volume = 0.55; Vehicle.bass = 0.5; Vehicle.treble = 0.5; Vehicle.useMiles = false
                        Theme.night = true; Theme.ambient = Vehicle.modeColor(Vehicle.driveMode); App.toast("Settings reset", "\u2713")
                    }
                }
            }
        }

        // ---------- about ----------
        Column {
            id: colAbout
            visible: sp.tab === 4
            width: contentFlick.width
            spacing: 14
            Rectangle {
                width: parent.width; height: 100; radius: 22
                color: Theme.glass; border.color: Theme.glassB; border.width: 1
                Column {
                    anchors.centerIn: parent; spacing: 4
                    Text { text: "Drive HMI 1.0 (Adaptive Cockpit)"; color: Theme.text; font.pixelSize: 28; font.weight: Font.DemiBold; font.family: Theme.family }
                    Text { text: "Adaptive Multi-Display Qt Quick / QML Automotive Cluster & Infotainment"; color: Theme.dim; font.pixelSize: 14; font.family: Theme.family }
                }
            }
            Rectangle {
                width: parent.width; height: 320; radius: 22
                color: Theme.glass; border.color: Theme.glassB; border.width: 1
                Column {
                    anchors.fill: parent; anchors.margins: 16; spacing: 8
                    Text { text: "HARDWARE & KEYBOARD CONTROLS"; color: Theme.dim; font.pixelSize: 12; font.letterSpacing: 2; font.weight: Font.DemiBold; font.family: Theme.family }
                    Grid {
                        width: parent.width
                        columns: width > 540 ? 2 : 1; columnSpacing: 24; rowSpacing: 6
                        Repeater {
                            model: [
                                { k: "F1 - F4", a: "Display presets (1920x720, FHD, 1600x900, 900x1200)" },
                                { k: "F9 / F10", a: "Focus modes: Cluster Full / Center Full" },
                                { k: "F11", a: "Toggle Fullscreen mode" },
                                { k: "Arrows / Enter", a: "Navigate focus & select" },
                                { k: "Esc / Back", a: "Back to previous page" },
                                { k: "H key", a: "Go to Home dashboard" },
                                { k: "N / M / P / C / D", a: "Quick-jump: Nav, Media, Phone, Climate, Drive" },
                                { k: "W / S keys", a: "Manual throttle / brake simulator pedals" },
                                { k: "Z / X keys", a: "Left / right turn indicators" },
                                { k: "Space bar", a: "Activate voice assistant" }
                            ]
                            Row {
                                width: (parent.width - (parent.columns - 1) * parent.columnSpacing) / parent.columns
                                spacing: 10
                                Rectangle { width: 105; height: 26; radius: 6; color: Theme.alpha(Theme.panel2, 0.8); border.color: Theme.line; border.width: 1
                                    Text { anchors.centerIn: parent; text: modelData.k; color: Theme.ambient; font.pixelSize: 11; font.weight: Font.DemiBold; font.family: Theme.familyMono } }
                                Text { anchors.verticalCenter: parent.verticalCenter; text: modelData.a; color: Theme.text; font.pixelSize: 13; font.family: Theme.family; elide: Text.ElideRight; width: parent.width - 115 }
                            }
                        }
                    }
                }
            }
        }
    }
}
