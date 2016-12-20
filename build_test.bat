@echo off
SET SDK_ROOT=E:\NDK\android-ndk-r11b
SET PATH=%PATH%;%ProgramFiles(x86)%\CMake\bin
FOR %%A IN (simple_sdk simple_sdk_with_mpbase multiple_modules_sdk) DO (
    cmake -DSOURCE_DIR=examples/%%A -DBINARY_DIR=_build/%%A -DTYPE=SHARED -DPLATFORM=android -DARCH=armv7-a -DVERBOSE=1 -D_BUILD=ON -P arcbuild.cmake
)
pause
