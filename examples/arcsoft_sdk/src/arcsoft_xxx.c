#include <arcsoft_xxx.h>
#include <ammem.h>

void ASXXX_Test()
{
  MVoid* pMem = MMemAlloc(0, 100);
  MMemFree(0, pMem);
}
