# ArcSoft SDK Building

## Add `mpbase` Dependency

Usage:

```cmake
# Add mpbase dependency if needed
include(${ARCBUILD_DIR}/mpbase.cmake)
target_link_libraries(arcsoft_xxx mpbase)
```

The version of `mpbase` will be selected automatically w.r.t. target platform, architecture and target type.

### Arguments for `mpbase`

```cmake
MPBASE_DIR      # The path to given version, e.g. "/home/mpbase/0.1.0.4/android_armv7-a"
MPBASE_ROOT     # The path to root directory, e.g. "/home/mpbase"
MPBASE_VERSION  # version name, e.g. "0.1.0.4/android_armv7-a"
```


## Arguments for `arcbuild_define_arcsoft_sdk()`

This `CMake` function define ArcSoft SDK information which is used by build system when calling `cmake -P arcbuild.cmake`.

```cmake
if(ARCBUILD) # defined when calling "cmake -P arcbuild.cmake"
  arcbuild_define_arcsoft_sdk(
    arcsoft_xxx             # SDK name
    LIBRARY arcsoft_xxx     # SDK main library
    INCS inc/*.h            # SDK headers ("*" for globbing; "**" for recursive globbing; directory for whole directory install)
    VERSION_FILE src/version.c # SDK version file
    SAMPLE_CODE samplecodes/samplecode.c # SDK sample code
    RELEASE_NOTES releasenotes.txt # SDK release notes
    DOCS doc/*.pdf          # SDK docs
  )
endif()
```
