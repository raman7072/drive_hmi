import QtQuick

// Reusable button with ripple, hover-lift and active-glow
Item {
    id: b
    property string text: ""
    property string glyph: ""
    property bool active: false
    property bool flat: false
    property bool round: false
    property color tint: Theme.accent
    property int fontSize: 22
    property alias pressed: ma.pressed

    signal clicked()

    implicitWidth: 120
    implicitHeight: 64
    width: implicitWidth
    height: implicitHeight

    // press + hover scale
    scale: ma.pressed ? 0.92 : (ma.containsMouse ? 1.03 : 1.0)
    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: b.round ? height / 2 : Theme.radius
        // glassmorphism on active; flat on flat; solid panel otherwise
        color: b.active ? Theme.alpha(b.tint, 0.22)
                        : (b.flat ? "transparent"
                                  : (ma.containsMouse ? Theme.alpha(b.tint, 0.08) : Theme.panel2))
        border.width: b.active ? 2 : (b.flat ? 0 : 1)
        border.color: b.active ? b.tint : (ma.containsMouse ? Theme.alpha(b.tint, 0.45) : Theme.line)
        clip: true
        Behavior on color { ColorAnimation { duration: 160 } }
        Behavior on border.color { ColorAnimation { duration: 160 } }

        // ripple blob
        Rectangle {
            id: rip
            anchors.centerIn: parent
            width: 0; height: width; radius: width / 2
            color: b.tint; opacity: 0
        }
    }

    // inner glow when active
    Rectangle {
        visible: b.active
        anchors.fill: parent
        radius: b.round ? height / 2 : Theme.radius
        color: "transparent"
        border.width: 1
        border.color: Theme.alpha(b.tint, 0.25)
        scale: 0.88
    }

    ParallelAnimation {
        id: ripAnim
        NumberAnimation { target: rip; property: "width"; from: 0; to: b.width * 1.7; duration: 440; easing.type: Easing.OutCubic }
        NumberAnimation { target: rip; property: "opacity"; from: 0.30; to: 0; duration: 440 }
    }

    Row {
        anchors.centerIn: parent
        spacing: 8
        Text {
            visible: b.glyph !== ""
            text: b.glyph
            color: b.active ? b.tint : (ma.containsMouse ? Theme.lighten(Theme.text, 0.15) : Theme.text)
            font.pixelSize: b.fontSize + 4
            font.family: Theme.family
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: 160 } }
        }
        Text {
            visible: b.text !== ""
            text: b.text
            color: b.active ? b.tint : (ma.containsMouse ? Theme.lighten(Theme.text, 0.15) : Theme.text)
            font.pixelSize: b.fontSize
            font.family: Theme.family
            font.weight: b.active ? Font.Medium : Font.Normal
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: 160 } }
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        onClicked: { ripAnim.restart(); App.poke(); b.clicked() }
    }
}

