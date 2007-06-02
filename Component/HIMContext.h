#ifndef HIMContext_h
#define HIMContext_h

#include <Carbon/Carbon.h>


#define kBufferMax 1022


/*
 * Type definitions
 */

struct HIMSessionRecord
{
    ComponentInstance mComponentInstance;
    UInt32            mLastUpdateLength;
    UniCharCount      mCharBufferCount;
    UniCharPtr        mCharBuffer;
    UniCharCount      mKeyBufferCount;
    UniCharPtr        mKeyBuffer;
};

typedef struct HIMSessionRecord  HIMSessionRecord;
typedef HIMSessionRecord        *HIMSessionPtr;
typedef HIMSessionPtr           *HIMSessionHandle;


/*
 * Functions that operate on global contexts
 */

ComponentResult HIMInitialize(ComponentInstance aComponentInstance, MenuRef *aTextServiceMenu);
void            HIMTerminate(ComponentInstance aComponentInstance);

/*
 * Functions that operate on per-sesion contexts
 */

ComponentResult HIMSessionOpen(ComponentInstance aComponentInstance, HIMSessionHandle *aSessionHandle);
void            HIMSessionClose(HIMSessionHandle aSessionHandle);
ComponentResult HIMSessionActivate(HIMSessionHandle aSessinHandle);
ComponentResult HIMSessionDeactivate(HIMSessionHandle aSessionHandle);
ComponentResult HIMSessionEvent(HIMSessionHandle aSessionHandle, EventRef aEventRef);
ComponentResult HIMSessionFix(HIMSessionHandle aSessionHandle);
ComponentResult HIMSessionHidePalettes(HIMSessionHandle aSessionHandle);

/*
 * Other functions
 */

HIMSessionHandle HIMGetActiveSession();

void HIMLog(const char *aFormat, ...);


#endif
