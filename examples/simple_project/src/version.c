#include <arcsoft_xxx.h>

// for auto build system
#define VERSION_CODEBASE 0
#define VERSION_MAJOR   0
#define VERSION_MINOR   0
#define VERSION_BUILD   0
#define VERSION_DATE "00/00/0000"
#define VERSION_VERSION "ArcSoft_XXX_0.0.0.0"
#define VERSION_COPYRIGHT "Copyright 2014 ArcSoft, Inc. All rights reserved."

const ArcSoft_XXX_Version * ArcSoft_XXX_GetVersion()
{
    static ArcSoft_XXX_Version s_ver = {
        VERSION_CODEBASE,
        VERSION_MAJOR,
        VERSION_MINOR,
        VERSION_BUILD,
        (MTChar*)(VERSION_VERSION " (" __DATE__ " " __TIME__ ")"),
        (MTChar*)(VERSION_DATE),
        (MTChar*)(VERSION_COPYRIGHT)
    };
    return &s_ver;
}
