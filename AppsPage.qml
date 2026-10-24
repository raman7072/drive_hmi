import QtQuick

Item {
    id: ap
    width: 1120; height: 520
    property string app: ""      // "", weather, messages, calendar, calc, parking, timer

    readonly property var apps: [
        { key: "weather",  title: "Weather",  glyph: "\u2600\uFE0E", tint: "#f2b84b" },
        { key: "messages", title: "Messages", glyph: "\u2709\uFE0E", tint: "#4cc38a" },
        { key: "calendar", title: "Calendar", glyph: "\u25A6",       tint: "#ff6b6b" },
        { key: "parking",  title: "Parking",  glyph: "\u25EB",       tint: "#4aa3ff" },
        { key: "calc",     title: "Calculator", glyph: "\u00B1",     tint: "#b78cf5" },
        { key: "timer",    title: "Timer",    glyph: "\u23F1\uFE0E", tint: "#ff9f1a" }
    ]

    // ---------- app grid ----------
    Grid {
        id: grid
        visible: ap.app === ""
        anchors.centerIn: parent
        columns: 3; spacing: 22
        Repeater {
            model: ap.apps
            Rectangle {
                id: ic
                width: 330; height: 210; radius: 28
                color: Theme.panel2; border.color: ima.pressed ? modelData.tint : Theme.line
                scale: ima.pressed ? 0.95 : 1
                Behavior on scale { NumberAnimation { duration: 100 } }
                opacity: 0; y: 40
                Component.onCompleted: ent.start()
                SequentialAnimation { id: ent
                    PauseAnimation { duration: index * 80 }
                    ParallelAnimation {
                        NumberAnimation { target: ic; property: "opacity"; to: 1; duration: 350 }
                        NumberAnimation { target: ic; property: "y"; to: 0; duration: 350; easing.type: Easing.OutBack } } }
                gradient: Gradient {
                    GradientStop { position: 0; color: Theme.alpha(modelData.tint, 0.28) }
                    GradientStop { position: 1; color: Theme.panel2 }
                }
                Column {
                    anchors.centerIn: parent; spacing: 10
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.glyph; font.pixelSize: 72; color: modelData.tint }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.title; font.pixelSize: 26; color: Theme.text }
                }
                Rectangle { visible: modelData.key === "messages" && Vehicle.unread > 0; x: parent.width - 52; y: 14; width: 36; height: 36; radius: 18; color: Theme.danger
                    Text { anchors.centerIn: parent; text: Vehicle.unread; color: "white"; font.pixelSize: 18 } }
                MouseArea { id: ima; anchors.fill: parent; onClicked: { App.poke(); ap.app = modelData.key } }
            }
        }
    }

    // ---------- sub-app container ----------
    Item {
        id: sub
        visible: ap.app !== ""
        anchors.fill: parent
        Btn { x: 16; y: 12; width: 140; height: 52; glyph: Theme.g.back; text: "Apps"; flat: true; fontSize: 19; onClicked: ap.app = "" }
        Loader {
            x: 0; y: 70; width: parent.width; height: parent.height - 70
            sourceComponent: {
                switch (ap.app) {
                case "weather": return weatherC
                case "messages": return messagesC
                case "calendar": return calendarC
                case "parking": return parkingC
                case "calc": return calcC
                case "timer": return timerC
                default: return null
                }
            }
        }
    }

    // ================= WEATHER =================
    Component {
        id: weatherC
        Item {
            property real t: 0
            NumberAnimation on t { from: 0; to: 1; duration: 6000; loops: Animation.Infinite }
            Rectangle { x: 20; y: 0; width: 460; height: 430; radius: 28; color: Theme.panel2; border.color: Theme.line; clip: true
                // animated sun with rotating rays
                Item { x: 230; y: 130; width: 0; height: 0
                    Rectangle { x: -60; y: -60; width: 120; height: 120; radius: 60; color: "#ffcc4d"
                        SequentialAnimation on scale { loops: Animation.Infinite; NumberAnimation { to: 1.08; duration: 1500; easing.type: Easing.InOutSine } NumberAnimation { to: 1; duration: 1500; easing.type: Easing.InOutSine } } }
                    Repeater { model: 12
                        Rectangle { width: 6; height: 26; radius: 3; color: "#ffcc4d"; x: -3; y: -100
                                    transform: Rotation { origin.x: 3; origin.y: 100; angle: index * 30 } }
                        }
                    RotationAnimator on rotation { from: 0; to: 360; duration: 20000; loops: Animation.Infinite }
                }
                Rectangle { x: 90 + 40 * Math.sin(parent.parent.t * 6.283); y: 190; width: 140; height: 46; radius: 23; color: "white"; opacity: 0.85 }
                Rectangle { x: 150 + 40 * Math.sin(parent.parent.t * 6.283); y: 170; width: 90; height: 56; radius: 28; color: "white"; opacity: 0.85 }
                Text { x: 30; y: 290; text: "22\u00B0"; font.pixelSize: 84; font.weight: Font.Light; color: Theme.text }
                Text { x: 190; y: 304; text: "Sunny\nFeels like 21\u00B0"; font.pixelSize: 22; color: Theme.dim }
                Text { x: 30; y: 394; text: "Wind 12 km/h \u00B7 Humidity 48% \u00B7 UV 5"; font.pixelSize: 15; color: Theme.dim }
            }
            Column { x: 510; y: 0; spacing: 8
                Repeater {
                    model: [ { d: "Fri", g: "\u2600\uFE0E", hi: 23, lo: 12 }, { d: "Sat", g: "\u26C5", hi: 20, lo: 11 }, { d: "Sun", g: "\u2601\uFE0E", hi: 18, lo: 10 },
                             { d: "Mon", g: "\u2602\uFE0E", hi: 15, lo: 9 }, { d: "Tue", g: "\u2600\uFE0E", hi: 21, lo: 10 } ]
                    Rectangle { width: 560; height: 80; radius: 20; color: Theme.panel2; border.color: Theme.line
                        Text { x: 24; anchors.verticalCenter: parent.verticalCenter; text: modelData.d; font.pixelSize: 24; color: Theme.text }
                        Text { x: 180; anchors.verticalCenter: parent.verticalCenter; text: modelData.g; font.pixelSize: 38; color: "#ffcc4d" }
                        Text { anchors.right: parent.right; anchors.rightMargin: 24; anchors.verticalCenter: parent.verticalCenter; text: modelData.hi + "\u00B0  /  " + modelData.lo + "\u00B0"; font.pixelSize: 24; color: Theme.text } }
                }
            }
        }
    }

    // ================= MESSAGES =================
    Component {
        id: messagesC
        Item {
            property int sel: 0
            ListView {
                x: 20; y: 0; width: 440; height: 430; spacing: 8; clip: true
                model: Vehicle.messages
                delegate: Rectangle {
                    id: dl
                    required property int index
                    required property var modelData
                    width: ListView.view.width; height: 92; radius: 18
                    color: index === dl.ListView.view.parent.sel ? Theme.alpha(Theme.ambient, 0.2) : Theme.panel2
                    border.color: modelData.read ? Theme.line : Theme.warn
                    Column { x: 16; y: 12; width: parent.width - 32; spacing: 4
                        Text { text: modelData.from + "   " + modelData.time; font.pixelSize: 17; font.bold: !modelData.read; color: Theme.text }
                        Text { text: modelData.text; width: parent.width; elide: Text.ElideRight; maximumLineCount: 2; wrapMode: Text.Wrap; color: Theme.dim; font.pixelSize: 15 } }
                    MouseArea { anchors.fill: parent; onClicked: { dl.ListView.view.parent.sel = index; Vehicle.markRead(index) } }
                }
            }
            Rectangle {
                x: 480; y: 0; width: 620; height: 430; radius: 28; color: Theme.panel2; border.color: Theme.line
                property var m: Vehicle.messages[Math.min(parent.sel, Vehicle.messages.length - 1)]
                Text { x: 28; y: 24; text: parent.m ? parent.m.from : ""; font.pixelSize: 30; color: Theme.text }
                Text { x: 28; y: 70; width: parent.width - 56; wrapMode: Text.Wrap; text: parent.m ? parent.m.text : ""; font.pixelSize: 24; color: Theme.dim }
                Btn { x: 28; y: 190; width: 200; height: 60; glyph: "\u25B6"; text: "Read aloud"; onClicked: App.toast("Reading message\u2026", Theme.g.msg) }
                Text { x: 28; y: 276; text: "Quick replies"; font.pixelSize: 14; color: Theme.dim; font.letterSpacing: 2 }
                Flow { x: 28; y: 304; width: parent.width - 56; spacing: 10
                    Repeater { model: ["On my way", "Can't talk, driving", "Running 10 min late", "OK \uD83D\uDC4D"]
                        Btn { width: 260; height: 56; fontSize: 17; text: modelData; onClicked: App.toast("Reply sent: " + modelData, Theme.g.msg) } } }
            }
        }
    }

    // ================= CALENDAR =================
    Component {
        id: calendarC
        Item {
            Column { x: 20; spacing: 10
                Repeater {
                    model: [ { t: "10:30", n: "Team sync", p: "Room 4B", c: "#4aa3ff" }, { t: "13:00", n: "Lunch with Carla", p: "Trattoria Roma", c: "#4cc38a" },
                             { t: "15:45", n: "Design review", p: "Video call", c: "#b78cf5" }, { t: "19:30", n: "Dinner with Anna", p: "Chez Louis \u00B7 Navigate?", c: "#ff6b6b" } ]
                    Rectangle { width: 1080; height: 92; radius: 22; color: Theme.panel2; border.color: Theme.line
                        Rectangle { width: 8; height: parent.height - 24; x: 14; anchors.verticalCenter: parent.verticalCenter; radius: 4; color: modelData.c }
                        Text { x: 44; anchors.verticalCenter: parent.verticalCenter; text: modelData.t; font.pixelSize: 34; color: Theme.text }
                        Column { x: 200; anchors.verticalCenter: parent.verticalCenter
                            Text { text: modelData.n; font.pixelSize: 26; color: Theme.text }
                            Text { text: modelData.p; font.pixelSize: 16; color: Theme.dim } }
                        Btn { anchors.right: parent.right; anchors.rightMargin: 16; anchors.verticalCenter: parent.verticalCenter; width: 170; height: 56; glyph: Theme.g.nav; text: "Navigate"; fontSize: 17
                              onClicked: { Vehicle.startNav(index % Vehicle.places.length); App.goTo("nav") } } }
                }
            }
        }
    }

    // ================= PARKING (360 view with PDC) =================
    Component {
        id: parkingC
        Item {
            id: pk
            property real ph: 0
            NumberAnimation on ph { from: 0; to: 6.283; duration: 5000; loops: Animation.Infinite }
            // simulated distances in cm (front, rear, left, right)
            property real df: 40 + 30 * Math.sin(ph)
            property real dr: 70 + 50 * Math.sin(ph * 0.7 + 1)
            property real dl: 90 + 40 * Math.sin(ph * 1.3)
            property real drr: 110 + 30 * Math.sin(ph * 0.9 + 2)
            Rectangle { x: 20; y: 0; width: 700; height: 430; radius: 28; color: "#0a0e14"; border.color: Theme.line; clip: true
                Canvas {
                    anchors.fill: parent
                    property real a: pk.ph
                    onAChanged: requestPaint()
                    onPaint: {
                        var ctx = getContext("2d"); ctx.reset()
                        var cx = width / 2, cy = height / 2
                        // grid floor
                        ctx.strokeStyle = "rgba(255,255,255,0.06)"; ctx.lineWidth = 1
                        for (var i = 0; i < 20; i++) { ctx.beginPath(); ctx.moveTo(i * 40, 0); ctx.lineTo(i * 40, height); ctx.stroke() }
                        for (var j = 0; j < 12; j++) { ctx.beginPath(); ctx.moveTo(0, j * 40); ctx.lineTo(width, j * 40); ctx.stroke() }
                        // car
                        ctx.fillStyle = "#1a2230"; ctx.strokeStyle = Theme.css(Theme.ambient, 1); ctx.lineWidth = 3
                        ctx.beginPath(); ctx.roundedRect(cx - 55, cy - 110, 110, 220, 40, 40); ctx.fill(); ctx.stroke()
                        // sensor arcs
                        function arc(x, y, ang, d) {
                            var col = d < 35 ? "#ff4d4f" : (d < 60 ? "#ffb020" : "#35d07f")
                            for (var k = 1; k <= 3; k++) {
                                ctx.strokeStyle = col; ctx.globalAlpha = (d < 35 + k * 30) ? 0.95 : 0.15; ctx.lineWidth = 7
                                ctx.beginPath(); ctx.arc(x, y, 22 + k * 18, ang - 0.7, ang + 0.7); ctx.stroke()
                            }
                            ctx.globalAlpha = 1
                        }
                        arc(cx, cy - 100, -Math.PI / 2, pk.df)
                        arc(cx, cy + 100, Math.PI / 2, pk.dr)
                        arc(cx - 50, cy, Math.PI, pk.dl)
                        arc(cx + 50, cy, 0, pk.drr)
                    }
                }
                Text { x: 0; y: 10; width: parent.width; horizontalAlignment: Text.AlignHCenter; text: "Parking Assistant"; color: Theme.dim; font.pixelSize: 16; font.letterSpacing: 2 }
            }
            Column { x: 750; y: 0; spacing: 12
                Repeater {
                    model: [ { n: "Front", v: pk.df }, { n: "Rear", v: pk.dr }, { n: "Left", v: pk.dl }, { n: "Right", v: pk.drr } ]
                    Rectangle { width: 330; height: 92; radius: 20; color: Theme.panel2; border.color: Theme.line
                        Text { x: 22; y: 12; text: modelData.n; color: Theme.dim; font.pixelSize: 16 }
                        Text { x: 22; y: 38; text: Math.round(modelData.v) + " cm"; color: modelData.v < 35 ? Theme.danger : (modelData.v < 60 ? Theme.warn : Theme.ok); font.pixelSize: 32 }
                        Rectangle { x: 190; y: 40; width: 120; height: 10; radius: 5; color: Theme.bg
                            Rectangle { width: Math.min(120, 120 * modelData.v / 150); height: 10; radius: 5; color: modelData.v < 35 ? Theme.danger : (modelData.v < 60 ? Theme.warn : Theme.ok) } } }
                }
            }
        }
    }

    // ================= CALCULATOR =================
    Component {
        id: calcC
        Item {
            id: calc
            property string expr: ""
            property string result: "0"
            function press(k) {
                if (k === "C") { expr = ""; result = "0"; return }
                if (k === "\u232B") { expr = expr.slice(0, -1); return }
                if (k === "=") {
                    try {
                        var e = expr.replace(/\u00D7/g, "*").replace(/\u00F7/g, "/").replace(/\u2212/g, "-")
                        if (/^[0-9+\-*\/.() ]+$/.test(e)) { var r = Function('"use strict"; return (' + e + ')')(); result = String(Math.round(r * 1e9) / 1e9); expr = result }
                    } catch (err) { result = "Error"; expr = "" }
                    return
                }
                expr += k
            }
            Rectangle { x: 320; y: 0; width: 480; height: 90; radius: 20; color: Theme.panel2; border.color: Theme.line
                Text { anchors.right: parent.right; anchors.rightMargin: 20; y: 8; text: calc.expr; color: Theme.dim; font.pixelSize: 20 }
                Text { anchors.right: parent.right; anchors.rightMargin: 20; y: 34; text: calc.result; color: Theme.text; font.pixelSize: 44 } }
            Grid { x: 320; y: 104; columns: 4; spacing: 8
                Repeater {
                    model: ["C", "\u232B", "(", ")", "7", "8", "9", "\u00F7", "4", "5", "6", "\u00D7", "1", "2", "3", "\u2212", "0", ".", "=", "+"]
                    Btn { width: 114; height: 64; text: modelData; fontSize: 26
                          tint: (modelData === "=" ) ? Theme.ambient : Theme.accent; active: modelData === "="
                          onClicked: calc.press(modelData) } }
            }
        }
    }

    // ================= TIMER =================
    Component {
        id: timerC
        Item {
            id: tm
            property int secs: 300
            property bool run: false
            Timer { interval: 1000; repeat: true; running: tm.run; onTriggered: { if (tm.secs > 0) tm.secs--; else { tm.run = false; App.toast("Timer finished", "\u23F1\uFE0E") } } }
            Canvas {
                x: 380; y: 0; width: 340; height: 340
                property real f: tm.secs / 600
                onFChanged: requestPaint()
                onPaint: {
                    var ctx = getContext("2d"); ctx.reset(); ctx.lineCap = "round"; ctx.lineWidth = 14
                    ctx.strokeStyle = Theme.css(Theme.line, 1); ctx.beginPath(); ctx.arc(170, 170, 150, 0, Math.PI * 2); ctx.stroke()
                    ctx.strokeStyle = Theme.css(Theme.warn, 1)
                    ctx.beginPath(); ctx.arc(170, 170, 150, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * Math.min(1, f)); ctx.stroke()
                }
                Text { anchors.centerIn: parent; text: Math.floor(tm.secs / 60) + ":" + (tm.secs % 60 < 10 ? "0" : "") + tm.secs % 60; font.pixelSize: 72; font.weight: Font.Light; color: Theme.text }
            }
            Row { x: 330; y: 354; spacing: 10
                Btn { width: 100; height: 60; text: "\u2212 1m"; fontSize: 18; onClicked: tm.secs = Math.max(0, tm.secs - 60) }
                Btn { width: 150; height: 60; text: tm.run ? "Pause" : "Start"; fontSize: 20; active: tm.run; tint: Theme.warn; onClicked: tm.run = !tm.run }
                Btn { width: 100; height: 60; text: "+ 1m"; fontSize: 18; onClicked: tm.secs += 60 }
                Btn { width: 100; height: 60; text: "Reset"; fontSize: 18; onClicked: { tm.run = false; tm.secs = 300 } }
            }
        }
    }
}
