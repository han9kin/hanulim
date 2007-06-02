#include "Hanulim.h"
#include "HIMContext.h"
#include "HIMPreferences.h"
#include "HIMMessageSend.h"



static OSStatus HIMSendMessageToServer(UInt32     aMessageID,
                                       CFDataRef  aData,
                                       CFDataRef *aReplyData)
{
    OSStatus         sResult = noErr;
    CFMessagePortRef sServerPortRef;

    sServerPortRef = CFMessagePortCreateRemote(NULL, HanulimServerIdentifier);

    if (sServerPortRef == NULL)
    {
        sResult = -1;
    }

    if (sResult == noErr)
    {
        /*
         * aReplyData CAN BE NULL?
         */
        if (CFMessagePortSendRequest(sServerPortRef,
                                     aMessageID,
                                     aData,
                                     10,
                                     10,
                                     (aReplyData ? kCFRunLoopDefaultMode : NULL),
                                     aReplyData) != kCFMessagePortSuccess)
        {
            sResult = -2;
        }
    }

    if (sServerPortRef)
    {
        CFRelease(sServerPortRef);
    }

    return sResult;
}


OSStatus HIMSendActivated()
{
    OSStatus            sResult;
    ProcessSerialNumber sPsn;
    CFDataRef           sSendData = NULL;

    sResult = GetCurrentProcess(&sPsn);

    if (sResult == noErr)
    {
        sSendData = CFDataCreate(NULL, (UInt8 *)&sPsn, sizeof(ProcessSerialNumber));

        if (sSendData == NULL)
        {
            sResult = memFullErr;
        }
    }

    if (sResult == noErr)
    {
        sResult = HIMSendMessageToServer(HanulimMessageActivated, sSendData, NULL);

        CFRelease(sSendData);
    }

    return sResult;
}

OSStatus HIMSendDeactivated()
{
    return HIMSendMessageToServer(HanulimMessageDeactivated, NULL, NULL);
}

OSStatus HIMSendGetPreferences()
{
    OSStatus  sResult;
    CFDataRef sReplyData;

    sResult = HIMSendMessageToServer(HanulimMessageGetPreferences, NULL, &sReplyData);

    if ((sResult == noErr) && sReplyData)
    {
        CFRange range;

        range.location = 0;
        range.length   = sizeof(HanulimPreferences);

        CFDataGetBytes(sReplyData, range, (UInt8 *)&gPreferences);
        CFRelease(sReplyData);
    }

    return sResult;
}

OSStatus HIMSendSetPreferences()
{
    OSStatus  sResult = noErr;
    CFDataRef sSendData;

    sSendData = CFDataCreate(NULL, (UInt8 *)&gPreferences, sizeof(HanulimPreferences));

    if (sSendData == NULL)
    {
        sResult = memFullErr;
    }

    if (sResult == noErr)
    {
        sResult = HIMSendMessageToServer(HanulimMessageSetPreferences, sSendData, NULL);

        CFRelease(sSendData);
    }

    return sResult;
}
