pragma Singleton
import QtQuick

// Global UI state + event bus
QtObject {
    property string page: "home"
    property bool awake: false
    property bool screensaver: true
    property int idleSeconds: 60
    property string layoutMode: "split" // "split", "cluster", "infotainment"
    property int displayWidth: 1600
    property int displayHeight: 600

    signal pageRequested(string p)
    signal toastRequested(string text, string glyph)
    signal activity()
    signal wakeRequested()
    signal sleepRequested()
    signal voiceRequested()
    signal keyPressed(string k)
    signal resizeRequested(int w, int h)
    signal layoutModeRequested(string m)
    signal fullscreenRequested()

    function goTo(p) { pageRequested(p) }
    function toast(t, g) { toastRequested(t, g === undefined ? "\u24D8" : g) }
    function poke() { activity() }
    function setLayoutMode(m) { layoutMode = m; layoutModeRequested(m) }
    function resizeTo(w, h) { resizeRequested(w, h) }
    function toggleFullscreen() { fullscreenRequested() }
}
