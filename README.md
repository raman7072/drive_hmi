# Drive HMI – Qt/QML cluster + infotainment (iDrive-style)

Qt 6.5+ (Quick). Build with Qt Creator (open CMakeLists.txt) or:

    cmake -B build -DCMAKE_PREFIX_PATH=<Qt6 path> && cmake --build build && ./build/appDriveHMI

1920x720 virtual stage, scales to any window. F11 = fullscreen.

Flow: animated landing screen -> touch / mouse move / key -> wake animation
(gauge sweep, tiles fly in) -> auto-drive demo. Idle timeout returns to landing.

Keys (iDrive controller emulation): arrows+Enter navigate home carousel, Esc/Backspace back,
Space voice, H/N/M/P/C/D shortcuts, W/S throttle/brake, Z/X indicators.

Features: driver cluster (speed/power rings, ADAS road view, speed-limit, ACC, telltales, turn signals),
Navigation (procedural map, route guidance, traffic, day/night, search), Media (radio/BT/USB/online, EQ),
Phone (keypad, contacts, recents, calls, SOS, messages), Climate (dual zone, seats, defrost, airflow),
Vehicle (doors, tires, windows, lights, check control), Driving Assistant (modes, ADAS, simulator),
Energy (battery, power chart, charging), Apps (weather, messages, calendar, parking 360, calculator, timer),
Settings (display, sound, connectivity, units, language), Voice assistant (typed or demo commands).

Branding is generic ("DRIVE"); add your own logo/fonts/SVG icons (glyphs are Unicode placeholders).
Untested on-device: verify on your Qt version; report any QML warnings.
