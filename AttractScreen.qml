import QtQuick

// Landing / welcome screen: runs until the user touches, moves the mouse or presses a key
Item {
    id: at
    width: 1920; height: 720
    property real hue: 0.58
    property real bandX: -300
    property real burst: 0
    property bool armed: false
    readonly property bool active: visible && (!App.awake || burst < 1)
    signal woke()

    // hue ping-pong
    SequentialAnimation on hue {
        running: at.active
        loops: Animation.Infinite
        NumberAnimation { from: 0.52; to: 0.82; duration: 7000; easing.type: Easing.InOutSine }
        NumberAnimation { from: 0.82; to: 0.52; duration: 7000; easing.type: Easing.InOutSine }
    }
    NumberAnimation on bandX { running: at.active; from: -300; to: 760; duration: 4200; loops: Animation.Infinite; easing.type: Easing.InOutCubic }

    Timer { interval: 1400; running: at.active; onTriggered: at.armed = true }

    readonly property color tone: Qt.hsla(hue, 0.85, 0.55, 1)

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#03050a" }
            GradientStop { position: 1.0; color: "#0a1220" }
        }
    }

    // drifting light streaks
    Repeater {
        model: 9
        Rectangle {
            id: streak
            property real spd: 2600 + index * 380
            y: 40 + index * 72
            height: 3 + (index % 3) * 2
            width: 280 + (index % 4) * 140
            radius: height / 2
            opacity: 0.35
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0; color: "transparent" }
                GradientStop { position: 0.5; color: Qt.hsla((at.hue + index * 0.03) % 1, 0.9, 0.6, 1) }
                GradientStop { position: 1; color: "transparent" }
            }
            NumberAnimation on x {
                running: at.active
                from: -streak.width; to: 1920
                duration: streak.spd; loops: Animation.Infinite
            }
        }
    }

    Glow { x: 960 - 700; y: 360 - 500; width: 1400; height: 1000; color: at.tone; strength: 0.25 }

    // emblem rings
    Item {
        id: emblem
        x: 960 - 140; y: 70; width: 280; height: 280
        scale: 1 + at.burst * 3
        opacity: 1 - at.burst
        Repeater {
            model: 3
            Rectangle {
                anchors.centerIn: parent
                width: 120 + index * 70; height: width; radius: width / 2
                color: "transparent"
                border.width: 2 - (index === 0 ? 0 : 1)
                border.color: Theme.alpha(at.tone, 0.9 - index * 0.25)
                SequentialAnimation on scale {
                    running: at.active
                    loops: Animation.Infinite
                    PauseAnimation { duration: index * 450 }
                    NumberAnimation { from: 0.92; to: 1.08; duration: 1600; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 1.08; to: 0.92; duration: 1600; easing.type: Easing.InOutSine }
                }
            }
        }
        Canvas {
            id: orbit
            anchors.fill: parent
            property real a: 0
            NumberAnimation on a { running: at.active; from: 0; to: Math.PI * 2; duration: 6000; loops: Animation.Infinite }
            onAChanged: if (at.active) requestPaint()
            onPaint: {
                var ctx = getContext("2d"); ctx.reset()
                for (var i = 0; i < 3; i++) {
                    var rad = 60 + i * 35, ang = a * (1 + i * 0.4) + i * 2
                    ctx.fillStyle = Theme.css(at.tone, 1)
                    ctx.beginPath(); ctx.arc(140 + Math.cos(ang) * rad, 140 + Math.sin(ang) * rad, 5, 0, Math.PI * 2); ctx.fill()
                }
            }
        }
        Text {
            anchors.centerIn: parent
            text: "DRIVE"
            font.pixelSize: 34; font.letterSpacing: 8; font.weight: Font.Light
            color: "white"
        }
    }

    // car silhouette with sweeping highlight
    Canvas {
        id: car
        x: 960 - 320; y: 395; width: 640; height: 190
        property real sweep: at.bandX
        onSweepChanged: if (at.active) requestPaint()
        onPaint: {
            var ctx = getContext("2d"); ctx.reset()
            function body() {
                ctx.beginPath()
                ctx.moveTo(30, 140)
                ctx.bezierCurveTo(30, 120, 60, 110, 110, 105)
                ctx.bezierCurveTo(150, 70, 230, 55, 330, 58)
                ctx.bezierCurveTo(400, 60, 450, 90, 500, 105)
                ctx.bezierCurveTo(560, 112, 590, 120, 595, 140)
                ctx.lineTo(595, 150); ctx.lineTo(30, 150); ctx.closePath()
            }
            ctx.lineWidth = 2
            ctx.strokeStyle = "rgba(180,200,230,0.28)"
            body(); ctx.stroke()
            ctx.beginPath(); ctx.arc(130, 150, 30, 0, Math.PI * 2); ctx.stroke()
            ctx.beginPath(); ctx.arc(490, 150, 30, 0, Math.PI * 2); ctx.stroke()
            ctx.save()
            ctx.beginPath(); ctx.rect(car.sweep, 0, 110, 190); ctx.clip()
            ctx.lineWidth = 3
            ctx.strokeStyle = Theme.css(at.tone, 1)
            body(); ctx.stroke()
            ctx.beginPath(); ctx.arc(130, 150, 30, 0, Math.PI * 2); ctx.stroke()
            ctx.beginPath(); ctx.arc(490, 150, 30, 0, Math.PI * 2); ctx.stroke()
            ctx.restore()
        }
    }

    // welcome light carpet under the car
    Rectangle {
        id: carpet
        x: 960 - width / 2; y: 590; height: 6; radius: 3
        width: 120 + 380 * (0.5 + 0.5 * Math.sin(at.bandX / 90))
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0; color: "transparent" }
            GradientStop { position: 0.5; color: at.tone }
            GradientStop { position: 1; color: "transparent" }
        }
        opacity: 0.9 - at.burst
    }

    // clock + welcome text
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 610; spacing: 2
        opacity: 1 - at.burst
        Text { anchors.horizontalCenter: parent.horizontalCenter; text: Vehicle.timeText; font.pixelSize: 54; font.weight: Font.Thin; color: "white" }
        Text { anchors.horizontalCenter: parent.horizontalCenter; text: Vehicle.dateText; font.pixelSize: 18; color: "#9fb0c8"; font.letterSpacing: 2 }
    }
    Text {
        id: hint
        anchors.horizontalCenter: parent.horizontalCenter
        y: 24
        text: "Welcome \u00B7 touch the screen or press any key"
        font.pixelSize: 20; font.letterSpacing: 3; color: "#9fb0c8"
        SequentialAnimation on opacity {
            running: at.active
            loops: Animation.Infinite
            NumberAnimation { from: 0.25; to: 1; duration: 1300; easing.type: Easing.InOutSine }
            NumberAnimation { from: 1; to: 0.25; duration: 1300; easing.type: Easing.InOutSine }
        }
    }

    // wake burst
    NumberAnimation { id: burstAnim; target: at; property: "burst"; from: 0; to: 1; duration: 700; easing.type: Easing.OutCubic }
    function trigger() { burst = 0; burstAnim.restart(); woke() }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        property real lx: -1
        onClicked: if (at.armed) at.trigger()
        onPositionChanged: (m) => {
            if (!at.armed) return
            if (lx >= 0 && Math.abs(m.x - lx) > 25) at.trigger()
            lx = m.x
        }
    }
}
