# Financy

Long where the days that I used a spreadsheet to take care of my finances, I created this to make it easily manegeable and more rewarding

## Getting up and running

Follow these steps to run it locally

### Windows
- 1 Install [Visual Studio 2019](https://visualstudio.microsoft.com/vs/older-downloads);
- 2 Install [CMake](https://cmake.org/download) (Version 3.11.0);
- 3 Install [QtCore, QtQuick, QtGui, QtQml, QtChart](https://www.qt.io/download-dev) (Version 6.7.0);
- 4 Go to the `Script/Vendors` folder;
- 5 Run the command `./OpenCV.bat "Visual Studio 16 2019" "Debug"`;
- 6 Go the root of the repo;
- 7 Create a file named `.env.cmake` and add your **Qt** installation location as `QT_PATH` variable `set(QT_PATH "{QT_PATH}")`;
- 8 Run the command `cmake . -B "./build" -G "Visual Studio 16 2019" -DCMAKE_BUILD_TYPE="Debug"`;
- 9 Go to the `Bin/Debug` and open the `Financy.exe`.
