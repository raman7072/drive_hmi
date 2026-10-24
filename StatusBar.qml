import QtQuick

Item {
    id: sb
    width: 1120; height: 64
    property string title: ""

    Btn {
        x: 14; y: 8; width: 118; height: 48
        flat: true; glyph: Theme.g.back; text: "Back"; fontSize: 20
        visible: App.page !== "home"
        onClicked: App.goTo("home")
    }
    Text {
        x: App.page === "home" ? 30 : 146
        anchors.verticalCenter: parent.verticalCenter
        text: sb.title
        color: Theme.text; font.pixelSize: 28; font.family: Theme.family
        Behavior on x { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
    }

    Row {
        anchors.right: parent.right; anchors.rightMargin: 28
        anchors.verticalCenter: parent.verticalCenter
        spacing: 24

        Text {
            visible: Vehicle.unread > 0
            anchors.verticalCenter: parent.verticalCenter
            text: Theme.g.msg + " " + Vehicle.unread
            color: Theme.warn; font.pixelSize: 20
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "\u25CF"
            color: Vehicle.phoneConnected ? Theme.ambient : Theme.dim
            font.pixelSize: 12
            Text { anchors.left: parent.right; anchors.leftMargin: 6; anchors.verticalCenter: parent.verticalCenter; text: "BT"; color: Theme.dim; font.pixelSize: 15 }
        }
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3
            Repeater {
                model: 4
                Rectangle {
                    width: 5; height: 6 + index * 4; radius: 1
                    anchors.bottom: parent.bottom
                    color: index < 3 ? Theme.text : Theme.line
                }
            }
        }
        Text { anchors.verticalCenter: parent.verticalCenter; text: "5G"; color: Theme.dim; font.pixelSize: 16 }
        Text { anchors.verticalCenter: parent.verticalCenter; text: Vehicle.outsideTemp.toFixed(0) + "\u00B0C"; color: Theme.dim; font.pixelSize: 20 }
        Text { anchors.verticalCenter: parent.verticalCenter; text: Vehicle.timeText; color: Theme.text; font.pixelSize: 28 }
    }
    Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.line }
}
