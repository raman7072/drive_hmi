import QtQuick
import QtQuick.Controls

Item {
    id: vo
    anchors.fill: parent
    visible: opacity > 0.01
    opacity: 0
    Behavior on opacity { NumberAnimation { duration: 250 } }

    property bool open: false
    property string heard: ""
    property string reply: ""
    property bool listening: false
    property int demoIndex: 0
    readonly property var demos: ["Navigate to Home", "Call Anna", "Play music", "Set temperature to 22",
                                  "Activate sport mode", "Open energy", "Turn on seat heating", "What is the weather"]

    function show() {
        open = true; opacity = 1; heard = ""; reply = ""; listening = true
        typed.text = ""
        listenTimer.restart()
        typed.forceActiveFocus()
    }
    function hide() {
        open = false; opacity = 0; listening = false; listenTimer.stop()
        typed.focus = false
        if (parent) parent.forceActiveFocus()
    }

    function run(text) {
        var t = text.toLowerCase()
        heard = text
        var done = true
        if (t.indexOf("navigate") >= 0 || t.indexOf("take me") >= 0 || t.indexOf("route") >= 0) {
            var idx = 0
            for (var i = 0; i < Vehicle.places.length; i++)
                if (t.indexOf(Vehicle.places[i].name.toLowerCase()) >= 0) idx = i
            Vehicle.startNav(idx); App.goTo("nav"); reply = "Starting guidance to " + Vehicle.places[idx].name
        } else if (t.indexOf("call") >= 0 || t.indexOf("phone") >= 0 && t.indexOf("open") < 0) {
            var c = Vehicle.contacts[0]
            for (var j = 0; j < Vehicle.contacts.length; j++)
                if (t.indexOf(Vehicle.contacts[j].name.split(" ")[0].toLowerCase()) >= 0) c = Vehicle.contacts[j]
            Vehicle.dial(c.name, c.number); App.goTo("phone"); reply = "Calling " + c.name
        } else if (t.indexOf("pause") >= 0 || t.indexOf("stop music") >= 0) {
            Vehicle.playing = false; reply = "Music paused"
        } else if (t.indexOf("play") >= 0 || t.indexOf("music") >= 0) {
            Vehicle.playing = true; App.goTo("media"); reply = "Playing " + Vehicle.nowPlaying.title
        } else if (t.indexOf("temperature") >= 0 || t.indexOf("warmer") >= 0 || t.indexOf("cooler") >= 0 || t.indexOf("colder") >= 0) {
            var m = t.match(/(\d+(\.\d)?)/)
            if (m) Vehicle.setDriverTemp(parseFloat(m[1]))
            else if (t.indexOf("warmer") >= 0) Vehicle.setDriverTemp(Vehicle.driverTemp + 1)
            else Vehicle.setDriverTemp(Vehicle.driverTemp - 1)
            reply = "Temperature set to " + Vehicle.driverTemp.toFixed(1) + "\u00B0C"
        } else if (t.indexOf("sport") >= 0) { Vehicle.setMode("Sport"); reply = "Sport mode on" }
        else if (t.indexOf("eco") >= 0) { Vehicle.setMode("Eco Pro"); reply = "Eco Pro mode on" }
        else if (t.indexOf("comfort") >= 0) { Vehicle.setMode("Comfort"); reply = "Comfort mode on" }
        else if (t.indexOf("seat") >= 0) { Vehicle.seatHeatL = 3; Vehicle.seatHeatR = 3; reply = "Seat heating set to maximum" }
        else if (t.indexOf("defrost") >= 0) { Vehicle.defrostFront = true; reply = "Front defrost on" }
        else if (t.indexOf("unlock") >= 0) { Vehicle.locked = false; reply = "Vehicle unlocked" }
        else if (t.indexOf("lock") >= 0) { Vehicle.locked = true; reply = "Vehicle locked" }
        else if (t.indexOf("time") >= 0) reply = "It is " + Vehicle.timeText
        else if (t.indexOf("weather") >= 0) { App.goTo("apps"); reply = "Showing the weather" }
        else if (t.indexOf("open") >= 0 || t.indexOf("show") >= 0) {
            var pages = ["navigation:nav", "media:media", "phone:phone", "climate:climate", "vehicle:vehicle",
                         "drive:drive", "energy:energy", "apps:apps", "settings:settings"]
            reply = ""
            for (var k = 0; k < pages.length; k++) {
                var p = pages[k].split(":")
                if (t.indexOf(p[0]) >= 0) { App.goTo(p[1]); reply = "Opening " + p[0] }
            }
            if (reply === "") { reply = "Opening home"; App.goTo("home") }
        } else { reply = "Sorry, I didn't catch that."; done = false }
        listening = false
        closeTimer.interval = done ? 1800 : 2400
        closeTimer.restart()
    }

    Timer { id: listenTimer; interval: 2200; onTriggered: { vo.run(vo.demos[vo.demoIndex % vo.demos.length]); vo.demoIndex++ } }
    Timer { id: closeTimer; onTriggered: vo.hide() }

    Rectangle { anchors.fill: parent; color: "#000000"; opacity: 0.78 }
    MouseArea { anchors.fill: parent; onClicked: vo.hide() }

    // orb
    Item {
        id: orb
        x: 960 - 140; y: 120; width: 280; height: 280
        Repeater {
            model: 4
            Rectangle {
                anchors.centerIn: parent
                width: 110 + index * 46; height: width; radius: width / 2
                color: "transparent"; border.width: 2
                border.color: Theme.alpha(Theme.ambient, 0.7 - index * 0.15)
                SequentialAnimation on scale {
                    running: vo.visible; loops: Animation.Infinite
                    PauseAnimation { duration: index * 120 }
                    NumberAnimation { from: 0.9; to: vo.listening ? 1.25 : 1.05; duration: vo.listening ? 500 : 900; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 0.9; duration: vo.listening ? 500 : 900; easing.type: Easing.InOutSine }
                }
            }
        }
        Rectangle { anchors.centerIn: parent; width: 100; height: 100; radius: 50; color: Theme.ambient
            Text { anchors.centerIn: parent; text: Theme.g.mic; font.pixelSize: 52; color: "white" } }
    }

    // waveform
    Row {
        visible: vo.listening
        x: 960 - width / 2; y: 440; spacing: 6
        Repeater {
            model: 28
            Rectangle {
                width: 6; radius: 3; color: Theme.ambient; anchors.verticalCenter: parent.verticalCenter
                height: 8
                SequentialAnimation on height {
                    running: vo.listening; loops: Animation.Infinite
                    NumberAnimation { to: 10 + Math.abs(Math.sin(index * 0.7)) * 50; duration: 260 + (index % 5) * 70 }
                    NumberAnimation { to: 6; duration: 260 + (index % 4) * 80 }
                }
            }
        }
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 440; spacing: 14
        visible: !vo.listening
        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "\u201C" + vo.heard + "\u201D"; color: Theme.dim; font.pixelSize: 26 }
        Text { anchors.horizontalCenter: parent.horizontalCenter; text: vo.reply; color: "white"; font.pixelSize: 38; font.weight: Font.Light }
    }
    Text {
        visible: vo.listening
        anchors.horizontalCenter: parent.horizontalCenter; y: 520
        text: "Listening\u2026  say or type a command"; color: Theme.dim; font.pixelSize: 22
    }

    TextField {
        id: typed
        x: 960 - 300; y: 580; width: 600; height: 56
        placeholderText: "Type a command, e.g. \u201Cnavigate to airport\u201D"
        color: "white"; font.pixelSize: 22
        placeholderTextColor: "#6d7889"
        background: Rectangle { radius: 28; color: "#141a24"; border.color: typed.activeFocus ? Theme.ambient : Theme.line }
        leftPadding: 24
        onAccepted: { if (text.length > 0) { listenTimer.stop(); vo.run(text); text = "" } }
        onTextChanged: if (text.length > 0) listenTimer.stop()
    }
}
