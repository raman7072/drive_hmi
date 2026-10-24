import QtQuick
import QtQuick.Controls

Item {
    id: np
    width: 1120; height: 520

    property real zoom: 0.30
    property bool traffic: true
    property bool mapNight: Theme.night
    property bool searchOpen: false
    property string filter: ""

    function hash(i, j) {
        var h = (i * 374761393 + j * 668265263) ^ 0x5bd1e995
        h = (h ^ (h >>> 13)) * 1274126177
        return ((h ^ (h >>> 16)) >>> 0) % 1000
    }

    Rectangle { anchors.fill: parent; color: np.mapNight ? "#0c1119" : "#e9e5dc" }

    Canvas {
        id: map
        anchors.fill: parent
        renderStrategy: Canvas.Cooperative
        property real dash: 0
        Timer { interval: 80; repeat: true; running: np.visible && App.page === "nav"; onTriggered: { map.dash = (map.dash + 6) % 80; map.requestPaint() } }

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            var w = width, h = height
            var night = np.mapNight
            var pos = Vehicle.posAt(Vehicle.mapProgress)
            var z = np.zoom
            var S = 300
            var R = Math.sqrt(w * w + h * h) / z * 0.62

            ctx.save()
            ctx.translate(w / 2, h * 0.68)
            ctx.rotate(-Vehicle.mapHeading)
            ctx.scale(z, z)
            ctx.translate(-pos.x, -pos.y)

            var gx0 = Math.floor((pos.x - R) / S), gx1 = Math.ceil((pos.x + R) / S)
            var gy0 = Math.floor((pos.y - R) / S), gy1 = Math.ceil((pos.y + R) / S)

            // blocks: parks + buildings
            for (var i = gx0; i < gx1; i++) {
                for (var j = gy0; j < gy1; j++) {
                    var hv = np.hash(i, j)
                    if (hv % 9 === 0) {
                        ctx.fillStyle = night ? "#10261a" : "#c8e2b8"
                        ctx.fillRect(i * S + 14, j * S + 14, S - 28, S - 28)
                    } else if (hv % 3 === 0) {
                        ctx.fillStyle = night ? "#131a25" : "#d8d3c6"
                        ctx.fillRect(i * S + 30, j * S + 30, S * 0.42, S * 0.4)
                        ctx.fillRect(i * S + 30 + S * 0.46, j * S + 60, S * 0.3, S * 0.5)
                    }
                }
            }

            // river
            ctx.strokeStyle = night ? "#0f2740" : "#a8cfee"
            ctx.lineWidth = 220
            ctx.beginPath()
            var first = true
            for (var yy = pos.y - R; yy <= pos.y + R; yy += 150) {
                var rx = 2400 + 700 * Math.sin(yy / 1400)
                if (first) { ctx.moveTo(rx, yy); first = false } else ctx.lineTo(rx, yy)
            }
            ctx.stroke()

            // roads
            for (var a = gx0; a <= gx1; a++) {
                var major = (a % 4 === 0)
                ctx.strokeStyle = night ? (major ? "#2b3547" : "#1f2836") : (major ? "#ffffff" : "#f6f3ec")
                ctx.lineWidth = major ? 30 : 16
                ctx.beginPath(); ctx.moveTo(a * S, pos.y - R); ctx.lineTo(a * S, pos.y + R); ctx.stroke()
            }
            for (var b = gy0; b <= gy1; b++) {
                var majorB = (b % 4 === 0)
                ctx.strokeStyle = night ? (majorB ? "#2b3547" : "#1f2836") : (majorB ? "#ffffff" : "#f6f3ec")
                ctx.lineWidth = majorB ? 30 : 16
                ctx.beginPath(); ctx.moveTo(pos.x - R, b * S); ctx.lineTo(pos.x + R, b * S); ctx.stroke()
            }

            // route
            var r = Vehicle.route
            if (Vehicle.navActive) {
                ctx.lineJoin = "round"; ctx.lineCap = "round"
                ctx.lineWidth = 34
                ctx.strokeStyle = night ? "#06203f" : "#0b4a9c"
                ctx.beginPath(); ctx.moveTo(r.pts[0].x, r.pts[0].y)
                for (var k = 1; k < r.pts.length; k++) ctx.lineTo(r.pts[k].x, r.pts[k].y)
                ctx.stroke()
                ctx.lineWidth = 22
                ctx.strokeStyle = Theme.css(Theme.ambient, 1)
                ctx.beginPath(); ctx.moveTo(r.pts[0].x, r.pts[0].y)
                for (var k2 = 1; k2 < r.pts.length; k2++) ctx.lineTo(r.pts[k2].x, r.pts[k2].y)
                ctx.stroke()
                if (np.traffic) {
                    for (var s = 1; s < r.pts.length; s++) {
                        if (s % 4 === 2 || s % 7 === 3) {
                            ctx.strokeStyle = s % 4 === 2 ? "#ff4d4f" : "#ffb020"
                            ctx.lineWidth = 22
                            ctx.beginPath(); ctx.moveTo(r.pts[s - 1].x, r.pts[s - 1].y); ctx.lineTo(r.pts[s].x, r.pts[s].y); ctx.stroke()
                        }
                    }
                }
                // destination flag
                var e = r.pts[r.pts.length - 1]
                ctx.fillStyle = "#ffffff"
                ctx.beginPath(); ctx.arc(e.x, e.y, 46, 0, Math.PI * 2); ctx.fill()
                ctx.fillStyle = Theme.css(Theme.danger, 1)
                ctx.beginPath(); ctx.arc(e.x, e.y, 28, 0, Math.PI * 2); ctx.fill()
            } else if (np.traffic) {
                // faint traffic on arterials
                ctx.lineWidth = 30
                ctx.strokeStyle = "rgba(255,77,79,0.45)"
                ctx.beginPath(); ctx.moveTo(4 * S * 2, pos.y - R); ctx.lineTo(4 * S * 2, pos.y - R + 1500); ctx.stroke()
            }
            ctx.restore()

            // car chevron
            var rel = pos.h - Vehicle.mapHeading
            ctx.save()
            ctx.translate(w / 2, h * 0.68)
            ctx.rotate(rel)
            ctx.shadowColor = Theme.css(Theme.ambient, 1); ctx.shadowBlur = 20
            ctx.fillStyle = "white"
            ctx.beginPath(); ctx.moveTo(0, -26); ctx.lineTo(20, 20); ctx.lineTo(0, 10); ctx.lineTo(-20, 20); ctx.closePath(); ctx.fill()
            ctx.restore()
        }
    }

    // vignette to blend map into UI
    Rectangle {
        anchors.fill: parent; color: "transparent"
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.alpha(Theme.panel, 0.75) }
            GradientStop { position: 0.18; color: "transparent" }
            GradientStop { position: 0.85; color: "transparent" }
            GradientStop { position: 1.0; color: Theme.alpha(Theme.panel, 0.7) }
        }
    }

    // ---------- guidance banner ----------
    Rectangle {
        id: banner
        x: 20; y: Vehicle.navActive ? 16 : -140; width: 380; height: 104; radius: 24
        color: Theme.alpha("#0f1319", 0.94); border.color: Theme.ambient
        Behavior on y { NumberAnimation { duration: 500; easing.type: Easing.OutBack } }
        Row {
            anchors.verticalCenter: parent.verticalCenter; x: 20; spacing: 18
            Text {
                text: Vehicle.turnDir === "left" ? "\u2B05" : (Vehicle.turnDir === "right" ? "\u27A1" : (Vehicle.turnDir === "arrive" ? "\u2691" : "\u2B06"))
                font.pixelSize: 62; color: Theme.ambient; anchors.verticalCenter: parent.verticalCenter
            }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    color: "white"; font.pixelSize: 34
                    text: Vehicle.turnDist >= 1000 ? (Vehicle.turnDist / 1000 * Vehicle.unitK).toFixed(1) + " " + Vehicle.distUnit
                                                   : Math.round(Vehicle.turnDist * (Vehicle.useMiles ? 3.28084 : 1) / 10) * 10 + (Vehicle.useMiles ? " ft" : " m")
                }
                Text { color: Theme.dim; font.pixelSize: 18; text: Vehicle.turnDir === "arrive" ? "Arrive at " + Vehicle.navDest : "onto " + Vehicle.turnStreet; elide: Text.ElideRight; width: 220 }
            }
        }
    }

    // ---------- ETA card ----------
    Rectangle {
        x: 20; y: Vehicle.navActive ? parent.height - 100 : parent.height + 20
        width: 520; height: 84; radius: 24
        color: Theme.alpha("#0f1319", 0.94); border.color: Theme.line
        Behavior on y { NumberAnimation { duration: 500; easing.type: Easing.OutBack } }
        Row {
            x: 22; anchors.verticalCenter: parent.verticalCenter; spacing: 30
            Column { Text { text: Vehicle.etaClock; color: "white"; font.pixelSize: 30 } Text { text: "arrival"; color: Theme.dim; font.pixelSize: 14 } }
            Column { Text { text: Math.round(Vehicle.etaMin) + " min"; color: "white"; font.pixelSize: 30 } Text { text: "remaining"; color: Theme.dim; font.pixelSize: 14 } }
            Column { Text { text: (Vehicle.remaining / 1000 * Vehicle.unitK).toFixed(1) + " " + Vehicle.distUnit; color: "white"; font.pixelSize: 30 } Text { text: "distance"; color: Theme.dim; font.pixelSize: 14 } }
        }
        Btn { anchors.right: parent.right; anchors.rightMargin: 14; anchors.verticalCenter: parent.verticalCenter; width: 70; height: 56; glyph: "\u2715"; tint: Theme.danger; active: true; onClicked: Vehicle.stopNav() }
    }

    // ---------- map controls ----------
    Column {
        x: parent.width - 86; y: 16; spacing: 12
        Btn { width: 70; height: 64; glyph: "\u2315"; onClicked: np.searchOpen = !np.searchOpen; active: np.searchOpen }
        Btn { width: 70; height: 64; text: "+"; fontSize: 30; onClicked: np.zoom = Math.min(1.1, np.zoom * 1.3) }
        Btn { width: 70; height: 64; text: "\u2212"; fontSize: 30; onClicked: np.zoom = Math.max(0.1, np.zoom / 1.3) }
        Btn { width: 70; height: 64; text: "TMC"; fontSize: 15; active: np.traffic; onClicked: np.traffic = !np.traffic }
        Btn { width: 70; height: 64; glyph: np.mapNight ? "\u263E" : "\u2600\uFE0E"; onClicked: np.mapNight = !np.mapNight }
    }

    // ---------- destination search sheet ----------
    Rectangle {
        id: sheet
        x: np.searchOpen ? parent.width - 86 - 420 : parent.width
        y: 16; width: 400; height: parent.height - 32; radius: 26
        color: Theme.alpha("#0f1319", 0.97); border.color: Theme.line
        Behavior on x { NumberAnimation { duration: 380; easing.type: Easing.OutCubic } }
        TextField {
            id: tf
            x: 16; y: 16; width: parent.width - 32; height: 52
            placeholderText: "Search destination"
            color: "white"; font.pixelSize: 20; placeholderTextColor: "#6d7889"
            background: Rectangle { radius: 26; color: "#171d28"; border.color: tf.activeFocus ? Theme.ambient : Theme.line }
            leftPadding: 20
            onTextChanged: np.filter = text.toLowerCase()
        }
        ListView {
            x: 8; y: 84; width: parent.width - 16; height: parent.height - 96
            clip: true; spacing: 6
            model: Vehicle.places
            delegate: Rectangle {
                id: row
                required property int index
                required property var modelData
                width: ListView.view.width; radius: 16
                visible: np.filter === "" || modelData.name.toLowerCase().indexOf(np.filter) >= 0
                opacity: visible ? 1 : 0
                color: rma.pressed ? Theme.panel2 : "transparent"
                Row {
                    x: 12; anchors.verticalCenter: parent.verticalCenter; spacing: 16
                    Text { text: modelData.glyph; font.pixelSize: 28; color: Theme.ambient; width: 34; horizontalAlignment: Text.AlignHCenter; anchors.verticalCenter: parent.verticalCenter }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        Text { text: modelData.name; color: "white"; font.pixelSize: 20 }
                        Text { text: modelData.addr; color: Theme.dim; font.pixelSize: 13 }
                    }
                }
                Text { anchors.right: parent.right; anchors.rightMargin: 14; anchors.verticalCenter: parent.verticalCenter; text: (modelData.km * Vehicle.unitK).toFixed(1) + " " + Vehicle.distUnit; color: Theme.dim; font.pixelSize: 16 }
                MouseArea { id: rma; anchors.fill: parent; onClicked: { App.poke(); Vehicle.startNav(row.index); np.searchOpen = false } }
                height: visible ? 62 : 0
            }
        }
    }
}
