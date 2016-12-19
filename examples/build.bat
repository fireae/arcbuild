@echo off
set SDK_ROOT=E:\NDK\android-ndk-r11b
set PATH=%PATH%;%ProgramFiles(x86)%\CMake\bin
set PATH=%PATH%;%SDK_ROOT%\prebuilt\windows-x86_64\bin
mkdir _build\simple_sdk_with_mpbase
pushd
cd _build\simple_sdk_with_mpbase
cmake ..\..\simple_sdk_with_mpbase -DCMAKE_TOOLCHAIN_FILE=..\..\..\toolchains\android-ndk.cmake -G"Unix Makefiles" -DARCBUILD_ROOT_DIR=F:\projects\autobuild2 -DARCBUILD_VERBOSE=ON -DARCBUILD_TYPE=SHARED -DARCBUILD=1
cmake --build .
REM make install
make package
popd
pause
