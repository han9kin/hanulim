#ifndef HIMComponent_h
#define HIMComponent_h

#include <Carbon/Carbon.h>


/*
 * Standard functions for any component
 */

pascal ComponentResult HIMOpenComponent(ComponentInstance aComponentInstance);
pascal ComponentResult HIMCloseComponent(Handle            aSessionHandle,
                                         ComponentInstance aComponentInstance);
pascal ComponentResult HIMCanDo(SInt16 aSelector);
pascal ComponentResult HIMGetVersion();

/*
 * Required functions for text service component
 */

pascal ComponentResult HIMGetScriptLangSupport(Handle                       aSessionHandle,
                                               ScriptLanguageSupportHandle *aScriptHandle);
pascal ComponentResult HIMInitiateTextService(Handle aSessionHandle);
pascal ComponentResult HIMTerminateTextService(Handle aSessionHandle);
pascal ComponentResult HIMActivateTextService(Handle aSessionHandle);
pascal ComponentResult HIMDeactivateTextService(Handle aSessionHandle);
pascal ComponentResult HIMTextServiceEventRef(Handle   aSessionHandle,
                                              EventRef aEventRef);
pascal ComponentResult HIMGetTextServiceMenu(Handle      aSessionHandle,
                                             MenuHandle *aMenuHandle);
pascal ComponentResult HIMFixTextService(Handle aSessionHandle);
pascal ComponentResult HIMHidePaletteWindows(Handle aSessionHandle);
pascal ComponentResult HIMCopyTextServiceInputModeList(Handle           aSessionHandle,
                                                       CFDictionaryRef *aInputModes);
pascal ComponentResult HIMSetTextServiceProperty(Handle                   aSessionHandle,
                                                 TextServicePropertyTag   aTag,
                                                 TextServicePropertyValue aValue);

/*
 * Component function info
 */

enum
{
    gUppOpenComponentProcInfo = kPascalStackBased
    | RESULT_SIZE(SIZE_CODE(sizeof(ComponentResult)))
    | STACK_ROUTINE_PARAMETER(1, SIZE_CODE(sizeof(ComponentInstance))),

    gUppCloseComponentProcInfo = kPascalStackBased
    | RESULT_SIZE(SIZE_CODE(sizeof(ComponentResult)))
    | STACK_ROUTINE_PARAMETER(1, SIZE_CODE(sizeof(Handle)))
    | STACK_ROUTINE_PARAMETER(2, SIZE_CODE(sizeof(ComponentInstance))),

    gUppCanDoProcInfo = kPascalStackBased
    | RESULT_SIZE(SIZE_CODE(sizeof(ComponentResult)))
    | STACK_ROUTINE_PARAMETER(1, SIZE_CODE(sizeof(short))),

    gUppGetVersionProcInfo = kPascalStackBased
    | RESULT_SIZE(SIZE_CODE(sizeof(ComponentResult))),

    gUppGetScriptLangSupportProcInfo = kPascalStackBased
    | RESULT_SIZE(SIZE_CODE(sizeof(ComponentResult)))
    | STACK_ROUTINE_PARAMETER(1, SIZE_CODE(sizeof(Handle)))
    | STACK_ROUTINE_PARAMETER(2, SIZE_CODE(sizeof(ScriptLanguageSupportHandle *))),

    gUppInitiateTextServiceProcInfo = kPascalStackBased
    | RESULT_SIZE(SIZE_CODE(sizeof(ComponentResult)))
    | STACK_ROUTINE_PARAMETER(1, SIZE_CODE(sizeof(Handle))),

    gUppTerminateTextServiceProcInfo = kPascalStackBased
    | RESULT_SIZE(SIZE_CODE(sizeof(ComponentResult)))
    | STACK_ROUTINE_PARAMETER(1, SIZE_CODE(sizeof(Handle))),

    gUppActivateTextServiceProcInfo = kPascalStackBased
    | RESULT_SIZE(SIZE_CODE(sizeof(ComponentResult)))
    | STACK_ROUTINE_PARAMETER(1, SIZE_CODE(sizeof(Handle))),

    gUppDeactivateTextServiceProcInfo = kPascalStackBased
    | RESULT_SIZE(SIZE_CODE(sizeof(ComponentResult)))
    | STACK_ROUTINE_PARAMETER(1, SIZE_CODE(sizeof(Handle))),

    gUppTextServiceEventRefProcInfo = kPascalStackBased
    | RESULT_SIZE(SIZE_CODE(sizeof(ComponentResult)))
    | STACK_ROUTINE_PARAMETER(1, SIZE_CODE(sizeof(Handle)))
    | STACK_ROUTINE_PARAMETER(2, SIZE_CODE(sizeof(EventRef))),

    gUppGetTextServiceMenuProcInfo = kPascalStackBased
    | RESULT_SIZE(SIZE_CODE(sizeof(ComponentResult)))
    | STACK_ROUTINE_PARAMETER(1, SIZE_CODE(sizeof(Handle)))
    | STACK_ROUTINE_PARAMETER(2, SIZE_CODE(sizeof(MenuHandle *))),

    gUppFixTextServiceProcInfo = kPascalStackBased
    | RESULT_SIZE(SIZE_CODE(sizeof(ComponentResult)))
    | STACK_ROUTINE_PARAMETER(1, SIZE_CODE(sizeof(Handle))),

    gUppHidePaletteWindowsProcInfo = kPascalStackBased
    | RESULT_SIZE(SIZE_CODE(sizeof(ComponentResult)))
    | STACK_ROUTINE_PARAMETER(1, SIZE_CODE(sizeof(Handle))),

    gUppCopyTextServiceInputModeListInfo = kPascalStackBased
    | RESULT_SIZE(SIZE_CODE(sizeof(ComponentResult)))
    | STACK_ROUTINE_PARAMETER(1, SIZE_CODE(sizeof(Handle)))
    | STACK_ROUTINE_PARAMETER(2, SIZE_CODE(sizeof(CFDictionaryRef*))),

    gUppSetTextServicePropertyInfo = kPascalStackBased
    | RESULT_SIZE(SIZE_CODE(sizeof(ComponentResult)))
    | STACK_ROUTINE_PARAMETER(1, SIZE_CODE(sizeof(Handle)))
    | STACK_ROUTINE_PARAMETER(2, SIZE_CODE(sizeof(TextServicePropertyTag)))
    | STACK_ROUTINE_PARAMETER(3, SIZE_CODE(sizeof(TextServicePropertyValue)))
};


#endif
