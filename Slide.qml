import QtQuick

// Horizontal slider with accent fill, animated knob, and hover feedback
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

    // track background
    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width; height: 6; radius: 3
        color: Theme.panel2
        border.color: Theme.line; border.width: 1

        // filled portion
        Rectangle {
            width: knob.x + knob.width / 2
            height: parent.height; radius: 3
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0; color: Theme.alpha(s.tint, 0.7) }
                GradientStop { position: 1; color: s.tint }
            }
        }
    }

    // knob
    Rectangle {
        id: knob
        width: 28; height: 28; radius: 14
        anchors.verticalCenter: parent.verticalCenter
        x: s.norm * (s.width - width)
        color: "white"
        border.color: s.tint; border.width: 2.5
        scale: ma.pressed ? 1.3 : (ma.containsMouse ? 1.12 : 1.0)
        Behavior on scale { NumberAnimation { duration: 130; easing.type: Easing.OutBack } }

        // glow ring when dragging
        Rectangle {
            visible: ma.pressed
            anchors.centerIn: parent
            width: parent.width + 14; height: width; radius: width / 2
            color: "transparent"
            border.color: Theme.alpha(s.tint, 0.35)
            border.width: 3
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        function setAt(mx) {
            var f = Math.max(0, Math.min(1, (mx - knob.width / 2) / (s.width - knob.width)))
            App.poke()
            s.moved(s.from + f * (s.to - s.from))
        }
        onPressed: (m) => setAt(m.x)
        onPositionChanged: (m) => { if (pressed) setAt(m.x) }
    }
}

