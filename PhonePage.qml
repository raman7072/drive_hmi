import QtQuick

Item {
    id: pp
    width: 1120; height: 520
    property int tab: 2        // 0 recents, 1 contacts, 2 keypad, 3 favorites
    property string number: ""

    readonly property var keypadKeys: [
        { digit: "1", sub: "" },     { digit: "2", sub: "ABC" },  { digit: "3", sub: "DEF" },
        { digit: "4", sub: "GHI" },   { digit: "5", sub: "JKL" },  { digit: "6", sub: "MNO" },
        { digit: "7", sub: "PQRS" },  { digit: "8", sub: "TUV" },  { digit: "9", sub: "WXYZ" },
        { digit: "*", sub: "" },     { digit: "0", sub: "+" },    { digit: "#", sub: "" }
    ]

    Column {
        x: 20; y: 16; spacing: 10
        Repeater {
            model: ["Recents", "Contacts", "Keypad", "Favorites"]
            Btn { width: 190; height: 76; text: modelData; active: pp.tab === index; tint: Theme.ok; onClicked: pp.tab = index }
        }
        Rectangle {
            width: 190; height: 96; radius: 20
            color: Theme.glass; border.color: Theme.glassB; border.width: 1
            Column {
                anchors.centerIn: parent; spacing: 4
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter; spacing: 6
                    Rectangle {
                        width: 8; height: 8; radius: 4
                        color: Vehicle.phoneConnected ? Theme.ok : Theme.dimmer
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text { text: Vehicle.deviceName; color: Vehicle.phoneConnected ? Theme.ok : Theme.dim; font.pixelSize: 15; font.weight: Font.DemiBold; font.family: Theme.family }
                }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: Vehicle.phoneConnected ? "Connected \u00B7 5G" : "Disconnected"; color: Theme.dim; font.pixelSize: 13; font.family: Theme.family }
                Btn {
                    anchors.horizontalCenter: parent.horizontalCenter; width: 140; height: 32; fontSize: 13
                    text: Vehicle.phoneConnected ? "Disconnect" : "Connect"
                    onClicked: Vehicle.phoneConnected = !Vehicle.phoneConnected
                }
            }
        }
    }

    // ----- keypad -----
    Item {
        visible: pp.tab === 2
        x: 250; y: 10; width: 560; height: 500

        // Number input field
        Rectangle {
            x: 0; y: 0; width: 560; height: 76; radius: 22
            color: Theme.glass; border.color: Theme.glassB; border.width: 1.5

            Rectangle {
                anchors.fill: parent; radius: parent.radius; color: "transparent"
                border.width: 1; border.color: Theme.alpha("white", 0.12)
            }

            Text {
                anchors.centerIn: parent
                text: pp.number.length ? pp.number : "Enter number"
                color: pp.number.length ? Theme.text : Theme.dimmer
                font.pixelSize: 34; font.weight: Font.DemiBold; font.family: Theme.family
                letterSpacing: 2
            }
            Btn {
                anchors.right: parent.right; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter
                width: 64; height: 52; flat: true; glyph: "\u232B"; onClicked: pp.number = pp.number.slice(0, -1)
            }
        }

        // Keypad grid
        Grid {
            x: 55; y: 92; columns: 3; spacing: 14
            Repeater {
                model: pp.keypadKeys
                Rectangle {
                    id: keyBox
                    width: 140; height: 72; radius: 20
                    color: kma.pressed ? Theme.alpha(Theme.ok, 0.25) : (kma.containsMouse ? Theme.alpha(Theme.panel2, 0.9) : Theme.panel2)
                    border.width: 1
                    border.color: kma.containsMouse ? Theme.alpha(Theme.ok, 0.5) : Theme.line
                    scale: kma.pressed ? 0.94 : 1.0
                    Behavior on scale { NumberAnimation { duration: 90 } }
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Column {
                        anchors.centerIn: parent; spacing: 1
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.digit
                            font.pixelSize: 28; font.weight: Font.DemiBold; color: Theme.text; font.family: Theme.family
                        }
                        Text {
                            visible: modelData.sub.length > 0
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.sub
                            font.pixelSize: 11; font.weight: Font.DemiBold; color: Theme.dim; font.family: Theme.family
                            letterSpacing: 1.5
                        }
                    }
                    MouseArea {
                        id: kma; anchors.fill: parent; hoverEnabled: true
                        onClicked: { App.poke(); pp.number += modelData.digit }
                    }
                }
            }
        }

        Btn {
            x: 140; y: 442; width: 280; height: 58; round: true
            glyph: Theme.g.phone; text: "Call"; tint: Theme.ok; active: true
            fontSize: 20
            onClicked: if (pp.number.length) Vehicle.dial(pp.number, pp.number)
        }
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
            id: contactRow
            required property int index
            required property var modelData
            width: ListView.view.width; height: 74; radius: 18
            color: lma.pressed ? Theme.panel2 : (lma.containsMouse ? Theme.alpha(Theme.panel2, 0.7) : Theme.glass)
            border.color: Theme.glassB; border.width: 1
            Behavior on color { ColorAnimation { duration: 150 } }

            Row {
                x: 14; spacing: 16; anchors.verticalCenter: parent.verticalCenter
                Rectangle {
                    width: 48; height: 48; radius: 24; color: Theme.alpha(Theme.ok, 0.18); border.color: Theme.ok; border.width: 1.5
                    Text { anchors.centerIn: parent; text: contactRow.modelData.name[0]; color: Theme.ok; font.pixelSize: 22; font.weight: Font.DemiBold; font.family: Theme.family }
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter; spacing: 2
                    Text { text: contactRow.modelData.name; color: Theme.text; font.pixelSize: 20; font.weight: Font.DemiBold; font.family: Theme.family }
                    Text {
                        text: contactRow.modelData.time !== undefined ? ((contactRow.modelData.kind === "in" ? "\u2199 " : (contactRow.modelData.kind === "out" ? "\u2197 " : "\u2716 ")) + contactRow.modelData.time) : contactRow.modelData.number
                        color: contactRow.modelData.kind === "missed" ? Theme.danger : Theme.dim; font.pixelSize: 14; font.family: Theme.family
                    }
                }
            }
            Btn {
                anchors.right: parent.right; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter
                width: 64; height: 50; round: true; glyph: Theme.g.phone; tint: Theme.ok; active: true
                onClicked: {
                    var num = contactRow.modelData.number
                    if (num === undefined) for (var i = 0; i < Vehicle.contacts.length; i++) if (Vehicle.contacts[i].name === contactRow.modelData.name) num = Vehicle.contacts[i].number
                    Vehicle.dial(contactRow.modelData.name, num)
                }
            }
            MouseArea { id: lma; anchors.fill: parent; anchors.rightMargin: 90; hoverEnabled: true }
        }
    }

    // ----- messages / SOS panel -----
    Rectangle {
        x: 840; y: 14; width: 260; height: 492; radius: 24
        color: Theme.glass; border.color: Theme.glassB; border.width: 1

        Rectangle {
            anchors.fill: parent; radius: parent.radius; color: "transparent"
            border.width: 1; border.color: Theme.alpha(Theme.ambient, 0.15)
        }

        Text {
            x: 18; y: 14; text: "MESSAGES"
            color: Theme.dim; font.pixelSize: 13; font.letterSpacing: 2
            font.weight: Font.DemiBold; font.family: Theme.family
        }

        ListView {
            x: 8; y: 44; width: parent.width - 16; height: 340; clip: true; spacing: 6
            model: Vehicle.messages
            delegate: Rectangle {
                id: msgRow
                required property int index
                required property var modelData
                width: ListView.view.width; height: 82; radius: 14
                color: modelData.read ? (mma.containsMouse ? Theme.alpha(Theme.panel2, 0.6) : "transparent") : Theme.alpha(Theme.warn, 0.12)
                border.width: 1
                border.color: modelData.read ? Theme.line : Theme.warn

                Column {
                    x: 12; y: 8; width: parent.width - 24; spacing: 3
                    Text { text: msgRow.modelData.from + "  \u00B7  " + msgRow.modelData.time; color: Theme.text; font.pixelSize: 14; font.weight: msgRow.modelData.read ? Font.Normal : Font.DemiBold; font.family: Theme.family }
                    Text { text: msgRow.modelData.text; color: Theme.dim; font.pixelSize: 13; width: parent.width; wrapMode: Text.Wrap; maximumLineCount: 3; elide: Text.ElideRight; font.family: Theme.family }
                }
                MouseArea {
                    id: mma; anchors.fill: parent; hoverEnabled: true
                    onClicked: { App.poke(); Vehicle.markRead(msgRow.index); App.toast("Reading message aloud\u2026", Theme.g.msg) }
                }
            }
        }

        Btn {
            x: 18; y: 406; width: 224; height: 62; text: "SOS  Emergency Call"; fontSize: 16; tint: Theme.danger; active: true
            onClicked: Vehicle.dial("Emergency Services", "112")
        }
    }

    // ----- in-call overlay -----
    Rectangle {
        id: callUi
        anchors.fill: parent
        color: Theme.alpha("#05080e", 0.96)
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
                        SequentialAnimation {
                            PauseAnimation { duration: index * 500 }
                            ParallelAnimation {
                                NumberAnimation { target: parent; property: "scale"; from: 1; to: 1.9; duration: 1500; easing.type: Easing.OutCubic }
                                NumberAnimation { target: parent; property: "opacity"; from: 0.8; to: 0; duration: 1500 }
                            }
                        }
                    }
                }
            }
            Rectangle {
                anchors.centerIn: parent; width: 120; height: 120; radius: 60
                color: Theme.alpha(Theme.ok, 0.3); border.color: Theme.ok; border.width: 3
                Text { anchors.centerIn: parent; text: Vehicle.callName.length ? Vehicle.callName[0] : ""; color: Theme.ok; font.pixelSize: 56; font.weight: Font.DemiBold }
            }
        }
        Text { x: 0; y: 240; width: parent.width; horizontalAlignment: Text.AlignHCenter; text: Vehicle.callName; color: Theme.text; font.pixelSize: 44; font.weight: Font.DemiBold; font.family: Theme.family }
        Text {
            x: 0; y: 298; width: parent.width; horizontalAlignment: Text.AlignHCenter; color: Theme.dim; font.pixelSize: 24; font.family: Theme.family
            text: Vehicle.callState === "active" ? Vehicle.fmt(Vehicle.callSecs) : (Vehicle.callState === "incoming" ? "Incoming call\u2026" : "Calling\u2026")
        }
        Row {
            x: 560 - width / 2; y: 374; spacing: 24
            Btn { width: 120; height: 76; text: "Mute"; active: Vehicle.micMuted; tint: Theme.danger; onClicked: Vehicle.micMuted = !Vehicle.micMuted }
            Btn { width: 120; height: 76; text: "Speaker"; active: Vehicle.speakerOn; onClicked: Vehicle.speakerOn = !Vehicle.speakerOn }
            Btn { width: 120; height: 76; text: "Answer"; visible: Vehicle.callState === "incoming"; tint: Theme.ok; active: true; onClicked: Vehicle.answer() }
            Btn { width: 120; height: 76; text: Vehicle.callState === "incoming" ? "Decline" : "End"; tint: Theme.danger; active: true; onClicked: Vehicle.endCall() }
        }
    }
}
