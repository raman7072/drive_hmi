import QtQuick

Item {
    id: ap
    implicitWidth: 1120; implicitHeight: 520
    width: parent ? parent.width : implicitWidth
    height: parent ? parent.height : implicitHeight

    property string app: ""      // "", weather, messages, calendar, calc, parking, timer

    readonly property var apps: [
        { key: "weather",  title: "Weather",    glyph: "\u2600\uFE0E", tint: "#0ea5e9" }, // Sky cyan/blue
        { key: "messages", title: "Messages",   glyph: "\u2709\uFE0E", tint: "#10b981" }, // Emerald green
        { key: "calendar", title: "Calendar",   glyph: "\u25A6",       tint: "#f43f5e" }, // Rose coral
        { key: "parking",  title: "Parking",    glyph: "\u25EB",       tint: "#6366f1" }, // Indigo / violet blue
        { key: "calc",     title: "Calculator", glyph: "\u00B1",       tint: "#a855f7" }, // Purple
        { key: "timer",    title: "Timer",      glyph: "\u23F1\uFE0E", tint: "#06b6d4" }  // Electric cyan
    ]

    readonly property bool isCompact: width < 780

    // ---------- app grid ----------
    Flickable {
        id: gridFlick
        visible: ap.app === ""
        anchors.fill: parent
        contentWidth: width
        contentHeight: grid.height + 40
        clip: true; boundsBehavior: Flickable.StopAtBounds

        Grid {
            id: grid
            anchors.centerIn: parent
            columns: ap.width > 920 ? 3 : (ap.width > 560 ? 2 : 1)
            columnSpacing: 18; rowSpacing: 18

            readonly property real cardW: Math.min(340, Math.floor((Math.min(ap.width - 40, 1080) - (columns - 1) * columnSpacing) / columns))
            readonly property real cardH: Math.min(210, Math.max(140, ap.height * 0.40))

            Repeater {
                model: ap.apps
                Rectangle {
                    id: ic
                    width: grid.cardW; height: grid.cardH; radius: 24
                    color: Theme.glass
                    border.width: ima.containsMouse ? 1.5 : 1
                    border.color: ima.containsMouse ? modelData.tint : Theme.glassB
                    scale: ima.pressed ? 0.96 : (ima.containsMouse ? 1.02 : 1.0)
                    Behavior on scale { NumberAnimation { duration: 110; easing.type: Easing.OutCubic } }
                    Behavior on border.color { ColorAnimation { duration: 180 } }

                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Theme.alpha(modelData.tint, 0.20) }
                        GradientStop { position: 0.45; color: Theme.alpha(Theme.panel2, 0.8) }
                        GradientStop { position: 1.0; color: Theme.panel }
                    }

                    // Watermark glyph in background
                    Text {
                        anchors.right: parent.right; anchors.rightMargin: 10
                        anchors.bottom: parent.bottom; anchors.bottomMargin: -4
                        text: modelData.glyph; font.pixelSize: ic.height > 160 ? 104 : 72
                        color: Theme.alpha(modelData.tint, ima.containsMouse ? 0.14 : 0.07)
                    }

                    // Top accent glow pill
                    Rectangle {
                        x: 20; y: 16; width: 32; height: 4; radius: 2
                        color: modelData.tint; opacity: 0.85
                    }

                    Column {
                        anchors.centerIn: parent; spacing: ic.height > 160 ? 10 : 6
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.glyph; font.pixelSize: ic.height > 160 ? 58 : 42; color: modelData.tint
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.title; font.pixelSize: ic.height > 160 ? 22 : 18; color: Theme.text
                            font.weight: Font.DemiBold; font.family: Theme.family
                        }
                    }

                    // Unread notification badge
                    Rectangle {
                        visible: modelData.key === "messages" && Vehicle.unread > 0
                        x: parent.width - 42; y: 14; width: 28; height: 28; radius: 14; color: Theme.danger
                        Text {
                            anchors.centerIn: parent; text: Vehicle.unread; color: "white"
                            font.pixelSize: 14; font.weight: Font.DemiBold; font.family: Theme.family
                        }
                    }

                    MouseArea {
                        id: ima; anchors.fill: parent; hoverEnabled: true
                        onClicked: { App.poke(); ap.app = modelData.key }
                    }
                }
            }
        }
    }

    // ---------- sub-app container ----------
    Item {
        id: sub
        visible: ap.app !== ""
        anchors.fill: parent

        Btn {
            x: 16; y: 10; width: 130; height: 46; glyph: Theme.g.back
            text: "Apps"; flat: true; fontSize: 17
            onClicked: ap.app = ""
        }

        Loader {
            x: 0; y: 62; width: parent.width; height: parent.height - 62
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
        Flickable {
            contentWidth: width
            contentHeight: ap.isCompact ? (wCol.height + 40) : Math.max(height, 440)
            clip: true; boundsBehavior: Flickable.StopAtBounds

            // Compact view
            Column {
                id: wCol
                visible: ap.isCompact
                x: 16; y: 6; width: parent.width - 32; spacing: 14
                Rectangle {
                    width: parent.width; height: 240; radius: 24
                    color: Theme.glass; border.color: Theme.glassB; border.width: 1; clip: true
                    Column {
                        anchors.centerIn: parent; spacing: 8
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "\u2600\uFE0E 22\u00B0"; font.pixelSize: 52; font.weight: 300; color: Theme.text; font.family: Theme.family }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Sunny \u00B7 Feels like 21\u00B0"; font.pixelSize: 18; color: Theme.dim; font.family: Theme.family }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Wind 12 km/h \u00B7 Humidity 48%"; font.pixelSize: 14; color: Theme.dim; font.family: Theme.family }
                    }
                }
                Repeater {
                    model: [
                        { d: "Fri", g: "\u2600\uFE0E", hi: 23, lo: 12, c: "#f59e0b" },
                        { d: "Sat", g: "\u26C5", hi: 20, lo: 11, c: "#38bdf8" },
                        { d: "Sun", g: "\u2601\uFE0E", hi: 18, lo: 10, c: "#94a3b8" }
                    ]
                    Rectangle {
                        width: parent.width; height: 60; radius: 18; color: Theme.glass; border.color: Theme.glassB; border.width: 1
                        Text { x: 20; anchors.verticalCenter: parent.verticalCenter; text: modelData.d; font.pixelSize: 18; font.weight: Font.DemiBold; color: Theme.text; font.family: Theme.family }
                        Text { anchors.centerIn: parent; text: modelData.g; font.pixelSize: 26; color: modelData.c }
                        Text { anchors.right: parent.right; anchors.rightMargin: 20; anchors.verticalCenter: parent.verticalCenter; text: modelData.hi + "\u00B0 / " + modelData.lo + "\u00B0"; font.pixelSize: 17; font.weight: Font.DemiBold; color: Theme.text; font.family: Theme.family }
                    }
                }
            }

            // Wide view
            Item {
                visible: !ap.isCompact
                anchors.fill: parent
                property real t: 0
                NumberAnimation on t { from: 0; to: 1; duration: 6000; loops: Animation.Infinite }

                Rectangle {
                    id: wLeft
                    x: 20; y: 6; width: Math.min(460, Math.max(300, (parent.width - 40) * 0.44)); height: Math.min(430, parent.height - 12); radius: 28
                    color: Theme.glass; border.color: Theme.glassB; border.width: 1; clip: true

                    // Sun
                    Item {
                        x: wLeft.width / 2; y: 120; width: 0; height: 0
                        Rectangle {
                            x: -50; y: -50; width: 100; height: 100; radius: 50
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#f59e0b" }
                                GradientStop { position: 1.0; color: "#ea580c" }
                            }
                            SequentialAnimation on scale {
                                loops: Animation.Infinite
                                NumberAnimation { to: 1.06; duration: 1500; easing.type: Easing.InOutSine }
                                NumberAnimation { to: 1.0; duration: 1500; easing.type: Easing.InOutSine }
                            }
                        }
                    }
                    Text { x: 24; y: wLeft.height - 146; text: "22\u00B0"; font.pixelSize: 72; font.weight: 300; color: Theme.text; font.family: Theme.family }
                    Text { x: 160; y: wLeft.height - 130; text: "Sunny\nFeels like 21\u00B0"; font.pixelSize: 20; color: Theme.dim; font.family: Theme.family }
                    Text { x: 24; y: wLeft.height - 46; text: "Wind 12 km/h \u00B7 Humidity 48% \u00B7 UV 5"; font.pixelSize: 14; color: Theme.dim; font.family: Theme.family }
                }

                Column {
                    anchors.left: wLeft.right; anchors.leftMargin: 16
                    anchors.right: parent.right; anchors.rightMargin: 20
                    y: 6; spacing: 8
                    Repeater {
                        model: [
                            { d: "Fri", g: "\u2600\uFE0E", hi: 23, lo: 12, c: "#f59e0b" },
                            { d: "Sat", g: "\u26C5", hi: 20, lo: 11, c: "#38bdf8" },
                            { d: "Sun", g: "\u2601\uFE0E", hi: 18, lo: 10, c: "#94a3b8" },
                            { d: "Mon", g: "\u2602\uFE0E", hi: 15, lo: 9,  c: "#0ea5e9" },
                            { d: "Tue", g: "\u2600\uFE0E", hi: 21, lo: 10, c: "#f59e0b" }
                        ]
                        Rectangle {
                            width: parent.width; height: Math.min(74, Math.max(56, (wLeft.height - 32) / 5)); radius: 18
                            color: Theme.glass; border.color: Theme.glassB; border.width: 1
                            Text { x: 20; anchors.verticalCenter: parent.verticalCenter; text: modelData.d; font.pixelSize: 20; font.weight: Font.DemiBold; color: Theme.text; font.family: Theme.family }
                            Text { anchors.centerIn: parent; text: modelData.g; font.pixelSize: 30; color: modelData.c }
                            Text { anchors.right: parent.right; anchors.rightMargin: 20; anchors.verticalCenter: parent.verticalCenter; text: modelData.hi + "\u00B0  /  " + modelData.lo + "\u00B0"; font.pixelSize: 20; font.weight: Font.DemiBold; color: Theme.text; font.family: Theme.family }
                        }
                    }
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
                id: msgList
                x: 20; y: 6
                width: ap.isCompact ? (parent.width - 40) : Math.min(440, Math.max(280, (parent.width - 40) * 0.42))
                height: parent.height - 12
                spacing: 8; clip: true
                model: Vehicle.messages
                delegate: Rectangle {
                    id: dl
                    required property int index
                    required property var modelData
                    width: ListView.view.width; height: 86; radius: 18
                    property bool isSel: index === dl.ListView.view.parent.sel
                    color: isSel ? Theme.alpha(Theme.ambient, 0.24) : (dma.containsMouse ? Theme.alpha(Theme.panel2, 0.7) : Theme.glass)
                    border.width: isSel ? 2 : 1
                    border.color: isSel ? Theme.ambient : (modelData.read ? Theme.glassB : Theme.info)

                    Column {
                        x: 14; y: 10; width: parent.width - 28; spacing: 3
                        Text { text: dl.modelData.from + " \u00B7 " + dl.modelData.time; font.pixelSize: 15; font.weight: dl.modelData.read ? Font.Normal : Font.DemiBold; color: Theme.text; font.family: Theme.family }
                        Text { text: dl.modelData.text; width: parent.width; elide: Text.ElideRight; maximumLineCount: 2; wrapMode: Text.Wrap; color: Theme.dim; font.pixelSize: 13; font.family: Theme.family }
                    }
                    MouseArea {
                        id: dma; anchors.fill: parent; hoverEnabled: true
                        onClicked: { dl.ListView.view.parent.sel = dl.index; Vehicle.markRead(dl.index) }
                    }
                }
            }
            Rectangle {
                visible: !ap.isCompact
                anchors.left: msgList.right; anchors.leftMargin: 16
                anchors.right: parent.right; anchors.rightMargin: 20
                y: 6; height: parent.height - 12; radius: 28
                color: Theme.glass; border.color: Theme.glassB; border.width: 1
                property var m: Vehicle.messages[Math.min(parent.sel, Vehicle.messages.length - 1)]

                Text { x: 24; y: 20; text: parent.m ? parent.m.from : ""; font.pixelSize: 26; font.weight: Font.DemiBold; color: Theme.text; font.family: Theme.family }
                Text { x: 24; y: 58; width: parent.width - 48; wrapMode: Text.Wrap; text: parent.m ? parent.m.text : ""; font.pixelSize: 19; color: Theme.dim; font.family: Theme.family }
                Btn { x: 24; y: 170; width: 180; height: 50; glyph: "\u25B6"; text: "Read aloud"; onClicked: App.toast("Reading message\u2026", Theme.g.msg) }
                Text { x: 24; y: 244; text: "QUICK REPLIES"; font.pixelSize: 12; color: Theme.dim; font.letterSpacing: 2; font.weight: Font.DemiBold; font.family: Theme.family }
                Flow {
                    x: 24; y: 270; width: parent.width - 48; spacing: 8
                    Repeater {
                        model: ["On my way", "Can't talk, driving", "Running 10 min late", "OK \uD83D\uDC4D"]
                        Btn { width: Math.min(220, (parent.width - 8) / 2); height: 48; fontSize: 14; text: modelData; onClicked: App.toast("Reply sent: " + modelData, Theme.g.msg) }
                    }
                }
            }
        }
    }

    // ================= CALENDAR =================
    Component {
        id: calendarC
        Flickable {
            contentWidth: width; contentHeight: calCol.height + 24
            clip: true; boundsBehavior: Flickable.StopAtBounds
            Column {
                id: calCol
                x: 20; y: 6; width: parent.width - 40; spacing: 10
                Repeater {
                    model: [
                        { t: "10:30", n: "Team Sync", p: "Design Studio Room 4B", c: "#0ea5e9" },
                        { t: "13:00", n: "Lunch with Carla", p: "Trattoria Roma", c: "#10b981" },
                        { t: "15:45", n: "Automotive HMI Review", p: "Executive Video Call", c: "#a855f7" },
                        { t: "19:30", n: "Dinner with Anna", p: "Chez Louis \u00B7 Navigate?", c: "#f43f5e" }
                    ]
                    Rectangle {
                        width: parent.width; height: 86; radius: 20
                        color: Theme.glass; border.color: Theme.glassB; border.width: 1
                        Rectangle { width: 5; height: parent.height - 24; x: 12; anchors.verticalCenter: parent.verticalCenter; radius: 2.5; color: modelData.c }
                        Text { x: 30; anchors.verticalCenter: parent.verticalCenter; text: modelData.t; font.pixelSize: 26; font.weight: Font.DemiBold; color: Theme.text; font.family: Theme.family }
                        Column {
                            anchors.left: parent.left; anchors.leftMargin: 130
                            anchors.right: navB.left; anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter; spacing: 2
                            Text { text: modelData.n; font.pixelSize: 19; font.weight: Font.DemiBold; color: Theme.text; font.family: Theme.family; elide: Text.ElideRight; width: parent.width }
                            Text { text: modelData.p; font.pixelSize: 13; color: Theme.dim; font.family: Theme.family; elide: Text.ElideRight; width: parent.width }
                        }
                        Btn {
                            id: navB
                            anchors.right: parent.right; anchors.rightMargin: 14; anchors.verticalCenter: parent.verticalCenter
                            width: 140; height: 50; glyph: Theme.g.nav; text: "Navigate"; fontSize: 15
                            onClicked: { Vehicle.startNav(index % Vehicle.places.length); App.goTo("nav") }
                        }
                    }
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
            property real df: 40 + 30 * Math.sin(ph)
            property real dr: 70 + 50 * Math.sin(ph * 0.7 + 1)
            property real dl: 90 + 40 * Math.sin(ph * 1.3)
            property real drr: 110 + 30 * Math.sin(ph * 0.9 + 2)

            Rectangle {
                id: pdcBox
                x: 20; y: 6
                width: ap.isCompact ? (parent.width - 40) : Math.min(700, Math.max(340, (parent.width - 40) * 0.64))
                height: parent.height - 12; radius: 26
                color: "#080c12"; border.color: Theme.glassB; border.width: 1; clip: true

                Canvas {
                    anchors.fill: parent
                    property real a: pk.ph
                    onAChanged: requestPaint()
                    onPaint: {
                        var ctx = getContext("2d"); ctx.reset()
                        var cx = width / 2, cy = height / 2

                        ctx.strokeStyle = "rgba(255,255,255,0.05)"; ctx.lineWidth = 1
                        for (var i = 0; i < 20; i++) { ctx.beginPath(); ctx.moveTo(i * 40, 0); ctx.lineTo(i * 40, height); ctx.stroke() }
                        for (var j = 0; j < 12; j++) { ctx.beginPath(); ctx.moveTo(0, j * 40); ctx.lineTo(width, j * 40); ctx.stroke() }

                        ctx.fillStyle = "#141c28"; ctx.strokeStyle = Theme.css(Theme.ambient, 1); ctx.lineWidth = 2.5
                        ctx.beginPath(); ctx.roundedRect(cx - 50, cy - 100, 100, 200, 32, 32); ctx.fill(); ctx.stroke()

                        function arc(x, y, ang, d) {
                            var col = d < 35 ? "#ff4d4f" : (d < 60 ? "#f97316" : "#10b981")
                            for (var k = 1; k <= 3; k++) {
                                ctx.strokeStyle = col; ctx.globalAlpha = (d < 35 + k * 30) ? 0.95 : 0.15; ctx.lineWidth = 5
                                ctx.beginPath(); ctx.arc(x, y, 20 + k * 16, ang - 0.7, ang + 0.7); ctx.stroke()
                            }
                            ctx.globalAlpha = 1
                        }
                        arc(cx, cy - 90, -Math.PI / 2, pk.df)
                        arc(cx, cy + 90, Math.PI / 2, pk.dr)
                        arc(cx - 45, cy, Math.PI, pk.dl)
                        arc(cx + 45, cy, 0, pk.drr)
                    }
                }
                Text {
                    x: 0; y: 12; width: parent.width; horizontalAlignment: Text.AlignHCenter
                    text: "PARKING SENSOR ASSIST (360\u00B0 PDC)"; color: Theme.dim
                    font.pixelSize: 13; font.letterSpacing: 2; font.weight: Font.DemiBold; font.family: Theme.family
                }
            }

            Column {
                visible: !ap.isCompact
                anchors.left: pdcBox.right; anchors.leftMargin: 16
                anchors.right: parent.right; anchors.rightMargin: 20
                y: 6; spacing: 10
                Repeater {
                    model: [ { n: "Front", v: pk.df }, { n: "Rear", v: pk.dr }, { n: "Left", v: pk.dl }, { n: "Right", v: pk.drr } ]
                    Rectangle {
                        width: parent.width; height: Math.min(88, Math.max(68, (pdcBox.height - 30) / 4)); radius: 18
                        color: Theme.glass; border.color: Theme.glassB; border.width: 1
                        Text { x: 18; y: 12; text: modelData.n; color: Theme.dim; font.pixelSize: 14; font.family: Theme.family }
                        Text {
                            x: 18; y: 32; text: Math.round(modelData.v) + " cm"
                            color: modelData.v < 35 ? Theme.danger : (modelData.v < 60 ? "#f97316" : Theme.ok)
                            font.pixelSize: 26; font.weight: Font.DemiBold; font.family: Theme.family
                        }
                        Rectangle {
                            anchors.right: parent.right; anchors.rightMargin: 16; anchors.verticalCenter: parent.verticalCenter
                            width: Math.min(110, parent.width * 0.35); height: 8; radius: 4; color: Theme.alpha(Theme.bg, 0.8)
                            Rectangle {
                                width: Math.min(parent.width, parent.width * modelData.v / 150); height: parent.height; radius: 4
                                color: modelData.v < 35 ? Theme.danger : (modelData.v < 60 ? "#f97316" : Theme.ok)
                            }
                        }
                    }
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
                        if (/^[0-9+\-*\/.() ]+$/.test(e)) {
                            var r = Function('"use strict"; return (' + e + ')')()
                            result = String(Math.round(r * 1e9) / 1e9)
                            expr = result
                        }
                    } catch (err) { result = "Error"; expr = "" }
                    return
                }
                expr += k
            }

            readonly property real cw: Math.min(460, parent.width - 40)

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 6; width: calc.cw; height: 84; radius: 20
                color: Theme.glass; border.color: Theme.glassB; border.width: 1
                Text { anchors.right: parent.right; anchors.rightMargin: 20; y: 6; text: calc.expr; color: Theme.dim; font.pixelSize: 16; font.family: Theme.family }
                Text { anchors.right: parent.right; anchors.rightMargin: 20; y: 28; text: calc.result; color: Theme.text; font.pixelSize: 38; font.weight: Font.DemiBold; font.family: Theme.family }
            }

            Grid {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 100; columns: 4; spacing: 8
                Repeater {
                    model: ["C", "\u232B", "(", ")", "7", "8", "9", "\u00F7", "4", "5", "6", "\u00D7", "1", "2", "3", "\u2212", "0", ".", "=", "+"]
                    Btn {
                        width: (calc.cw - 24) / 4; height: 56; text: modelData; fontSize: 22
                        tint: (modelData === "=" ) ? Theme.ambient : Theme.accent; active: modelData === "="
                        onClicked: calc.press(modelData)
                    }
                }
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
            Timer {
                interval: 1000; repeat: true; running: tm.run
                onTriggered: {
                    if (tm.secs > 0) tm.secs--
                    else { tm.run = false; App.toast("Timer finished", "\u23F1\uFE0E") }
                }
            }

            Canvas {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 10; width: Math.min(300, parent.height - 110); height: width
                property real f: tm.secs / 600
                onFChanged: requestPaint()
                onPaint: {
                    var ctx = getContext("2d"); ctx.reset(); ctx.lineCap = "round"; ctx.lineWidth = 12
                    var cr = width / 2
                    ctx.strokeStyle = Theme.css(Theme.line, 0.6); ctx.beginPath(); ctx.arc(cr, cr, cr - 16, 0, Math.PI * 2); ctx.stroke()
                    ctx.strokeStyle = Theme.css("#06b6d4", 1)
                    ctx.beginPath(); ctx.arc(cr, cr, cr - 16, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * Math.min(1, f)); ctx.stroke()
                }
                Text {
                    anchors.centerIn: parent
                    text: Math.floor(tm.secs / 60) + ":" + (tm.secs % 60 < 10 ? "0" : "") + tm.secs % 60
                    font.pixelSize: parent.width * 0.20; font.weight: 300; color: Theme.text; font.family: Theme.family
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom; anchors.bottomMargin: 16; spacing: 10
                Btn { width: 90; height: 54; text: "\u2212 1m"; fontSize: 16; onClicked: tm.secs = Math.max(0, tm.secs - 60) }
                Btn { width: 130; height: 54; text: tm.run ? "Pause" : "Start"; fontSize: 18; active: tm.run; tint: "#06b6d4"; onClicked: tm.run = !tm.run }
                Btn { width: 90; height: 54; text: "+ 1m"; fontSize: 16; onClicked: tm.secs += 60 }
                Btn { width: 90; height: 54; text: "Reset"; fontSize: 16; onClicked: { tm.run = false; tm.secs = 300 } }
            }
        }
    }
}
