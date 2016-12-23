# ArcBuild

Easy native and cross compiling for CMake projects.


## Features

- Pure CMake scripts and no other dependencies.
- Support major platforms and system architectres, e.g. `windows`, `linux`, `android`, `ios`, `tizen`, etc.
- Support to combine multiple modules into one library automatically. It's useful when building static library for SDK delivery.
- Support NDK STL for Android (`system`, `gabi++`, `stlport` and `gnulstl`) by two-pass generation of Makefiles.


## Dependencies

- [CMake](http://cmake.org/) >= 3.0

**Note**: higher version will be downloaded and installed to `~/.arcbuild` if version of  installed CMake is too low.


## Usage

1. Download `arcbuild.cmake` or whole project.
2. Build your project by runing `cmake -P arcbuild.cmake`.
3. More documents will be found in [docs](docs/README.md).

### Building Examples

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

- [hello_world](examples/hello_world): "Hello world" project.
- [local_arcbuild](examples/local_arcbuild): project with local `arcbuild.cmake`.
- [combine_modules](examples/combine_modules): combine multiple modules into one when building SDK.


## Upgrade

Delete the `_arcbuild` directory in project root directory, then the build system will be upgraded automatically.


## TODO

- More tests.
- Set compile flags to individual source files.
- Add gui.
