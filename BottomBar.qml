import QtQuick

// Bottom control bar – glassmorphism, temp controls, home + mic + mute, volume
Item {
    id: bb
    width: 1120; height: 96

    // Smoked glass footer background
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.night ? Qt.rgba(0.05, 0.07, 0.13, 0.50) : Qt.rgba(0.92, 0.95, 0.98, 0.70) }
            GradientStop { position: 1.0; color: Theme.night ? Qt.rgba(0.08, 0.12, 0.20, 0.85) : Qt.rgba(0.96, 0.98, 1.0, 0.90) }
        }
    }

    // top separator with ambient gradient
    Rectangle {
        width: parent.width; height: 1
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Theme.line }
            GradientStop { position: 0.5; color: Theme.alpha(Theme.ambient, 0.45) }
            GradientStop { position: 1.0; color: Theme.line }
        }
        opacity: 0.7
    }

    function cycleSeat(side) {
        if (side === "L") Vehicle.seatHeatL = (Vehicle.seatHeatL + 1) % 4
        else Vehicle.seatHeatR = (Vehicle.seatHeatR + 1) % 4
    }

    // ---- Left zone: driver temp ----
    // seat heat
    Btn { x: 14; y: 14; width: 70; height: 68; glyph: Theme.g.seat
          text: Vehicle.seatHeatL > 0 ? Vehicle.seatHeatL : ""
          active: Vehicle.seatHeatL > 0; tint: Theme.heat; onClicked: bb.cycleSeat("L") }

    Btn { x: 90; y: 22; width: 46; height: 52; text: "\u2212"; fontSize: 26; onClicked: Vehicle.setDriverTemp(Vehicle.driverTemp - 0.5) }
    Item {
        x: 140; y: 0; width: 88; height: parent.height
        Text {
            anchors.centerIn: parent
            text: Vehicle.driverTemp.toFixed(1) + "\u00B0"
            font.pixelSize: 28; font.weight: Font.DemiBold; color: Theme.text
        }
        MouseArea { anchors.fill: parent; onClicked: App.goTo("climate") }
    }
    Btn { x: 232; y: 22; width: 46; height: 52; text: "+"; fontSize: 26; onClicked: Vehicle.setDriverTemp(Vehicle.driverTemp + 0.5) }

    // fan speed
    Btn { x: 286; y: 14; width: 88; height: 68; glyph: Theme.g.fan; text: Vehicle.fan > 0 ? Vehicle.fan : "off"
          active: Vehicle.fan > 0; tint: Theme.ambient; onClicked: Vehicle.fan = (Vehicle.fan + 1) % 8 }

    // ---- Center cluster: voice – home – mute ----
    Btn {
        x: 402; y: 14; width: 76; height: 68
        round: true; glyph: Theme.g.mic; tint: Theme.ambient
        onClicked: App.voiceRequested()
    }

    // Home button – glowing pill
    Rectangle {
        id: homeBtn
        x: 490; y: 8; width: 80; height: 80; radius: 26
        color: App.page === "home" ? Theme.ambient : Theme.panel2
        border.color: Theme.ambient; border.width: 2
        scale: hma.pressed ? 0.90 : (hma.containsMouse ? 1.04 : 1.0)
        Behavior on scale { NumberAnimation { duration: 110; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation { duration: 260 } }

        // inner glow ring when active
        Rectangle {
            visible: App.page === "home"
            anchors.fill: parent; radius: parent.radius
            color: "transparent"
            border.width: 2; border.color: Theme.alpha(Theme.ambient, 0.45)
            scale: 1.15
        }
        Text {
            anchors.centerIn: parent; text: Theme.g.home; font.pixelSize: 38
            color: App.page === "home" ? "white" : Theme.ambient
        }
        MouseArea { id: hma; anchors.fill: parent; hoverEnabled: true; onClicked: { App.poke(); App.goTo("home") } }
    }

    Btn { x: 582; y: 14; width: 76; height: 68
          round: true; glyph: Vehicle.muted ? Theme.g.mute : Theme.g.vol
          active: Vehicle.muted; tint: Theme.danger; onClicked: Vehicle.muted = !Vehicle.muted }

    // Volume slider
    Slide {
        x: 676; y: 28; width: 148
        value: Vehicle.muted ? 0 : Vehicle.volume
        tint: Theme.ambient
        onMoved: (val) => { Vehicle.volume = val; Vehicle.muted = false }
    }

    // ---- Right zone: passenger temp ----
    Btn { x: 842; y: 22; width: 46; height: 52; text: "\u2212"; fontSize: 26; onClicked: Vehicle.setPassTemp(Vehicle.passTemp - 0.5) }
    Item {
        x: 892; y: 0; width: 80; height: parent.height
        Text {
            anchors.centerIn: parent
            text: Vehicle.passTemp.toFixed(1) + "\u00B0"
            font.pixelSize: 24; font.weight: Font.DemiBold; color: Theme.text
        }
        MouseArea { anchors.fill: parent; onClicked: App.goTo("climate") }
    }
    Btn { x: 976; y: 22; width: 46; height: 52; text: "+"; fontSize: 26; onClicked: Vehicle.setPassTemp(Vehicle.passTemp + 0.5) }
    Btn { x: 1026; y: 14; width: 78; height: 68; glyph: Theme.g.seat
          text: Vehicle.seatHeatR > 0 ? Vehicle.seatHeatR : ""; active: Vehicle.seatHeatR > 0
          tint: Theme.heat; fontSize: 18; onClicked: bb.cycleSeat("R") }
}

