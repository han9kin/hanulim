#ifndef HIMComponent_h
#define HIMComponent_h

#include <Carbon/Carbon.h>

// These first four entry points are standard for any component.

pascal ComponentResult HIMOpenComponent(ComponentInstance inComponentInstance);
pascal ComponentResult HIMCloseComponent(Handle inSessionHandle, ComponentInstance inComponentInstance);
pascal ComponentResult HIMCanDo(SInt16 inSelector);
pascal ComponentResult HIMGetVersion();

// The next entry points are required for any text service component.

pascal ComponentResult HIMGetScriptLangSupport(Handle inSessionHandle, ScriptLanguageSupportHandle *outScriptHandle);
pascal ComponentResult HIMInitiateTextService(Handle inSessionHandle);
pascal ComponentResult HIMTerminateTextService(Handle inSessionHandle);
pascal ComponentResult HIMActivateTextService(Handle inSessionHandle);
pascal ComponentResult HIMDeactivateTextService(Handle inSessionHandle);
pascal ComponentResult HIMTextServiceEventRef(Handle inSessionHandle, EventRef inEventRef);
pascal ComponentResult HIMGetTextServiceMenu(Handle inSessionHandle, MenuHandle *outMenuHandle);
pascal ComponentResult HIMFixTextService(Handle inSessionHandle);
pascal ComponentResult HIMHidePaletteWindows(Handle inSessionHandle);
pascal ComponentResult HIMCopyTextServiceInputModeList(Handle inSessionHandle, CFDictionaryRef* outInputModes);
pascal ComponentResult HIMSetTextServiceProperty(Handle inSessionHandle, TextServicePropertyTag tag, TextServicePropertyValue value);
//

enum {
    uppOpenComponentProcInfo = kPascalStackBased
    | RESULT_SIZE(SIZE_CODE(sizeof(ComponentResult)))
    | STACK_ROUTINE_PARAMETER(1, SIZE_CODE(sizeof(ComponentInstance))),

    uppCloseComponentProcInfo = kPascalStackBased
    | RESULT_SIZE(SIZE_CODE(sizeof(ComponentResult)))
    | STACK_ROUTINE_PARAMETER(1, SIZE_CODE(sizeof(Handle)))
    | STACK_ROUTINE_PARAMETER(2, SIZE_CODE(sizeof(ComponentInstance))),

    uppCanDoProcInfo = kPascalStackBased
    | RESULT_SIZE(SIZE_CODE(sizeof(ComponentResult)))
    | STACK_ROUTINE_PARAMETER(1, SIZE_CODE(sizeof(short))),

    uppGetVersionProcInfo = kPascalStackBased
    | RESULT_SIZE(SIZE_CODE(sizeof(ComponentResult))),

    uppGetScriptLangSupportProcInfo = kPascalStackBased
    | RESULT_SIZE(SIZE_CODE(sizeof(ComponentResult)))
    | STACK_ROUTINE_PARAMETER(1, SIZE_CODE(sizeof(Handle)))
    | STACK_ROUTINE_PARAMETER(2, SIZE_CODE(sizeof(ScriptLanguageSupportHandle *))),

    uppInitiateTextServiceProcInfo = kPascalStackBased
    | RESULT_SIZE(SIZE_CODE(sizeof(ComponentResult)))
    | STACK_ROUTINE_PARAMETER(1, SIZE_CODE(sizeof(Handle))),

    uppTerminateTextServiceProcInfo = kPascalStackBased
    | RESULT_SIZE(SIZE_CODE(sizeof(ComponentResult)))
    | STACK_ROUTINE_PARAMETER(1, SIZE_CODE(sizeof(Handle))),

    uppActivateTextServiceProcInfo = kPascalStackBased
    | RESULT_SIZE(SIZE_CODE(sizeof(ComponentResult)))
    | STACK_ROUTINE_PARAMETER(1, SIZE_CODE(sizeof(Handle))),

    uppDeactivateTextServiceProcInfo = kPascalStackBased
    | RESULT_SIZE(SIZE_CODE(sizeof(ComponentResult)))
    | STACK_ROUTINE_PARAMETER(1, SIZE_CODE(sizeof(Handle))),

    uppTextServiceEventRefProcInfo = kPascalStackBased
    | RESULT_SIZE(SIZE_CODE(sizeof(ComponentResult)))
    | STACK_ROUTINE_PARAMETER(1, SIZE_CODE(sizeof(Handle)))
    | STACK_ROUTINE_PARAMETER(2, SIZE_CODE(sizeof(EventRef))),

    uppGetTextServiceMenuProcInfo = kPascalStackBased
    | RESULT_SIZE(SIZE_CODE(sizeof(ComponentResult)))
    | STACK_ROUTINE_PARAMETER(1, SIZE_CODE(sizeof(Handle)))
    | STACK_ROUTINE_PARAMETER(2, SIZE_CODE(sizeof(MenuHandle *))),

    uppFixTextServiceProcInfo = kPascalStackBased
    | RESULT_SIZE(SIZE_CODE(sizeof(ComponentResult)))
    | STACK_ROUTINE_PARAMETER(1, SIZE_CODE(sizeof(Handle))),

    uppHidePaletteWindowsProcInfo = kPascalStackBased
    | RESULT_SIZE(SIZE_CODE(sizeof(ComponentResult)))
    | STACK_ROUTINE_PARAMETER(1, SIZE_CODE(sizeof(Handle))),

    uppCopyTextServiceInputModeListInfo = kPascalStackBased
    | RESULT_SIZE(SIZE_CODE(sizeof(ComponentResult)))
    | STACK_ROUTINE_PARAMETER(1, SIZE_CODE(sizeof(Handle)))
    | STACK_ROUTINE_PARAMETER(2, SIZE_CODE(sizeof(CFDictionaryRef*))),

    uppSetTextServicePropertyInfo = kPascalStackBased
    | RESULT_SIZE(SIZE_CODE(sizeof(ComponentResult)))
    | STACK_ROUTINE_PARAMETER(1, SIZE_CODE(sizeof(Handle)))
    | STACK_ROUTINE_PARAMETER(2, SIZE_CODE(sizeof(TextServicePropertyTag)))
    | STACK_ROUTINE_PARAMETER(3, SIZE_CODE(sizeof(TextServicePropertyValue)))
};

#endif
