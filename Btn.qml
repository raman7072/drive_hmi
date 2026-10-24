import QtQuick

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
    scale: ma.pressed ? 0.93 : 1.0
    Behavior on scale { NumberAnimation { duration: 110; easing.type: Easing.OutCubic } }

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: b.round ? height / 2 : Theme.radius
        color: b.active ? Theme.alpha(b.tint, 0.28) : (b.flat ? "transparent" : Theme.panel2)
        border.width: b.active ? 2 : (b.flat ? 0 : 1)
        border.color: b.active ? b.tint : Theme.line
        clip: true
        Behavior on color { ColorAnimation { duration: 180 } }

        Rectangle {
            id: rip
            anchors.centerIn: parent
            width: 0; height: width; radius: width / 2
            color: b.tint; opacity: 0
        }
    }
    ParallelAnimation {
        id: ripAnim
        NumberAnimation { target: rip; property: "width"; from: 0; to: b.width * 1.6; duration: 420; easing.type: Easing.OutCubic }
        NumberAnimation { target: rip; property: "opacity"; from: 0.35; to: 0; duration: 420 }
    }

    Row {
        anchors.centerIn: parent
        spacing: 8
        Text {
            visible: b.glyph !== ""
            text: b.glyph
            color: b.active ? b.tint : Theme.text
            font.pixelSize: b.fontSize + 4
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            visible: b.text !== ""
            text: b.text
            color: b.active ? b.tint : Theme.text
            font.pixelSize: b.fontSize
            font.family: Theme.family
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        onClicked: { ripAnim.restart(); App.poke(); b.clicked() }
    }
}
