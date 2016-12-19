@echo off
set SDK_ROOT=E:\NDK\android-ndk-r11b
set PATH=%PATH%;%ProgramFiles(x86)%\CMake\bin
set PATH=%PATH%;%SDK_ROOT%\prebuilt\windows-x86_64\bin
mkdir _build\multiple_modules_sdk
pushd
cd _build\multiple_modules_sdk
cmake ..\..\multiple_modules_sdk -DCMAKE_TOOLCHAIN_FILE=..\..\..\toolchains\android-ndk.cmake -G"Unix Makefiles" -DARCBUILD_ROOT_DIR=F:\projects\autobuild2 -DARCBUILD_VERBOSE=ON -DARCBUILD_TYPE=SHARED
cmake --build .
make install
REM make package
popd
pause
