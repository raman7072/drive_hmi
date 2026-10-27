pragma Singleton
import QtQuick

QtObject {
    // ---- mode ----
    property bool night: true

    // ---- brand accent (changes with drive mode) ----
    property color ambient: "#00a8ff"
    property color accent: ambient

    // ---- surface palette ----
    property color bg:     night ? "#04060c"  : "#c8cdd8"
    property color panel:  night ? "#0c1018"  : "#f0f3fa"
    property color panel2: night ? "#141b27"  : "#e0e5f0"
    property color glass:  night ? Qt.rgba(1, 1, 1, 0.05) : Qt.rgba(1, 1, 1, 0.45)
    property color glassB: night ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(0, 0, 0, 0.08)

    // ---- lines & text ----
    property color line:   night ? "#1e293b"  : "#c2c9d8"
    property color text:   night ? "#edf0f8"  : "#0e1420"
    property color dim:    night ? "#7d8a9e"  : "#545f72"
    property color dimmer: night ? "#3e4c60"  : "#8896a8"

    // ---- semantic (clean, high-contrast, premium automotive palette) ----
    property color warn:   "#f59e0b"   // Refined automotive amber (no muddy yellow)
    property color danger: "#ff4455"   // Sport crimson red
    property color ok:     "#10b981"   // Modern emerald green
    property color heat:   "#ff5733"   // Warm infrared heat (seats, defrost, steering wheel)
    property color info:   "#00a8ff"   // High-tech electric cyan

    // ---- typography ----
    property string family: "Inter, Helvetica Neue, sans-serif"
    property string familyMono: "monospace"

    // ---- shape ----
    property int radius:   20
    property int radiusSm: 12
    property int radiusLg: 30

    // ---- glyphs ----
    readonly property var g: ({
        nav: "\u27A4", media: "\u266B", phone: "\u2706", climate: "\u2744\uFE0E",
        vehicle: "\u25A3", drive: "\u25C9", energy: "\u26A1\uFE0E", apps: "\u25A6",
        settings: "\u2699\uFE0E", home: "\u2302", back: "\u2039", mic: "\u25CE",
        play: "\u25B6", pause: "\u275A\u275A", next: "\u23ED\uFE0E", prev: "\u23EE\uFE0E",
        shuffle: "\u21C4", repeat: "\u21BB", seat: "\u2668\uFE0E", fan: "\u2735",
        mute: "\u2297", vol: "\u266A", msg: "\u2709\uFE0E", info: "\u24D8", star: "\u2605"
    })

    // ---- helpers ----
    function alpha(c, a) {
        var k = Qt.color(c)
        return Qt.rgba(k.r, k.g, k.b, a)
    }
    function css(c, a) {
        var k = Qt.color(c)
        return "rgba(" + Math.round(k.r * 255) + "," + Math.round(k.g * 255) + ","
               + Math.round(k.b * 255) + "," + (a === undefined ? k.a : a) + ")"
    }
    function lighten(c, f) {
        var k = Qt.color(c)
        return Qt.rgba(k.r + (1 - k.r) * f, k.g + (1 - k.g) * f, k.b + (1 - k.b) * f, k.a)
    }
}
