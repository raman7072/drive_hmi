import QtQuick

// Top info bar – glassmorphism background, animated indicators, cockpit layout switcher & display presets
Item {
    id: sb
    implicitWidth: 1120; implicitHeight: 64
    property string title: ""

    // Smoked glass header background
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.night ? Qt.rgba(0.08, 0.12, 0.20, 0.75) : Qt.rgba(0.96, 0.98, 1.0, 0.85) }
            GradientStop { position: 1.0; color: Theme.night ? Qt.rgba(0.05, 0.07, 0.13, 0.40) : Qt.rgba(0.92, 0.95, 0.98, 0.60) }
        }
    }

    // Left zone: Back button & Page title
    Row {
        anchors.left: parent.left; anchors.leftMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        Btn {
            width: 104; height: 46
            flat: true; glyph: Theme.g.back; text: "Back"; fontSize: 18
            visible: App.page !== "home"
            onClicked: App.goTo("home")
        }

        Text {
            id: titleTxt
            text: sb.title
            color: Theme.text; font.pixelSize: sb.width < 700 ? 21 : 25; font.family: Theme.family
            font.weight: Font.DemiBold; font.letterSpacing: 0.3
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // Center zone: Cockpit layout switcher & Display preset selector
    Row {
        anchors.centerIn: parent
        spacing: 10
        visible: sb.width >= 860

        // Cockpit mode selector pill (Split / Cluster / Center Display)
        Rectangle {
            height: 40; width: 226; radius: 20
            color: Theme.alpha(Theme.panel2, 0.75)
            border.color: Theme.line; border.width: 1
            anchors.verticalCenter: parent.verticalCenter

            Row {
                anchors.centerIn: parent; spacing: 2
                Repeater {
                    model: [
                        { key: "split", label: "Dual", glyph: "\u25EB" },
                        { key: "cluster", label: "Cluster", glyph: "\u25C9" },
                        { key: "infotainment", label: "Center", glyph: "\u25A3" }
                    ]
                    Rectangle {
                        id: modeChip
                        width: 72; height: 34; radius: 17
                        property bool sel: App.layoutMode === modelData.key
                        color: sel ? Theme.alpha(Theme.ambient, 0.3) : (chipMa.containsMouse ? Theme.alpha("white", 0.08) : "transparent")
                        border.color: sel ? Theme.ambient : "transparent"; border.width: 1
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Row {
                            anchors.centerIn: parent; spacing: 4
                            Text { text: modelData.glyph; font.pixelSize: 13; color: modeChip.sel ? Theme.ambient : Theme.dim }
                            Text { text: modelData.label; font.pixelSize: 12; font.weight: modeChip.sel ? Font.Bold : Font.Normal; color: modeChip.sel ? "white" : Theme.dim }
                        }
                        MouseArea {
                            id: chipMa; anchors.fill: parent; hoverEnabled: true
                            onClicked: { App.poke(); App.setLayoutMode(modelData.key) }
                        }
                    }
                }
            }
        }

        // Screen Resolution & Display Presets Button
        Rectangle {
            id: resBtn
            height: 40; width: resRow.width + 24; radius: 20
            color: resMa.containsMouse || resMenu.visible ? Theme.alpha(Theme.ambient, 0.22) : Theme.alpha(Theme.panel2, 0.75)
            border.color: resMa.containsMouse || resMenu.visible ? Theme.ambient : Theme.line
            border.width: 1
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: 150 } }

            Row {
                id: resRow; anchors.centerIn: parent; spacing: 6
                Text { text: "\u2699\uFE0E"; font.pixelSize: 14; color: Theme.ambient; anchors.verticalCenter: parent.verticalCenter }
                Text {
                    text: App.displayWidth + " \u00D7 " + App.displayHeight
                    font.pixelSize: 12; font.weight: Font.DemiBold; font.family: Theme.familyMono
                    color: Theme.text; anchors.verticalCenter: parent.verticalCenter
                }
                Text { text: "\u25BE"; font.pixelSize: 11; color: Theme.dim; anchors.verticalCenter: parent.verticalCenter }
            }
            MouseArea {
                id: resMa; anchors.fill: parent; hoverEnabled: true
                onClicked: { App.poke(); resMenu.visible = !resMenu.visible }
            }
        }
    }

    // Display Presets Floating Modal Menu
    Rectangle {
        id: resMenu
        z: 999
        visible: false
        anchors.top: parent.bottom; anchors.topMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        width: 320; height: menuCol.height + 24; radius: 22
        color: Theme.alpha("#0c111a", 0.96)
        border.color: Theme.ambient; border.width: 1.5

        Rectangle {
            anchors.fill: parent; radius: parent.radius; color: "transparent"
            border.width: 1; border.color: Theme.alpha("white", 0.12)
        }

        Column {
            id: menuCol; x: 12; y: 12; width: parent.width - 24; spacing: 6
            Text {
                text: "AUTOMOTIVE DISPLAY PRESETS"
                color: Theme.dim; font.pixelSize: 11; font.letterSpacing: 1.5
                font.weight: Font.DemiBold; font.family: Theme.family
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Repeater {
                model: [
                    { name: "Panoramic Ultrawide", res: "1920 \u00D7 720 (24:9)", w: 1920, h: 720, icon: "\uD83D\uDCFA" },
                    { name: "Full HD Cockpit", res: "1920 \u00D7 1080 (16:9)", w: 1920, h: 1080, icon: "\uD83D\uDDA5" },
                    { name: "Standard Console", res: "1600 \u00D7 900 (16:9)", w: 1600, h: 900, icon: "\uD83D\uDCBB" },
                    { name: "Portrait Vertical (Tesla)", res: "900 \u00D7 1200 (3:4)", w: 900, h: 1200, icon: "\uD83D\uDCF1" },
                    { name: "Compact 7\" Touchscreen", res: "1024 \u00D7 600 (8:5)", w: 1024, h: 600, icon: "\uD83D\uDCDF" }
                ]
                Rectangle {
                    id: pItem
                    width: parent.width; height: 44; radius: 12
                    property bool cur: App.displayWidth === modelData.w && App.displayHeight === modelData.h
                    color: cur ? Theme.alpha(Theme.ambient, 0.25) : (pma.containsMouse ? Theme.alpha(Theme.panel2, 0.8) : "transparent")
                    border.color: cur ? Theme.ambient : "transparent"; border.width: 1

                    Row {
                        x: 12; anchors.verticalCenter: parent.verticalCenter; spacing: 10
                        Text { text: modelData.icon; font.pixelSize: 16; anchors.verticalCenter: parent.verticalCenter }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter; spacing: 1
                            Text { text: modelData.name; font.pixelSize: 13; font.weight: Font.DemiBold; color: pItem.cur ? "white" : Theme.text }
                            Text { text: modelData.res; font.pixelSize: 11; color: Theme.dim }
                        }
                    }
                    MouseArea {
                        id: pma; anchors.fill: parent; hoverEnabled: true
                        onClicked: {
                            App.poke()
                            App.resizeTo(modelData.w, modelData.h)
                            resMenu.visible = false
                        }
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: Theme.line }

            // Fullscreen toggle item
            Rectangle {
                width: parent.width; height: 38; radius: 10
                color: fma.containsMouse ? Theme.alpha(Theme.panel2, 0.8) : "transparent"
                Row {
                    anchors.centerIn: parent; spacing: 8
                    Text { text: "\u26F6"; font.pixelSize: 15; color: Theme.ambient }
                    Text { text: "Toggle Fullscreen (F11)"; font.pixelSize: 13; font.weight: Font.DemiBold; color: Theme.text }
                }
                MouseArea {
                    id: fma; anchors.fill: parent; hoverEnabled: true
                    onClicked: {
                        App.poke()
                        App.toggleFullscreen()
                        resMenu.visible = false
                    }
                }
            }
        }
    }

    // Right cluster: telemetry & system status
    Row {
        anchors.right: parent.right; anchors.rightMargin: 18
        anchors.verticalCenter: parent.verticalCenter
        spacing: sb.width < 750 ? 12 : 18

        // Unread badge
        Row {
            visible: Vehicle.unread > 0
            spacing: 5
            anchors.verticalCenter: parent.verticalCenter
            Rectangle {
                width: 22; height: 22; radius: 11; color: Theme.danger
                anchors.verticalCenter: parent.verticalCenter
                Text { anchors.centerIn: parent; text: Vehicle.unread; color: "white"; font.pixelSize: 13; font.weight: Font.Bold }
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Theme.g.msg; color: Theme.info; font.pixelSize: 18
            }
        }

        // Bluetooth dot
        Row {
            visible: sb.width >= 580
            anchors.verticalCenter: parent.verticalCenter; spacing: 4
            Rectangle {
                width: 8; height: 8; radius: 4
                anchors.verticalCenter: parent.verticalCenter
                color: Vehicle.phoneConnected ? Theme.ok : Theme.dimmer
                Behavior on color { ColorAnimation { duration: 300 } }
            }
            Text { anchors.verticalCenter: parent.verticalCenter; text: "BT"; color: Theme.dim; font.pixelSize: 13 }
        }

        // Signal strength bars (4 bars)
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3
            Repeater {
                model: 4
                Rectangle {
                    width: 4; height: 6 + index * 4; radius: 2
                    anchors.bottom: parent.bottom
                    color: index < 3 ? Theme.ambient : Theme.line
                    opacity: index < 3 ? 0.95 : 0.35
                }
            }
        }

        Text { visible: sb.width >= 640; anchors.verticalCenter: parent.verticalCenter; text: "5G"; color: Theme.dim; font.pixelSize: 13; font.weight: Font.Medium }

        // Outside temp
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Vehicle.outsideTemp.toFixed(0) + "\u00B0"
            color: Theme.dim; font.pixelSize: 17
        }

        // Clock
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Vehicle.timeText
            color: Theme.text; font.pixelSize: 24
            font.weight: Font.DemiBold; font.family: Theme.family
        }
    }

    // bottom separator line with ambient gradient
    Rectangle {
        anchors.bottom: parent.bottom; width: parent.width; height: 1
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Theme.line }
            GradientStop { position: 0.5; color: Theme.alpha(Theme.ambient, 0.45) }
            GradientStop { position: 1.0; color: Theme.line }
        }
        opacity: 0.7
    }
}

