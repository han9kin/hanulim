#include "Hanulim.h"
#include "HIMContext.h"
#include "HIMInput.h"
#include "HIMPreferences.h"
#include "HIMMethod.h"
#include "HIMMethodTables.h"
#include "HIMScript.h"


#define KIND(code) (code >> 8)
#define VALUE(code) ((SInt8)code)

enum {
    kKindSymbol = 0,
    kKindInitial = 1,
    kKindMedial = 2,
    kKindFinal = 3
};


UInt16 HIMKeyCode(UInt32 inKeyCode, Boolean inShiftFlag) {
    if (inKeyCode <= keyMapMax) {
        UInt16 code = keyMap[preferences.keyboardLayout][inKeyCode] >> (inShiftFlag ? 16 : 0);
        UInt8 kind = KIND(code);
        UInt8 value = VALUE(code);
        
        if ((kind == kKindSymbol) && ((value > symbolMax) || (symbol[value] == 0)))
            return 0;
        
        return code;
    }
    return 0;
}

Boolean HIMIsShift(UInt32 inModifiers) {
    static UInt32 shiftBits = shiftKey | rightShiftKey;
    if (preferences.handleCapsLockAsShift && (inModifiers & alphaLock))
        return true;
    else
        return (inModifiers & shiftBits) ? true : false;
}

Boolean HIMCanHandle(UInt32 inModifiers) {
    static UInt32 otherBits = ~(shiftKey | rightShiftKey | alphaLock);
    return (inModifiers & otherBits) ? false : true;
}

UniChar HIMQuotationMark(UniChar ch) {
    static UniChar singleQuots[] = {0x2018, 0x2019};
    static UniChar doubleQuots[] = {0x201c, 0x201d};
    static Boolean singleQuot = true;
    static Boolean doubleQuot = true;
    
    if (ch == 0) { // initialize
        singleQuot = true;
        doubleQuot = true;
    } else if (ch == 0x27) { // single quotation mark
        singleQuot = !singleQuot;
        return singleQuots[singleQuot];
    } else if (ch == 0x22) { // double quotation mark
        doubleQuot = !doubleQuot;
        return doubleQuots[doubleQuot];
    }
    return ch;
}

Boolean HIMHandleKey(HIMSessionHandle inSessionHandle, UInt32 inKeyCode, UInt32 inModifiers, unsigned char inCharCode) {
    Boolean canHandle = HIMCanHandle(inModifiers);
    UInt16 code = canHandle ? HIMKeyCode(inKeyCode, HIMIsShift(inModifiers)) : 0;
    
    if (code) {
        if (KIND(code) == kKindSymbol) {
            UniChar ch = symbol[VALUE(code)];
            if (preferences.smartQuotationMarks)
                ch = HIMQuotationMark(ch);
            (*inSessionHandle)->fCharBuffer[(*inSessionHandle)->fCharBufferCount] = ch;
            ((*inSessionHandle)->fCharBufferCount)++;
            HIMSessionFix(inSessionHandle);
        } else if ((*inSessionHandle)->fKeyBufferCount < kBufferMax) {
            (*inSessionHandle)->fKeyBuffer[(*inSessionHandle)->fKeyBufferCount] = code;
            ((*inSessionHandle)->fKeyBufferCount)++;
            HIMComposite(inSessionHandle);
        } else {
            fprintf(stderr, "HANULIM ERROR: Buffer overflow. Key ignored.\n");
        }
        return true;
    } else if (canHandle && (*inSessionHandle)->fKeyBufferCount) {
        if (inCharCode == 0x08) { // delete
            ((*inSessionHandle)->fKeyBufferCount)--;
            HIMComposite(inSessionHandle);
            return true;
        } else if (TSMGetActiveDocument() == NULL) {
            (*inSessionHandle)->fCharBuffer[(*inSessionHandle)->fCharBufferCount] = inCharCode;
            ((*inSessionHandle)->fCharBufferCount)++;
            HIMSessionFix(inSessionHandle);
            return true;
        } else {
            HIMSessionFix(inSessionHandle);
            return false;
        }
    } else {
        HIMSessionFix(inSessionHandle);
        return false;
    }
}

SInt8 HIMCombine(UInt8 kind, SInt8 value1, SInt8 value2) {
    UInt32 i, count = compoundCount[kind - 1][HIMArchaicKeyboard()];
    UInt16 factor = (value1 << 8) | value2;
    
    for (i = 0; i < count; i++) {
        if (compoundFactor[kind - 1][i] == factor)
            return compoundResult[kind - 1][i];
    }
    
    return -1;
}

void HIMBufferClear(SInt8 *buffer) {
    buffer[0] = 0;
    buffer[1] = -1;
    buffer[2] = -1;
    buffer[3] = -1;
}

void HIMBufferCopy(SInt8 *srcBuf, SInt8 *destBuf) {
    destBuf[0] = srcBuf[0];
    destBuf[1] = srcBuf[1];
    destBuf[2] = srcBuf[2];
    destBuf[3] = srcBuf[3];
}

void HIMBufferSet(SInt8 *buffer, UInt8 kind, SInt8 value) {
    buffer[0] = kind;
    buffer[kind] = value;
}

UInt32 HIMGenerateChar(SInt8 *inBuffer, UniChar *outChar) {
    static const SInt8 min[4] = {0, 0, 0, 1};
    static const SInt8 cMax[4] = {0, 89, 65, 82};
    static const SInt8 sMax[4] = {0, 18, 20, 27};
    static const UniChar base[4] = {0, 0x1100, 0x1161, 0x11a7};
    static const UniChar filler[4] = {0, 0x115f, 0x1160, 0};
    UInt32 i, length = 0;
    
    if (HIMInputConjoiningJamo()) {
        for (i = kKindInitial; i <= kKindFinal; i++) {
            if ((inBuffer[i] >= min[i]) && (inBuffer[i] <= cMax[i])) {
                outChar[i - 1] = base[i] + inBuffer[i];
                length = i;
            } else {
                outChar[i - 1] = filler[i];
            }
        }
    } else {
        SInt8 buffer[4];
        UInt8 count = 0;
        UInt8 kind = 0;

        HIMBufferCopy(inBuffer, buffer);

        if (buffer[3] < 0)
            buffer[3] = 0;
        length = 1;
        
        for (i = kKindInitial; i <= kKindFinal; i++) {
            if ((buffer[i] >= min[i]) && (buffer[i] <= sMax[i])) {
                count++;
                kind = i;
            }
        }

        if (count == ((kind == kKindFinal) ? 3 : 2)) {
            int index = (buffer[kKindInitial] * 21 * 28) + (buffer[kKindMedial] * 28) + buffer[kKindFinal];
            if (HIMInputDocumentHasProperty(kTSMDocumentUnicodePropertyTag) || CanBeConvertedToKSC(index))
                *outChar = 0xac00 + index;
            else
                length = 0;
        } else if (count == 1) {
            *outChar = compatibilityJamo[kind - 1][buffer[kind]];
        } else {
            length = 0;
        }
    }
    return length;
}

UInt32 HIMCompositeBuffer(SInt8 *buffer, UInt8 kind, SInt8 value, UniChar *outChar) {
    UInt32 length;
    
    if (buffer[0] <= kind) {
        SInt8 newValue = (buffer[kind] > -1) ? HIMCombine(kind, buffer[kind], value) : value;
        
        if (newValue > -1) {
            SInt8 testBuf[4];
        
            HIMBufferCopy(buffer, testBuf);
            HIMBufferSet(testBuf, kind, newValue);

            if (HIMGenerateChar(testBuf, outChar)) {
                HIMBufferCopy(testBuf, buffer);
                return 0;
            }
        }
    }
    
    length = HIMGenerateChar(buffer, outChar);
        
    HIMBufferClear(buffer);
    HIMBufferSet(buffer, kind, value);
    
    return length;
}

void HIMDequeueKeyBuffer(HIMSessionHandle inSessionHandle, UInt32 inCount) {
    UInt32 i;
    
    (*inSessionHandle)->fKeyBufferCount -= inCount;
    for (i = 0; i < (*inSessionHandle)->fKeyBufferCount; i++)
        (*inSessionHandle)->fKeyBuffer[i] = (*inSessionHandle)->fKeyBuffer[i + inCount];
}

void HIMComposite(HIMSessionHandle inSessionHandle) {
    UniCharPtr charBuffer = (*inSessionHandle)->fCharBuffer;
    SInt8 buffer[4] = {0, -1, -1, -1};
    UInt32 length, i;
    
    (*inSessionHandle)->fCharBufferCount = 0;
    
    for (i = 0; i < (*inSessionHandle)->fKeyBufferCount; i++) {
        UInt16 code = (*inSessionHandle)->fKeyBuffer[i];
        UInt8 kind = KIND(code);
        SInt8 value = VALUE(code);
        
        if (HIMOverloadConsonants()) {
            if ((kind == kKindInitial) && (buffer[0] > kind)) {
                SInt8 final = initialToFinal[value];
                if (final && ((buffer[kKindFinal] == -1) || ((buffer[kKindFinal] != final) && ((final = HIMCombine(kKindFinal, buffer[kKindFinal], final)) > -1)))) {
                    SInt8 testBuf[4];
                    
                    HIMBufferCopy(buffer, testBuf);
                    HIMBufferSet(testBuf, kKindFinal, final);
                    if (HIMGenerateChar(testBuf, charBuffer)) {
                        kind = kKindFinal;
                        value = initialToFinal[value];
                    }
                }
            } else if ((kind == kKindMedial) && (buffer[0] == kKindFinal)) {
                SInt8 initial = VALUE((*inSessionHandle)->fKeyBuffer[i - 1]);
                SInt8 final = ((i > 1) && (KIND((*inSessionHandle)->fKeyBuffer[i - 2]) == kKindInitial)) ? initialToFinal[VALUE((*inSessionHandle)->fKeyBuffer[i - 2])] : -1;
                
                buffer[kKindFinal] = final;
                length = HIMGenerateChar(buffer, charBuffer);

                if (preferences.fixImmediately) {
                    (*inSessionHandle)->fCharBufferCount = length;
                    HIMInput(inSessionHandle, true);
                    HIMDequeueKeyBuffer(inSessionHandle, i - 1);
                    i = 1;
                } else {
                    (*inSessionHandle)->fCharBufferCount += length;
                    charBuffer += length;
                }
                
                HIMBufferClear(buffer);
                HIMBufferSet(buffer, kKindInitial, initial);
            }
        }
        
        length = HIMCompositeBuffer(buffer, kind, value, charBuffer);
        if (length) {
            if (preferences.fixImmediately) {
                (*inSessionHandle)->fCharBufferCount = length;
                HIMInput(inSessionHandle, true);
                HIMDequeueKeyBuffer(inSessionHandle, i);
                i = 0;
            } else {
                (*inSessionHandle)->fCharBufferCount += length;
                charBuffer += length;
            }
        }
    }
    
    length = HIMGenerateChar(buffer, charBuffer);
    if (length) {
        if (preferences.fixImmediately)
            (*inSessionHandle)->fCharBufferCount = length;
        else
            (*inSessionHandle)->fCharBufferCount += length;
    }

    HIMInput(inSessionHandle, false);
}
