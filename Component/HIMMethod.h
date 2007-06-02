#ifndef HIMMethod_h
#define HIMMethod_h

#include <Carbon/Carbon.h>


UniChar HIMQuotationMark(UniChar aChar);

Boolean HIMHandleKey(HIMSessionHandle aSessionHandle,
                     UInt32           aKeyCode,
                     UInt32           aModifiers,
                     unsigned char    aCharCode);

void HIMComposite(HIMSessionHandle aSessionHandle);


#endif
