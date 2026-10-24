import QtQuick

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

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width; height: 8; radius: 4
        color: Theme.panel2
        Rectangle { width: knob.x + knob.width / 2; height: parent.height; radius: 4; color: s.tint }
    }
    Rectangle {
        id: knob
        width: 30; height: 30; radius: 15
        anchors.verticalCenter: parent.verticalCenter
        x: Math.max(0, Math.min(1, (s.value - s.from) / (s.to - s.from))) * (s.width - width)
        color: "white"
        border.color: s.tint; border.width: 3
        scale: ma.pressed ? 1.25 : 1
        Behavior on scale { NumberAnimation { duration: 120 } }
    }
    MouseArea {
        id: ma
        anchors.fill: parent
        function setAt(mx) {
            var f = Math.max(0, Math.min(1, (mx - knob.width / 2) / (s.width - knob.width)))
            App.poke()
            s.moved(s.from + f * (s.to - s.from))
        }
        onPressed: (m) => setAt(m.x)
        onPositionChanged: (m) => { if (pressed) setAt(m.x) }
    }
}
