import QtQuick

// Pill toggle with accent fill, glow, and hover feedback
Item {
    id: t
    property bool checked: false
    property color tint: Theme.accent
    signal toggled(bool value)
    width: 76; height: 40

    // outer pill
    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: t.checked ? Theme.alpha(t.tint, 0.85) : Theme.panel2
        border.color: t.checked ? t.tint : Theme.line
        border.width: 1
        Behavior on color { ColorAnimation { duration: 200 } }
        Behavior on border.color { ColorAnimation { duration: 200 } }
    }

    // accent glow border when active
    Rectangle {
        visible: t.checked
        anchors.fill: parent
        radius: height / 2
        color: "transparent"
        border.width: 2
        border.color: Theme.alpha(t.tint, 0.30)
        scale: 1.12
    }

    // thumb
    Rectangle {
        width: 32; height: 32; radius: 16; y: 4
        x: t.checked ? t.width - width - 4 : 4
        color: "white"
        Behavior on x { NumberAnimation { duration: 220; easing.type: Easing.OutBack } }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: { App.poke(); t.toggled(!t.checked) }
    }
}

