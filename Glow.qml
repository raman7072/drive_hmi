import QtQuick
import QtQuick.Shapes

Shape {
    id: c
    property color color: Theme.ambient
    property real strength: 0.5

    ShapePath {
        strokeColor: "transparent"
        fillGradient: RadialGradient {
            centerX: c.width / 2
            centerY: c.height / 2
            centerRadius: Math.max(c.width, c.height) / 2
            focalX: centerX
            focalY: centerY
            GradientStop { position: 0.0; color: Theme.alpha(c.color, c.strength) }
            GradientStop { position: 1.0; color: "transparent" }
        }
        startX: 0; startY: 0
        PathLine { x: c.width; y: 0 }
        PathLine { x: c.width; y: c.height }
        PathLine { x: 0; y: c.height }
        PathLine { x: 0; y: 0 }
    }
}
