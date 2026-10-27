import QtQuick

// Automotive pill switch – crisp, steady, low latency
Item {
    id: t
    property bool checked: false
    property color tint: Theme.accent
    signal toggled(bool value)
    width: 68; height: 38

    // Track
    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: t.checked ? Theme.alpha(t.tint, 0.90) : Theme.panel2
        border.color: t.checked ? t.tint : Theme.line
        border.width: 1.5
        Behavior on color { ColorAnimation { duration: 110 } }
        Behavior on border.color { ColorAnimation { duration: 110 } }
    }

    // Thumb with instant tactile feedback
    Rectangle {
        id: thumb
        width: ma.pressed ? 32 : 28
        height: 28; radius: 14; y: 5
        x: t.checked ? (t.width - width - 5) : 5
        color: "white"
        Behavior on x { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
        Behavior on width { NumberAnimation { duration: 80 } }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        onClicked: { App.poke(); t.toggled(!t.checked) }
    }
}
