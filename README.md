# CMake build scripts for ArcSoft SDK

Pure cmake scripts for native and cross compiling building of ArcSoft SDK.
The previous version is [arcbuild](http://172.17.10.213/lny1856/arcbuild).


## Features

- Integration is light! Only need to add ONLY ONE file (`arcbuild.cmake`) to your CMake project.
- Pure CMake scripts and no other dependencies.
- Support major platforms and system architectres of ArcSoft SDK, e.g. `win32`, `linux`, `android`, `ios`, `tizen`, etc.
- Support CMake library depended on multiple modules. All modules will be combined into one library automatically when building SDK.
- Extract version numbers from release notes.
- Update version file with date, version numbers and platform number.
- Generating meta informations in release notes, including publish date, version, platform, compile flags and file list.
- Import `mpbase` prebuilt into your CMake project easily by adding `include(${ARCBUILD_DIR}/mpbase.cmake)`.
- Install or pack SDK by `make install` and `make package` commands.


## Dependencies

- [CMake](http://cmake.org/) >= 3.0


## Usage

1. Download `arcbuild.cmake` to root directory of your CMake project.
2. Define SDK in your `CMakeLists.txt` according to your project.
3. Build SDK by runing `cmake -D_BUILD=ON -P arcbuild.cmake`.

```cmake
# Define library
file(GLOB_RECURSE HDRS inc/*.h)
file(GLOB_RECURSE SRCS src/*.h src/*.c src/*.cpp)
add_library(arcsoft_xxx ${ARCBUILD_TYPE} ${HDRS} ${SRCS}) # NOTE: ${ARCBUILD_TYPE}
target_include_directories(arcsoft_xxx PUBLIC inc)

# Enable arcbuild functions
include(arcbuild.cmake)
arcbuild_enable_features(cxx11 neon sse2 hidden)

# Add mpbase dependency if needed
include(${ARCBUILD_DIR}/mpbase.cmake)
target_link_libraries(arcsoft_xxx mpbase)

if(ARCBUILD)
  # Define ArcSoft SDK
  include(${ARCBUILD_DIR}/arcsoft_sdk.cmake)
  arcbuild_define_arcsoft_sdk(
    arcsoft_xxx             # SDK name
    LIBRARY arcsoft_xxx     # SDK main library
    INCS inc/*.h            # SDK headers
    VERSION_FILE src/version.c # SDK version file
    SAMPLE_CODE samplecodes/samplecode.c # SDK sample code
    RELEASE_NOTES releasenotes.txt # SDK release notes
    DOCS doc/*.pdf          # SDK docs
  )
endif()
```

### Build SDK

#### Build for Android (`ARCH=armv7-a` by default)

```shell
cmake -D_BUILD=ON -DPLATFORM=android -DROOT="E:\NDK\android-ndk-r11b" -P arcbuild.cmake
```

#### Build for VS2015 (`ARCH=x86` by default)

```shell
cmake -D_BUILD=ON -DPLATFORM=vs2015 -P arcbuild.cmake
```

#### Build for Linux (`ARCH=x86` by default)

```shell
cmake -D_BUILD=ON -DPLATFORM=linux -P arcbuild.cmake
```

#### Build for iOS (`ARCH="armv7;armv7s;arm64"` by default)

```shell
cmake -D_BUILD=ON -DPLATFORM=ios -P arcbuild.cmake
```


## Example Projects

- [local_arcbuild](examples/local_arcbuild): project with local `arcbuild.cmake` and latest build scripts will be download when `_arbuild` directory does not existed.
- [simple_sdk](examples/simple_sdk): simple SDK without dependency
- [simple_sdk_with_mpbase](examples/simple_sdk_with_mpbase): simple SDK with only mpbase dependency
- [multiple_modules_sdk](examples/multiple_modules_sdk): SDK with multiple modules and no mpbase dependency


## Upgrade

Delete the `_arcbuild` directory in project root directory, then the build system will be upgraded automatically.


## TODO

- Add doc for `arcbuild_define_arcsoft_sdk`.
- Add doc for `cmake -P arcbuild.cmake`.
