# ArcBuild

Easy native and cross compiling for CMake projects.


## Features

### For Noraml CMake Projects

- Integration is light! Only need to add ONLY ONE file (`arcbuild.cmake`) to your CMake project.
- Pure CMake scripts and no other dependencies.
- Support major platforms and system architectres, e.g. `win32`, `linux`, `android`, `ios`, `tizen`, etc.
- Support to combine multiple modules into one library automatically. It's useful when building static library for SDK delivery.
- Support NDK STL for Android (`system`, `gabi++`, `stlport` and `gnulstl`) by two-pass generation of Makefiles.

It's easy to extend the script to support custom SDK building, e.g. [ArcSoft SDK Building](docs/ArcSoftSDKBuilding.md).

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
- [combine_modules](examples/combine_modules): Combine multiple modules into one when compiling SDK.
- [arcsoft_sdk](examples/arcsfot_sdk): simple ArcSoft SDK with mpbase dependency


## Upgrade

Delete the `_arcbuild` directory in project root directory, then the build system will be upgraded automatically.


## TODO

- More tests.
- Set compile flags to individual source files.
- Add gui.
