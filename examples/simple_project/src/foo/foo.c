#include <stdio.h>

typedef void MVoid;
typedef void* MHandle;
typedef long MLong;

MHandle MMemMgrCreate(MVoid* pMem, MLong lMemSize);
MVoid	MMemMgrDestroy(MHandle hMemMgr);	

int foo()
{
    printf("foo\n");
    return 0;
}

void memoryMgrTest()
{
    enum { BUFSZ = 1024 };
    char buf[BUFSZ];
    MHandle hMemMgr;

    printf("Memory manager test BEGAN\n");

    hMemMgr = MMemMgrCreate(buf, BUFSZ);
    MMemMgrDestroy(hMemMgr);
    hMemMgr = NULL;

    printf("Memory manager test END\n");
}
