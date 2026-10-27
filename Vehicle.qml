pragma Singleton
import QtQuick

// Vehicle simulation: drive dynamics, energy, climate, media, phone, navigation
Item {
    id: v

    // ================= DRIVE =================
    property string gear: "P"
    property real speed: 0            // km/h
    property real accel: 0            // m/s2
    property real power: 0            // kW (negative = regen)
    property real throttle: 0
    property real brake: 0
    property bool manual: false       // manual pedals (W / S keys or Drive page)
    property bool autoDrive: false    // simulated cruising
    property bool demoAuto: true      // start driving automatically on wake
    property real targetSpeed: 60
    property string driveMode: "Comfort"
    property int regen: 1
    property real maxSpeed: 260
    property real bootSweep: 0
    property int speedLimit: 50
    property real leadGap: 0.6
    property real leadPhase: 0
    property real odometer: 12847.3
    property real trip: 0
    property real brightness: 0.9
    property bool useMiles: false
    property bool use24h: true
    readonly property real unitK: useMiles ? 0.621371 : 1.0
    readonly property string speedUnit: useMiles ? "mph" : "km/h"
    readonly property string distUnit: useMiles ? "mi" : "km"

    // lights / signals
    property bool leftSignal: false
    property bool rightSignal: false
    property bool hazard: false
    property bool blink: false
    property string lightsMode: "Auto"
    property bool highBeam: false
    property bool fogLight: false
    readonly property bool lowBeamOn: lightsMode === "Low" || (lightsMode === "Auto" && Theme.night)

    // driver assistance
    property bool acc: false
    property real cruiseSpeed: 110
    property bool laneAssist: true
    property bool collisionWarn: true
    property bool blindSpot: true
    property bool speedInfo: true
    property bool parkAssist: true
    readonly property bool collisionAlert: collisionWarn && speed > 60 && leadGap < 0.33

    // ================= ENERGY =================
    property real battery: 87
    property real rangeKm: battery * 4.9 * (driveMode === "Eco Pro" ? 1.08 : (driveMode === "Sport" ? 0.9 : 1.0))
    property bool charging: false
    property real chargePower: 0
    property real chargeLimit: 90
    property bool preconditioning: false
    property var powerHist: []
    property real ecoScore: 82
    property real histAcc: 0

    // ================= CLIMATE =================
    property real driverTemp: 21.0
    property real passTemp: 21.0
    property real cabinTemp: 24.5
    property real outsideTemp: 18.5
    property int fan: 3
    property bool acOn: true
    property bool autoClimate: true
    property bool sync: true
    property bool recirc: false
    property bool defrostFront: false
    property bool defrostRear: false
    property bool steeringHeat: false
    property int seatHeatL: 0
    property int seatHeatR: 0
    property bool ionizer: false

    // ================= BODY =================
    property bool locked: true
    property var doors: ({ fl: false, fr: false, rl: false, rr: false, trunk: false, hood: false })
    property var windows: [0, 0, 0, 0]
    property var tires: [2.4, 2.4, 2.5, 2.5]
    property int serviceDays: 214
    property int serviceKm: 8400
    property int brakePads: 78
    property bool washerOk: true
    property var alerts: {
        var a = []
        if (doors.fl || doors.fr || doors.rl || doors.rr) a.push("Door open")
        if (doors.trunk) a.push("Tailgate open")
        if (doors.hood) a.push("Hood open")
        if (!locked && speed > 5) a.push("Vehicle unlocked while driving")
        if (battery < 20) a.push("Battery low \u2013 charge soon")
        if (tires[0] < 2.0 || tires[1] < 2.0 || tires[2] < 2.0 || tires[3] < 2.0) a.push("Tire pressure low")
        if (collisionAlert) a.push("Collision warning")
        if (a.length === 0) a.push("All systems OK")
        return a
    }

    // ================= MEDIA =================
    readonly property var sources: ["FM Radio", "DAB+", "Bluetooth", "USB", "Online"]
    property var lists: [
        [ { title: "Radio Aurora", artist: "FM 98.3", album: "Pop Hits", dur: 0, hue: 0.58, freq: 98.3 },
          { title: "City FM", artist: "FM 101.7", album: "News & Talk", dur: 0, hue: 0.08, freq: 101.7 },
          { title: "Pulse 90", artist: "FM 90.1", album: "Dance", dur: 0, hue: 0.85, freq: 90.1 },
          { title: "Classic Drive", artist: "FM 94.5", album: "Classic Rock", dur: 0, hue: 0.0, freq: 94.5 },
          { title: "Smooth Jazz", artist: "FM 105.2", album: "Jazz", dur: 0, hue: 0.12, freq: 105.2 } ],
        [ { title: "DAB Classic", artist: "Ch 12B", album: "Classical", dur: 0, hue: 0.7, freq: 0 },
          { title: "Electro Wave", artist: "Ch 11D", album: "Electronic", dur: 0, hue: 0.5, freq: 0 },
          { title: "World Report", artist: "Ch 10A", album: "News", dur: 0, hue: 0.3, freq: 0 } ],
        [ { title: "Neon Highway", artist: "The Midnight Lanes", album: "Night Drive", dur: 214, hue: 0.75 },
          { title: "Glass Horizon", artist: "Aria Voss", album: "Skyline", dur: 187, hue: 0.55 },
          { title: "Turbine Heart", artist: "Kilo & The Sparks", album: "Overdrive", dur: 242, hue: 0.0 },
          { title: "Slow Lightning", artist: "Mara Quinn", album: "Afterglow", dur: 205, hue: 0.12 },
          { title: "Alpine Run", artist: "Nordlicht", album: "Passes", dur: 231, hue: 0.4 } ],
        [ { title: "Autobahn Dreams", artist: "Kessler", album: "Open Road", dur: 258, hue: 0.62 },
          { title: "Coastline", artist: "Juno Park", album: "Salt & Sun", dur: 196, hue: 0.5 },
          { title: "Midnight Garage", artist: "Rev Theory", album: "Idle", dur: 221, hue: 0.95 },
          { title: "Quiet Valley", artist: "Elin Roth", album: "Hush", dur: 174, hue: 0.33 } ],
        [ { title: "Daily Mix", artist: "Streaming", album: "For You", dur: 199, hue: 0.8 },
          { title: "Road Trip Essentials", artist: "Streaming", album: "Playlist", dur: 226, hue: 0.07 },
          { title: "Focus Flow", artist: "Streaming", album: "Playlist", dur: 188, hue: 0.45 },
          { title: "New Releases", artist: "Streaming", album: "Playlist", dur: 212, hue: 0.9 } ]
    ]
    property int sourceIndex: 2
    property int trackIndex: 0
    property bool playing: false
    property real position: 0
    property real volume: 0.55
    property bool muted: false
    property bool shuffle: false
    property int repeatMode: 0
    readonly property bool isRadio: sourceIndex < 2
    property var nowPlaying: {
        var l = lists[sourceIndex]
        return l[Math.min(trackIndex, l.length - 1)]
    }
    property real bass: 0.5
    property real treble: 0.5
    property real balance: 0.5
    property real fader: 0.5
    property bool loudness: true

    // ================= PHONE =================
    property bool phoneConnected: true
    property string deviceName: "My Phone"
    property string callState: "idle"      // idle | dialing | incoming | active
    readonly property bool inCall: callState === "active" || callState === "dialing"
    property string callName: ""
    property string callNumber: ""
    property int callSecs: 0
    property real callAcc: 0
    property bool micMuted: false
    property bool speakerOn: true
    property var contacts: [
        { name: "Anna Weber", number: "+49 170 1234567", fav: true },
        { name: "Ben Fischer", number: "+49 171 2345678", fav: false },
        { name: "Carla Rossi", number: "+39 333 4567890", fav: true },
        { name: "David Kim", number: "+82 10 5678 1234", fav: false },
        { name: "Office", number: "+49 89 998877", fav: true },
        { name: "Mom", number: "+49 160 7654321", fav: true },
        { name: "Roadside Assistance", number: "+49 89 1122334", fav: false }
    ]
    property var recents: [
        { name: "Anna Weber", kind: "in", time: "Today 08:12" },
        { name: "Office", kind: "out", time: "Today 07:40" },
        { name: "Mom", kind: "missed", time: "Yesterday 19:05" },
        { name: "Ben Fischer", kind: "out", time: "Yesterday 12:31" }
    ]
    property var messages: [
        { from: "Anna Weber", text: "Are you on your way? Dinner is at 7.", time: "08:41", read: false },
        { from: "Office", text: "Meeting moved to 10:30. Room 4B.", time: "07:58", read: true },
        { from: "Mom", text: "Call me when you get a chance :)", time: "Yesterday", read: true }
    ]
    readonly property int unread: {
        var c = 0
        for (var i = 0; i < messages.length; i++) if (!messages[i].read) c++
        return c
    }

    // ================= NAVIGATION =================
    property var places: [
        { name: "Home", addr: "Maximilianstrasse 12", km: 7.4, glyph: "\u2302" },
        { name: "Office", addr: "Business Park 3", km: 12.8, glyph: "\u25A6" },
        { name: "Central Station", addr: "Bahnhofplatz 1", km: 3.6, glyph: "\u25A3" },
        { name: "Fast Charging Hub", addr: "Ring Road 88 \u00B7 6 free", km: 5.2, glyph: "\u26A1\uFE0E" },
        { name: "Olympic Park", addr: "Spiridon-Louis-Ring", km: 9.1, glyph: "\u2605" },
        { name: "Lake Starnberg", addr: "Seepromenade", km: 27.3, glyph: "\u2248" },
        { name: "Airport", addr: "Terminal 2", km: 38.5, glyph: "\u2708\uFE0E" }
    ]
    property bool navActive: false
    property string navDest: ""
    property var route: ({ pts: [{ x: 0, y: 0 }, { x: 0, y: 1 }], cum: [0, 1], total: 1, names: ["Main Street"] })
    property real mapProgress: 0
    property real mapHeading: 0
    property string turnDir: "straight"
    property real turnDist: 0
    property string turnStreet: ""
    property real remaining: 0
    property real etaMin: 0
    property string etaClock: "--:--"
    property real navEtaAcc: 0

    // ================= CLOCK =================
    property string timeText: "00:00"
    property string dateText: ""

    // ================= FUNCTIONS =================
    function modeColor(m) {
        if (m === "Eco Pro") return "#10b981"
        if (m === "Sport") return "#ff3355"
        if (m === "Individual") return "#8b5cf6"
        return "#00a8ff"
    }
    function setMode(m) {
        driveMode = m
        Theme.ambient = modeColor(m)
        App.toast(m + " mode activated", Theme.g.drive)
    }
    function setGear(g) {
        if (g === "P" && speed > 3) { App.toast("Stop the vehicle before selecting P", "\u26A0"); return }
        if (g === "R" && speed > 8) { App.toast("Vehicle must be stationary for R", "\u26A0"); return }
        gear = g
        if (g === "P" || g === "N" || g === "R") autoDrive = false
    }
    function startAutoDrive() { charging = false; gear = "D"; manual = false; autoDrive = true; targetSpeed = 50 }
    function stopAutoDrive() { autoDrive = false }
    function setDriverTemp(t) { driverTemp = Math.max(16, Math.min(28, t)); if (sync) passTemp = driverTemp }
    function setPassTemp(t) { passTemp = Math.max(16, Math.min(28, t)); sync = false }
    function toggleDoor(k) {
        var d = { fl: doors.fl, fr: doors.fr, rl: doors.rl, rr: doors.rr, trunk: doors.trunk, hood: doors.hood }
        d[k] = !d[k]
        doors = d
    }
    function setWindow(i, val) { var w = windows.slice(); w[i] = val; windows = w }
    function toggleCharging() {
        if (!charging) {
            if (gear !== "P") { App.toast("Select P to start charging", "\u26A0"); return }
            if (battery >= chargeLimit) { App.toast("Charge limit already reached", Theme.g.energy); return }
            charging = true
            App.toast("Charging started", Theme.g.energy)
        } else { charging = false; App.toast("Charging stopped", Theme.g.energy) }
    }
    function currentLen() { return lists[sourceIndex].length }
    function selectSource(i) { sourceIndex = i; trackIndex = 0; position = 0 }
    function nextTrack() {
        var n = currentLen()
        trackIndex = shuffle ? Math.floor(Math.random() * n) : (trackIndex + 1) % n
        position = 0
    }
    function prevTrack() {
        if (!isRadio && position > 4) { position = 0; return }
        var n = currentLen()
        trackIndex = (trackIndex - 1 + n) % n
        position = 0
    }
    function fmt(sec) {
        var s = Math.max(0, Math.floor(sec))
        var m = Math.floor(s / 60)
        var r = s % 60
        return m + ":" + (r < 10 ? "0" : "") + r
    }
    function dial(name, number) {
        if (callState !== "idle") return
        callName = name; callNumber = number; callState = "dialing"; callSecs = 0
        dialTimer.restart()
        App.toast("Calling " + name + "\u2026", Theme.g.phone)
    }
    function incoming(name, number) {
        if (callState !== "idle") return
        callName = name; callNumber = number; callState = "incoming"; callSecs = 0
    }
    function answer() { if (callState === "incoming") { callState = "active"; callSecs = 0 } }
    function endCall() {
        if (callState === "idle") return
        var kind = callState === "incoming" ? "missed" : (callState === "dialing" || callSecs >= 0 ? "out" : "in")
        var r = recents.slice()
        r.unshift({ name: callName, kind: kind, time: "Today " + timeText })
        recents = r.slice(0, 12)
        callState = "idle"
        dialTimer.stop()
    }
    function markRead(i) {
        var m = messages.slice()
        var o = m[i]
        m[i] = { from: o.from, text: o.text, time: o.time, read: true }
        messages = m
    }
    function addMessage(from, text) {
        var m = messages.slice()
        m.unshift({ from: from, text: text, time: timeText, read: false })
        messages = m
        App.toast("New message from " + from, Theme.g.msg)
    }

    // ---- navigation helpers
    function buildRoute(target) {
        var pts = [{ x: 0, y: 0 }], cum = [0], names = []
        var x = 0, y = 0, total = 0, k = 0
        var st = ["Leopoldstrasse", "Ludwigstrasse", "Prinzregentenstrasse", "Maximilianstrasse",
                  "Sendlinger Strasse", "Rosenheimer Strasse", "Landsberger Strasse", "Nymphenburger Strasse"]
        while (total < target) {
            var len = 300 * (2 + ((k * 7 + 3) % 4))
            if (total + len > target) len = Math.max(150, target - total)
            if (k % 2 === 0) y += len; else x += len
            total += len
            pts.push({ x: x, y: y }); cum.push(total); names.push(st[k % st.length])
            k++
        }
        return { pts: pts, cum: cum, total: total, names: names }
    }
    function posAt(s) {
        var r = route
        var i = 0
        while (i < r.pts.length - 2 && s >= r.cum[i + 1]) i++
        var a = r.pts[i], b = r.pts[i + 1]
        var l = r.cum[i + 1] - r.cum[i]
        var t = l > 0 ? Math.min(1, Math.max(0, (s - r.cum[i]) / l)) : 0
        return { x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t,
                 h: Math.atan2(b.x - a.x, -(b.y - a.y)), seg: i }
    }
    function startNav(i) {
        var p = places[i]
        navDest = p.name
        route = buildRoute(p.km * 1000)
        mapProgress = 0
        navActive = true
        App.toast("Route to " + p.name + " calculated", Theme.g.nav)
        if (gear !== "D" || !autoDrive) startAutoDrive()
    }
    function stopNav() {
        navActive = false
        route = buildRoute(60000)
        mapProgress = 0
    }
    function updateNav() {
        var r = route
        var s = mapProgress
        if (s >= r.total - 5) {
            if (navActive) {
                var d = navDest
                stopNav()
                App.toast("You have arrived at " + d, Theme.g.nav)
            } else mapProgress = 0
            return
        }
        var p = posAt(s)
        var look = posAt(Math.min(r.total - 1, s + 70)).h
        var diff = look - mapHeading
        while (diff > Math.PI) diff -= 2 * Math.PI
        while (diff < -Math.PI) diff += 2 * Math.PI
        mapHeading += diff * 0.12
        var i = p.seg
        turnDist = r.cum[i + 1] - s
        remaining = r.total - s
        if (i >= r.pts.length - 2) { turnDir = "arrive"; turnStreet = navActive ? navDest : "" }
        else {
            var a = r.pts[i], b = r.pts[i + 1], c = r.pts[i + 2]
            var cross = (b.x - a.x) * (c.y - b.y) - (b.y - a.y) * (c.x - b.x)
            turnDir = cross > 0 ? "right" : "left"
            turnStreet = r.names[i + 1]
        }
        etaMin = remaining / 1000 / 45 * 60
        navEtaAcc += 0.04
        if (navEtaAcc >= 1.0 || etaClock === "--:--") {
            navEtaAcc = 0
            etaClock = Qt.formatTime(new Date(Date.now() + etaMin * 60000), use24h ? "HH:mm" : "h:mm AP")
        }
    }

    // ---- main simulation step (called at 25 Hz)
    function step(dt) {
        // cache frequently-read properties into locals for perf
        var spd = speed, gearNow = gear, modeNow = driveMode
        var cap = modeNow === "Eco Pro" ? 1.4 : (modeNow === "Sport" ? 4.2 : 2.4)
        var a = 0

        if (gearNow === "D" || gearNow === "R") {
            if (manual) {
                // rolling resistance + speed-squared drag
                var resist = spd > 0 ? 0.25 + spd * 0.0035 : 0
                a = throttle * cap - brake * 9 - resist
                if (throttle < 0.05 && brake < 0.05 && spd > 0) a -= 0.4 + regen * 0.5
            } else {
                var tgt = autoDrive ? targetSpeed : 0
                if (acc) tgt = autoDrive ? Math.min(tgt, cruiseSpeed) : cruiseSpeed
                if (gearNow === "R") tgt = Math.min(tgt, 10)
                var err = tgt - spd
                a = Math.max(-4.5, Math.min(cap, err * 0.35))
                throttle = a > 0 ? a / cap : 0
                brake    = a < -1 ? Math.min(1, -a / 6) : 0
            }
            var maxS = gearNow === "R" ? 12 : maxSpeed
            spd = Math.max(0, Math.min(maxS, spd + a * 3.6 * dt))
            speed = spd
        } else if (gearNow === "N") {
            spd = Math.max(0, spd - 1.2 * 3.6 * dt)
            speed = spd; a = -1.2; throttle = 0; brake = 0
        } else {
            speed = 0; spd = 0; throttle = 0; brake = 0
        }
        accel = a

        // power (kW): traction + aero drag + base load
        var pw = 0.4
        if (gearNow === "D" || gearNow === "R") {
            var spdMs = spd / 3.6
            pw = 2.4 * a * spdMs + 0.0000085 * spd * spd * spd + 0.07 * spd
            if (pw < 0) pw = Math.max(-110, pw * (0.55 + 0.15 * regen))
        }
        power += (pw - power) * Math.min(1, dt * 8)

        // energy accounting
        if (charging) {
            if (gearNow !== "P" || battery >= chargeLimit) {
                charging = false
                if (battery >= chargeLimit)
                    App.toast("Charge limit reached (" + Math.round(chargeLimit) + "%)", Theme.g.energy)
            } else {
                chargePower = Math.max(7, 150 - battery * 1.2)
                battery = Math.min(100, battery + chargePower * dt / 3600 / 108 * 100 * 120)
            }
        } else {
            chargePower = 0
            battery = Math.max(0, Math.min(100, battery - power * dt / 3600 / 108 * 100 * 60))
        }

        // odometer
        var dd = spd * dt / 3600
        odometer += dd; trip += dd
        ecoScore = Math.max(40, Math.min(100, ecoScore + (throttle > 0.8 ? -0.02 : 0.004)))

        // power history – only on relevant pages
        histAcc += dt
        if (histAcc >= 0.5) {
            histAcc = 0
            if (App.page === "energy" || App.page === "home") {
                var h = powerHist.slice()
                h.push(power)
                if (h.length > 80) h.shift()
                powerHist = h
            }
        }

        // climate simulation
        var tT = sync ? driverTemp : (driverTemp + passTemp) * 0.5
        cabinTemp += (tT - cabinTemp) * dt * (0.02 + fan * 0.01)

        // lead vehicle
        leadPhase += dt
        leadGap = 0.55 + 0.25 * Math.sin(leadPhase * 0.35)

        // media position
        if (playing && !isRadio && nowPlaying.dur > 0) {
            position += dt
            if (position >= nowPlaying.dur) {
                if (repeatMode === 2) position = 0; else nextTrack()
            }
        }

        // call timer
        if (callState === "active") {
            callAcc += dt
            if (callAcc >= 1) { callAcc = 0; callSecs++ }
        }

        mapProgress += spd / 3.6 * dt
        updateNav()
    }

    // ================= TIMERS =================
    Timer { interval: 40; repeat: true; running: true; onTriggered: v.step(0.04) }
    Timer {
        interval: 1000; repeat: true; running: true; triggeredOnStart: true
        onTriggered: {
            v.timeText = Qt.formatTime(new Date(), v.use24h ? "HH:mm" : "h:mm AP")
            v.dateText = Qt.formatDate(new Date(), "ddd, d MMM")
        }
    }
    Timer {
        interval: 450; repeat: true
        running: v.leftSignal || v.rightSignal || v.hazard
        onTriggered: v.blink = !v.blink
    }
    Timer {
        interval: 7000; repeat: true; running: v.autoDrive
        onTriggered: {
            var opts = [40, 55, 70, 90, 110, 130, 80, 50, 120, 60]
            v.targetSpeed = opts[Math.floor(Math.random() * opts.length)]
            v.leftSignal = false; v.rightSignal = false
            if (Math.random() < 0.25) v.leftSignal = true
            else if (Math.random() < 0.25) v.rightSignal = true
        }
    }
    Timer {
        interval: 4000; repeat: true; running: v.autoDrive
        onTriggered: { if (v.leftSignal || v.rightSignal) { v.leftSignal = false; v.rightSignal = false } }
    }
    Timer {
        interval: 18000; repeat: true; running: v.autoDrive
        onTriggered: {
            var l = [30, 50, 70, 80, 100, 120, 130]
            v.speedLimit = l[Math.floor(Math.random() * l.length)]
        }
    }
    Timer { id: dialTimer; interval: 2200; onTriggered: { if (v.callState === "dialing") { v.callState = "active"; v.callSecs = 0 } } }
    Timer {
        interval: 75000; repeat: true; running: App.awake
        onTriggered: v.addMessage("Anna Weber", "I booked the table for 7:30. See you there!")
    }
    Timer {
        interval: 160000; repeat: true; running: App.awake
        onTriggered: v.incoming("Ben Fischer", "+49 171 2345678")
    }

    Component.onCompleted: route = buildRoute(60000)
}
