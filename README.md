# CMake build scripts for ArcSoft SDK

Pure cmake scripts for native and cross compiling building of ArcSoft SDK.
The previous version is [arcbuild](http://172.17.10.213/lny1856/arcbuild).

## Example Projects

- [simple_sdk](examples/simple_sdk): simple SDK without dependency
- [simple_sdk_with_mpbase](examples/simple_sdk_with_mpbase): simple SDK with only mpbase dependency
- [multiple_modules_sdk](examples/multiple_modules_sdk): SDK with multiple modules and no mpbase dependency


## Usage

1. Download `arcbuild.cmake` to root directory of your CMake project.
2. Define SDK in your `CMakeLists.txt` according to your project.

```cmake
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

3. Build SDK's
```shell
cmake -D_BUILD=ON -DSOURCE_DIR=. -DBINARY_DIR=_build -DROOT="E:\NDK\android-ndk-r11b" -DTYPE=SHARED -DPLATFORM=android -DARCH=armv7-a -DVERBOSE=1 -P arcbuild.cmake
```


## Upgrade

Delete the `_arcbuild` directory, then the build system will be upgraded automatically.
