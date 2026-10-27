import QtQuick

// Top info bar – glassmorphism background, animated indicators
Item {
    id: sb
    width: 1120; height: 64
    property string title: ""

    // Smoked glass header background
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.night ? Qt.rgba(0.08, 0.12, 0.20, 0.75) : Qt.rgba(0.96, 0.98, 1.0, 0.85) }
            GradientStop { position: 1.0; color: Theme.night ? Qt.rgba(0.05, 0.07, 0.13, 0.40) : Qt.rgba(0.92, 0.95, 0.98, 0.60) }
        }
    }

    // Back button
    Btn {
        x: 14; y: 8; width: 110; height: 48
        flat: true; glyph: Theme.g.back; text: "Back"; fontSize: 19
        visible: App.page !== "home"
        onClicked: App.goTo("home")
    }

    // Page title
    Text {
        id: titleTxt
        x: App.page === "home" ? 28 : 140
        anchors.verticalCenter: parent.verticalCenter
        text: sb.title
        color: Theme.text; font.pixelSize: 26; font.family: Theme.family
        font.weight: Font.DemiBold; font.letterSpacing: 0.3
        Behavior on x { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
    }

    // Right cluster
    Row {
        anchors.right: parent.right; anchors.rightMargin: 24
        anchors.verticalCenter: parent.verticalCenter
        spacing: 20

        // Unread badge
        Row {
            visible: Vehicle.unread > 0
            spacing: 5
            anchors.verticalCenter: parent.verticalCenter
            Rectangle {
                width: 22; height: 22; radius: 11; color: Theme.danger
                anchors.verticalCenter: parent.verticalCenter
                Text { anchors.centerIn: parent; text: Vehicle.unread; color: "white"; font.pixelSize: 13; font.weight: Font.Bold }
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Theme.g.msg; color: Theme.info; font.pixelSize: 18
            }
        }

        // Bluetooth dot
        Row {
            anchors.verticalCenter: parent.verticalCenter; spacing: 4
            Rectangle {
                width: 8; height: 8; radius: 4
                anchors.verticalCenter: parent.verticalCenter
                color: Vehicle.phoneConnected ? Theme.ok : Theme.dimmer
                Behavior on color { ColorAnimation { duration: 300 } }
            }
            Text { anchors.verticalCenter: parent.verticalCenter; text: "BT"; color: Theme.dim; font.pixelSize: 14 }
        }

        // Signal strength bars (4 bars)
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3
            Repeater {
                model: 4
                Rectangle {
                    width: 4; height: 6 + index * 4; radius: 2
                    anchors.bottom: parent.bottom
                    color: index < 3 ? Theme.ambient : Theme.line
                    opacity: index < 3 ? 0.95 : 0.35
                }
            }
        }

        Text { anchors.verticalCenter: parent.verticalCenter; text: "5G"; color: Theme.dim; font.pixelSize: 14; font.weight: Font.Medium }

        // Outside temp
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Vehicle.outsideTemp.toFixed(0) + "\u00B0"
            color: Theme.dim; font.pixelSize: 18
        }

        // Clock
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Vehicle.timeText
            color: Theme.text; font.pixelSize: 26
            font.weight: Font.DemiBold; font.family: Theme.family
        }
    }

    // bottom separator line with ambient gradient
    Rectangle {
        anchors.bottom: parent.bottom; width: parent.width; height: 1
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Theme.line }
            GradientStop { position: 0.5; color: Theme.alpha(Theme.ambient, 0.45) }
            GradientStop { position: 1.0; color: Theme.line }
        }
        opacity: 0.7
    }
}

