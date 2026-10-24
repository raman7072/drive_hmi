import QtQuick

Item {
    id: t
    property bool checked: false
    property color tint: Theme.accent
    signal toggled(bool value)
    width: 78; height: 42

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: t.checked ? Theme.alpha(t.tint, 0.9) : Theme.panel2
        border.color: t.checked ? t.tint : Theme.line
        border.width: 1
        Behavior on color { ColorAnimation { duration: 180 } }
    }
    Rectangle {
        width: 34; height: 34; radius: 17; y: 4
        x: t.checked ? t.width - width - 4 : 4
        color: "white"
        Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
    }
    MouseArea {
        anchors.fill: parent
        onClicked: { App.poke(); t.toggled(!t.checked) }
    }
}
