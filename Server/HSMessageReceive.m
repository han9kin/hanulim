#import "Hanulim.h"
#import "HSMessageReceive.h"
#import "HSPreferences.h"


ProcessSerialNumber gActiveInputMethod;

CFDataRef HSMessagePortCallBack(CFMessagePortRef inLocalPort, SInt32 inMessageID, CFDataRef inData, void *inContextInfo) {
    HanulimPreferences preferences;
    CFDataRef replyData = NULL;

    switch (inMessageID) {
        case HanulimMessageActivated:
            if (inData) {
                CFRange range;
                range.location = 0;
                range.length = sizeof(ProcessSerialNumber);
                CFDataGetBytes(inData, range, (UInt8 *)&gActiveInputMethod);
            }
            break;
        case HanulimMessageDeactivated:
            gActiveInputMethod.highLongOfPSN = 0;
            gActiveInputMethod.lowLongOfPSN = kNoProcess;
            break;
        case HanulimMessageGetPreferences:
            [HSPreferences get:&preferences];
            replyData = CFDataCreate(NULL, (UInt8 *)&preferences, sizeof(HanulimPreferences));
            break;
        case HanulimMessageSetPreferences:
            if (inData) {
                CFRange range;
                range.location = 0;
                range.length = sizeof(HanulimPreferences);
                CFDataGetBytes(inData, range, (UInt8 *)&preferences);
                [HSPreferences set:&preferences];
            }
            break;
    }
    
    return replyData;
}

int HSRegisterServerToRunLoop(CFRunLoopRef runLoop) {
    CFMessagePortContext context;
    CFMessagePortRef port = NULL;
    CFRunLoopSourceRef source = NULL;
    
    context.version = 0;
    context.info = NULL;
    context.retain = NULL;
    context.release = NULL;
    context.copyDescription = NULL;
    
    gActiveInputMethod.highLongOfPSN = 0;
    gActiveInputMethod.lowLongOfPSN = kNoProcess;
    
    port = CFMessagePortCreateLocal(NULL, HanulimServerIdentifier, HSMessagePortCallBack, &context, NULL);
    if (port == NULL)
        return -1;
    
    source = CFMessagePortCreateRunLoopSource(NULL, port, 0);
    if (source == NULL)
        return -2;
    
    CFRunLoopAddSource(runLoop, source, kCFRunLoopCommonModes);
    
    CFRelease(source);
    CFRelease(port);
    
    return 0;
}
