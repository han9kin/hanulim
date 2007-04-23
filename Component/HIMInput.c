#include "Hanulim.h"
#include "HIMContext.h"
#include "HIMInput.h"
#include "HIMScript.h"

Boolean HIMInputDocumentHasProperty(OSType propertyTag) {
    UInt32 size, buffer;
    OSStatus result = TSMGetDocumentProperty(TSMGetActiveDocument(), propertyTag, sizeof(buffer), &size, &buffer);
    return (result == noErr) ? true : false;
}

OSErr HIMInput(HIMSessionHandle inSessionHandle, Boolean inFix) {
    UInt32 length = (*inSessionHandle)->fCharBufferCount * sizeof(UniChar);
    UInt32 fixLength = inFix ? length : 0;
    EventRef event;
    OSErr error = noErr;

    // create a new text input event (carbon event)
    error = CreateEvent(NULL, kEventClassTextInput, kEventTextInputUpdateActiveInputArea, GetCurrentEventTime(), kEventAttributeUserEvent, &event);
    
    // text service component instance 
    if (error == noErr) {
        ComponentInstance componentInstance = (*inSessionHandle)->fComponentInstance;
        error = SetEventParameter(event, kEventParamTextInputSendComponentInstance, typeComponentInstance, sizeof(ComponentInstance), &componentInstance);
    }
    
    // script information record
    if (error == noErr) {
        ScriptLanguageRecord scriptLanguageRecord;
        scriptLanguageRecord.fScript = kHIMScript;
        scriptLanguageRecord.fLanguage = kHIMLanguage;
        error = SetEventParameter(event, kEventParamTextInputSendSLRec, typeIntlWritingCode, sizeof(ScriptLanguageRecord), &scriptLanguageRecord);
    }
    
    // fix length
    if (error == noErr) {
        error = SetEventParameter(event, kEventParamTextInputSendFixLen, typeLongInteger, sizeof(long), &fixLength);
    }
    
    // input text
    if (error == noErr) {
        error = SetEventParameter(event, kEventParamTextInputSendText, typeUnicodeText, length, (*inSessionHandle)->fCharBuffer);
    }
    
    // update region
    if (error == noErr) {
        TextRangeArrayPtr updateRangePtr = (TextRangeArrayPtr)NewPtrClear(sizeof(short) + sizeof(TextRange) * 2);
        
        if (updateRangePtr) {
            updateRangePtr->fNumOfRanges = 2;
            updateRangePtr->fRange[0].fStart = 0;
            updateRangePtr->fRange[0].fEnd = (*inSessionHandle)->fLastUpdateLength;
            updateRangePtr->fRange[0].fHiliteStyle = 0;
            updateRangePtr->fRange[1].fStart = 0;
            updateRangePtr->fRange[1].fEnd = length;
            updateRangePtr->fRange[1].fHiliteStyle = 0;
            
            (*inSessionHandle)->fLastUpdateLength = length;
            
            error = SetEventParameter(event, kEventParamTextInputSendUpdateRng, typeTextRangeArray, sizeof(short) + sizeof(TextRange) * 2, updateRangePtr);
            
            DisposePtr((Ptr)updateRangePtr);
        } else {
            error = memFullErr;
        }
    }
    
    if (error == noErr) {
        TextRangeArrayPtr hiliteRangePtr = (TextRangeArrayPtr)NewPtrClear(sizeof(short) + sizeof(TextRange) * 2);
        
        if (hiliteRangePtr) {
            hiliteRangePtr->fNumOfRanges = 2;
            hiliteRangePtr->fRange[0].fStart = 0;
            hiliteRangePtr->fRange[0].fEnd = length;
            hiliteRangePtr->fRange[0].fHiliteStyle = inFix ? kTSMHiliteConvertedText : kTSMHiliteRawText;
            
            hiliteRangePtr->fRange[1].fStart = length;
            hiliteRangePtr->fRange[1].fEnd = length;
            hiliteRangePtr->fRange[1].fHiliteStyle = kTSMHiliteCaretPosition;
            
            error = SetEventParameter(event, kEventParamTextInputSendHiliteRng, typeTextRangeArray, sizeof(short) + sizeof(TextRange) * 2, hiliteRangePtr);
            
            DisposePtr((Ptr)hiliteRangePtr);
        } else {
            error = memFullErr;
        }
    }
    
    if (error == noErr) {
        TextRange pinRange;
        pinRange.fStart = 0;
        pinRange.fEnd = length;
        error = SetEventParameter(event, kEventParamTextInputSendPinRng, typeTextRange, sizeof(TextRange), &pinRange);
    }
    
    if (inFix) {
        (*inSessionHandle)->fLastUpdateLength = 0;
        (*inSessionHandle)->fCharBufferCount = 0;
    }

    if (error == noErr)
        error = SendTextInputEvent(event);
    
    if ((error == noErr) && (inFix || (length == 0)) && (TSMGetActiveDocument() == NULL)) {
        WindowRef window = GetFrontWindowOfClass(kUtilityWindowClass, true);
        if (window)
            HideWindow(window);
    }

    return error;
}
