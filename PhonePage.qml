import QtQuick

Item {
    id: pp
    width: 1120; height: 520
    property int tab: 2        // 0 recents, 1 contacts, 2 keypad, 3 favorites
    property string number: ""

    Column {
        x: 20; y: 16; spacing: 10
        Repeater {
            model: ["Recents", "Contacts", "Keypad", "Favorites"]
            Btn { width: 190; height: 76; text: modelData; active: pp.tab === index; tint: Theme.ok; onClicked: pp.tab = index }
        }
        Rectangle {
            width: 190; height: 96; radius: 20; color: Theme.panel2; border.color: Theme.line
            Column {
                anchors.centerIn: parent; spacing: 4
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: Theme.g.phone + "  " + Vehicle.deviceName; color: Theme.ok; font.pixelSize: 16 }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: Vehicle.phoneConnected ? "Connected \u00B7 5G" : "Not connected"; color: Theme.dim; font.pixelSize: 14 }
                Btn { anchors.horizontalCenter: parent.horizontalCenter; width: 140; height: 32; fontSize: 13; text: Vehicle.phoneConnected ? "Disconnect" : "Connect"
                      onClicked: Vehicle.phoneConnected = !Vehicle.phoneConnected }
            }
        }
    }

    // ----- keypad -----
    Item {
        visible: pp.tab === 2
        x: 250; y: 10; width: 560; height: 500
        Rectangle { x: 0; y: 0; width: 560; height: 76; radius: 20; color: Theme.panel2; border.color: Theme.line
            Text { anchors.centerIn: parent; text: pp.number.length ? pp.number : "Enter number"; color: pp.number.length ? Theme.text : Theme.dim; font.pixelSize: 36 }
            Btn { anchors.right: parent.right; anchors.rightMargin: 10; anchors.verticalCenter: parent.verticalCenter; width: 70; height: 52; flat: true; glyph: "\u232B"; onClicked: pp.number = pp.number.slice(0, -1) } }
        Grid {
            x: 70; y: 92; columns: 3; spacing: 14
            Repeater {
                model: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "*", "0", "#"]
                Btn { width: 130; height: 72; text: modelData; fontSize: 30; onClicked: pp.number += modelData }
            }
        }
        Btn { x: 140; y: 440; width: 280; height: 60; round: true; glyph: Theme.g.phone; text: "Call"; tint: Theme.ok; active: true
              onClicked: if (pp.number.length) Vehicle.dial(pp.number, pp.number) }
    }

    // ----- lists -----
    ListView {
        id: list
        visible: pp.tab !== 2
        x: 250; y: 10; width: 560; height: 500; clip: true; spacing: 6
        model: {
            if (pp.tab === 0) return Vehicle.recents
            var out = []
            for (var i = 0; i < Vehicle.contacts.length; i++)
                if (pp.tab === 1 || Vehicle.contacts[i].fav) out.push(Vehicle.contacts[i])
            return out
        }
        delegate: Rectangle {
            required property int index
            required property var modelData
            width: ListView.view.width; height: 74; radius: 18
            color: lma.pressed ? Theme.panel2 : Theme.panel
            border.color: Theme.line
            Row {
                x: 14; spacing: 16; anchors.verticalCenter: parent.verticalCenter
                Rectangle { width: 48; height: 48; radius: 24; color: Theme.alpha(Theme.ok, 0.2); border.color: Theme.ok
                    Text { anchors.centerIn: parent; text: modelData.name[0]; color: Theme.ok; font.pixelSize: 22 } }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    Text { text: modelData.name; color: Theme.text; font.pixelSize: 22 }
                    Text { text: modelData.time !== undefined ? ((modelData.kind === "in" ? "\u2199 " : (modelData.kind === "out" ? "\u2197 " : "\u2716 ")) + modelData.time) : modelData.number
                           color: modelData.kind === "missed" ? Theme.danger : Theme.dim; font.pixelSize: 14 }
                }
            }
            Btn { anchors.right: parent.right; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter; width: 64; height: 50; round: true; glyph: Theme.g.phone; tint: Theme.ok; active: true
                  onClicked: {
                      var num = modelData.number
                      if (num === undefined) for (var i = 0; i < Vehicle.contacts.length; i++) if (Vehicle.contacts[i].name === modelData.name) num = Vehicle.contacts[i].number
                      Vehicle.dial(modelData.name, num)
                  } }
            MouseArea { id: lma; anchors.fill: parent; anchors.rightMargin: 90 }
        }
    }

    // ----- messages / SOS panel -----
    Rectangle {
        x: 840; y: 14; width: 260; height: 492; radius: 24; color: Theme.panel2; border.color: Theme.line
        Text { x: 18; y: 12; text: "Messages"; color: Theme.dim; font.pixelSize: 15; font.letterSpacing: 2 }
        ListView {
            x: 8; y: 44; width: parent.width - 16; height: 340; clip: true; spacing: 6
            model: Vehicle.messages
            delegate: Rectangle {
                required property int index
                required property var modelData
                width: ListView.view.width; height: 82; radius: 14
                color: modelData.read ? "transparent" : Theme.alpha(Theme.warn, 0.12)
                border.color: modelData.read ? Theme.line : Theme.warn
                Column {
                    x: 12; y: 8; width: parent.width - 24; spacing: 2
                    Text { text: modelData.from + "  \u00B7  " + modelData.time; color: Theme.text; font.pixelSize: 14; font.bold: !modelData.read }
                    Text { text: modelData.text; color: Theme.dim; font.pixelSize: 13; width: parent.width; wrapMode: Text.Wrap; maximumLineCount: 3; elide: Text.ElideRight }
                }
                MouseArea { anchors.fill: parent; onClicked: { App.poke(); Vehicle.markRead(index); App.toast("Reading message aloud\u2026", Theme.g.msg) } }
            }
        }
        Btn { x: 18; y: 400; width: 224; height: 64; text: "SOS  Emergency call"; fontSize: 16; tint: Theme.danger; active: true
              onClicked: Vehicle.dial("Emergency Services", "112") }
    }

    // ----- in-call overlay -----
    Rectangle {
        id: callUi
        anchors.fill: parent
        color: Theme.alpha(Theme.panel, 0.97)
        opacity: Vehicle.callState === "active" || Vehicle.callState === "dialing" || Vehicle.callState === "incoming" ? 1 : 0
        visible: opacity > 0.01
        Behavior on opacity { NumberAnimation { duration: 280 } }
        MouseArea { anchors.fill: parent }

        Item {
            x: 560 - 90; y: 40; width: 180; height: 180
            Repeater {
                model: 3
                Rectangle {
                    anchors.centerIn: parent; width: 120; height: 120; radius: 60
                    color: "transparent"; border.color: Theme.ok; border.width: 2
                    ParallelAnimation {
                        running: callUi.visible; loops: Animation.Infinite
                        SequentialAnimation { PauseAnimation { duration: index * 500 }
                            ParallelAnimation {
                                NumberAnimation { target: parent; property: "scale"; from: 1; to: 1.9; duration: 1500; easing.type: Easing.OutCubic }
                                NumberAnimation { target: parent; property: "opacity"; from: 0.8; to: 0; duration: 1500 } } }
                    }
                }
            }
            Rectangle { anchors.centerIn: parent; width: 120; height: 120; radius: 60; color: Theme.alpha(Theme.ok, 0.3); border.color: Theme.ok; border.width: 3
                Text { anchors.centerIn: parent; text: Vehicle.callName.length ? Vehicle.callName[0] : ""; color: Theme.ok; font.pixelSize: 56 } }
        }
        Text { x: 0; y: 240; width: parent.width; horizontalAlignment: Text.AlignHCenter; text: Vehicle.callName; color: Theme.text; font.pixelSize: 44 }
        Text { x: 0; y: 296; width: parent.width; horizontalAlignment: Text.AlignHCenter; color: Theme.dim; font.pixelSize: 24
               text: Vehicle.callState === "active" ? Vehicle.fmt(Vehicle.callSecs) : (Vehicle.callState === "incoming" ? "Incoming call\u2026" : "Calling\u2026") }
        Row {
            x: 560 - width / 2; y: 370; spacing: 24
            Btn { width: 120; height: 80; text: "Mute"; active: Vehicle.micMuted; tint: Theme.warn; onClicked: Vehicle.micMuted = !Vehicle.micMuted }
            Btn { width: 120; height: 80; text: "Speaker"; active: Vehicle.speakerOn; onClicked: Vehicle.speakerOn = !Vehicle.speakerOn }
            Btn { width: 120; height: 80; text: "Answer"; visible: Vehicle.callState === "incoming"; tint: Theme.ok; active: true; onClicked: Vehicle.answer() }
            Btn { width: 120; height: 80; text: Vehicle.callState === "incoming" ? "Decline" : "End"; tint: Theme.danger; active: true; onClicked: Vehicle.endCall() }
        }
    }
}
