import QtQuick

Item {
    id: mp
    width: 1120; height: 520

    property var eq: []
    Component.onCompleted: {
        var a = []
        for (var i = 0; i < 24; i++) a.push(0.08)
        eq = a
    }

    // Only run equalizer simulation when page is visible and music is playing
    Timer {
        interval: 90
        repeat: true
        running: mp.visible && Vehicle.playing
        onTriggered: {
            var a = mp.eq.slice()
            var vol = Vehicle.volume
            for (var i = 0; i < a.length; i++) {
                var tgt = 0.12 + Math.random() * (0.45 + 0.5 * vol) * (0.6 + 0.4 * Math.sin(i * 0.4))
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

        // Vinyl record disc
        Item {
            x: 10; y: 10; width: 240; height: 240

            Glow {
                anchors.centerIn: parent
                width: 360; height: 360
                color: Qt.hsla(Vehicle.nowPlaying.hue, 0.85, 0.55, 1)
                strength: Vehicle.playing ? 0.35 : 0.12
                z: -1
            }

            Rectangle {
                id: disc
                anchors.fill: parent; radius: 120
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#161b24" }
                    GradientStop { position: 0.5; color: "#0d1118" }
                    GradientStop { position: 1.0; color: "#06090e" }
                }
                border.width: 2; border.color: Theme.alpha("white", 0.12)

                RotationAnimator on rotation {
                    from: 0; to: 360; duration: 8000
                    loops: Animation.Infinite; running: Vehicle.playing
                }

                // Vinyl groove rings
                Repeater {
                    model: 5
                    Rectangle {
                        anchors.centerIn: parent
                        width: 100 + index * 26; height: width; radius: width / 2
                        color: "transparent"; border.color: "white"
                        border.width: 1; opacity: 0.07 + (index % 2) * 0.04
                    }
                }

                // Center label with artwork hue gradient
                Rectangle {
                    anchors.centerIn: parent
                    width: 86; height: 86; radius: 43
                    gradient: Gradient {
                        GradientStop { position: 0; color: Qt.hsla(Vehicle.nowPlaying.hue, 0.85, 0.55, 1) }
                        GradientStop { position: 1; color: Qt.hsla((Vehicle.nowPlaying.hue + 0.12) % 1, 0.85, 0.35, 1) }
                    }
                    border.width: 2; border.color: Theme.alpha("white", 0.4)

                    Text {
                        anchors.centerIn: parent
                        text: Theme.g.media
                        font.pixelSize: 32; color: "white"
                        opacity: 0.9
                    }

                    // Spindle hole
                    Rectangle {
                        anchors.centerIn: parent
                        width: 16; height: 16; radius: 8
                        color: Theme.bg; border.color: Theme.alpha("white", 0.3); border.width: 1
                    }
                }

                // Vinyl sheen reflection line
                Rectangle {
                    x: 24; y: parent.height / 2 - 4
                    width: 60; height: 8; radius: 4
                    color: "white"; opacity: 0.25
                }
            }
        }

        // Track info
        Column {
            x: 280; y: 24; width: 290; spacing: 6
            Text {
                text: Vehicle.nowPlaying.title
                color: Theme.text; font.pixelSize: 32
                font.weight: Font.DemiBold; font.family: Theme.family
                width: parent.width; elide: Text.ElideRight
            }
            Text {
                text: Vehicle.nowPlaying.artist
                color: Theme.dim; font.pixelSize: 21; font.family: Theme.family
                width: parent.width; elide: Text.ElideRight
            }
            Text {
                text: Vehicle.nowPlaying.album
                color: Theme.dimmer; font.pixelSize: 16; font.family: Theme.family
                width: parent.width; elide: Text.ElideRight
            }
            Row {
                visible: Vehicle.isRadio
                spacing: 8
                Rectangle {
                    width: 8; height: 8; radius: 4; color: Theme.ok
                    anchors.verticalCenter: parent.verticalCenter
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite; running: Vehicle.isRadio
                        NumberAnimation { to: 0.3; duration: 700 }
                        NumberAnimation { to: 1.0; duration: 700 }
                    }
                }
                Text {
                    text: Vehicle.sourceIndex === 0 ? "Live FM " + Vehicle.nowPlaying.freq.toFixed(1) + " MHz" : "Digital DAB Radio"
                    color: Theme.ok; font.pixelSize: 15; font.family: Theme.family
                }
            }
        }

        // progress / tuner
        Item {
            x: 10; y: 268; width: 560; height: 60
            visible: !Vehicle.isRadio
            Slide {
                width: parent.width; y: 0
                from: 0; to: Math.max(1, Vehicle.nowPlaying.dur)
                value: Vehicle.position
                onMoved: (val) => Vehicle.position = val
            }
            Text { y: 34; text: Vehicle.fmt(Vehicle.position); color: Theme.dim; font.pixelSize: 15; font.family: Theme.family }
            Text { y: 34; anchors.right: parent.right; text: Vehicle.fmt(Vehicle.nowPlaying.dur); color: Theme.dim; font.pixelSize: 15; font.family: Theme.family }
        }
        Item {
            x: 10; y: 268; width: 560; height: 60
            visible: Vehicle.sourceIndex === 0
            Slide {
                width: parent.width
                from: 87.5; to: 108; value: (Vehicle.nowPlaying && Vehicle.nowPlaying.freq !== undefined) ? Vehicle.nowPlaying.freq : 87.5
                onMoved: (val) => {
                    var l = Vehicle.lists[0], best = 0
                    for (var i = 0; i < l.length; i++) if (Math.abs(l[i].freq - val) < Math.abs(l[best].freq - val)) best = i
                    if (Math.abs(l[best].freq - val) < 1.5) Vehicle.trackIndex = best
                }
            }
            Text { y: 34; text: "87.5"; color: Theme.dim; font.pixelSize: 15 }
            Text { y: 34; anchors.right: parent.right; text: "108.0 MHz"; color: Theme.dim; font.pixelSize: 15 }
        }

        // transport controls
        Row {
            x: 10; y: 338; spacing: 14
            Btn { width: 70; height: 70; round: true; glyph: Theme.g.shuffle; active: Vehicle.shuffle; onClicked: Vehicle.shuffle = !Vehicle.shuffle; visible: !Vehicle.isRadio }
            Btn { width: 80; height: 70; round: true; glyph: Theme.g.prev; onClicked: Vehicle.prevTrack() }
            Btn {
                width: 110; height: 70; round: true
                glyph: Vehicle.playing ? Theme.g.pause : Theme.g.play
                active: true
                tint: Qt.hsla(Vehicle.nowPlaying.hue, 0.8, 0.6, 1)
                onClicked: Vehicle.playing = !Vehicle.playing
            }
            Btn { width: 80; height: 70; round: true; glyph: Theme.g.next; onClicked: Vehicle.nextTrack() }
            Btn { width: 70; height: 70; round: true; glyph: Theme.g.repeat; text: Vehicle.repeatMode === 2 ? "1" : ""; active: Vehicle.repeatMode > 0
                  visible: !Vehicle.isRadio; onClicked: Vehicle.repeatMode = (Vehicle.repeatMode + 1) % 3 }
        }

        // equalizer visualizer
        Row {
            x: 10; y: 432; spacing: 7; height: 72
            Repeater {
                model: mp.eq.length
                Rectangle {
                    width: 16; radius: 4
                    anchors.bottom: parent.bottom
                    height: Math.max(4, 68 * mp.eq[index])
                    Behavior on height { NumberAnimation { duration: 80 } }
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.hsla((Vehicle.nowPlaying.hue + index * 0.008) % 1, 0.85, 0.65, 1) }
                        GradientStop { position: 1.0; color: Theme.alpha(Qt.hsla(Vehicle.nowPlaying.hue, 0.8, 0.45, 1), 0.3) }
                    }
                }
            }
        }
    }

    // ----- playlist -----
    Rectangle {
        x: 830; y: 14; width: 270; height: 492; radius: 24
        color: Theme.glass; border.color: Theme.glassB; border.width: 1

        Rectangle {
            anchors.fill: parent; radius: parent.radius
            color: "transparent"; border.width: 1
            border.color: Theme.alpha(Theme.ambient, 0.15)
        }

        Text {
            x: 18; y: 14
            text: Vehicle.isRadio ? "STATIONS" : "UP NEXT"
            color: Theme.dim; font.pixelSize: 13; font.letterSpacing: 2
            font.weight: Font.DemiBold; font.family: Theme.family
        }

        ListView {
            x: 8; y: 44; width: parent.width - 16; height: parent.height - 54
            clip: true; spacing: 6
            model: Vehicle.lists[Vehicle.sourceIndex]
            delegate: Rectangle {
                id: trackRow
                required property int index
                required property var modelData
                width: ListView.view.width; height: 64; radius: 14
                property bool isCur: index === Vehicle.trackIndex

                color: isCur ? Theme.alpha(Qt.hsla(modelData.hue, 0.8, 0.5, 1), 0.28)
                             : (pma.containsMouse ? Theme.alpha(Theme.panel2, 0.8) : "transparent")
                border.width: isCur ? 1 : 0
                border.color: isCur ? Qt.hsla(modelData.hue, 0.8, 0.6, 0.8) : "transparent"
                Behavior on color { ColorAnimation { duration: 150 } }

                Row {
                    x: 10; spacing: 12; anchors.verticalCenter: parent.verticalCenter
                    Rectangle {
                        width: 42; height: 42; radius: 10
                        color: Qt.hsla(modelData.hue, 0.8, 0.5, 1)
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            anchors.centerIn: parent
                            text: trackRow.isCur && Vehicle.playing ? "\u266B" : (trackRow.index + 1)
                            color: "white"; font.pixelSize: 16; font.weight: Font.DemiBold
                        }
                    }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter; spacing: 2
                        Text {
                            text: trackRow.modelData.title
                            color: trackRow.isCur ? "white" : Theme.text
                            font.pixelSize: 16; font.weight: trackRow.isCur ? Font.DemiBold : Font.Normal
                            width: 168; elide: Text.ElideRight; font.family: Theme.family
                        }
                        Text {
                            text: trackRow.modelData.artist
                            color: Theme.dim; font.pixelSize: 12; width: 168
                            elide: Text.ElideRight; font.family: Theme.family
                        }
                    }
                }
                MouseArea {
                    id: pma; anchors.fill: parent; hoverEnabled: true
                    onClicked: { App.poke(); Vehicle.trackIndex = trackRow.index; Vehicle.position = 0; Vehicle.playing = true }
                }
            }
        }
    }
}
