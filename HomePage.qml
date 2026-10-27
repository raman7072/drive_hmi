import QtQuick

Item {
    id: hp
    implicitWidth: 1120; implicitHeight: 520

    readonly property real cardWidth: Math.min(420, Math.max(270, (lv.width - 44) / Math.max(1, Math.min(3, Math.floor(lv.width / 310)))))

    readonly property var tiles: [
        { key: "nav",     title: "Navigation",  glyph: Theme.g.nav,     tint: "#00a8ff" },
        { key: "media",   title: "Media",       glyph: Theme.g.media,   tint: "#ec4899" },
        { key: "phone",   title: "Phone",       glyph: Theme.g.phone,   tint: "#10b981" },
        { key: "climate", title: "Climate",     glyph: Theme.g.climate, tint: "#0ea5e9" },
        { key: "vehicle", title: "Vehicle",     glyph: Theme.g.vehicle, tint: "#8b5cf6" },
        { key: "drive",   title: "Driving Assistant", glyph: Theme.g.drive, tint: "#f97316" },
        { key: "energy",  title: "Energy",      glyph: Theme.g.energy,  tint: "#06b6d4" },
        { key: "apps",    title: "Apps",        glyph: Theme.g.apps,    tint: "#a855f7" },
        { key: "settings", title: "Settings",   glyph: Theme.g.settings, tint: "#64748b" }
    ]

    Connections {
        target: App
        function onKeyPressed(k) {
            if (App.page !== "home") return
            if (k === "left") lv.currentIndex = Math.max(0, lv.currentIndex - 1)
            else if (k === "right") lv.currentIndex = Math.min(hp.tiles.length - 1, lv.currentIndex + 1)
            else if (k === "enter") App.goTo(hp.tiles[lv.currentIndex].key)
        }
    }

    ListView {
        id: lv
        anchors.fill: parent
        anchors.bottomMargin: 30
        orientation: ListView.Horizontal
        spacing: 20
        model: hp.tiles
        highlightRangeMode: ListView.StrictlyEnforceRange
        preferredHighlightBegin: (width - hp.cardWidth) / 2
        preferredHighlightEnd: (width + hp.cardWidth) / 2
        highlightMoveDuration: 420
        snapMode: ListView.SnapToItem
        boundsBehavior: Flickable.StopAtBounds
        currentIndex: 0
        onMovementEnded: App.poke()

        delegate: Item {
            id: d
            required property int index
            required property var modelData
            width: hp.cardWidth; height: lv.height
            readonly property bool cur: ListView.isCurrentItem

            Component.onCompleted: entry.start()
            SequentialAnimation {
                id: entry
                PauseAnimation { duration: d.index * 70 }
                ParallelAnimation {
                    NumberAnimation { target: d; property: "y"; from: 80; to: 0; duration: 500; easing.type: Easing.OutCubic }
                    NumberAnimation { target: d; property: "opacity"; from: 0; to: 1; duration: 500 }
                }
            }

            Rectangle {
                id: card
                anchors.fill: parent
                anchors.topMargin: 12; anchors.bottomMargin: 12
                radius: Theme.radiusLg
                scale: d.cur ? 1.0 : 0.88
                opacity: d.cur ? 1.0 : 0.60
                Behavior on scale { NumberAnimation { duration: 340; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: 340 } }
                border.width: d.cur ? 1.5 : 0
                border.color: d.cur ? Theme.alpha(d.modelData.tint, 0.8) : "transparent"
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Theme.alpha(d.modelData.tint, d.cur ? 0.38 : 0.16) }
                    GradientStop { position: 0.45; color: Theme.panel2 }
                    GradientStop { position: 1.0; color: Theme.panel }
                }

                // watermark glyph
                Text {
                    anchors.right: parent.right; anchors.rightMargin: 18
                    anchors.top: parent.top; anchors.topMargin: 50
                    text: d.modelData.glyph; font.pixelSize: Math.round(Math.min(100, card.width * 0.28))
                    color: Theme.alpha(d.modelData.tint, d.cur ? 0.12 : 0.07)
                }

                // title
                Text {
                    x: 24; y: 22
                    text: d.modelData.title
                    color: Theme.text; font.pixelSize: 24; font.family: Theme.family
                    font.weight: Font.DemiBold; font.letterSpacing: 0.2
                }

                Loader {
                    id: hero
                    x: 18; y: 72; width: parent.width - 36; height: Math.max(140, parent.height - 156)
                    sourceComponent: {
                        switch (d.modelData.key) {
                        case "nav": return heroNav
                        case "media": return heroMedia
                        case "energy": return heroEnergy
                        case "climate": return heroClimate
                        default: return heroGeneric
                        }
                    }
                    onLoaded: { item.glyph = d.modelData.glyph; item.tint = d.modelData.tint }
                }

                // subtitle
                Text {
                    x: 28; y: parent.height - 78; width: parent.width - 56
                    elide: Text.ElideRight
                    color: Theme.dim; font.pixelSize: 18
                    text: {
                        switch (d.modelData.key) {
                        case "nav": return Vehicle.navActive ? Vehicle.navDest + "  ·  ETA " + Vehicle.etaClock : "Where to?"
                        case "media": return Vehicle.nowPlaying.title + (Vehicle.playing ? "  ▶" : "  ❚❚")
                        case "phone": return Vehicle.callState !== "idle" ? "In call: " + Vehicle.callName : (Vehicle.phoneConnected ? Vehicle.deviceName + " connected" : "No phone")
                        case "climate": return "Driver " + Vehicle.driverTemp.toFixed(1) + "°  ·  Cabin " + Vehicle.cabinTemp.toFixed(1) + "°"
                        case "vehicle": return Vehicle.alerts[0]
                        case "drive": return Vehicle.driveMode + (Vehicle.acc ? "  ·  ACC on" : "")
                        case "energy": return Math.round(Vehicle.battery) + "%  ·  " + Math.round(Vehicle.rangeKm * Vehicle.unitK) + " " + Vehicle.distUnit + (Vehicle.charging ? "  ⚡︎" : "")
                        case "apps": return "Weather · Messages · Calendar · Parking"
                        default: return "Display · Sound · Connectivity · System"
                        }
                    }
                }

                // bottom accent pill
                Rectangle {
                    x: 28; y: parent.height - 38; height: 5; radius: 3
                    width: d.cur ? parent.width - 56 : 32
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0; color: d.modelData.tint }
                        GradientStop { position: 1; color: Theme.alpha(d.modelData.tint, 0.4) }
                    }
                    opacity: d.cur ? 0.9 : 0.5
                    Behavior on width { NumberAnimation { duration: 420; easing.type: Easing.OutCubic } }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        App.poke()
                        if (d.cur) App.goTo(d.modelData.key)
                        else lv.currentIndex = d.index
                    }
                }
            }
        }
    }

    // page dots
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height - 24; spacing: 10
        Repeater {
            model: hp.tiles.length
            Rectangle {
                width: index === lv.currentIndex ? 26 : 8; height: 8; radius: 4
                color: index === lv.currentIndex ? Theme.ambient : Theme.line
                Behavior on width { NumberAnimation { duration: 250 } }
            }
        }
    }

    // ---------- hero components ----------
    Component {
        id: heroGeneric
        Item {
            property string glyph: ""
            property color tint: Theme.accent
            Rectangle {
                anchors.centerIn: parent; width: 150; height: 150; radius: 75
                color: "transparent"; border.color: Theme.alpha(parent.tint, 0.6); border.width: 2
                SequentialAnimation on scale { loops: Animation.Infinite
                    NumberAnimation { to: 1.18; duration: 1500; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0; duration: 1500; easing.type: Easing.InOutSine } }
                SequentialAnimation on opacity { loops: Animation.Infinite
                    NumberAnimation { to: 0.2; duration: 1500 } NumberAnimation { to: 1; duration: 1500 } }
            }
            Text {
                id: gl
                anchors.centerIn: parent
                text: parent.glyph; font.pixelSize: 90; color: parent.tint
                SequentialAnimation on y { loops: Animation.Infinite
                    NumberAnimation { from: 90; to: 80; duration: 1400; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 80; to: 90; duration: 1400; easing.type: Easing.InOutSine } }
            }
        }
    }

    Component {
        id: heroNav
        Item {
            id: nv
            property string glyph: ""
            property color tint: "white"
            property real t: 0
            NumberAnimation on t { running: hp.visible && App.page === "home"; from: 0; to: 1; duration: 4200; loops: Animation.Infinite }
            Canvas {
                anchors.fill: parent
                layer.enabled: true
                onPaint: {
                    var ctx = getContext("2d"); ctx.reset()
                    ctx.strokeStyle = "rgba(255,255,255,0.07)"; ctx.lineWidth = 2
                    for (var i = 0; i < 6; i++) { ctx.beginPath(); ctx.moveTo(0, i * 50 + 10); ctx.lineTo(width, i * 50 + 10); ctx.stroke() }
                    for (var j = 0; j < 7; j++) { ctx.beginPath(); ctx.moveTo(j * 52, 0); ctx.lineTo(j * 52, height); ctx.stroke() }
                    var pts = [[20, 240], [20, 160], [156, 160], [156, 60], [300, 60]]
                    ctx.strokeStyle = Theme.css(Theme.ambient, 1); ctx.lineWidth = 7; ctx.lineJoin = "round"
                    ctx.beginPath(); ctx.moveTo(pts[0][0], pts[0][1])
                    for (var k = 1; k < pts.length; k++) ctx.lineTo(pts[k][0], pts[k][1])
                    ctx.stroke()
                }
            }
            Rectangle {
                width: 22; height: 22; radius: 11; color: "white"; border.color: Theme.ambient; border.width: 4
                property var seg: {
                    var P = [[20, 240], [20, 160], [156, 160], [156, 60], [300, 60]]
                    var L = [80, 136, 100, 144]
                    var tot = 460
                    var d = nv.t * tot
                    for (var i = 0; i < 4; i++) {
                        if (d <= L[i]) {
                            var f = d / L[i]
                            return { x: P[i][0] + (P[i + 1][0] - P[i][0]) * f, y: P[i][1] + (P[i + 1][1] - P[i][1]) * f }
                        }
                        d -= L[i]
                    }
                    return { x: 300, y: 60 }
                }
                x: seg.x - 11 + 20; y: seg.y - 11 + 10
            }
        }
    }

    Component {
        id: heroMedia
        Item {
            property string glyph: ""
            property color tint: "white"
            Rectangle {
                id: disc
                anchors.centerIn: parent; width: 190; height: 190; radius: 95
                gradient: Gradient {
                    GradientStop { position: 0; color: Qt.hsla(Vehicle.nowPlaying.hue, 0.8, 0.55, 1) }
                    GradientStop { position: 1; color: Qt.hsla((Vehicle.nowPlaying.hue + 0.15) % 1, 0.8, 0.3, 1) }
                }
                RotationAnimator on rotation { from: 0; to: 360; duration: 7000; loops: Animation.Infinite; running: Vehicle.playing }
                Rectangle { anchors.centerIn: parent; width: 50; height: 50; radius: 25; color: Theme.panel }
                Rectangle { x: 20; y: parent.height / 2 - 3; width: 40; height: 6; radius: 3; color: "white"; opacity: 0.4 }
            }
        }
    }

    Component {
        id: heroEnergy
        Item {
            property string glyph: ""
            property color tint: "white"
            Rectangle {
                anchors.centerIn: parent; width: 120; height: 220; radius: 22
                color: "transparent"; border.color: Theme.dim; border.width: 3
                Rectangle {
                    anchors.bottom: parent.bottom; anchors.bottomMargin: 6; anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - 12; radius: 16
                    height: (parent.height - 12) * Vehicle.battery / 100
                    color: Vehicle.battery < 20 ? Theme.danger : Theme.ok
                    Behavior on height { NumberAnimation { duration: 400 } }
                }
                Text { anchors.centerIn: parent; text: Math.round(Vehicle.battery) + "%"; font.pixelSize: 38; font.bold: true; color: "white" }
            }
        }
    }

    Component {
        id: heroClimate
        Item {
            property string glyph: ""
            property color tint: "white"
            Text {
                anchors.centerIn: parent
                text: Vehicle.driverTemp.toFixed(1) + "\u00B0"
                font.pixelSize: 92; font.weight: Font.Light; color: Theme.text
            }
            Text {
                x: parent.width / 2 - 14; y: 20; text: Theme.g.fan; font.pixelSize: 46; color: Theme.ambient
                RotationAnimator on rotation { from: 0; to: 360; duration: Math.max(400, 3200 - Vehicle.fan * 400); loops: Animation.Infinite; running: Vehicle.fan > 0 }
            }
        }
    }
}
