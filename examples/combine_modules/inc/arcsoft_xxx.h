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

typedef long MLong;
typedef char MTChar;

#ifdef __cplusplus
extern "C" {
#endif

ASXXX_DLL void ASXXX_Test();

#ifdef __cplusplus
}
#endif

#endif // end of header file
