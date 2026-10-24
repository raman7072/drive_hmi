import QtQuick

Item {
    id: mp
    width: 1120; height: 520

    property var eq: []
    Component.onCompleted: { var a = []; for (var i = 0; i < 32; i++) a.push(0.1); eq = a }
    Timer {
        interval: 90; repeat: true; running: true
        onTriggered: {
            var a = mp.eq.slice()
            for (var i = 0; i < a.length; i++) {
                var tgt = Vehicle.playing ? 0.12 + Math.random() * (0.5 + 0.5 * Vehicle.volume) * (0.6 + 0.4 * Math.sin(i * 0.3)) : 0.06
                a[i] += (tgt - a[i]) * 0.5
            }
            mp.eq = a
        }
    }

    // ----- source list -----
    Column {
        x: 20; y: 16; spacing: 10
        Repeater {
            model: Vehicle.sources
            Btn {
                width: 180; height: 68
                text: modelData
                active: Vehicle.sourceIndex === index
                tint: Qt.hsla(Vehicle.nowPlaying.hue, 0.8, 0.6, 1)
                onClicked: Vehicle.selectSource(index)
            }
        }
    }

    // ----- now playing -----
    Item {
        x: 220; y: 10; width: 580; height: 500

        Rectangle {
            id: disc
            x: 10; y: 10; width: 240; height: 240; radius: 120
            gradient: Gradient {
                GradientStop { position: 0; color: Qt.hsla(Vehicle.nowPlaying.hue, 0.8, 0.55, 1) }
                GradientStop { position: 1; color: Qt.hsla((Vehicle.nowPlaying.hue + 0.15) % 1, 0.85, 0.28, 1) }
            }
            RotationAnimator on rotation { from: 0; to: 360; duration: 8000; loops: Animation.Infinite; running: Vehicle.playing }
            Repeater {
                model: 4
                Rectangle { anchors.centerIn: parent; width: 90 + index * 38; height: width; radius: width / 2; color: "transparent"; border.color: "white"; border.width: 1; opacity: 0.12 }
            }
            Rectangle { anchors.centerIn: parent; width: 56; height: 56; radius: 28; color: Theme.panel }
            Rectangle { x: 26; y: parent.height / 2 - 4; width: 56; height: 8; radius: 4; color: "white"; opacity: 0.35 }
            layer.enabled: false
        }
        Glow { x: -60; y: -60; width: 380; height: 380; color: Qt.hsla(Vehicle.nowPlaying.hue, 0.8, 0.5, 1); strength: Vehicle.playing ? 0.3 : 0.1; z: -1 }

        Column {
            x: 280; y: 30; width: 290; spacing: 6
            Text { text: Vehicle.nowPlaying.title; color: Theme.text; font.pixelSize: 34; font.weight: Font.Medium; width: parent.width; elide: Text.ElideRight }
            Text { text: Vehicle.nowPlaying.artist; color: Theme.dim; font.pixelSize: 22; width: parent.width; elide: Text.ElideRight }
            Text { text: Vehicle.nowPlaying.album; color: Theme.dim; font.pixelSize: 16; width: parent.width; elide: Text.ElideRight }
            Text {
                visible: Vehicle.isRadio
                text: Vehicle.sourceIndex === 0 ? "\u25CF  Signal strong  " + Vehicle.nowPlaying.freq.toFixed(1) + " MHz" : "\u25CF  Digital radio"
                color: Theme.ok; font.pixelSize: 15
            }
        }

        // progress / tuner
        Item {
            x: 10; y: 270; width: 560; height: 60
            visible: !Vehicle.isRadio
            Slide {
                width: parent.width; y: 0
                from: 0; to: Math.max(1, Vehicle.nowPlaying.dur)
                value: Vehicle.position
                onMoved: (val) => Vehicle.position = val
            }
            Text { y: 36; text: Vehicle.fmt(Vehicle.position); color: Theme.dim; font.pixelSize: 15 }
            Text { y: 36; anchors.right: parent.right; text: Vehicle.fmt(Vehicle.nowPlaying.dur); color: Theme.dim; font.pixelSize: 15 }
        }
        Item {
            x: 10; y: 270; width: 560; height: 60
            visible: Vehicle.sourceIndex === 0
            Slide {
                width: parent.width
                from: 87.5; to: 108; value: Vehicle.nowPlaying.freq
                onMoved: (val) => {
                    var l = Vehicle.lists[0], best = 0
                    for (var i = 0; i < l.length; i++) if (Math.abs(l[i].freq - val) < Math.abs(l[best].freq - val)) best = i
                    if (Math.abs(l[best].freq - val) < 1.5) Vehicle.trackIndex = best
                }
            }
            Text { y: 36; text: "87.5"; color: Theme.dim; font.pixelSize: 15 }
            Text { y: 36; anchors.right: parent.right; text: "108.0 MHz"; color: Theme.dim; font.pixelSize: 15 }
        }

        // transport controls
        Row {
            x: 10; y: 340; spacing: 14
            Btn { width: 70; height: 70; round: true; glyph: Theme.g.shuffle; active: Vehicle.shuffle; onClicked: Vehicle.shuffle = !Vehicle.shuffle; visible: !Vehicle.isRadio }
            Btn { width: 80; height: 70; round: true; glyph: Theme.g.prev; onClicked: Vehicle.prevTrack() }
            Btn { width: 110; height: 70; round: true; glyph: Vehicle.playing ? Theme.g.pause : Theme.g.play; active: true
                  tint: Qt.hsla(Vehicle.nowPlaying.hue, 0.8, 0.6, 1); onClicked: Vehicle.playing = !Vehicle.playing }
            Btn { width: 80; height: 70; round: true; glyph: Theme.g.next; onClicked: Vehicle.nextTrack() }
            Btn { width: 70; height: 70; round: true; glyph: Theme.g.repeat; text: Vehicle.repeatMode === 2 ? "1" : ""; active: Vehicle.repeatMode > 0
                  visible: !Vehicle.isRadio; onClicked: Vehicle.repeatMode = (Vehicle.repeatMode + 1) % 3 }
        }

        // equalizer
        Row {
            x: 10; y: 480; spacing: 6; height: 90
            Repeater {
                model: mp.eq.length
                Rectangle {
                    width: 12; radius: 4
                    anchors.bottom: parent.bottom
                    height: Math.max(4, 85 * mp.eq[index])
                    color: Qt.hsla((Vehicle.nowPlaying.hue + index * 0.006) % 1, 0.8, 0.58, 1)
                    opacity: 0.85
                }
            }
        }
    }

    // ----- playlist -----
    Rectangle {
        x: 830; y: 14; width: 270; height: 492; radius: 24
        color: Theme.panel2; border.color: Theme.line
        Text { x: 18; y: 12; text: Vehicle.isRadio ? "Stations" : "Up next"; color: Theme.dim; font.pixelSize: 15; font.letterSpacing: 2 }
        ListView {
            x: 8; y: 44; width: parent.width - 16; height: parent.height - 54
            clip: true; spacing: 4
            model: Vehicle.lists[Vehicle.sourceIndex]
            delegate: Rectangle {
                required property int index
                required property var modelData
                width: ListView.view.width; height: 62; radius: 14
                color: index === Vehicle.trackIndex ? Theme.alpha(Qt.hsla(modelData.hue, 0.8, 0.5, 1), 0.28) : (pma.pressed ? Theme.panel : "transparent")
                Behavior on color { ColorAnimation { duration: 150 } }
                Row {
                    x: 10; spacing: 12; anchors.verticalCenter: parent.verticalCenter
                    Rectangle { width: 40; height: 40; radius: 10; color: Qt.hsla(modelData.hue, 0.8, 0.5, 1); anchors.verticalCenter: parent.verticalCenter
                        Text { anchors.centerIn: parent; text: index === Vehicle.trackIndex && Vehicle.playing ? "\u266B" : (index + 1); color: "white"; font.pixelSize: 16 } }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        Text { text: modelData.title; color: Theme.text; font.pixelSize: 16; width: 170; elide: Text.ElideRight }
                        Text { text: modelData.artist; color: Theme.dim; font.pixelSize: 12; width: 170; elide: Text.ElideRight }
                    }
                }
                MouseArea { id: pma; anchors.fill: parent; onClicked: { App.poke(); Vehicle.trackIndex = index; Vehicle.position = 0; Vehicle.playing = true } }
            }
        }
    }
}
