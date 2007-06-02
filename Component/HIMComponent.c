#include "Hanulim.h"
#include "HIMComponent.h"
#include "HIMContext.h"
#include "HIMPreferences.h"
#include "HIMScript.h"


/*
 * Global variables
 */

long    gInstanceRefCount = 0;
MenuRef gTextServiceMenu  = nil;

/*
 * Local functions
 */

static ComponentResult HIMComponentFunctionCall(ComponentParameters *aParams,
                                                ProcPtr              aProcPtr,
                                                SInt32               aProcInfo)
{
    ComponentFunctionUPP sComponentFunctionUPP;
    ComponentResult      sResult;

    sComponentFunctionUPP = NewComponentFunctionUPP(aProcPtr, aProcInfo);
    sResult               = CallComponentFunction(aParams, sComponentFunctionUPP);

    DisposeComponentFunctionUPP(sComponentFunctionUPP);

    return sResult;
}

static ComponentResult HIMComponentFunctionCallWithStorage(Handle               aStorage,
                                                           ComponentParameters *aParams,
                                                           ProcPtr              aProcPtr,
                                                           SInt32               aProcInfo)
{
    ComponentFunctionUPP sComponentFunctionUPP;
    ComponentResult      sResult;

    sComponentFunctionUPP = NewComponentFunctionUPP(aProcPtr, aProcInfo);
    sResult               = CallComponentFunctionWithStorage(aStorage, aParams, sComponentFunctionUPP);

    DisposeComponentFunctionUPP(sComponentFunctionUPP);

    return sResult;
}

/*
 * Component main entry point
 */

pascal ComponentResult HIMComponentDispatch(ComponentParameters *aParams, Handle aSessionHandle)
{
    switch (aParams->what) {
        case kComponentOpenSelect:
            HIMLog("HIMComponentDispatch::kComponentOpenSelect");
            return HIMComponentFunctionCall(aParams,
                                            (ProcPtr)HIMOpenComponent,
                                            gUppOpenComponentProcInfo);
        case kComponentCloseSelect:
            HIMLog("HIMComponentDispatch::kComponentCloseSelect");
            return HIMComponentFunctionCallWithStorage(aSessionHandle,
                                                       aParams,
                                                       (ProcPtr)HIMCloseComponent,
                                                       gUppCloseComponentProcInfo);
        case kComponentCanDoSelect:
            HIMLog("HIMComponentDispatch::kComponentCanDoSelect");
            return HIMComponentFunctionCall(aParams,
                                            (ProcPtr)HIMCanDo,
                                            gUppCanDoProcInfo);
        case kComponentVersionSelect:
            HIMLog("HIMComponentDispatch::kComponentVersionSelect");
            return HIMComponentFunctionCall(aParams,
                                            (ProcPtr)HIMGetVersion,
                                            gUppGetVersionProcInfo);
        case kCMGetScriptLangSupport:
            HIMLog("HIMComponentDispatch::kCMGetScriptLangSupport");
            return HIMComponentFunctionCallWithStorage(aSessionHandle,
                                                       aParams,
                                                       (ProcPtr)HIMGetScriptLangSupport,
                                                       gUppGetScriptLangSupportProcInfo);
        case kCMInitiateTextService:
            HIMLog("HIMComponentDispatch::kCMInitiateTextService");
            return HIMComponentFunctionCallWithStorage(aSessionHandle,
                                                       aParams,
                                                       (ProcPtr)HIMInitiateTextService,
                                                       gUppInitiateTextServiceProcInfo);
        case kCMTerminateTextService:
            HIMLog("HIMComponentDispatch::kCMTerminateTextService");
            return HIMComponentFunctionCallWithStorage(aSessionHandle,
                                                       aParams,
                                                       (ProcPtr)HIMTerminateTextService,
                                                       gUppTerminateTextServiceProcInfo);
        case kCMActivateTextService:
            HIMLog("HIMComponentDispatch::kCMActivateTextService");
            return HIMComponentFunctionCallWithStorage(aSessionHandle,
                                                       aParams,
                                                       (ProcPtr)HIMActivateTextService,
                                                       gUppActivateTextServiceProcInfo);
        case kCMDeactivateTextService:
            HIMLog("HIMComponentDispatch::kCMDeactivateTextService");
            return HIMComponentFunctionCallWithStorage(aSessionHandle,
                                                       aParams,
                                                       (ProcPtr)HIMDeactivateTextService,
                                                       gUppDeactivateTextServiceProcInfo);
        case kCMTextServiceEvent:
            HIMLog("HIMComponentDispatch::kCMTextServiceEvent");
            return HIMComponentFunctionCallWithStorage(aSessionHandle,
                                                       aParams,
                                                       (ProcPtr)HIMTextServiceEventRef,
                                                       gUppTextServiceEventRefProcInfo);
        case kCMGetTextServiceMenu:
            HIMLog("HIMComponentDispatch::kCMGetTextServiceMenu");
            return HIMComponentFunctionCallWithStorage(aSessionHandle,
                                                       aParams,
                                                       (ProcPtr)HIMGetTextServiceMenu,
                                                       gUppGetTextServiceMenuProcInfo);
        case kCMFixTextService:
            HIMLog("HIMComponentDispatch::kCMFixTextService");
            return HIMComponentFunctionCallWithStorage(aSessionHandle,
                                                       aParams,
                                                       (ProcPtr)HIMFixTextService,
                                                       gUppFixTextServiceProcInfo);
        case kCMHidePaletteWindows:
            HIMLog("HIMComponentDispatch::kCMHidePaletteWindows");
            return HIMComponentFunctionCallWithStorage(aSessionHandle,
                                                       aParams,
                                                       (ProcPtr)HIMHidePaletteWindows,
                                                       gUppHidePaletteWindowsProcInfo);
        case kCMCopyTextServiceInputModeList:
            HIMLog("HIMComponentDispatch::kCMCopyTextServiceInputModeList");
            return HIMComponentFunctionCallWithStorage(aSessionHandle,
                                                       aParams,
                                                       (ProcPtr)HIMCopyTextServiceInputModeList,
                                                       gUppCopyTextServiceInputModeListInfo);
        case kCMSetTextServiceProperty:
            HIMLog("HIMComponentDispatch::kCMSetTextServiceProperty");
            return HIMComponentFunctionCallWithStorage(aSessionHandle,
                                                       aParams,
                                                       (ProcPtr)HIMSetTextServiceProperty,
                                                       gUppSetTextServicePropertyInfo);
        default:
            return badComponentSelector;
    }
}

/*
 * Component functions
 */

pascal ComponentResult HIMOpenComponent(ComponentInstance aComponentInstance)
{
    ComponentResult sResult        = noErr;
    Handle          sSessionHandle = nil;

    if (gInstanceRefCount == 0)
    {
        sResult = HIMInitialize(aComponentInstance, &gTextServiceMenu);
    }

    gInstanceRefCount++;

    if (sResult == noErr)
    {
        sSessionHandle = GetComponentInstanceStorage(aComponentInstance);
        sResult        = HIMSessionOpen(aComponentInstance, (HIMSessionHandle *)&sSessionHandle);

        if (sResult == noErr)
        {
            SetComponentInstanceStorage(aComponentInstance, sSessionHandle);
        }
    }

    return sResult;
}

pascal ComponentResult HIMCloseComponent(Handle aSessionHandle, ComponentInstance aComponentInstance)
{
    ComponentResult sResult = noErr;

    if (aComponentInstance == nil)
    {
        return paramErr;
    }

    HIMSessionClose((HIMSessionHandle)aSessionHandle);
    SetComponentInstanceStorage(aComponentInstance, nil);

    gInstanceRefCount--;

    if (gInstanceRefCount == 0)
    {
        HIMTerminate(aComponentInstance);
    }

    return sResult;
}

pascal ComponentResult HIMCanDo(SInt16 aSelector)
{
    switch (aSelector)
    {
        /*
         * These first four calls are made by the Component Manager to every component.
         */
        case kComponentOpenSelect:
        case kComponentCloseSelect:
        case kComponentCanDoSelect:
        case kComponentVersionSelect:
            return true;

        /*
         * These calls are made by the Text Services Manager to text service componets.
         */
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
            HIMLog("HIMCanDo: %d", aSelector);
            return false;
    }
}

pascal ComponentResult HIMGetVersion()
{
    return 0x00010000;
}

pascal ComponentResult HIMGetScriptLangSupport(Handle                       aSessionHandle,
                                               ScriptLanguageSupportHandle *aScriptHandle)
{
    OSStatus             sResult = noErr;
    ScriptLanguageRecord sScriptLanguageRecord;

    if (*aScriptHandle == NULL)
    {
        *aScriptHandle = (ScriptLanguageSupportHandle)NewHandle(sizeof(SInt16));

        if (*aScriptHandle == NULL)
        {
            sResult = memFullErr;
        }
    }

    if (sResult == noErr)
    {
        SetHandleSize((Handle)*aScriptHandle, sizeof(SInt16));

        sResult = MemError();

        if (sResult == noErr)
        {
            (**aScriptHandle)->fScriptLanguageCount = 0;
        }
    }

    if (sResult == noErr)
    {
        sScriptLanguageRecord.fScript   = kTextEncodingUnicodeDefault;
        sScriptLanguageRecord.fLanguage = kHIMLanguage;

        sResult = PtrAndHand(&sScriptLanguageRecord,
                             (Handle)*aScriptHandle,
                             sizeof(ScriptLanguageRecord));

        if (sResult == noErr)
        {
            (**aScriptHandle)->fScriptLanguageCount++;
        }
    }

    if (sResult && *aScriptHandle)
    {
        DisposeHandle((Handle)*aScriptHandle);

        *aScriptHandle = NULL;
    }

    return sResult;
}

pascal ComponentResult HIMInitiateTextService(Handle aSessionHandle)
{
    return noErr;
}

pascal ComponentResult HIMTerminateTextService(Handle aSessionHandle)
{
    return noErr;
}

pascal ComponentResult HIMActivateTextService(Handle aSessionHandle)
{
    return HIMSessionActivate((HIMSessionHandle)aSessionHandle);
}

pascal ComponentResult HIMDeactivateTextService(Handle aSessionHandle)
{
    return HIMSessionDeactivate((HIMSessionHandle)aSessionHandle);
}

pascal ComponentResult HIMTextServiceEventRef(Handle aSessionHandle, EventRef aEventRef)
{
    return HIMSessionEvent((HIMSessionHandle)aSessionHandle, aEventRef);
}

pascal ComponentResult HIMGetTextServiceMenu(Handle aSessionHandle, MenuHandle *aMenuHandle)
{
    *aMenuHandle = gTextServiceMenu;

    return noErr;
}

pascal ComponentResult HIMFixTextService(Handle aSessionHandle)
{
    return HIMSessionFix((HIMSessionHandle)aSessionHandle);
}

pascal ComponentResult HIMHidePaletteWindows(Handle aSessionHandle)
{
    return HIMSessionHidePalettes((HIMSessionHandle)aSessionHandle);
}

pascal ComponentResult HIMCopyTextServiceInputModeList(Handle           aSessionHandle,
                                                       CFDictionaryRef* aInputModes)
{
    CFBundleRef     sBundleRef;
    CFDictionaryRef sBundleInfoDict;
    CFDictionaryRef sInputModes;

    sBundleRef = CFBundleGetBundleWithIdentifier(CFSTR("org.osxdev.Hanulim"));

    if(sBundleRef)
    {
	sBundleInfoDict = CFBundleGetInfoDictionary(sBundleRef);

        if(sBundleInfoDict)
        {
            CFRetain(sBundleInfoDict);

            sInputModes = (CFDictionaryRef)CFDictionaryGetValue(sBundleInfoDict,
                                                                kComponentBundleInputModeDictKey);
	    if(sInputModes)
            {
		*aInputModes = CFDictionaryCreateCopy(kCFAllocatorDefault, sInputModes);
	    }
            else
            {
		HIMLog("CFDictionaryCreateCopy() failed\n");
	    }

            CFRelease(sBundleInfoDict);
	}
        else
        {
	    HIMLog("CFBundleGetInfoDictionary() failed\n");
	}
    }
    else
    {
	HIMLog("CFBundleGetBundleWithIdentifier() failed\n");
    }

    return noErr;
}

pascal ComponentResult HIMSetTextServiceProperty(Handle                   aSessionHandle,
                                                 TextServicePropertyTag   aTag,
						 TextServicePropertyValue aValue)
{
    CFStringRef sNewMode = (CFStringRef)aValue;

    if(aTag != kTextServiceInputModePropertyTag)
    {
	HIMLog("Can't SetTextServiceProperty[%d]\n", aTag);

        return tsmComponentPropertyUnsupportedErr;
    }

    if (CFStringCompare(sNewMode, CFSTR("org.osxdev.Hanulim.Keyboard.2"), 0) == 0)
    {
        gPreferences.mKeyboardLayout = kKeyboardLayout2;
    }
    else if (CFStringCompare(sNewMode, CFSTR("org.osxdev.Hanulim.Keyboard.3"), 0) == 0)
    {
        gPreferences.mKeyboardLayout = kKeyboardLayout3;
    }
    else if (CFStringCompare(sNewMode, CFSTR("org.osxdev.Hanulim.Keyboard.390"), 0) == 0)
    {
        gPreferences.mKeyboardLayout = kKeyboardLayout390;
    }
    else if (CFStringCompare(sNewMode, CFSTR("org.osxdev.Hanulim.Keyboard.393"), 0) == 0)
    {
        gPreferences.mKeyboardLayout = kKeyboardLayout393;
    }
    else
    {
        HIMLog("Unknown Mode: %s", CFStringGetCStringPtr(sNewMode, kCFStringEncodingUTF8));
    }

    return noErr;
}
