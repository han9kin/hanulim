#include "Hanulim.h"
#include "HIMContext.h"
#include "HIMInput.h"
#include "HIMPreferences.h"
#include "HIMMethod.h"
#include "HIMMethodTables.h"
#include "HIMScript.h"


#define KIND(code)  (code >> 8)
#define VALUE(code) ((SInt8)code)


enum
{
    kKindSymbol  = 0,
    kKindInitial = 1,
    kKindMedial  = 2,
    kKindFinal   = 3
};


UInt16 HIMKeyCode(UInt32 aKeyCode, Boolean aShiftFlag)
{
    UInt16 sCode;
    UInt8  sKind;
    UInt8  sValue;

    if (aKeyCode <= gKeyMapMax)
    {
        sCode  = gKeyMap[gPreferences.mKeyboardLayout][aKeyCode] >> (aShiftFlag ? 16 : 0);
        sKind  = KIND(sCode);
        sValue = VALUE(sCode);

        if ((sKind == kKindSymbol) && ((sValue > gSymbolMax) || (gSymbol[sValue] == 0)))
        {
            return 0;
        }

        return sCode;
    }

    return 0;
}

Boolean HIMIsShift(UInt32 aModifiers)
{
    static UInt32 sShiftBits = shiftKey | rightShiftKey;

    if (gPreferences.mHandleCapsLockAsShift && (aModifiers & alphaLock))
    {
        return true;
    }
    else
    {
        return (aModifiers & sShiftBits) ? true : false;
    }
}

Boolean HIMCanHandle(UInt32 aModifiers)
{
    static UInt32 sOtherBits = ~(shiftKey | rightShiftKey | alphaLock);

    return (aModifiers & sOtherBits) ? false : true;
}

UniChar HIMQuotationMark(UniChar aChar)
{
    static UniChar sSingleQuots[] = { 0x2018, 0x2019 };
    static UniChar sDoubleQuots[] = { 0x201c, 0x201d };
    static Boolean sSingleQuot    = true;
    static Boolean sDoubleQuot    = true;

    /*
     * initialize
     */
    if (aChar == 0)
    {
        sSingleQuot = true;
        sDoubleQuot = true;
    }
    /*
     * single quotation mark
     */
    else if (aChar == 0x27)
    {
        sSingleQuot = !sSingleQuot;

        return sSingleQuots[sSingleQuot];
    }
    /*
     * double quotation mark
     */
    else if (aChar == 0x22)
    {
        sDoubleQuot = !sDoubleQuot;

        return sDoubleQuots[sDoubleQuot];
    }

    return aChar;
}

Boolean HIMHandleKey(HIMSessionHandle aSessionHandle,
                     UInt32           aKeyCode,
                     UInt32           aModifiers,
                     unsigned char    aCharCode)
{
    Boolean sCanHandle;
    UInt16  sCode;
    UniChar sChar;

    sCanHandle = HIMCanHandle(aModifiers);
    sCode      = sCanHandle ? HIMKeyCode(aKeyCode, HIMIsShift(aModifiers)) : 0;

    if (sCode)
    {
        if (KIND(sCode) == kKindSymbol)
        {
            sChar = gSymbol[VALUE(sCode)];

            if (gPreferences.mSmartQuotationMarks)
            {
                sChar = HIMQuotationMark(sChar);
            }

            (*aSessionHandle)->mCharBuffer[(*aSessionHandle)->mCharBufferCount] = sChar;
            ((*aSessionHandle)->mCharBufferCount)++;

            HIMSessionFix(aSessionHandle);
        }
        else if ((*aSessionHandle)->mKeyBufferCount < kBufferMax)
        {
            (*aSessionHandle)->mKeyBuffer[(*aSessionHandle)->mKeyBufferCount] = sCode;
            ((*aSessionHandle)->mKeyBufferCount)++;

            HIMComposite(aSessionHandle);
        }
        else
        {
            fprintf(stderr, "HANULIM ERROR: Buffer overflow. Key ignored.\n");
        }

        return true;
    }
    else if (sCanHandle && (*aSessionHandle)->mKeyBufferCount)
    {
        if (aCharCode == 0x08) /* delete */
        {
            ((*aSessionHandle)->mKeyBufferCount)--;

            HIMComposite(aSessionHandle);

            return true;
        }
        else if (TSMGetActiveDocument() == NULL)
        {
            (*aSessionHandle)->mCharBuffer[(*aSessionHandle)->mCharBufferCount] = aCharCode;
            ((*aSessionHandle)->mCharBufferCount)++;

            HIMSessionFix(aSessionHandle);

            return true;
        }
        else
        {
            HIMSessionFix(aSessionHandle);

            return false;
        }
    }
    else
    {
        HIMSessionFix(aSessionHandle);

        return false;
    }
}

SInt8 HIMCombine(UInt8 aKind, SInt8 aValue1, SInt8 aValue2)
{
    UInt16 sFactor;
    UInt32 sCount;
    UInt32 i;

    sCount  = gCompoundCount[aKind - 1][HIMArchaicKeyboard()];
    sFactor = (aValue1 << 8) | aValue2;

    for (i = 0; i < sCount; i++)
    {
        if (gCompoundFactor[aKind - 1][i] == sFactor)
        {
            return gCompoundResult[aKind - 1][i];
        }
    }

    return -1;
}

void HIMBufferClear(SInt8 *aBuffer)
{
    aBuffer[0] = 0;
    aBuffer[1] = -1;
    aBuffer[2] = -1;
    aBuffer[3] = -1;
}

void HIMBufferCopy(SInt8 *aSrcBuf, SInt8 *aDestBuf)
{
    aDestBuf[0] = aSrcBuf[0];
    aDestBuf[1] = aSrcBuf[1];
    aDestBuf[2] = aSrcBuf[2];
    aDestBuf[3] = aSrcBuf[3];
}

void HIMBufferSet(SInt8 *aBuffer, UInt8 aKind, SInt8 aValue)
{
    aBuffer[0]     = aKind;
    aBuffer[aKind] = aValue;
}

UInt32 HIMGenerateChar(SInt8 *aBuffer, UniChar *aChar)
{
    static const SInt8   sMin[4]    = { 0, 0, 0, 1 };
    static const SInt8   sCMax[4]   = { 0, 89, 65, 82 };
    static const SInt8   sSMax[4]   = { 0, 18, 20, 27 };
    static const UniChar sBase[4]   = { 0, 0x1100, 0x1161, 0x11a7 };
    static const UniChar sFiller[4] = { 0, 0x115f, 0x1160, 0 };
    UInt32 sLength                  = 0;
    UInt32 i;

    if (HIMInputConjoiningJamo())
    {
        for (i = kKindInitial; i <= kKindFinal; i++)
        {
            if ((aBuffer[i] >= sMin[i]) && (aBuffer[i] <= sCMax[i]))
            {
                aChar[i - 1] = sBase[i] + aBuffer[i];
                sLength = i;
            }
            else
            {
                aChar[i - 1] = sFiller[i];
            }
        }

        if (sLength == 1)
        {
            sLength = 2;
        }
    }
    else
    {
        SInt8 sBuffer[4];
        UInt8 sCount = 0;
        UInt8 sKind  = 0;

        HIMBufferCopy(aBuffer, sBuffer);

        if (sBuffer[3] < 0)
        {
            sBuffer[3] = 0;
        }

        sLength = 1;

        for (i = kKindInitial; i <= kKindFinal; i++)
        {
            if ((sBuffer[i] >= sMin[i]) && (sBuffer[i] <= sSMax[i]))
            {
                sCount++;
                sKind = i;
            }
        }

        if (sCount == ((sKind == kKindFinal) ? 3 : 2))
        {
            int sIndex = (sBuffer[kKindInitial] * 21 * 28) + (sBuffer[kKindMedial] * 28) + sBuffer[kKindFinal];
            if (HIMInputDocumentHasProperty(kTSMDocumentUnicodePropertyTag) ||
                CanBeConvertedToKSC(sIndex))
            {
                *aChar = 0xac00 + sIndex;
            }
            else
            {
                sLength = 0;
            }
        }
        else if (sCount == 1)
        {
            *aChar = gCompatibilityJamo[sKind - 1][sBuffer[sKind]];
        }
        else
        {
            sLength = 0;
        }
    }

    return sLength;
}

UInt32 HIMCompositeBuffer(SInt8 *aBuffer, UInt8 aKind, SInt8 aValue, UniChar *aChar)
{
    UInt32 sLength;

    if (aBuffer[0] <= aKind)
    {
        SInt8 sNewValue = (aBuffer[aKind] > -1) ? HIMCombine(aKind, aBuffer[aKind], aValue) : aValue;

        if (sNewValue > -1)
        {
            SInt8 sTestBuf[4];

            HIMBufferCopy(aBuffer, sTestBuf);
            HIMBufferSet(sTestBuf, aKind, sNewValue);

            if (HIMGenerateChar(sTestBuf, aChar))
            {
                HIMBufferCopy(sTestBuf, aBuffer);
                return 0;
            }
        }
    }

    sLength = HIMGenerateChar(aBuffer, aChar);

    HIMBufferClear(aBuffer);
    HIMBufferSet(aBuffer, aKind, aValue);

    return sLength;
}

void HIMDequeueKeyBuffer(HIMSessionHandle aSessionHandle, UInt32 aCount)
{
    UInt32 i;

    (*aSessionHandle)->mKeyBufferCount -= aCount;

    for (i = 0; i < (*aSessionHandle)->mKeyBufferCount; i++)
    {
        (*aSessionHandle)->mKeyBuffer[i] = (*aSessionHandle)->mKeyBuffer[i + aCount];
    }
}

void HIMComposite(HIMSessionHandle aSessionHandle)
{
    UniCharPtr sCharBuffer = (*aSessionHandle)->mCharBuffer;
    SInt8      sBuffer[4]  = {0, -1, -1, -1};
    UInt32     sLength;
    UInt32     i;

    (*aSessionHandle)->mCharBufferCount = 0;

    for (i = 0; i < (*aSessionHandle)->mKeyBufferCount; i++)
    {
        UInt16 sCode  = (*aSessionHandle)->mKeyBuffer[i];
        UInt8  sKind  = KIND(sCode);
        SInt8  sValue = VALUE(sCode);

        if (HIMOverloadConsonants())
        {
            if ((sKind == kKindInitial) && (sBuffer[0] > sKind))
            {
                SInt8 sFinal = gInitialToFinal[sValue];

                if (sFinal &&
                    ((sBuffer[kKindFinal] == -1) ||
                     ((sBuffer[kKindFinal] != sFinal) &&
                      ((sFinal = HIMCombine(kKindFinal, sBuffer[kKindFinal], sFinal)) > -1))))
                {
                    SInt8 sTestBuf[4];

                    HIMBufferCopy(sBuffer, sTestBuf);
                    HIMBufferSet(sTestBuf, kKindFinal, sFinal);

                    if (HIMGenerateChar(sTestBuf, sCharBuffer))
                    {
                        sKind = kKindFinal;
                        sValue = gInitialToFinal[sValue];
                    }
                }
            }
            else if ((sKind == kKindMedial) && (sBuffer[0] == kKindFinal))
            {
                SInt8 sInitial;
                SInt8 sFinal;

                sInitial = VALUE((*aSessionHandle)->mKeyBuffer[i - 1]);
                sFinal   = ((i > 1) && (KIND((*aSessionHandle)->mKeyBuffer[i - 2]) == kKindInitial)) ?
                    gInitialToFinal[VALUE((*aSessionHandle)->mKeyBuffer[i - 2])] :
                    -1;

                sBuffer[kKindFinal] = sFinal;
                sLength             = HIMGenerateChar(sBuffer, sCharBuffer);

                if (gPreferences.mFixImmediately)
                {
                    (*aSessionHandle)->mCharBufferCount = sLength;

                    HIMInput(aSessionHandle, true);
                    HIMDequeueKeyBuffer(aSessionHandle, i - 1);

                    i = 1;
                }
                else
                {
                    (*aSessionHandle)->mCharBufferCount += sLength;
                    sCharBuffer += sLength;
                }

                HIMBufferClear(sBuffer);
                HIMBufferSet(sBuffer, kKindInitial, sInitial);
            }
        }

        sLength = HIMCompositeBuffer(sBuffer, sKind, sValue, sCharBuffer);

        if (sLength)
        {
            if (gPreferences.mFixImmediately)
            {
                (*aSessionHandle)->mCharBufferCount = sLength;

                HIMInput(aSessionHandle, true);
                HIMDequeueKeyBuffer(aSessionHandle, i);

                i = 0;
            }
            else
            {
                (*aSessionHandle)->mCharBufferCount += sLength;
                sCharBuffer += sLength;
            }
        }
    }

    sLength = HIMGenerateChar(sBuffer, sCharBuffer);

    if (sLength)
    {
        if (gPreferences.mFixImmediately)
        {
            (*aSessionHandle)->mCharBufferCount = sLength;
        }
        else
        {
            (*aSessionHandle)->mCharBufferCount += sLength;
        }
    }

    HIMInput(aSessionHandle, false);
}
