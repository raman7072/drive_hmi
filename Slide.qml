import QtQuick

// High-precision horizontal slider – steady, low latency, clean
Item {
    id: s
    property real from: 0
    property real to: 1
    property real value: 0.5
    property color tint: Theme.accent
    signal moved(real v)

    implicitWidth: 300
    implicitHeight: 40
    width: implicitWidth
    height: implicitHeight

    readonly property real norm: Math.max(0, Math.min(1, (s.value - s.from) / (s.to - s.from)))

    // Track
    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width; height: 6; radius: 3
        color: Theme.panel2
        border.color: Theme.line; border.width: 1

        Rectangle {
            width: knob.x + knob.width / 2
            height: parent.height; radius: 3
            color: s.tint
        }
    }

    // Knob
    Rectangle {
        id: knob
        width: 26; height: 26; radius: 13
        anchors.verticalCenter: parent.verticalCenter
        x: s.norm * (s.width - width)
        color: "white"
        border.color: s.tint; border.width: 3
        scale: ma.pressed ? 1.15 : (ma.containsMouse ? 1.08 : 1.0)
        Behavior on scale { NumberAnimation { duration: 70; easing.type: Easing.OutCubic } }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        preventStealing: true
        function setAt(mx) {
            var f = Math.max(0, Math.min(1, (mx - knob.width / 2) / (s.width - knob.width)))
            App.poke()
            s.moved(s.from + f * (s.to - s.from))
        }
        onPressed: (m) => setAt(m.x)
        onPositionChanged: (m) => { if (pressed) setAt(m.x) }
    }
}
