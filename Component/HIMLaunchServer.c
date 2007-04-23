#include "Hanulim.h"
#include "HIMLaunchServer.h"

static OSStatus HIMLaunchWithFSSpec(FSSpec *fileSpec);

OSStatus HIMLaunchServer() {
    OSStatus result;
    long timeout;
    CFBundleRef componentBundle;
    CFMessagePortRef serverPortRef;
    CFURLRef sharedSupportURL;
    CFURLRef serverURL;
    FSRef serverFSRef;
    FSSpec serverFileSpec;
    
    serverPortRef = NULL;
    sharedSupportURL = NULL;
    serverURL = NULL;
    
    serverPortRef = CFMessagePortCreateRemote(NULL, HanulimServerIdentifier);
    if (serverPortRef) {
        CFRelease(serverPortRef);
        return noErr;
    }
    
    componentBundle = CFBundleGetBundleWithIdentifier(HanulimIdentifier);
    if (componentBundle)
        sharedSupportURL = CFBundleCopySharedSupportURL(componentBundle);
    if (sharedSupportURL)
        serverURL = CFURLCreateCopyAppendingPathComponent(NULL, sharedSupportURL, HanulimServerAppName, false);
    
    if (serverURL && CFURLGetFSRef(serverURL, &serverFSRef))
        result = FSGetCatalogInfo(&serverFSRef, kFSCatInfoNone, NULL, NULL, &serverFileSpec, NULL);
    else
        result = -2;
    
    if (result == noErr)
        result = HIMLaunchWithFSSpec(&serverFileSpec);
    
    timeout = TickCount() + 1200;
    while ((result == noErr) && (serverPortRef == NULL)) {
        Delay(1, NULL);
        serverPortRef = CFMessagePortCreateRemote(NULL, HanulimServerIdentifier);
        if ((serverPortRef == NULL) && TickCount() > timeout)
            result = -1;
    }
    
    if (serverPortRef)
        CFRelease(serverPortRef);
    if (serverURL)
        CFRelease(serverURL);
    if (sharedSupportURL)
        CFRelease(sharedSupportURL);
    
    if (result == -1)
        fprintf(stderr, "HANULIM ERROR: A timeout occured while trying to launch the UI server.\n");
    else if (result == -2)
        fprintf(stderr, "HANULIM ERROR: Unable to locate the SharedSupport directory inside the component.\n");
    else if (result)
        fprintf(stderr, "HANULIM ERROR: An error of type %d occured while trying to launch the server.\n", (int)result);
    
    return result;
}

static OSStatus HIMLaunchWithFSSpec(FSSpec *fileSpec) {
    LaunchParamBlockRec launchParams;
    
    launchParams.launchBlockID = extendedBlock;
    launchParams.launchEPBLength = extendedBlockLen;
    launchParams.launchFileFlags = 0;
    launchParams.launchControlFlags = launchNoFileFlags + launchContinue + launchDontSwitch;
    launchParams.launchAppSpec = fileSpec;
    launchParams.launchAppParameters = NULL;

    return LaunchApplication(&launchParams);
}
