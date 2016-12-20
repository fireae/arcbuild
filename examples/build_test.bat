@ECHO off
SET SDK_ROOT=E:\NDK\android-ndk-r11b
SET PATH=%PATH%;%ProgramFiles(x86)%\CMake\bin
SET PATH=%PATH%;%SDK_ROOT%\prebuilt\windows-x86_64\bin
FOR %%i in ("%~dp0..") do set "ROOT_DIR=%%~fi"
ECHO ROOT_DIR: %ROOT_DIR%
FOR %%A IN (simple_sdk simple_sdk_with_mpbase multiple_modules_sdk) DO (
    mkdir %ROOT_DIR%\_build\%%A\android_armv-a
    pushd %ROOT_DIR%\_build\%%A\android_armv-a
    cmake "%ROOT_DIR%\examples\%%A" -DCMAKE_TOOLCHAIN_FILE="%ROOT_DIR%\toolchains\android-ndk.cmake" -G"Unix Makefiles" -DARCBUILD_TYPE=SHARED -DARCBUILD=1 -DARCBUILD_VERBOSE=OFF
    REM make install
    make package
    popd
)
pause
