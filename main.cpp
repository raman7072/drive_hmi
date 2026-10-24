#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("DriveHMI");

    // Rely on GPU-side antialiasing for shapes and scene-graph primitives
    // instead of forcing 4x full-framebuffer MSAA across the entire window

    QQmlApplicationEngine engine;
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, []() { QCoreApplication::exit(-1); },
                     Qt::QueuedConnection);
    engine.loadFromModule("DriveHMI", "Main");
    return app.exec();
}
