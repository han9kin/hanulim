#include "Hanulim.h"
#include "HIMContext.h"
#include "HIMInput.h"
#include "HIMScript.h"


Boolean HIMInputDocumentHasProperty(OSType aPropertyTag)
{
    UInt32   sSize;
    UInt32   sBuffer;
    OSStatus sResult;

    sResult = TSMGetDocumentProperty(TSMGetActiveDocument(),
                                    aPropertyTag,
                                    sizeof(sBuffer),
                                    &sSize,
                                    &sBuffer);

    return (sResult == noErr) ? true : false;
}

OSErr HIMInput(HIMSessionHandle aSessionHandle, Boolean aFix)
{
    UInt32   sLength;
    UInt32   sFixLength;
    EventRef sEvent;
    OSErr    sErr = noErr;

    sLength    = (*aSessionHandle)->mCharBufferCount * sizeof(UniChar);
    sFixLength = aFix ? sLength : 0;

    /*
     * create a new text input event (carbon event)
     */
    sErr = CreateEvent(NULL,
                       kEventClassTextInput,
                       kEventTextInputUpdateActiveInputArea,
                       GetCurrentEventTime(),
                       kEventAttributeUserEvent,
                       &sEvent);

    /*
     * text service component instance
     */
    if (sErr == noErr)
    {
        ComponentInstance sComponentInstance = (*aSessionHandle)->mComponentInstance;

        sErr = SetEventParameter(sEvent,
                                 kEventParamTextInputSendComponentInstance,
                                 typeComponentInstance,
                                 sizeof(ComponentInstance),
                                 &sComponentInstance);
    }

    /*
     * script information record
     */
    if (sErr == noErr)
    {
        ScriptLanguageRecord sScriptLanguageRecord;

        sScriptLanguageRecord.fScript   = kHIMScript;
        sScriptLanguageRecord.fLanguage = kHIMLanguage;

        sErr = SetEventParameter(sEvent,
                                 kEventParamTextInputSendSLRec,
                                 typeIntlWritingCode,
                                 sizeof(ScriptLanguageRecord),
                                 &sScriptLanguageRecord);
    }

    /*
     * fix length
     */
    if (sErr == noErr)
    {
        sErr = SetEventParameter(sEvent,
                                 kEventParamTextInputSendFixLen,
                                 typeLongInteger,
                                 sizeof(long),
                                 &sFixLength);
    }

    /*
     * input text
     */
    if (sErr == noErr)
    {
        sErr = SetEventParameter(sEvent,
                                 kEventParamTextInputSendText,
                                 typeUnicodeText,
                                 sLength,
                                 (*aSessionHandle)->mCharBuffer);
    }

    /*
     * update region
     */
    if (sErr == noErr)
    {
        TextRangeArrayPtr sUpdateRangePtr;

        sUpdateRangePtr = (TextRangeArrayPtr)NewPtrClear(sizeof(short) + sizeof(TextRange) * 2);

        if (sUpdateRangePtr)
        {
            sUpdateRangePtr->fNumOfRanges           = 2;
            sUpdateRangePtr->fRange[0].fStart       = 0;
            sUpdateRangePtr->fRange[0].fEnd         = (*aSessionHandle)->mLastUpdateLength;
            sUpdateRangePtr->fRange[0].fHiliteStyle = 0;
            sUpdateRangePtr->fRange[1].fStart       = 0;
            sUpdateRangePtr->fRange[1].fEnd         = sLength;
            sUpdateRangePtr->fRange[1].fHiliteStyle = 0;

            (*aSessionHandle)->mLastUpdateLength    = sLength;

            sErr = SetEventParameter(sEvent,
                                     kEventParamTextInputSendUpdateRng,
                                     typeTextRangeArray,
                                     sizeof(short) + sizeof(TextRange) * 2,
                                     sUpdateRangePtr);

            DisposePtr((Ptr)sUpdateRangePtr);
        }
        else
        {
            sErr = memFullErr;
        }
    }

    if (sErr == noErr)
    {
        TextRangeArrayPtr sHiliteRangePtr;

        sHiliteRangePtr = (TextRangeArrayPtr)NewPtrClear(sizeof(short) + sizeof(TextRange) * 2);

        if (sHiliteRangePtr)
        {
            sHiliteRangePtr->fNumOfRanges           = 2;
            sHiliteRangePtr->fRange[0].fStart       = 0;
            sHiliteRangePtr->fRange[0].fEnd         = sLength;
            sHiliteRangePtr->fRange[0].fHiliteStyle = aFix ? kTSMHiliteConvertedText : kTSMHiliteRawText;
            sHiliteRangePtr->fRange[1].fStart       = sLength;
            sHiliteRangePtr->fRange[1].fEnd         = sLength;
            sHiliteRangePtr->fRange[1].fHiliteStyle = kTSMHiliteCaretPosition;

            sErr = SetEventParameter(sEvent,
                                     kEventParamTextInputSendHiliteRng,
                                     typeTextRangeArray,
                                     sizeof(short) + sizeof(TextRange) * 2,
                                     sHiliteRangePtr);

            DisposePtr((Ptr)sHiliteRangePtr);
        }
        else
        {
            sErr = memFullErr;
        }
    }

    if (sErr == noErr)
    {
        TextRange sPinRange;

        sPinRange.fStart = 0;
        sPinRange.fEnd   = sLength;

        sErr = SetEventParameter(sEvent,
                                 kEventParamTextInputSendPinRng,
                                 typeTextRange,
                                 sizeof(TextRange),
                                 &sPinRange);
    }

    if (aFix)
    {
        (*aSessionHandle)->mLastUpdateLength = 0;
        (*aSessionHandle)->mCharBufferCount  = 0;
    }

    if (sErr == noErr)
    {
        sErr = SendTextInputEvent(sEvent);
    }

    if ((sErr == noErr) && (aFix || (sLength == 0)) && (TSMGetActiveDocument() == NULL))
    {
        WindowRef sWindow;

        sWindow = GetFrontWindowOfClass(kUtilityWindowClass, true);

        if (sWindow)
        {
            HideWindow(sWindow);
        }
    }

    return sErr;
}
