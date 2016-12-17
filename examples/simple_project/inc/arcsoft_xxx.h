#ifndef __ARCSOFT_XXX_H__
#define __ARCSOFT_XXX_H__

#if defined(arcsoft_xxx_EXPORTS)
#   if defined(_WINDOWS) || defined(__CYGWIN__)
#       define ASXXX_DLL __declspec(dllexport)
#   elif defined(__GNUC__) && __GNUC__ >= 4
#       define ASXXX_DLL __attribute__ ((visibility ("default")))
#   else
#       define ASXXX_DLL
#   endif
#else
#   define ASXXX_DLL
#endif

//#include "asvloffscreen.h"
typedef long MLong;
typedef char MTChar;

#ifdef __cplusplus
extern "C" {
#endif
    
typedef struct
{
    MLong lCodebase;                ///< Codebase version number
    MLong lMajor;                   ///< major version number
    MLong lMinor;                   ///< minor version number
    MLong lBuild;                   ///< Build version number, increasable only
    MTChar* Version;                ///< version in string form
    MTChar* BuildDate;              ///< latest build Date
    MTChar* CopyRight;              ///< copyright
} ArcSoft_XXX_Version;  ///< Object Tracking Engine Version

//////////////////////////////////////////////////////////////////////////
/// @brief   The function used to get version information of the library.
///
/// @return const ArcSoft_XXX_Version *  [OUT]
///
/// @since Version 1.0
///
/// @details
///
/// @remark
///
/// @see
//////////////////////////////////////////////////////////////////////////
ASXXX_DLL const ArcSoft_XXX_Version * ArcSoft_XXX_GetVersion();
ASXXX_DLL void ASXXX_Test();

#ifdef __cplusplus
}
#endif

#endif // end of header file
