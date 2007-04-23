#include "Hanulim.h"
#include "HIMContext.h"
#include "HIMInput.h"
#include "HIMPreferences.h"
#include "HIMMethod.h"
#include "HIMLaunchServer.h"
#include "HIMMessageSend.h"
#include "HIMScript.h"

// Constants

enum {
    kAboutMenuCommand = 'abou',
    kKbdLayout2MenuCommand = 'kl2s',
    kKbdLayout3MenuCommand = 'kl3l',
    kKbdLayout390MenuCommand = 'k390',
    kKbdLayout393MenuCommand = 'k393',
    kFixImmediatelyMenuCommand = 'fixi',
    kSmartQuotationMarksMenuCommand = 'quot',
    kHandleCapsLockAsShiftMenuCommand = 'caps',
    kInputConjoiningJamoMenuCommand = 'conj'
};

// Global variables

static HIMSessionHandle gActiveSession;
static MenuRef gPencilMenu;


// Local functions

static pascal OSStatus HIMPencilMenuEventHandler(EventHandlerCallRef inEventHandlerCallRef, EventRef inEventRef, void *inUserData);


void HIMUpdateMenuItems() {
    static MenuCommand commandID[] = {kKbdLayout2MenuCommand, kKbdLayout3MenuCommand, kKbdLayout390MenuCommand, kKbdLayout393MenuCommand};
    int i;
    MenuRef outMenu;
    MenuItemIndex outIndex;
    OSStatus result;

    for (i = 0; i < 4; i++) {
        result = GetIndMenuItemWithCommandID(gPencilMenu, commandID[i], 1, &outMenu, &outIndex);
        if (result == noErr)
            CheckMenuItem(gPencilMenu, outIndex, (i == (UInt16)preferences.keyboardLayout));
    }
    
    result = GetIndMenuItemWithCommandID(gPencilMenu, kFixImmediatelyMenuCommand, 1, &outMenu, &outIndex);
    if (result == noErr)
        CheckMenuItem(gPencilMenu, outIndex, preferences.fixImmediately);
    
    result = GetIndMenuItemWithCommandID(gPencilMenu, kSmartQuotationMarksMenuCommand, 1, &outMenu, &outIndex);
    if (result == noErr)
        CheckMenuItem(gPencilMenu, outIndex, preferences.smartQuotationMarks);
    
    result = GetIndMenuItemWithCommandID(gPencilMenu, kHandleCapsLockAsShiftMenuCommand, 1, &outMenu, &outIndex);
    if (result == noErr)
        CheckMenuItem(gPencilMenu, outIndex, preferences.handleCapsLockAsShift);
    
    result = GetIndMenuItemWithCommandID(gPencilMenu, kInputConjoiningJamoMenuCommand, 1, &outMenu, &outIndex);
    if (result == noErr) {
        CheckMenuItem(gPencilMenu, outIndex, HIMInputConjoiningJamo());
        if (HIMArchaicKeyboard())
            DisableMenuItem(gPencilMenu, outIndex);
        else
            EnableMenuItem(gPencilMenu, outIndex);
    }
}

ComponentResult HIMInitialize(ComponentInstance inComponentInstance, MenuRef *outTextServiceMenu) {
    ComponentResult result = noErr;
    
    gActiveSession = NULL;
    gPencilMenu = NULL;
    
    result = HIMLaunchServer();
    
    if (result == noErr) {
        CFBundleRef bundleRef = CFBundleGetBundleWithIdentifier(HanulimIdentifier);
        IBNibRef nibRef;
        OSStatus err;
        
        err = CreateNibReferenceWithCFBundle(bundleRef, CFSTR("PencilMenu"), &nibRef);
        if (err) {
            HIMLog("Hanulim Error: Cannot find PencilMenu.nib");
            return resNotFound;
        }
        err = CreateMenuFromNib(nibRef, CFSTR("Menu"), &gPencilMenu);
        if (err) {
            HIMLog("Hanulim Error: Cannot unarchive menu from PencilMenu.nib");
            return resNotFound;
        }
        DisposeNibReference(nibRef);

        if (gPencilMenu)
            *outTextServiceMenu = gPencilMenu;
        else
            result = resNotFound;
        
        if (result == noErr) {
            EventTypeSpec menuEventSpec;
            menuEventSpec.eventClass = kEventClassCommand;
            menuEventSpec.eventKind = kEventProcessCommand;
            result = InstallMenuEventHandler(gPencilMenu, NewEventHandlerUPP(HIMPencilMenuEventHandler), 1, &menuEventSpec, nil, nil);
            
            HIMUpdateMenuItems();
        }
    }

    return result;
}

void HIMTerminate(ComponentInstance inComponentInstance) {
    DisposeMenu(gPencilMenu); // THIS MAY NOT BE SAFE
    gActiveSession = NULL;
    gPencilMenu = NULL;
}

ComponentResult HIMSessionOpen(ComponentInstance inComponentInstance, HIMSessionHandle *outSessionHandle) {
    ComponentResult result = noErr;
    
    if (*outSessionHandle == nil)
        *outSessionHandle = (HIMSessionHandle)NewHandle(sizeof(HIMSessionRecord));
    if (*outSessionHandle == nil)
        result = memFullErr;

    if (result == noErr) {
        (**outSessionHandle)->fComponentInstance = inComponentInstance;
        (**outSessionHandle)->fLastUpdateLength = 0;
        (**outSessionHandle)->fCharBufferCount = 0;
        (**outSessionHandle)->fCharBuffer = (UniCharPtr)NewPtr(kBufferMax + 2);
        (**outSessionHandle)->fKeyBufferCount = 0;
        (**outSessionHandle)->fKeyBuffer = (UniCharPtr)NewPtr(kBufferMax + 1);
        result = MemError();
    }

    return result;
}

void HIMSessionClose(HIMSessionHandle inSessionHandle) {
    if (inSessionHandle) {
        if ((*inSessionHandle)->fCharBuffer)
            DisposePtr((Ptr)(*inSessionHandle)->fCharBuffer);
        if ((*inSessionHandle)->fKeyBuffer)
            DisposePtr((Ptr)(*inSessionHandle)->fKeyBuffer);
        DisposeHandle((Handle)inSessionHandle);
    }
}

ComponentResult HIMSessionActivate(HIMSessionHandle inSessionHandle) {
    OSStatus result;

    gActiveSession = inSessionHandle;

    HIMQuotationMark(0);

    result = HIMSendActivated();

    if (result == noErr)
        result = HIMSendGetPreferences();
    
    if (result == noErr)
        HIMUpdateMenuItems();

    return result;
}

ComponentResult HIMSessionDeactivate(HIMSessionHandle inSessionHandle) {
    gActiveSession = nil;
    return HIMSendDeactivated();
}

ComponentResult HIMSessionEvent(HIMSessionHandle inSessionHandle, EventRef inEventRef) {
    Boolean handled = false;
    UInt32 eventClass = GetEventClass(inEventRef);
    UInt32 eventKind = GetEventKind(inEventRef);

    if ((eventClass == kEventClassKeyboard) && (eventKind == kEventRawKeyDown || eventKind == kEventRawKeyRepeat)) {
        UInt32 keyCode;
        unsigned char charCode;
        UInt32 modifiers;
        
        // extract key code
        GetEventParameter(inEventRef, kEventParamKeyCode, typeUInt32, nil, sizeof(keyCode), nil, &keyCode);
        
        // extract character code
        GetEventParameter(inEventRef, kEventParamKeyMacCharCodes, typeChar, nil, sizeof(charCode), nil, &charCode);
        
        // extract modifiers
        GetEventParameter(inEventRef, kEventParamKeyModifiers, typeUInt32, nil, sizeof(modifiers), nil, &modifiers);
        
        handled = HIMHandleKey(inSessionHandle, keyCode, modifiers, charCode);
    }
    
    return handled;
}

ComponentResult HIMSessionFix(HIMSessionHandle inSessionHandle) {
    ComponentResult result = noErr;
    
    if ((*inSessionHandle)->fCharBufferCount) {
        result = HIMInput(inSessionHandle, true);
        (*inSessionHandle)->fKeyBufferCount = 0;
    }
    return result;
}

ComponentResult HIMSessionHidePalettes(HIMSessionHandle inSessionHandle) {
    return noErr;
}

HIMSessionHandle HIMGetActiveSession() {
    return gActiveSession;
}

static pascal OSStatus HIMPencilMenuEventHandler(EventHandlerCallRef inEventHandlerCallRef, EventRef inEventRef, void *inUserData) {
    OSStatus result;
    HICommand command;

    result = GetEventParameter(inEventRef, kEventParamDirectObject, typeHICommand, nil, sizeof(command), nil, &command);
    if (result == noErr) {
        Boolean preferencesChanged = true;

        switch (command.commandID) {
            case kAboutMenuCommand:
                preferencesChanged = false;
                break;
            case kKbdLayout2MenuCommand:
                preferences.keyboardLayout = kKeyboardLayout2;
                break;
            case kKbdLayout3MenuCommand:
                preferences.keyboardLayout = kKeyboardLayout3;
                break;
            case kKbdLayout390MenuCommand:
                preferences.keyboardLayout = kKeyboardLayout390;
                break;
            case kKbdLayout393MenuCommand:
                preferences.keyboardLayout = kKeyboardLayout393;
                break;
            case kFixImmediatelyMenuCommand:
                preferences.fixImmediately = !preferences.fixImmediately;
                break;
            case kSmartQuotationMarksMenuCommand:
                preferences.smartQuotationMarks = !preferences.smartQuotationMarks;
                break;
            case kHandleCapsLockAsShiftMenuCommand:
                preferences.handleCapsLockAsShift = !preferences.handleCapsLockAsShift;
                break;
            case kInputConjoiningJamoMenuCommand:
                preferences.inputConjoiningJamo = !preferences.inputConjoiningJamo;
                break;
            default:
                preferencesChanged = false;
                break;
        }

        if (preferencesChanged) {
            HIMUpdateMenuItems();
            HIMSendSetPreferences();
        }
    }

    return result;
}


void HIMLog(const char *format, ...) {
/* #ifdef DEBUG */
    va_list ap;

    va_start(ap, format);
    vfprintf(stderr, format, ap);
    va_end(ap);

    fprintf(stderr, "\n");
/* #endif */
}
