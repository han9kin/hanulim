#import "Hanulim.h"
#import "HSMessageReceive.h"
#import "HSPreferences.h"


ProcessSerialNumber gActiveInputMethod;

CFDataRef HSMessagePortCallBack(CFMessagePortRef  aLocalPort,
                                SInt32            aMessageID,
                                CFDataRef         aData,
                                void             *aContextInfo)
{
    HanulimPreferences sPreferences;
    CFDataRef          sReplyData = NULL;

    switch (aMessageID)
    {
        case HanulimMessageActivated:
            if (aData)
            {
                CFRange sRange;

                sRange.location = 0;
                sRange.length   = sizeof(ProcessSerialNumber);

                CFDataGetBytes(aData, sRange, (UInt8 *)&gActiveInputMethod);
            }
            break;

        case HanulimMessageDeactivated:
            gActiveInputMethod.highLongOfPSN = 0;
            gActiveInputMethod.lowLongOfPSN = kNoProcess;
            break;

        case HanulimMessageGetPreferences:
            [HSPreferences get:&sPreferences];
            sReplyData = CFDataCreate(NULL, (UInt8 *)&sPreferences, sizeof(HanulimPreferences));
            break;

        case HanulimMessageSetPreferences:
            if (aData)
            {
                CFRange sRange;

                sRange.location = 0;
                sRange.length   = sizeof(HanulimPreferences);

                CFDataGetBytes(aData, sRange, (UInt8 *)&sPreferences);

                [HSPreferences set:&sPreferences];
            }
            break;
    }

    return sReplyData;
}

int HSRegisterServerToRunLoop(CFRunLoopRef aRunLoop)
{
    CFMessagePortContext sContext;
    CFMessagePortRef     sPort   = NULL;
    CFRunLoopSourceRef   sSource = NULL;

    sContext.version         = 0;
    sContext.info            = NULL;
    sContext.retain          = NULL;
    sContext.release         = NULL;
    sContext.copyDescription = NULL;

    gActiveInputMethod.highLongOfPSN = 0;
    gActiveInputMethod.lowLongOfPSN  = kNoProcess;

    sPort = CFMessagePortCreateLocal(NULL,
                                    HanulimServerIdentifier,
                                    HSMessagePortCallBack,
                                    &sContext,
                                    NULL);

    if (sPort == NULL)
    {
        return -1;
    }

    sSource = CFMessagePortCreateRunLoopSource(NULL, sPort, 0);

    if (sSource == NULL)
    {
        return -2;
    }

    CFRunLoopAddSource(aRunLoop, sSource, kCFRunLoopCommonModes);

    CFRelease(sSource);
    CFRelease(sPort);

    return 0;
}
