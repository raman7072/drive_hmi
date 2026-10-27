import QtQuick

// Reusable high-performance automotive button – crisp, low-latency, steady
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

    // Instant, subtle micro-compression on press (no squishy or bouncy delays)
    scale: ma.pressed ? 0.96 : (ma.containsMouse ? 1.01 : 1.0)
    Behavior on scale { NumberAnimation { duration: 60; easing.type: Easing.OutCubic } }

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: b.round ? height / 2 : Theme.radius
        color: b.active ? Theme.alpha(b.tint, 0.24)
                        : (b.flat ? (ma.pressed ? Theme.alpha(b.tint, 0.15) : (ma.containsMouse ? Theme.alpha(Theme.panel2, 0.6) : "transparent"))
                                  : (ma.pressed ? Theme.alpha(b.tint, 0.18) : (ma.containsMouse ? Theme.alpha(b.tint, 0.08) : Theme.panel2)))
        border.width: b.active ? 2 : (b.flat ? 0 : 1)
        border.color: b.active ? b.tint : (ma.containsMouse ? Theme.alpha(b.tint, 0.5) : Theme.line)
        Behavior on color { ColorAnimation { duration: 80 } }
        Behavior on border.color { ColorAnimation { duration: 80 } }
    }

    Row {
        anchors.centerIn: parent
        spacing: 8
        Text {
            visible: b.glyph !== ""
            text: b.glyph
            color: b.active ? b.tint : (ma.containsMouse ? "white" : Theme.text)
            font.pixelSize: b.fontSize + 4
            font.family: Theme.family
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            visible: b.text !== ""
            text: b.text
            color: b.active ? b.tint : (ma.containsMouse ? "white" : Theme.text)
            font.pixelSize: b.fontSize
            font.family: Theme.family
            font.weight: b.active ? Font.DemiBold : Font.Normal
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        onClicked: { App.poke(); b.clicked() }
    }
}
