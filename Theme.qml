pragma Singleton
import QtQuick

QtObject {
    property bool night: true
    property color ambient: "#1c69d4"
    property color accent: ambient
    property color bg: night ? "#05070a" : "#cfd5df"
    property color panel: night ? "#0f1319" : "#f4f6fa"
    property color panel2: night ? "#181e28" : "#e3e8f0"
    property color line: night ? "#262e3c" : "#c5ccd8"
    property color text: night ? "#f2f5fa" : "#10151d"
    property color dim: night ? "#8b95a7" : "#586273"
    property color warn: "#ffb020"
    property color danger: "#ff4d4f"
    property color ok: "#35d07f"
    property string family: "Helvetica Neue"
    property int radius: 18

    // monochrome unicode glyphs (swap for SVG icons in production)
    readonly property var g: ({
        nav: "\u27A4", media: "\u266B", phone: "\u2706", climate: "\u2744\uFE0E",
        vehicle: "\u25A3", drive: "\u25C9", energy: "\u26A1\uFE0E", apps: "\u25A6",
        settings: "\u2699\uFE0E", home: "\u2302", back: "\u2039", mic: "\u25CE",
        play: "\u25B6", pause: "\u275A\u275A", next: "\u23ED\uFE0E", prev: "\u23EE\uFE0E",
        shuffle: "\u21C4", repeat: "\u21BB", seat: "\u2668\uFE0E", fan: "\u2735",
        mute: "\u2297", vol: "\u266A", msg: "\u2709\uFE0E", info: "\u24D8"
    })

    function alpha(c, a) { var k = Qt.color(c); return Qt.rgba(k.r, k.g, k.b, a) }
    function css(c, a) {
        var k = Qt.color(c)
        return "rgba(" + Math.round(k.r * 255) + "," + Math.round(k.g * 255) + ","
               + Math.round(k.b * 255) + "," + (a === undefined ? k.a : a) + ")"
    }
}
