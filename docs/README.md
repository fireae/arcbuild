
## Arguments for `cmake -P arcbuild.cmake`

All the following arguments MUST be added before `-P`.

```cmake
TYPE            # [REQUIRED] type of target library, "static" or "shared", "shared" by default.
PLATFORM        # target platform, e.g. android, ios, vs2015, etc.
ARCH            # target architectures, e.g. armv7-a, "armv7;armv7s;arm64", etc.
BUILD_TYPE      # build configure in "Debug|Release|MinSizeRel|RelWithDebInfo", default is "Release".
MAKE_TARGET     # target when calling "make <target>".

MAKE_PROGRAM    # path of "make" program, usually is searched automatically.
TOOLCHAIN_FILE  # toolchain file for CMake, usually is set automatically.
ROOT            # root directory of SDK or empty. e.g. "E:\NDK\android-ndk-r11b", default is empty.
API_VERSION     # SDK API version, e.g. android-9, default is empty.
VERBOSE         # level of output, see [Verbose Level](#verbose-level).

C_FLAGS         # compile flags for C compiler.
CXX_FLAGS       # compile flags for C++ compiler.
LINK_FLAGS      # linker flags.

CUSTOMER        # SDK customer, add "_FOR_<CUSTOMER>" in package name.
SUFFIX          # add this suffix to package name.

# Following arguments are unstable.
SDK             # reserved
STL             # reserved
```

### Verbose Level

The `VERBOSE` argument controls the output level of build system.
There are several levels as the following:

```cmake
0 - quiet
1 - warning
2 - information (default)
3 - debug
4 - verbose makefile
```


## Help for `arcbuild_enable_features()`

Usage:
```cmake
# Enable arcbuild functions
include(arcbuild.cmake)
arcbuild_enable_features(cxx11 neon sse2 hidden)
```

Supported Features:

```cmake
cxx11       # Enable C++11
neon        # Enable NEON if supported
sse         # Enable SSE if supported
sse2/sse3/sse4
hidden      # Hides most of the ELF symbols, see https://gcc.gnu.org/wiki/Visibility
```


## Add `mpbase` Dependency

Usage:

```cmake
# Add mpbase dependency if needed
include(${ARCBUILD_DIR}/mpbase.cmake)
target_link_libraries(arcsoft_xxx mpbase)
```

Please version of `mpbase` will be selected automatically w.r.t. target platform, architecture and target type.



## Arguments for `arcbuild_define_arcsoft_sdk()`

This `CMake` function define ArcSoft SDK information which is used by build system when calling `cmake -P arcbuild.cmake`.

```cmake
if(ARCBUILD) # defined when calling "cmake -P arcbuild.cmake"
  arcbuild_define_arcsoft_sdk(
    arcsoft_xxx             # SDK name
    LIBRARY arcsoft_xxx     # SDK main library
    INCS inc/*.h            # SDK headers ("*" for globbing and "**" for recursive globbing)
    VERSION_FILE src/version.c # SDK version file
    SAMPLE_CODE samplecodes/samplecode.c # SDK sample code
    RELEASE_NOTES releasenotes.txt # SDK release notes
    DOCS doc/*.pdf          # SDK docs
  )
endif()
```
