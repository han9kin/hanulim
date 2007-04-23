#ifndef HIMMethod_h
#define HIMMethod_h

#include <Carbon/Carbon.h>

UniChar HIMQuotationMark(UniChar ch);

Boolean HIMHandleKey(HIMSessionHandle inSessionHandle, UInt32 inKeyCode, UInt32 inModifiers, unsigned char inCharCode);

void HIMComposite(HIMSessionHandle inSessionHandle);

#endif
