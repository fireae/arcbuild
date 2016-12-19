@echo off
set SDK_ROOT=E:\NDK\android-ndk-r11b
set PATH=%PATH%;%ProgramFiles(x86)%\CMake\bin
set PATH=%PATH%;%SDK_ROOT%\prebuilt\windows-x86_64\bin
mkdir _build\simple_project
pushd
cd _build\simple_project
cmake ..\..\simple_project -DCMAKE_TOOLCHAIN_FILE=..\..\..\toolchains\android-ndk.cmake -G"Unix Makefiles" -DARCBUILD_ROOT_DIR=F:\projects\autobuild2 -DARCBUILD_VERBOSE=ON
cmake --build .
make package
popd
pause
