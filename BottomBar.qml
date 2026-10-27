import QtQuick

// Bottom control bar – glassmorphism, responsive driver/passenger zones, glowing home button, volume
Item {
    id: bb
    implicitWidth: 1120; implicitHeight: 96

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
        anchors.top: parent.top
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

    // ---- Left zone: driver HVAC ----
    Row {
        id: leftZone
        anchors.left: parent.left; anchors.leftMargin: Math.max(8, bb.width * 0.012)
        anchors.verticalCenter: parent.verticalCenter
        spacing: bb.width < 750 ? 4 : 8

        Btn {
            width: bb.width < 650 ? 54 : 64; height: 64; glyph: Theme.g.seat
            text: Vehicle.seatHeatL > 0 ? Vehicle.seatHeatL : ""
            active: Vehicle.seatHeatL > 0; tint: Theme.heat
            fontSize: 16
            onClicked: bb.cycleSeat("L")
        }

        Btn {
            width: 42; height: 50; text: "\u2212"; fontSize: 24
            onClicked: Vehicle.setDriverTemp(Vehicle.driverTemp - 0.5)
        }

        Item {
            width: bb.width < 650 ? 68 : 82; height: 64
            Text {
                anchors.centerIn: parent
                text: Vehicle.driverTemp.toFixed(1) + "\u00B0"
                font.pixelSize: bb.width < 650 ? 22 : 26
                font.weight: Font.DemiBold; color: Theme.text; font.family: Theme.family
            }
            MouseArea { anchors.fill: parent; onClicked: App.goTo("climate") }
        }

        Btn {
            width: 42; height: 50; text: "+"; fontSize: 24
            onClicked: Vehicle.setDriverTemp(Vehicle.driverTemp + 0.5)
        }

        Btn {
            visible: bb.width >= 720
            width: 76; height: 64; glyph: Theme.g.fan
            text: Vehicle.fan > 0 ? Vehicle.fan : "off"
            active: Vehicle.fan > 0; tint: Theme.ambient; fontSize: 16
            onClicked: Vehicle.fan = (Vehicle.fan + 1) % 8
        }
    }

    // ---- Center cluster: voice – home – mute – volume ----
    Row {
        id: centerZone
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: bb.width < 750 ? 6 : 10

        Btn {
            width: bb.width < 650 ? 58 : 68; height: 64
            round: true; glyph: Theme.g.mic; tint: Theme.ambient
            onClicked: App.voiceRequested()
        }

        // Home button – glowing luxury automotive pill
        Rectangle {
            id: homeBtn
            width: bb.width < 650 ? 68 : 76; height: width; radius: 24
            color: App.page === "home" ? Theme.ambient : Theme.panel2
            border.color: Theme.ambient; border.width: 2
            anchors.verticalCenter: parent.verticalCenter
            scale: hma.pressed ? 0.90 : (hma.containsMouse ? 1.05 : 1.0)
            Behavior on scale { NumberAnimation { duration: 110; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: 240 } }

            // inner glow ring when active
            Rectangle {
                visible: App.page === "home"
                anchors.fill: parent; radius: parent.radius
                color: "transparent"
                border.width: 2; border.color: Theme.alpha(Theme.ambient, 0.45)
                scale: 1.15
            }
            Text {
                anchors.centerIn: parent; text: Theme.g.home
                font.pixelSize: bb.width < 650 ? 30 : 36
                color: App.page === "home" ? "white" : Theme.ambient
            }
            MouseArea {
                id: hma; anchors.fill: parent; hoverEnabled: true
                onClicked: { App.poke(); App.goTo("home") }
            }
        }

        Btn {
            width: bb.width < 650 ? 58 : 68; height: 64
            round: true; glyph: Vehicle.muted ? Theme.g.mute : Theme.g.vol
            active: Vehicle.muted; tint: Theme.danger
            onClicked: Vehicle.muted = !Vehicle.muted
        }

        // Volume slider – flexes width
        Slide {
            visible: bb.width >= 560
            anchors.verticalCenter: parent.verticalCenter
            width: Math.max(76, Math.min(160, bb.width > 920 ? (bb.width - 760) * 0.35 + 85 : 85))
            value: Vehicle.muted ? 0 : Vehicle.volume
            tint: Theme.ambient
            onMoved: (val) => { Vehicle.volume = val; Vehicle.muted = false }
        }
    }

    // ---- Right zone: passenger HVAC ----
    Row {
        id: rightZone
        visible: bb.width >= 860
        anchors.right: parent.right; anchors.rightMargin: Math.max(8, bb.width * 0.012)
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        Btn {
            width: 42; height: 50; text: "\u2212"; fontSize: 24
            onClicked: Vehicle.setPassTemp(Vehicle.passTemp - 0.5)
        }

        Item {
            width: 76; height: 64
            Text {
                anchors.centerIn: parent
                text: Vehicle.passTemp.toFixed(1) + "\u00B0"
                font.pixelSize: 24; font.weight: Font.DemiBold; color: Theme.text; font.family: Theme.family
            }
            MouseArea { anchors.fill: parent; onClicked: App.goTo("climate") }
        }

        Btn {
            width: 42; height: 50; text: "+"; fontSize: 24
            onClicked: Vehicle.setPassTemp(Vehicle.passTemp + 0.5)
        }

        Btn {
            width: 64; height: 64; glyph: Theme.g.seat
            text: Vehicle.seatHeatR > 0 ? Vehicle.seatHeatR : ""; active: Vehicle.seatHeatR > 0
            tint: Theme.heat; fontSize: 16
            onClicked: bb.cycleSeat("R")
        }
    }
}

