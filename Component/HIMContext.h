#ifndef HIMContext_h
#define HIMContext_h

#include <Carbon/Carbon.h>

#define kBufferMax 1022

// Type definitions

struct HIMSessionRecord {
    ComponentInstance fComponentInstance;
    UInt32 fLastUpdateLength;
    UniCharCount fCharBufferCount;
    UniCharPtr fCharBuffer;
    UniCharCount fKeyBufferCount;
    UniCharPtr fKeyBuffer;
};

typedef struct HIMSessionRecord HIMSessionRecord;
typedef HIMSessionRecord *HIMSessionPtr;
typedef HIMSessionPtr *HIMSessionHandle;

// Functions that operate on global contexts.

ComponentResult HIMInitialize(ComponentInstance inComponentInstance, MenuRef *outTextServiceMenu);
void HIMTerminate(ComponentInstance inComponentInstance);

// Functions that operate on per-sesion contexts.

ComponentResult HIMSessionOpen(ComponentInstance inComponentInstance, HIMSessionHandle *outSessionHandle);
void HIMSessionClose(HIMSessionHandle sessionHandle);
ComponentResult HIMSessionActivate(HIMSessionHandle sessinHandle);
ComponentResult HIMSessionDeactivate(HIMSessionHandle sessionHandle);
ComponentResult HIMSessionEvent(HIMSessionHandle sessionHandle, EventRef eventRef);
ComponentResult HIMSessionFix(HIMSessionHandle sessionHandle);
ComponentResult HIMSessionHidePalettes(HIMSessionHandle sessionHandle);

// Other functions.

HIMSessionHandle HIMGetActiveSession();
void HIMLog(const char *format, ...);

#endif
