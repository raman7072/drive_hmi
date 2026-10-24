import QtQuick

Item {
    id: bb
    width: 1120; height: 96

    Rectangle { width: parent.width; height: 1; color: Theme.line }

    function cycleSeat(side) {
        if (side === "L") Vehicle.seatHeatL = (Vehicle.seatHeatL + 1) % 4
        else Vehicle.seatHeatR = (Vehicle.seatHeatR + 1) % 4
    }

    // driver seat heat
    Btn { x: 18; y: 16; width: 74; height: 64; glyph: Theme.g.seat; text: Vehicle.seatHeatL > 0 ? Vehicle.seatHeatL : ""; active: Vehicle.seatHeatL > 0; tint: Theme.warn; onClicked: bb.cycleSeat("L") }
    // driver temp
    Btn { x: 100; y: 22; width: 56; height: 52; text: "\u2212"; fontSize: 28; onClicked: Vehicle.setDriverTemp(Vehicle.driverTemp - 0.5) }
    Text { x: 160; y: 0; width: 82; height: parent.height; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; text: Vehicle.driverTemp.toFixed(1); font.pixelSize: 30; color: Theme.text
        MouseArea { anchors.fill: parent; onClicked: App.goTo("climate") } }
    Btn { x: 246; y: 22; width: 56; height: 52; text: "+"; fontSize: 28; onClicked: Vehicle.setDriverTemp(Vehicle.driverTemp + 0.5) }
    // fan
    Btn { x: 318; y: 16; width: 92; height: 64; glyph: Theme.g.fan; text: Vehicle.fan; active: Vehicle.fan > 0; onClicked: Vehicle.fan = (Vehicle.fan + 1) % 8 }

    // center cluster: voice - home - mute
    Btn { x: 430; y: 14; width: 80; height: 68; round: true; glyph: Theme.g.mic; tint: Theme.ambient; onClicked: App.voiceRequested() }
    Rectangle {
        id: homeBtn
        x: 522; y: 8; width: 76; height: 80; radius: 26
        color: App.page === "home" ? Theme.ambient : Theme.panel2
        border.color: Theme.ambient; border.width: 2
        scale: hma.pressed ? 0.92 : 1
        Behavior on scale { NumberAnimation { duration: 100 } }
        Behavior on color { ColorAnimation { duration: 250 } }
        Text { anchors.centerIn: parent; text: Theme.g.home; font.pixelSize: 40; color: App.page === "home" ? "white" : Theme.ambient }
        MouseArea { id: hma; anchors.fill: parent; onClicked: { App.poke(); App.goTo("home") } }
    }
    Btn { x: 610; y: 14; width: 80; height: 68; round: true; glyph: Vehicle.muted ? Theme.g.mute : Theme.g.vol; active: Vehicle.muted; tint: Theme.warn; onClicked: Vehicle.muted = !Vehicle.muted }

    // volume
    Slide {
        x: 712; y: 28; width: 150
        value: Vehicle.muted ? 0 : Vehicle.volume
        onMoved: (val) => { Vehicle.volume = val; Vehicle.muted = false }
    }

    // passenger temp
    Btn { x: 878; y: 22; width: 56; height: 52; text: "\u2212"; fontSize: 28; onClicked: Vehicle.setPassTemp(Vehicle.passTemp - 0.5) }
    Text { x: 938; y: 0; width: 62; height: parent.height; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; text: Vehicle.passTemp.toFixed(1); font.pixelSize: 26; color: Theme.text }
    Btn { x: 1002; y: 22; width: 48; height: 52; text: "+"; fontSize: 26; onClicked: Vehicle.setPassTemp(Vehicle.passTemp + 0.5) }
    Btn { x: 1056; y: 16; width: 58; height: 64; glyph: Theme.g.seat; text: Vehicle.seatHeatR > 0 ? Vehicle.seatHeatR : ""; active: Vehicle.seatHeatR > 0; tint: Theme.warn; fontSize: 18; onClicked: bb.cycleSeat("R") }
}
