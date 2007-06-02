#ifndef HIMInput_h
#define HIMInput_h

#include <Carbon/Carbon.h>


Boolean HIMInputDocumentHasProperty(OSType aPropertyTag);

OSErr HIMInput(HIMSessionHandle aSessionHandle, Boolean aFix);


#endif
