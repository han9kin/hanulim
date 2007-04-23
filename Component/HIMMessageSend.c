#include "Hanulim.h"
#include "HIMContext.h"
#include "HIMPreferences.h"
#include "HIMMessageSend.h"

static OSStatus HIMSendMessageToServer(UInt32 inMessageID, CFDataRef inData, CFDataRef *outReplyData);

OSStatus HIMSendActivated() {
    OSStatus result;
    ProcessSerialNumber psn;
    CFDataRef sendData = NULL;
    
    result = GetCurrentProcess(&psn);
    
    if (result == noErr) {
        sendData = CFDataCreate(NULL, (UInt8 *)&psn, sizeof(ProcessSerialNumber));
        if (sendData == NULL)
            result = memFullErr;
    }
    
    if (result == noErr) {
        result = HIMSendMessageToServer(HanulimMessageActivated, sendData, NULL);
        CFRelease(sendData);
    }
    
    return result;
}

OSStatus HIMSendDeactivated() {
    return HIMSendMessageToServer(HanulimMessageDeactivated, NULL, NULL);
}

OSStatus HIMSendGetPreferences() {
    OSStatus result;
    CFDataRef replyData;
    
    result = HIMSendMessageToServer(HanulimMessageGetPreferences, NULL, &replyData);
    if ((result == noErr) && replyData) {
        CFRange range;
        
        range.location = 0;
        range.length = sizeof(HanulimPreferences);
        CFDataGetBytes(replyData, range, (UInt8 *)&preferences);
        CFRelease(replyData);
    }
    
    return result;
}

OSStatus HIMSendSetPreferences() {
    OSStatus result = noErr;
    CFDataRef sendData;
    
    sendData = CFDataCreate(NULL, (UInt8 *)&preferences, sizeof(HanulimPreferences));
    if (sendData == NULL)
        result = memFullErr;
    
    if (result == noErr) {
        result = HIMSendMessageToServer(HanulimMessageSetPreferences, sendData, NULL);
        CFRelease(sendData);
    }
    
    return result;
}

static OSStatus HIMSendMessageToServer(UInt32 inMessageID, CFDataRef inData, CFDataRef *outReplyData) {
    OSStatus result = noErr;
    CFMessagePortRef serverPortRef;
    
    serverPortRef = CFMessagePortCreateRemote(NULL, HanulimServerIdentifier);
    if (serverPortRef == NULL)
        result = -1;
    
    if (result == noErr) {
        if (CFMessagePortSendRequest(serverPortRef, inMessageID, inData, 10, 10, (outReplyData ? kCFRunLoopDefaultMode : NULL), outReplyData) != kCFMessagePortSuccess) // outReplyData CAN BE NULL?
            result = -2;
    }
    
    if (serverPortRef)
        CFRelease(serverPortRef);
    
    return result;
}
