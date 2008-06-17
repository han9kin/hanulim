#include "Hanulim.h"
#include "HIMContext.h"
#include "HIMInput.h"
#include "HIMPreferences.h"
#include "HIMMethod.h"
#include "HIMMethodTables.h"
#include "HIMScript.h"


#define KIND(code)  (code >> 8)
#define VALUE(code) ((UInt8)code)


enum
{
    kKindSymbol    = 0,
    kKindInitial   = 1,
    kKindMedial    = 2,
    kKindFinal     = 3,
    kKindDiacritic = 4
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

        if ((sKind == kKindSymbol) && ((sValue > HNUnicodeSymbolMax) || (HNUnicodeSymbol[sValue] == 0)))
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
            sChar = HNUnicodeSymbol[VALUE(sCode)];

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

UInt8 HIMCombine(UInt8 aKind, UInt8 aValue1, UInt8 aValue2)
{
    if ((aKind >= kKindInitial) && (aKind <= kKindFinal))
    {
        HNJasoComposition *sTable = &HNJasoCompositionTable[aKind];
        UInt16             sFactor;
        UInt32             sCount;
        UInt32             i;

        sCount  = sTable->mCount[HIMArchaicKeyboard() ? 1 : 0];
        sFactor = (aValue1 << 8) | aValue2;

        for (i = 0; i < sCount; i++)
        {
            if (sTable->mIn[i] == sFactor)
            {
                return sTable->mOut[i];
            }
        }
    }

    return (UInt8)-1;
}

void HIMBufferClear(UInt8 *aBuffer)
{
    aBuffer[0] = 0;
    aBuffer[1] = (UInt8)-1;
    aBuffer[2] = (UInt8)-1;
    aBuffer[3] = (UInt8)-1;
    aBuffer[4] = (UInt8)-1;
}

void HIMBufferCopy(UInt8 *aSrcBuf, UInt8 *aDestBuf)
{
    aDestBuf[0] = aSrcBuf[0];
    aDestBuf[1] = aSrcBuf[1];
    aDestBuf[2] = aSrcBuf[2];
    aDestBuf[3] = aSrcBuf[3];
    aDestBuf[4] = aSrcBuf[4];
}

void HIMBufferSet(UInt8 *aBuffer, UInt8 aKind, UInt8 aValue)
{
    aBuffer[0]     = aKind;
    aBuffer[aKind] = aValue;
}

UInt32 HIMGenerateChar(UInt8 *aBuffer, UniChar *aChar)
{
    static const UInt8   sMaxNFC[]    = { 0x00, 0x13, 0x15, 0x1b };
    static const UInt8   sMaxNFD[]    = { 0x00, 0x7c, 0x5e, 0x89 };
    static const UniChar sDiacritic[] = { 0x0000, 0x302e, 0x302f };
    UInt32               sLength      = 0;
    UInt32               i;

    if (HIMInputConjoiningJamo())
    {
        for (i = kKindInitial; i <= kKindFinal; i++)
        {
            if (aBuffer[i] <= sMaxNFD[i])
            {
                aChar[i - 1] = HNUnicodeJaso[i][aBuffer[i]];
                sLength = i;
            }
            else
            {
                aChar[i - 1] = HNUnicodeJaso[i][0];
            }
        }

        if (sLength == 1)
        {
            sLength = 2;
        }

        if ((aBuffer[kKindDiacritic] > 0) && (aBuffer[kKindDiacritic] <= 2))
        {
            if (sLength < 2)
            {
                sLength = 2;
            }

            aChar[sLength] = sDiacritic[aBuffer[kKindDiacritic]];
            sLength++;
        }
    }
    else
    {
        UInt8 sBuffer[5];
        UInt8 sCount = 0;
        UInt8 sKind  = 0;

        HIMBufferCopy(aBuffer, sBuffer);

        for (i = kKindInitial; i <= kKindFinal; i++)
        {
            if (sBuffer[i] <= sMaxNFC[i])
            {
                sCount++;
                sKind = i;
            }
        }

        if (sCount == 1)
        {
            *aChar  = HNUnicodeJamo[sKind][sBuffer[sKind]];
            sLength = 1;
        }
        else
        {
            int sIndex = -1;

            if (sCount == 3)
            {
                sIndex = ((sBuffer[kKindInitial] - 1) * 21 * 28) + ((sBuffer[kKindMedial] - 1) * 28) + sBuffer[kKindFinal];
            }
            else if ((sCount == 2) && (sKind < kKindFinal))
            {
                sIndex = ((sBuffer[kKindInitial] - 1) * 21 * 28) + ((sBuffer[kKindMedial] - 1) * 28);
            }

            if ((sIndex > -1) && (HIMInputDocumentHasProperty(kTSMDocumentUnicodePropertyTag) || CanBeConvertedToKSC(sIndex)))
            {
                *aChar  = 0xac00 + sIndex;
                sLength = 1;
            }
            else
            {
                sLength = 0;
            }
        }
    }

    return sLength;
}

UInt32 HIMCompositeBuffer(UInt8 *aBuffer, UInt8 aKind, UInt8 aValue, UniChar *aChar)
{
    UInt32 sLength;

    if (aBuffer[0] <= aKind)
    {
        UInt8 sNewValue = (aBuffer[aKind] != (UInt8)-1) ? HIMCombine(aKind, aBuffer[aKind], aValue) : aValue;

        if (sNewValue != (UInt8)-1)
        {
            UInt8 sTestBuf[5];

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
    UniCharPtr sCharLimit  = sCharBuffer + (kBufferMax - 5);
    UInt8      sBuffer[5]  = {0, (UInt8)-1, (UInt8)-1, (UInt8)-1, (UInt8)-1};
    UInt32     sLength;
    UInt32     i;

    (*aSessionHandle)->mCharBufferCount = 0;

    for (i = 0; i < (*aSessionHandle)->mKeyBufferCount; i++)
    {
        UInt16 sCode  = (*aSessionHandle)->mKeyBuffer[i];
        UInt8  sKind  = KIND(sCode);
        UInt8  sValue = VALUE(sCode);

        if (HIMOverloadConsonants())
        {
            if ((sKind == kKindInitial) && (sBuffer[0] > sKind))
            {
                UInt8 sFinal = HNJasoInitialToFinal[sValue];

                if (sFinal &&
                    ((sBuffer[kKindFinal] == (UInt8)-1) ||
                     ((sBuffer[kKindFinal] != sFinal) &&
                      ((sFinal = HIMCombine(kKindFinal, sBuffer[kKindFinal], sFinal)) != (UInt8)-1))))
                {
                    UInt8 sTestBuf[5];

                    HIMBufferCopy(sBuffer, sTestBuf);
                    HIMBufferSet(sTestBuf, kKindFinal, sFinal);

                    if (HIMGenerateChar(sTestBuf, sCharBuffer))
                    {
                        sKind  = kKindFinal;
                        sValue = HNJasoInitialToFinal[sValue];
                    }
                }
            }
            else if ((sKind == kKindMedial) && (sBuffer[0] == kKindFinal))
            {
                UInt8 sInitial;
                UInt8 sFinal;

                sInitial = VALUE((*aSessionHandle)->mKeyBuffer[i - 1]);
                sFinal   = ((i > 1) && (KIND((*aSessionHandle)->mKeyBuffer[i - 2]) == kKindInitial)) ?
                    HNJasoInitialToFinal[VALUE((*aSessionHandle)->mKeyBuffer[i - 2])] :
                    (UInt8)-1;

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

                    if (sCharBuffer > sCharLimit)
                    {
                        fprintf(stderr, "HANULIM ERROR: Buffer overflow. composition stopped.\n");
                        break;
                    }
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

                if (sCharBuffer > sCharLimit)
                {
                    fprintf(stderr, "HANULIM ERROR: Buffer overflow. composition stopped.\n");
                    break;
                }
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
