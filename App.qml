pragma Singleton
import QtQuick

// Global UI state + event bus
QtObject {
    property string page: "home"
    property bool awake: false
    property bool screensaver: true
    property int idleSeconds: 60

    signal pageRequested(string p)
    signal toastRequested(string text, string glyph)
    signal activity()
    signal wakeRequested()
    signal sleepRequested()
    signal voiceRequested()
    signal keyPressed(string k)

    function goTo(p) { pageRequested(p) }
    function toast(t, g) { toastRequested(t, g === undefined ? "\u24D8" : g) }
    function poke() { activity() }
}
