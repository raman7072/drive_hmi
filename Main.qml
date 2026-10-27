import QtQuick
import QtQuick.Window

Window {
    id: root
    width: 1600; height: 600
    minimumWidth: 720; minimumHeight: 480
    visible: true
    title: "Drive HMI \u2013 Adaptive Cockpit & Infotainment"
    color: "#000000"

    onWidthChanged: App.displayWidth = width
    onHeightChanged: App.displayHeight = height
    Component.onCompleted: {
        App.displayWidth = width
        App.displayHeight = height
    }

    property string pendingPage: "home"
    readonly property var titles: ({
        home: "Home", nav: "Navigation", media: "Media", phone: "Phone", climate: "Climate",
        vehicle: "Vehicle", drive: "Driving Assistant", energy: "Energy & Charging",
        apps: "Apps", settings: "Settings"
    })
    readonly property var files: ({
        home: "HomePage.qml", nav: "NavPage.qml", media: "MediaPage.qml", phone: "PhonePage.qml",
        climate: "ClimatePage.qml", vehicle: "VehiclePage.qml", drive: "DrivePage.qml",
        energy: "EnergyPage.qml", apps: "AppsPage.qml", settings: "SettingsPage.qml"
    })

    // ---------- Adaptive display metrics ----------
    readonly property bool isPortrait: root.height > root.width * 0.92
    readonly property bool isCompact: root.width < 1120 || root.height < 540
    readonly property int pad: isCompact ? 10 : 16
    readonly property int gap: isCompact ? 10 : 16

    // Target sizes and positions for Cluster
    readonly property real clusterTargetW: {
        if (isPortrait) {
            return App.layoutMode === "infotainment" ? 0 : (root.width - 2 * pad)
        } else {
            if (App.layoutMode === "cluster") return root.width - 2 * pad
            if (App.layoutMode === "infotainment") return 0
            return Math.max(380, Math.min(760, Math.round(root.width * 0.38)))
        }
    }
    readonly property real clusterTargetH: {
        if (isPortrait) {
            if (App.layoutMode === "cluster") return root.height - 2 * pad
            if (App.layoutMode === "infotainment") return 0
            return Math.max(260, Math.min(420, Math.round(root.height * 0.36)))
        } else {
            return root.height - 2 * pad
        }
    }
    readonly property real clusterTargetX: pad
    readonly property real clusterTargetY: pad

    // Target sizes and positions for Control (Infotainment)
    readonly property real controlTargetW: {
        if (isPortrait) {
            return App.layoutMode === "cluster" ? 0 : (root.width - 2 * pad)
        } else {
            if (App.layoutMode === "cluster") return 0
            if (App.layoutMode === "infotainment") return root.width - 2 * pad
            return root.width - clusterTargetW - gap - 2 * pad
        }
    }
    readonly property real controlTargetH: {
        if (isPortrait) {
            if (App.layoutMode === "cluster") return 0
            if (App.layoutMode === "infotainment") return root.height - 2 * pad
            return root.height - clusterTargetH - gap - 2 * pad
        } else {
            return root.height - 2 * pad
        }
    }
    readonly property real controlTargetX: {
        if (isPortrait) return pad
        return App.layoutMode === "infotainment" ? pad : (pad + clusterTargetW + gap)
    }
    readonly property real controlTargetY: {
        if (isPortrait) {
            return App.layoutMode === "infotainment" ? pad : (pad + clusterTargetH + gap)
        }
        return pad
    }

    // ---------- Fluid adaptive stage ----------
    Item {
        id: stage
        anchors.fill: parent
        focus: true

        Keys.onPressed: (e) => root.handleKey(e)
        Keys.onReleased: (e) => {
            if (e.isAutoRepeat) return
            if (e.key === Qt.Key_W) Vehicle.throttle = 0
            if (e.key === Qt.Key_S) Vehicle.brake = 0
        }

        Rectangle { anchors.fill: parent; color: Theme.bg }

        // ambient lighting strips & glows
        Glow {
            x: -200; y: parent.height - 350; width: parent.width * 0.7; height: 500
            color: Theme.ambient; strength: 0.16
        }
        Glow {
            x: parent.width * 0.5; y: parent.height - 350; width: parent.width * 0.7; height: 500
            color: Theme.ambient; strength: 0.14
        }
        Rectangle {
            anchors.bottom: parent.bottom; width: parent.width; height: 4
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0; color: "transparent" }
                GradientStop { position: 0.5; color: Theme.ambient }
                GradientStop { position: 1; color: "transparent" }
            }
            opacity: App.awake ? 0.9 : 0
            Behavior on opacity { NumberAnimation { duration: 800 } }
        }

        // ---------- driver cluster container ----------
        Rectangle {
            id: clusterContainer
            x: root.clusterTargetX; y: root.clusterTargetY
            width: root.clusterTargetW; height: root.clusterTargetH
            radius: root.isCompact ? 24 : 34
            gradient: Gradient {
                GradientStop { position: 0.0; color: Theme.panel }
                GradientStop { position: 1.0; color: Theme.bg }
            }
            border.color: Theme.line; border.width: 1
            clip: true
            visible: width > 10 && height > 10

            Behavior on x { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
            Behavior on y { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
            Behavior on width { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
            Behavior on height { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }

            // subtle inner ambient glow
            Rectangle {
                anchors.fill: parent; radius: parent.radius; color: "transparent"
                border.color: Theme.alpha(Theme.ambient, 0.08); border.width: 2
                scale: 0.985
            }

            Cluster {
                id: cluster
                anchors.fill: parent
                opacity: App.awake ? 1 : 0
                scale: App.awake ? 1 : 0.94
                Behavior on opacity { NumberAnimation { duration: 900 } }
                Behavior on scale { NumberAnimation { duration: 900; easing.type: Easing.OutCubic } }
            }
        }

        // ---------- control display (infotainment) container ----------
        Rectangle {
            id: controlContainer
            x: root.controlTargetX; y: root.controlTargetY
            width: root.controlTargetW; height: root.controlTargetH
            radius: root.isCompact ? 24 : 34
            gradient: Gradient {
                GradientStop { position: 0.0; color: Theme.panel }
                GradientStop { position: 1.0; color: Theme.bg }
            }
            border.color: Theme.line; border.width: 1
            clip: true
            visible: width > 10 && height > 10

            Behavior on x { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
            Behavior on y { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
            Behavior on width { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
            Behavior on height { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }

            // subtle inner glow
            Rectangle {
                anchors.fill: parent; radius: parent.radius; color: "transparent"
                border.color: Theme.alpha(Theme.ambient, 0.08); border.width: 2
                scale: 0.985
            }

            Item {
                id: control
                anchors.fill: parent
                opacity: App.awake ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 700 } }

                StatusBar {
                    id: statusBar
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 64
                    title: root.titles[App.page]
                }

                Loader {
                    id: pageLoader
                    anchors.top: statusBar.bottom
                    anchors.bottom: bottomBar.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    source: root.files["home"]
                    clip: true
                }

                BottomBar {
                    id: bottomBar
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 96
                }
            }
        }

        // page transition
        SequentialAnimation {
            id: pageAnim
            ParallelAnimation {
                NumberAnimation { target: pageLoader; property: "opacity"; to: 0; duration: 140 }
                NumberAnimation { target: pageLoader; property: "x"; to: -50; duration: 140; easing.type: Easing.InCubic }
            }
            ScriptAction {
                script: {
                    App.page = root.pendingPage
                    pageLoader.source = root.files[App.page]
                    pageLoader.x = 70
                }
            }
            ParallelAnimation {
                NumberAnimation { target: pageLoader; property: "opacity"; to: 1; duration: 260 }
                NumberAnimation { target: pageLoader; property: "x"; to: 0; duration: 320; easing.type: Easing.OutCubic }
            }
        }

        // brightness dimmer
        Rectangle {
            anchors.fill: parent; color: "black"; z: 50
            opacity: (1 - Vehicle.brightness) * 0.75
            enabled: false
        }

        // ---------- incoming call popup ----------
        Rectangle {
            id: callPop
            z: 70
            width: Math.min(560, root.width - 40); height: 136; radius: 32
            x: (controlContainer.visible && controlContainer.width > 300)
               ? (controlContainer.x + (controlContainer.width - width) / 2)
               : ((root.width - width) / 2)
            y: Vehicle.callState === "incoming" && App.awake ? 38 : -210
            color: Theme.glass
            border.color: Theme.ok; border.width: 1.5
            Behavior on y { NumberAnimation { duration: 480; easing.type: Easing.OutBack } }

            // backdrop tint
            Rectangle { anchors.fill: parent; radius: parent.radius; color: "#0c1420"; opacity: 0.92 }

            Row {
                x: 24; anchors.verticalCenter: parent.verticalCenter; spacing: 18
                Rectangle {
                    width: 72; height: 72; radius: 36
                    color: Theme.alpha(Theme.ok, 0.20); border.color: Theme.ok; border.width: 2
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        anchors.centerIn: parent
                        text: Vehicle.callName.length ? Vehicle.callName[0] : ""
                        color: Theme.ok; font.pixelSize: 34; font.weight: Font.DemiBold
                    }
                    SequentialAnimation on scale {
                        running: callPop.y > 0; loops: Animation.Infinite
                        NumberAnimation { to: 1.10; duration: 550; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 1; duration: 550; easing.type: Easing.InOutSine }
                    }
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter; spacing: 4
                    Text { text: "Incoming call"; color: Theme.dim; font.pixelSize: 15; font.letterSpacing: 1 }
                    Text { text: Vehicle.callName; color: "white"; font.pixelSize: 26; font.weight: Font.Medium }
                }
            }
            Row {
                anchors.right: parent.right; anchors.rightMargin: 20
                anchors.verticalCenter: parent.verticalCenter; spacing: 12
                Btn { width: 82; height: 64; round: true; glyph: "\u2715"; tint: Theme.danger; active: true; onClicked: Vehicle.endCall() }
                Btn { width: 82; height: 64; round: true; glyph: Theme.g.phone; tint: Theme.ok; active: true
                    onClicked: { Vehicle.answer(); App.goTo("phone") } }
            }
        }

        // ---------- toast ----------
        Rectangle {
            id: toastBox
            z: 80
            property string msg: ""
            property string glyph: ""
            height: 58; radius: 29
            width: Math.min(tRow.width + 60, root.width - 40)
            x: (controlContainer.visible && controlContainer.width > 300)
               ? (controlContainer.x + (controlContainer.width - width) / 2)
               : ((root.width - width) / 2)
            y: -120
            color: Theme.alpha(Theme.panel, 0.92)
            border.color: Theme.alpha(Theme.ambient, 0.65); border.width: 1
            Row {
                id: tRow; anchors.centerIn: parent; spacing: 10
                Text { text: toastBox.glyph; color: Theme.ambient; font.pixelSize: 22; anchors.verticalCenter: parent.verticalCenter }
                Text { text: toastBox.msg; color: Theme.text; font.pixelSize: 21; font.weight: Font.Medium; anchors.verticalCenter: parent.verticalCenter }
            }
            SequentialAnimation {
                id: toastAnim
                NumberAnimation { target: toastBox; property: "y"; to: 34; duration: 340; easing.type: Easing.OutBack }
                PauseAnimation { duration: 2500 }
                NumberAnimation { target: toastBox; property: "y"; to: -120; duration: 300; easing.type: Easing.InCubic }
            }
        }

        VoiceOverlay { id: voice; z: 90; anchors.fill: parent }

        // ---------- landing / attract screen ----------
        AttractScreen {
            id: attract
            z: 100
            anchors.fill: parent
            opacity: App.awake ? 0 : 1
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: 800; easing.type: Easing.InOutCubic } }
            onWoke: App.wakeRequested()
        }
    }

    // ---------- gauge boot sweep ----------
    SequentialAnimation {
        id: bootAnim
        PauseAnimation { duration: 350 }
        NumberAnimation { target: Vehicle; property: "bootSweep"; from: 0; to: 1; duration: 1000; easing.type: Easing.InOutCubic }
        NumberAnimation { target: Vehicle; property: "bootSweep"; to: 0; duration: 1000; easing.type: Easing.InOutCubic }
        ScriptAction { script: if (Vehicle.demoAuto && !Vehicle.autoDrive && Vehicle.gear === "P") Vehicle.startAutoDrive() }
    }

    // ---------- idle -> back to landing ----------
    Timer {
        id: idle
        interval: App.idleSeconds * 1000
        running: App.awake && App.screensaver && Vehicle.callState === "idle"
        onTriggered: App.sleepRequested()
    }

    Connections {
        target: App
        function onActivity() { idle.restart() }
        function onWakeRequested() {
            if (App.awake) return
            App.awake = true
            App.page = "home"
            pageLoader.source = ""
            pageLoader.source = root.files["home"]
            pageLoader.opacity = 1; pageLoader.x = 0
            bootAnim.restart()
            idle.restart()
        }
        function onSleepRequested() {
            App.awake = false
            voice.hide()
            Vehicle.bootSweep = 0
            attract.burst = 0
            attract.armed = false
            armTimer.restart()
        }
        function onPageRequested(p) {
            if (!App.awake || p === App.page || !root.files[p]) return
            root.pendingPage = p
            pageAnim.restart()
        }
        function onToastRequested(text, glyph) {
            if (!App.awake) return
            toastBox.msg = text; toastBox.glyph = glyph
            toastAnim.restart()
        }
        function onVoiceRequested() { if (App.awake) voice.show() }
        function onResizeRequested(w, h) {
            root.visibility = Window.Windowed
            root.width = w
            root.height = h
        }
        function onFullscreenRequested() {
            root.visibility = root.visibility === Window.FullScreen ? Window.Windowed : Window.FullScreen
        }
        function onKeyPressed(k) { }
    }
    Timer { id: armTimer; interval: 1200; onTriggered: attract.armed = true }

    function handleKey(e) {
        if (!App.awake) { App.wakeRequested(); e.accepted = true; return }
        App.poke()
        switch (e.key) {
        case Qt.Key_Left: App.keyPressed("left"); break
        case Qt.Key_Right: App.keyPressed("right"); break
        case Qt.Key_Up: App.keyPressed("up"); break
        case Qt.Key_Down: App.keyPressed("down"); break
        case Qt.Key_Return: case Qt.Key_Enter: App.keyPressed("enter"); break
        case Qt.Key_Escape: case Qt.Key_Backspace: App.goTo("home"); break
        case Qt.Key_Space: App.voiceRequested(); break
        case Qt.Key_H: App.goTo("home"); break
        case Qt.Key_N: App.goTo("nav"); break
        case Qt.Key_M: App.goTo("media"); break
        case Qt.Key_P: App.goTo("phone"); break
        case Qt.Key_C: App.goTo("climate"); break
        case Qt.Key_D: App.goTo("drive"); break
        case Qt.Key_W: Vehicle.manual = true; if (Vehicle.gear === "P") Vehicle.setGear("D"); Vehicle.throttle = 1; break
        case Qt.Key_S: Vehicle.manual = true; Vehicle.brake = 1; break
        case Qt.Key_Z: Vehicle.leftSignal = !Vehicle.leftSignal; Vehicle.rightSignal = false; break
        case Qt.Key_X: Vehicle.rightSignal = !Vehicle.rightSignal; Vehicle.leftSignal = false; break
        case Qt.Key_F1: App.resizeTo(1920, 720); break
        case Qt.Key_F2: App.resizeTo(1920, 1080); break
        case Qt.Key_F3: App.resizeTo(900, 1200); break
        case Qt.Key_F4: App.resizeTo(1024, 600); break
        case Qt.Key_F9: App.setLayoutMode(App.layoutMode === "cluster" ? "split" : "cluster"); break
        case Qt.Key_F10: App.setLayoutMode(App.layoutMode === "infotainment" ? "split" : "infotainment"); break
        case Qt.Key_F11:
            root.visibility = root.visibility === Window.FullScreen ? Window.Windowed : Window.FullScreen
            break
        default: return
        }
        e.accepted = true
    }

    // passive pointer watcher -> idle timer (does not steal events)
    Item {
        anchors.fill: parent
        PointHandler { onPointChanged: App.poke() }
    }
}
