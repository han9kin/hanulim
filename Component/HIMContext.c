#include "Hanulim.h"
#include "HIMContext.h"
#include "HIMInput.h"
#include "HIMPreferences.h"
#include "HIMMethod.h"
#include "HIMLaunchServer.h"
#include "HIMMessageSend.h"
#include "HIMScript.h"


/*
 * Constants
 */

enum
{
    kAboutMenuCommand                 = 'abou',
    kFixImmediatelyMenuCommand        = 'fixi',
    kSmartQuotationMarksMenuCommand   = 'quot',
    kHandleCapsLockAsShiftMenuCommand = 'caps',
    kInputConjoiningJamoMenuCommand   = 'conj'
};


/*
 * Global variables
 */

static HIMSessionHandle gActiveSession;
static MenuRef          gPencilMenu;


/*
 * Local functions
 */

static void HIMUpdateMenuItems()
{
    MenuRef       sOutMenu;
    MenuItemIndex sOutIndex;
    OSStatus      sResult;

    sResult = GetIndMenuItemWithCommandID(gPencilMenu,
                                          kFixImmediatelyMenuCommand,
                                          1,
                                          &sOutMenu,
                                          &sOutIndex);

    if (sResult == noErr)
    {
        CheckMenuItem(gPencilMenu, sOutIndex, gPreferences.mFixImmediately);
    }

    sResult = GetIndMenuItemWithCommandID(gPencilMenu,
                                          kSmartQuotationMarksMenuCommand,
                                          1,
                                          &sOutMenu,
                                          &sOutIndex);

    if (sResult == noErr)
    {
        CheckMenuItem(gPencilMenu, sOutIndex, gPreferences.mSmartQuotationMarks);
    }

    sResult = GetIndMenuItemWithCommandID(gPencilMenu,
                                          kHandleCapsLockAsShiftMenuCommand,
                                          1,
                                          &sOutMenu,
                                          &sOutIndex);

    if (sResult == noErr)
    {
        CheckMenuItem(gPencilMenu, sOutIndex, gPreferences.mHandleCapsLockAsShift);
    }

    sResult = GetIndMenuItemWithCommandID(gPencilMenu,
                                          kInputConjoiningJamoMenuCommand,
                                          1,
                                          &sOutMenu,
                                          &sOutIndex);

    if (sResult == noErr)
    {
        CheckMenuItem(gPencilMenu, sOutIndex, HIMInputConjoiningJamo());

        if (HIMArchaicKeyboard())
        {
            DisableMenuItem(gPencilMenu, sOutIndex);
        }
        else
        {
            EnableMenuItem(gPencilMenu, sOutIndex);
        }
    }
}

static pascal OSStatus HIMPencilMenuEventHandler(EventHandlerCallRef  aEventHandlerCallRef,
                                                 EventRef             aEventRef,
                                                 void                *aUserData)
{
    OSStatus  sResult;
    HICommand sCommand;

    sResult = GetEventParameter(aEventRef,
                                kEventParamDirectObject,
                                typeHICommand,
                                nil,
                                sizeof(sCommand),
                                nil,
                                &sCommand);

    if (sResult == noErr)
    {
        Boolean sPreferencesChanged = true;

        switch (sCommand.commandID)
        {
            case kAboutMenuCommand:
                sPreferencesChanged = false;
                break;
            case kFixImmediatelyMenuCommand:
                gPreferences.mFixImmediately = !gPreferences.mFixImmediately;
                break;
            case kSmartQuotationMarksMenuCommand:
                gPreferences.mSmartQuotationMarks = !gPreferences.mSmartQuotationMarks;
                break;
            case kHandleCapsLockAsShiftMenuCommand:
                gPreferences.mHandleCapsLockAsShift = !gPreferences.mHandleCapsLockAsShift;
                break;
            case kInputConjoiningJamoMenuCommand:
                gPreferences.mInputConjoiningJamo = !gPreferences.mInputConjoiningJamo;
                break;
            default:
                sPreferencesChanged = false;
                break;
        }

        if (sPreferencesChanged)
        {
            HIMUpdateMenuItems();
            HIMSendSetPreferences();
        }
    }

    return sResult;
}


/*
 * Service functions
 */

ComponentResult HIMInitialize(ComponentInstance aComponentInstance, MenuRef *aTextServiceMenu)
{
    ComponentResult sResult = noErr;

    gActiveSession = NULL;
    gPencilMenu    = NULL;

    sResult = HIMLaunchServer();

    if (sResult == noErr)
    {
        CFBundleRef sBundleRef;
        IBNibRef    sNibRef;
        OSStatus    sErr;

        sBundleRef = CFBundleGetBundleWithIdentifier(HanulimIdentifier);

        sErr = CreateNibReferenceWithCFBundle(sBundleRef, CFSTR("PencilMenu"), &sNibRef);

        if (sErr)
        {
            HIMLog("Hanulim Error: Cannot find PencilMenu.nib");
            return resNotFound;
        }

        sErr = CreateMenuFromNib(sNibRef, CFSTR("Menu"), &gPencilMenu);

        if (sErr)
        {
            HIMLog("Hanulim Error: Cannot unarchive menu from PencilMenu.nib");
            return resNotFound;
        }

        DisposeNibReference(sNibRef);

        if (gPencilMenu)
        {
            *aTextServiceMenu = gPencilMenu;
        }
        else
        {
            sResult = resNotFound;
        }

        if (sResult == noErr)
        {
            EventTypeSpec sMenuEventSpec;

            sMenuEventSpec.eventClass = kEventClassCommand;
            sMenuEventSpec.eventKind  = kEventProcessCommand;

            sResult = InstallMenuEventHandler(gPencilMenu,
                                             NewEventHandlerUPP(HIMPencilMenuEventHandler),
                                             1,
                                             &sMenuEventSpec,
                                             nil,
                                             nil);

            HIMUpdateMenuItems();
        }
    }

    return sResult;
}

void HIMTerminate(ComponentInstance aComponentInstance)
{
    /*
     * THIS MAY NOT BE SAFE
     */
    DisposeMenu(gPencilMenu);

    gActiveSession = NULL;
    gPencilMenu    = NULL;
}

ComponentResult HIMSessionOpen(ComponentInstance  aComponentInstance,
                               HIMSessionHandle  *aSessionHandle)
{
    ComponentResult sResult = noErr;

    if (*aSessionHandle == nil)
    {
        *aSessionHandle = (HIMSessionHandle)NewHandle(sizeof(HIMSessionRecord));
    }

    if (*aSessionHandle == nil)
    {
        sResult = memFullErr;
    }

    if (sResult == noErr)
    {
        (**aSessionHandle)->mComponentInstance = aComponentInstance;
        (**aSessionHandle)->mLastUpdateLength  = 0;
        (**aSessionHandle)->mCharBufferCount   = 0;
        (**aSessionHandle)->mCharBuffer        = (UniCharPtr)NewPtr(kBufferMax + 2);
        (**aSessionHandle)->mKeyBufferCount    = 0;
        (**aSessionHandle)->mKeyBuffer         = (UniCharPtr)NewPtr(kBufferMax + 1);

        sResult = MemError();
    }

    return sResult;
}

void HIMSessionClose(HIMSessionHandle aSessionHandle)
{
    if (aSessionHandle)
    {
        if ((*aSessionHandle)->mCharBuffer)
        {
            DisposePtr((Ptr)(*aSessionHandle)->mCharBuffer);
        }

        if ((*aSessionHandle)->mKeyBuffer)
        {
            DisposePtr((Ptr)(*aSessionHandle)->mKeyBuffer);
        }

        DisposeHandle((Handle)aSessionHandle);
    }
}

ComponentResult HIMSessionActivate(HIMSessionHandle aSessionHandle)
{
    OSStatus sResult;

    gActiveSession = aSessionHandle;

    HIMQuotationMark(0);

    sResult = HIMSendActivated();

    if (sResult == noErr)
    {
        sResult = HIMSendGetPreferences();
    }

    if (sResult == noErr)
    {
        HIMUpdateMenuItems();
    }

    return sResult;
}

ComponentResult HIMSessionDeactivate(HIMSessionHandle aSessionHandle)
{
    gActiveSession = nil;

    return HIMSendDeactivated();
}

ComponentResult HIMSessionEvent(HIMSessionHandle aSessionHandle, EventRef aEventRef)
{
    Boolean sHandled    = false;
    UInt32  sEventClass = GetEventClass(aEventRef);
    UInt32  sEventKind  = GetEventKind(aEventRef);

    if ((sEventClass == kEventClassKeyboard) &&
        (sEventKind == kEventRawKeyDown || sEventKind == kEventRawKeyRepeat))
    {
        UInt32        sKeyCode;
        unsigned char sCharCode;
        UInt32        sModifiers;

        /*
         * extract key code
         */
        GetEventParameter(aEventRef,
                          kEventParamKeyCode,
                          typeUInt32,
                          nil,
                          sizeof(sKeyCode),
                          nil,
                          &sKeyCode);

        /*
         * extract character code
         */
        GetEventParameter(aEventRef,
                          kEventParamKeyMacCharCodes,
                          typeChar,
                          nil,
                          sizeof(sCharCode),
                          nil,
                          &sCharCode);

        /*
         * extract modifiers
         */
        GetEventParameter(aEventRef,
                          kEventParamKeyModifiers,
                          typeUInt32,
                          nil,
                          sizeof(sModifiers),
                          nil,
                          &sModifiers);

        sHandled = HIMHandleKey(aSessionHandle, sKeyCode, sModifiers, sCharCode);
    }

    return sHandled;
}

ComponentResult HIMSessionFix(HIMSessionHandle aSessionHandle)
{
    ComponentResult sResult = noErr;

    if ((*aSessionHandle)->mCharBufferCount)
    {
        sResult = HIMInput(aSessionHandle, true);

        (*aSessionHandle)->mKeyBufferCount = 0;
    }

    return sResult;
}

ComponentResult HIMSessionHidePalettes(HIMSessionHandle aSessionHandle)
{
    return noErr;
}

HIMSessionHandle HIMGetActiveSession()
{
    return gActiveSession;
}

void HIMLog(const char *format, ...)
{
#ifdef DEBUG
    va_list  ap;
    FILE    *fp = stderr;

    va_start(ap, format);
    vfprintf(fp, format, ap);
    va_end(ap);

    fprintf(fp, "\n");

    fflush(fp);
#endif
}
