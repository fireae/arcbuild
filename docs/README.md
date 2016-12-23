# Documents of arcbuild


## Arguments for `cmake -P arcbuild.cmake`

All the following arguments MUST be added before `-P`.

```cmake
PLATFORM        # [REQUIRED] target platform, e.g. android, ios, vs2015, etc.
ARCH            # target architectures, e.g. armv7-a, "armv7;armv7s;arm64", etc.
TYPE            # type of target library, "static" or "shared", "shared" by default.
BUILD_TYPE      # build configure in "Debug|Release|MinSizeRel|RelWithDebInfo", default is "Release".
MAKE_TARGET     # target when calling "make <target>".
VERBOSE         # level of output, see [Verbose Level](#verbose-level).

ROOT            # root directory of SDK or empty. e.g. "E:\NDK\android-ndk-r11b", default is empty.
TOOLCHAIN_FILE  # toolchain file for CMake, usually is set automatically.
API_VERSION     # SDK API version, e.g. android-9, default is empty.
MAKE_PROGRAM    # path of "make" program, usually is searched automatically.

C_FLAGS         # compile flags for C compiler.
CXX_FLAGS       # compile flags for C++ compiler.
LINK_FLAGS      # linker flags.

CUSTOMER        # SDK customer, add "_FOR_<CUSTOMER>" in package name.
SUFFIX          # add this suffix to package name.

SOURCE_DIR      # the path of CMake project, default is ".".
BINARY_DIR      # the path to the build tree, default is "_build".

# Following arguments are unstable.
SDK             # reserved
STL             # reserved
```

### Verbose Level

The `VERBOSE` argument controls the output level of build system.
There are several levels as the following:

```cmake
0 - quiet, only error
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
