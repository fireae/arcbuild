# ArcBuild

Easy native and cross compiling for CMake projects.
The previous version is [arcbuild](http://172.17.10.213/lny1856/arcbuild).


## Features

### For Noraml CMake Projects

- Integration is light! Only need to add ONLY ONE file (`arcbuild.cmake`) to your CMake project.
- Pure CMake scripts and no other dependencies.
- Support major platforms and system architectres, e.g. `win32`, `linux`, `android`, `ios`, `tizen`, etc.
- Support CMake library depended on multiple modules. All modules will be combined into one library automatically when building SDK.
- Support NDK STL for Android (`system`, `gabi++`, `stlport` and `gnulstl`) by two-pass generation of Makefiles.

### Extra Functions for ArcSoft SDK

- Extract version numbers from release notes.
- Update version file with date, version numbers and platform number.
- Generating meta informations in release notes, including publish date, version, platform, compile flags and file list.
- Import `mpbase` prebuilt into your CMake project easily by adding `include(${ARCBUILD_DIR}/mpbase.cmake)`.
- Install or pack SDK by `make install` and `make package` commands.

Pleae check [ArcSoft SDK Building](docs/ArcSoftSDKBuilding.md) for more information.


## Dependencies

- [CMake](http://cmake.org/) >= 3.0

**Note**: higher version will be downloaded and installed to `~/.arcbuild` if version of  installed CMake is too low.


## Usage

1. Download `arcbuild.cmake` to root directory of your CMake project.
2. Build SDK by runing `cmake -P arcbuild.cmake`.

More documents will be found in [docs](docs/README.md).

### Build SDK

#### Build for Android (`ARCH=armv7-a` by default)

```shell
cmake -DPLATFORM=android -DROOT="E:\NDK\android-ndk-r11b" -P arcbuild.cmake
```

#### Build for VS2015 (`ARCH=x86` by default)

```shell
cmake -DPLATFORM=vs2015 -P arcbuild.cmake
```

#### Build for Linux (`ARCH=x86` by default)

```shell
cmake -DPLATFORM=linux -P arcbuild.cmake
```

#### Build for iOS (`ARCH="armv7;armv7s;arm64"` by default)

```shell
cmake -DPLATFORM=ios -P arcbuild.cmake
```


## Example Projects

- [hello_world](examples/hello_world) CMake "Hello world" project.
- [local_arcbuild](examples/local_arcbuild): project with local `arcbuild.cmake` and latest build scripts will be download when `_arbuild` directory does not existed.
- [simple_sdk](examples/simple_sdk): simple SDK without dependency
- [simple_sdk_with_mpbase](examples/simple_sdk_with_mpbase): simple SDK with only mpbase dependency
- [multiple_modules_sdk](examples/multiple_modules_sdk): SDK with multiple modules and no mpbase dependency


## Upgrade

Delete the `_arcbuild` directory in project root directory, then the build system will be upgraded automatically.


## TODO

- More tests.
- Set compile flags to individual source files.
- Add gui.
