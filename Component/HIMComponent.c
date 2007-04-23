#include "Hanulim.h"
#include "HIMComponent.h"
#include "HIMContext.h"
#include "HIMScript.h"

// Main entry point

pascal ComponentResult HIMComponentDispatch(ComponentParameters *inParams, Handle inSessionHandle);

// Global variables

long gInstanceRefCount = 0;
MenuRef gTextServiceMenu = nil;

// Local function declarations

static ComponentResult CallHIMFunction(ComponentParameters *inParams, ProcPtr inProcPtr, SInt32 inProcInfo);
static ComponentResult CallHIMFunctionWithStorage(Handle inStorage, ComponentParameters *inParams, ProcPtr inProcPtr, SInt32 inProcInfo);


pascal ComponentResult HIMComponentDispatch(ComponentParameters *inParams, Handle inSessionHandle) {
    switch (inParams->what) {
        case kComponentOpenSelect:
            HIMLog("HIMComponentDispatch::kComponentOpenSelect");
            return CallHIMFunction(inParams, (ProcPtr)HIMOpenComponent, uppOpenComponentProcInfo);
        case kComponentCloseSelect:
            HIMLog("HIMComponentDispatch::kComponentCloseSelect");
            return CallHIMFunctionWithStorage(inSessionHandle, inParams, (ProcPtr)HIMCloseComponent, uppCloseComponentProcInfo);
        case kComponentCanDoSelect:
            HIMLog("HIMComponentDispatch::kComponentCanDoSelect");
            return CallHIMFunction(inParams, (ProcPtr)HIMCanDo, uppCanDoProcInfo);
        case kComponentVersionSelect:
            HIMLog("HIMComponentDispatch::kComponentVersionSelect");
            return CallHIMFunction(inParams, (ProcPtr)HIMGetVersion, uppGetVersionProcInfo);
        case kCMGetScriptLangSupport:
            HIMLog("HIMComponentDispatch::kCMGetScriptLangSupport");
            return CallHIMFunctionWithStorage(inSessionHandle, inParams, (ProcPtr)HIMGetScriptLangSupport, uppGetScriptLangSupportProcInfo);
        case kCMInitiateTextService:
            HIMLog("HIMComponentDispatch::kCMInitiateTextService");
            return CallHIMFunctionWithStorage(inSessionHandle, inParams, (ProcPtr)HIMInitiateTextService, uppInitiateTextServiceProcInfo);
        case kCMTerminateTextService:
            HIMLog("HIMComponentDispatch::kCMTerminateTextService");
            return CallHIMFunctionWithStorage(inSessionHandle, inParams, (ProcPtr)HIMTerminateTextService, uppTerminateTextServiceProcInfo);
        case kCMActivateTextService:
            HIMLog("HIMComponentDispatch::kCMActivateTextService");
            return CallHIMFunctionWithStorage(inSessionHandle, inParams, (ProcPtr)HIMActivateTextService, uppActivateTextServiceProcInfo);
        case kCMDeactivateTextService:
            HIMLog("HIMComponentDispatch::kCMDeactivateTextService");
            return CallHIMFunctionWithStorage(inSessionHandle, inParams, (ProcPtr)HIMDeactivateTextService, uppDeactivateTextServiceProcInfo);
        case kCMTextServiceEvent:
            HIMLog("HIMComponentDispatch::kCMTextServiceEvent");
            return CallHIMFunctionWithStorage(inSessionHandle, inParams, (ProcPtr)HIMTextServiceEventRef, uppTextServiceEventRefProcInfo);
        case kCMGetTextServiceMenu:
            HIMLog("HIMComponentDispatch::kCMGetTextServiceMenu");
            return CallHIMFunctionWithStorage(inSessionHandle, inParams, (ProcPtr)HIMGetTextServiceMenu, uppGetTextServiceMenuProcInfo);
        case kCMFixTextService:
            HIMLog("HIMComponentDispatch::kCMFixTextService");
            return CallHIMFunctionWithStorage(inSessionHandle, inParams, (ProcPtr)HIMFixTextService, uppFixTextServiceProcInfo);
        case kCMHidePaletteWindows:
            HIMLog("HIMComponentDispatch::kCMHidePaletteWindows");
            return CallHIMFunctionWithStorage(inSessionHandle, inParams, (ProcPtr)HIMHidePaletteWindows, uppHidePaletteWindowsProcInfo);
        case kCMCopyTextServiceInputModeList:
            HIMLog("HIMComponentDispatch::kCMCopyTextServiceInputModeList");
            return CallHIMFunctionWithStorage(inSessionHandle, inParams, (ProcPtr)HIMCopyTextServiceInputModeList, uppCopyTextServiceInputModeListInfo);
        case kCMSetTextServiceProperty:
            HIMLog("HIMComponentDispatch::kCMSetTextServiceProperty");
            return CallHIMFunctionWithStorage(inSessionHandle, inParams, (ProcPtr)HIMSetTextServiceProperty,
                                              uppSetTextServicePropertyInfo);
        default:
            return badComponentSelector;
    }
}


pascal ComponentResult HIMOpenComponent(ComponentInstance inComponentInstance) {
    ComponentResult result = noErr;
    Handle sessionHandle = nil;

    if (gInstanceRefCount == 0)
        result = HIMInitialize(inComponentInstance, &gTextServiceMenu);
    gInstanceRefCount++;

    if (result == noErr) {
        sessionHandle = GetComponentInstanceStorage(inComponentInstance);
        result = HIMSessionOpen(inComponentInstance, (HIMSessionHandle *)&sessionHandle);

        if (result == noErr)
            SetComponentInstanceStorage(inComponentInstance, sessionHandle);
    }

    return result;
}

pascal ComponentResult HIMCloseComponent(Handle inSessionHandle, ComponentInstance inComponentInstance) {
    ComponentResult result = noErr;

    if (inComponentInstance == nil)
        return paramErr;

    HIMSessionClose((HIMSessionHandle)inSessionHandle);
    SetComponentInstanceStorage(inComponentInstance, nil);

    gInstanceRefCount--;
    if (gInstanceRefCount == 0)
        HIMTerminate(inComponentInstance);

    return result;
}

pascal ComponentResult HIMCanDo(SInt16 inSelector) {
    switch (inSelector) {
        // These first four calls are made by the Component Manager to every component.
        case kComponentOpenSelect:
        case kComponentCloseSelect:
        case kComponentCanDoSelect:
        case kComponentVersionSelect:
            return true;

        // These calls are made by the Text Services Manager to text service componets.
        case kCMGetScriptLangSupport:
        case kCMInitiateTextService:
        case kCMTerminateTextService:
        case kCMActivateTextService:
        case kCMDeactivateTextService:
        case kCMTextServiceEvent:
        case kCMGetTextServiceMenu:
        case kCMFixTextService:
        case kCMHidePaletteWindows:
        case kCMCopyTextServiceInputModeList:
        case kCMSetTextServiceProperty:
            return true;

        default:
            HIMLog("HIMCanDo: %d", inSelector);
            return false;
    }
}

pascal ComponentResult HIMGetVersion() {
    return 0x00010000;
}

pascal ComponentResult HIMGetScriptLangSupport(Handle inSessionHandle, ScriptLanguageSupportHandle *outScriptHandle) {
    OSStatus result = noErr;
    ScriptLanguageRecord scriptLanguageRecord;

    if (*outScriptHandle == NULL) {
        *outScriptHandle = (ScriptLanguageSupportHandle)NewHandle(sizeof(SInt16));
        if (*outScriptHandle == NULL)
            result = memFullErr;
    }

    if (result == noErr) {
        SetHandleSize((Handle)*outScriptHandle, sizeof(SInt16));
        result = MemError();
        if (result == noErr)
            (**outScriptHandle)->fScriptLanguageCount = 0;
    }

    if (result == noErr) {
        scriptLanguageRecord.fScript = kTextEncodingUnicodeDefault;
        scriptLanguageRecord.fLanguage = kHIMLanguage;
        result = PtrAndHand(&scriptLanguageRecord, (Handle)*outScriptHandle, sizeof(ScriptLanguageRecord));
        if (result == noErr)
            (**outScriptHandle)->fScriptLanguageCount++;
    }

    if (result && *outScriptHandle) {
        DisposeHandle((Handle)*outScriptHandle);
        *outScriptHandle = NULL;
    }

    return result;
}

pascal ComponentResult HIMInitiateTextService(Handle inSessionHandle) {
    return noErr;
}

pascal ComponentResult HIMTerminateTextService(Handle inSessionHandle) {
    return noErr;
}

pascal ComponentResult HIMActivateTextService(Handle inSessionHandle) {
    return HIMSessionActivate((HIMSessionHandle)inSessionHandle);
}

pascal ComponentResult HIMDeactivateTextService(Handle inSessionHandle) {
    return HIMSessionDeactivate((HIMSessionHandle)inSessionHandle);
}

pascal ComponentResult HIMTextServiceEventRef(Handle inSessionHandle, EventRef inEventRef) {
    return HIMSessionEvent((HIMSessionHandle)inSessionHandle, inEventRef);
}

pascal ComponentResult HIMGetTextServiceMenu(Handle inSessionHandle, MenuHandle *outMenuHandle) {
    *outMenuHandle = gTextServiceMenu;
    return noErr;
}

pascal ComponentResult HIMFixTextService(Handle inSessionHandle) {
    return HIMSessionFix((HIMSessionHandle)inSessionHandle);
}

pascal ComponentResult HIMHidePaletteWindows(Handle inSessionHandle) {
    return HIMSessionHidePalettes((HIMSessionHandle)inSessionHandle);
}

pascal ComponentResult HIMCopyTextServiceInputModeList(Handle inSessionHandle, CFDictionaryRef* outInputModes) {
    CFBundleRef bundleRef = CFBundleGetBundleWithIdentifier(CFSTR("org.osxdev.Hanulim"));
    if(bundleRef) {
	CFDictionaryRef bundleDict = CFBundleGetInfoDictionary(bundleRef);
	if(bundleDict) {
	    CFRetain(bundleDict);
	    CFDictionaryRef tmpModes
		= (CFDictionaryRef)CFDictionaryGetValue(bundleDict, kComponentBundleInputModeDictKey);
	    if(tmpModes) {
		*outInputModes = CFDictionaryCreateCopy(kCFAllocatorDefault, tmpModes);
	    } else {
		HIMLog("CFDictionaryCreateCopy() failed\n");
	    }
	    CFRelease(bundleDict);
	} else {
	    HIMLog("CFBundleGetInfoDictionary() failed\n");
	}
    } else {
	HIMLog("CFBundleGetBundleWithIdentifier() failed\n");
    }

    return noErr;
}

pascal ComponentResult HIMSetTextServiceProperty(Handle inSessionHandle, TextServicePropertyTag tag,
						 TextServicePropertyValue value) {
    if(tag != kTextServiceInputModePropertyTag) {
	HIMLog("Can't SetTextServiceProperty[%d]\n", tag);
	return tsmComponentPropertyUnsupportedErr;
    }

    CFStringRef newMode = (CFStringRef)value;

    HIMLog("New Mode: %s", CFStringGetCStringPtr(newMode, kCFStringEncodingUTF8));

/*     if(CFStringCompare(newMode, kTextServiceInputModeJapanese, 0) == 0) { */
/* 	if(!inputMode->isHiraganaInputMode()) { */
/* 	    inputMode->goHiraganaInputMode(); */
/* 	    return noErr; */
/* 	} */
/*     } */

    return noErr;
}

static ComponentResult CallHIMFunction(ComponentParameters *inParams, ProcPtr inProcPtr, SInt32 inProcInfo) {
    ComponentFunctionUPP componentFunctionUPP = NewComponentFunctionUPP(inProcPtr, inProcInfo);
    ComponentResult result = CallComponentFunction(inParams, componentFunctionUPP);

    DisposeComponentFunctionUPP(componentFunctionUPP);
    return result;
}

static ComponentResult CallHIMFunctionWithStorage(Handle inStorage, ComponentParameters *inParams, ProcPtr inProcPtr, SInt32 inProcInfo) {
    ComponentFunctionUPP componentFunctionUPP = NewComponentFunctionUPP(inProcPtr, inProcInfo);
    ComponentResult result = CallComponentFunctionWithStorage(inStorage, inParams, componentFunctionUPP);

    DisposeComponentFunctionUPP(componentFunctionUPP);
    return result;
}
