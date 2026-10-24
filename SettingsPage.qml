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
        width: 760; height: 66
        Column { anchors.verticalCenter: parent.verticalCenter
            Text { text: r2.label; color: Theme.text; font.pixelSize: 21 }
            Text { visible: r2.hint !== ""; text: r2.hint; color: Theme.dim; font.pixelSize: 13 } }
        Item { id: slot; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; width: 380; height: 50 }
        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.line }
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
            Row2 { label: "Brightness"
                Slide { anchors.right: parent.right; width: 300; from: 0.25; to: 1; value: Vehicle.brightness; onMoved: (v) => Vehicle.brightness = v } }
            Row2 { label: "Day / Night theme"; hint: "Applies to the whole interface and map"
                Row { anchors.right: parent.right; spacing: 8
                    Btn { width: 120; height: 50; fontSize: 17; text: "Night"; active: Theme.night; onClicked: Theme.night = true }
                    Btn { width: 120; height: 50; fontSize: 17; text: "Day"; active: !Theme.night; onClicked: Theme.night = false } } }
            Row2 { label: "Ambient light colour"; hint: "Also changes with the selected drive mode"
                Row { anchors.right: parent.right; spacing: 8
                    Repeater { model: ["#1c69d4", "#2ecc71", "#ff3b30", "#a855f7", "#ff9f1a", "#19d3da", "#ff5fa2"]
                        Rectangle { width: 40; height: 40; radius: 20; color: modelData; anchors.verticalCenter: parent.verticalCenter
                            border.width: Theme.ambient.toString() === Qt.color(modelData).toString() ? 4 : 1
                            border.color: Theme.ambient.toString() === Qt.color(modelData).toString() ? "white" : Theme.line
                            scale: cma.pressed ? 0.88 : 1
                            Behavior on scale { NumberAnimation { duration: 90 } }
                            MouseArea { id: cma; anchors.fill: parent; onClicked: { App.poke(); Theme.ambient = modelData } } } } } }
            Row2 { label: "Screen saver"; hint: "Return to the welcome animation when idle"
                Toggle { anchors.right: parent.right; checked: App.screensaver; onToggled: (v) => App.screensaver = v } }
            Row2 { label: "Idle time before screen saver"
                Row { anchors.right: parent.right; spacing: 8
                    Repeater { model: [15, 30, 60, 120]
                        Btn { width: 80; height: 50; fontSize: 16; text: modelData + "s"; active: App.idleSeconds === modelData; onClicked: App.idleSeconds = modelData } } } }
            Row2 { label: "Demo auto-drive"; hint: "Start simulated driving when the system wakes"
                Toggle { anchors.right: parent.right; checked: Vehicle.demoAuto; onToggled: (v) => Vehicle.demoAuto = v } }
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
            Row2 { label: "Sound profile"
                Row { anchors.right: parent.right; spacing: 8
                    Btn { width: 90; height: 50; fontSize: 15; text: "Flat"; onClicked: { Vehicle.bass = 0.5; Vehicle.treble = 0.5 } }
                    Btn { width: 100; height: 50; fontSize: 15; text: "Concert"; onClicked: { Vehicle.bass = 0.7; Vehicle.treble = 0.65 } }
                    Btn { width: 90; height: 50; fontSize: 15; text: "Voice"; onClicked: { Vehicle.bass = 0.3; Vehicle.treble = 0.7 } } } }
        }

        // ---------- connectivity ----------
        Column {
            visible: sp.tab === 2; width: 760
            Row2 { label: "Bluetooth"; hint: Vehicle.deviceName + (Vehicle.phoneConnected ? " connected" : "")
                Toggle { anchors.right: parent.right; checked: Vehicle.phoneConnected; onToggled: (v) => Vehicle.phoneConnected = v } }
            Row2 { id: wifiRow; label: "Wi-Fi"; Toggle { id: wifiT; anchors.right: parent.right; checked: true; onToggled: (v) => wifiT.checked = v } }
            Row2 { label: "In-car hotspot"; hint: "Share 5G with passengers"; Toggle { id: hotT; anchors.right: parent.right; checked: false; onToggled: (v) => { hotT.checked = v; App.toast("Hotspot " + (v ? "on" : "off"), "\u2248") } } }
            Row2 { label: "Over-the-air updates"; hint: "Software version 1.0.0 is up to date"
                Btn { anchors.right: parent.right; width: 200; height: 50; fontSize: 16; text: "Check for updates"; onClicked: App.toast("Software is up to date", "\u2713") } }
            Row2 { label: "Paired devices"; hint: "My Phone \u00B7 Tablet \u00B7 Smartwatch"
                Btn { anchors.right: parent.right; width: 200; height: 50; fontSize: 16; text: "Pair new device"; onClicked: App.toast("Pairing mode active\u2026", Theme.g.phone) } }
        }

        // ---------- system ----------
        Column {
            visible: sp.tab === 3; width: 760
            Row2 { label: "Distance & speed units"
                Row { anchors.right: parent.right; spacing: 8
                    Btn { width: 140; height: 50; fontSize: 17; text: "km  km/h"; active: !Vehicle.useMiles; onClicked: Vehicle.useMiles = false }
                    Btn { width: 140; height: 50; fontSize: 17; text: "mi  mph"; active: Vehicle.useMiles; onClicked: Vehicle.useMiles = true } } }
            Row2 { label: "Time format"
                Row { anchors.right: parent.right; spacing: 8
                    Btn { width: 120; height: 50; fontSize: 17; text: "24 h"; active: Vehicle.use24h; onClicked: Vehicle.use24h = true }
                    Btn { width: 120; height: 50; fontSize: 17; text: "12 h"; active: !Vehicle.use24h; onClicked: Vehicle.use24h = false } } }
            Row2 { label: "Language"; hint: "UI labels are English in this demo"
                Row { anchors.right: parent.right; spacing: 6
                    Repeater { model: ["EN", "DE", "ES", "FR", "JA", "HI"]
                        Btn { width: 56; height: 50; fontSize: 15; text: modelData; active: index === 0; onClicked: App.toast("Language: " + modelData + " (demo)", "\u2713") } } } }
            Row2 { label: "Replay welcome screen"
                Btn { anchors.right: parent.right; width: 200; height: 50; fontSize: 16; text: "Sleep now"; onClicked: App.sleepRequested() } }
            Row2 { label: "Reset to defaults"
                Btn { anchors.right: parent.right; width: 200; height: 50; fontSize: 16; text: "Reset"; tint: Theme.warn
                      onClicked: { Vehicle.brightness = 0.9; Vehicle.volume = 0.55; Vehicle.bass = 0.5; Vehicle.treble = 0.5; Vehicle.useMiles = false
                                   Theme.night = true; Theme.ambient = Vehicle.modeColor(Vehicle.driveMode); App.toast("Settings reset", "\u2713") } } }
        }

        // ---------- about ----------
        Column {
            visible: sp.tab === 4; width: 760; spacing: 10
            Text { text: "Drive HMI 1.0"; color: Theme.text; font.pixelSize: 36 }
            Text { text: "Qt Quick / QML \u00B7 digital cluster + control display"; color: Theme.dim; font.pixelSize: 18 }
            Text { width: 700; wrapMode: Text.Wrap; color: Theme.dim; font.pixelSize: 16
                   text: "Keyboard (iDrive controller emulation): arrows + Enter = navigate, Esc/Backspace = back, Space = voice, H = home, N/M/P/C/D = Navigation/Media/Phone/Climate/Driving, W/S = accelerate/brake, Z/X = indicators, F11 = full screen." }
        }
    }
}
