cmake_minimum_required(VERSION 3.21)
project(DriveHMI VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Quick)
qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appDriveHMI main.cpp)

# Singletons (global state objects)
set_source_files_properties(Theme.qml Vehicle.qml App.qml
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_qml_module(appDriveHMI
    URI DriveHMI
    VERSION 1.0
    QML_FILES
        Main.qml Theme.qml Vehicle.qml App.qml
        Btn.qml Toggle.qml Slide.qml Glow.qml
        SpeedRing.qml Cluster.qml StatusBar.qml BottomBar.qml
        AttractScreen.qml VoiceOverlay.qml
        HomePage.qml NavPage.qml MediaPage.qml PhonePage.qml
        ClimatePage.qml VehiclePage.qml DrivePage.qml EnergyPage.qml
        SettingsPage.qml AppsPage.qml
)

target_link_libraries(appDriveHMI PRIVATE Qt6::Quick)

set_target_properties(appDriveHMI PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE)

include(GNUInstallDirs)
install(TARGETS appDriveHMI BUNDLE DESTINATION . RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
