#ifndef HIMInput_h
#define HIMInput_h

#include <Carbon/Carbon.h>

Boolean HIMInputDocumentHasProperty(OSType propertyTag);

OSErr HIMInput(HIMSessionHandle inSessionHandle, Boolean inFix);

#endif
