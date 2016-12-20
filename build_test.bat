@echo off
SET PATH=%PATH%;%ProgramFiles(x86)%\CMake\bin
DEL /S /Q *.zip
DEL /S /Q _build
FOR %%A IN (simple_sdk simple_sdk_with_mpbase multiple_modules_sdk) DO (
    cmake -D_BUILD=ON -DPLATFORM=android -DTYPE=SHARED -DROOT=E:\NDK\android-ndk-r11b -DSOURCE_DIR=examples/%%A -DBINARY_DIR=_build/%%A -DSUFFIX=_%%A -P arcbuild.cmake
    cmake -D_BUILD=ON -DPLATFORM=vs2015 -DTYPE=SHARED -DSOURCE_DIR=examples/%%A -DBINARY_DIR=_build/%%A -DSUFFIX=_%%A -P arcbuild.cmake
)
pause
