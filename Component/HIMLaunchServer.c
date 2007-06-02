#include "Hanulim.h"
#include "HIMLaunchServer.h"


static OSStatus HIMLaunchWithFSSpec(FSSpec *aFileSpec)
{
    LaunchParamBlockRec sLaunchParams;

    sLaunchParams.launchBlockID       = extendedBlock;
    sLaunchParams.launchEPBLength     = extendedBlockLen;
    sLaunchParams.launchFileFlags     = 0;
    sLaunchParams.launchControlFlags  = launchNoFileFlags + launchContinue + launchDontSwitch;
    sLaunchParams.launchAppSpec       = aFileSpec;
    sLaunchParams.launchAppParameters = NULL;

    return LaunchApplication(&sLaunchParams);
}


OSStatus HIMLaunchServer()
{
    OSStatus         sResult;
    long             sTimeout;
    CFBundleRef      sComponentBundle;
    CFMessagePortRef sServerPortRef;
    CFURLRef         sSharedSupportURL;
    CFURLRef         sServerURL;
    FSRef            sServerFSRef;
    FSSpec           sServerFileSpec;

    sServerPortRef    = NULL;
    sSharedSupportURL = NULL;
    sServerURL        = NULL;

    sServerPortRef = CFMessagePortCreateRemote(NULL, HanulimServerIdentifier);

    if (sServerPortRef)
    {
        CFRelease(sServerPortRef);

        return noErr;
    }

    sComponentBundle = CFBundleGetBundleWithIdentifier(HanulimIdentifier);

    if (sComponentBundle)
    {
        sSharedSupportURL = CFBundleCopySharedSupportURL(sComponentBundle);
    }

    if (sSharedSupportURL)
    {
        sServerURL = CFURLCreateCopyAppendingPathComponent(NULL,
                                                          sSharedSupportURL,
                                                          HanulimServerAppName,
                                                          false);
    }

    if (sServerURL && CFURLGetFSRef(sServerURL, &sServerFSRef))
    {
        sResult = FSGetCatalogInfo(&sServerFSRef, kFSCatInfoNone, NULL, NULL, &sServerFileSpec, NULL);
    }
    else
    {
        sResult = -2;
    }

    if (sResult == noErr)
    {
        sResult = HIMLaunchWithFSSpec(&sServerFileSpec);
    }

    sTimeout = TickCount() + 1200;

    while ((sResult == noErr) && (sServerPortRef == NULL))
    {
        Delay(1, NULL);

        sServerPortRef = CFMessagePortCreateRemote(NULL, HanulimServerIdentifier);

        if ((sServerPortRef == NULL) && TickCount() > sTimeout)
        {
            sResult = -1;
        }
    }

    if (sServerPortRef)
    {
        CFRelease(sServerPortRef);
    }

    if (sServerURL)
    {
        CFRelease(sServerURL);
    }

    if (sSharedSupportURL)
    {
        CFRelease(sSharedSupportURL);
    }

    if (sResult == -1)
    {
        fprintf(stderr,
                "HANULIM ERROR: A timeout occured while trying to launch the UI server.\n");
    }
    else if (sResult == -2)
    {
        fprintf(stderr,
                "HANULIM ERROR: Unable to locate the SharedSupport directory inside the component.\n");
    }
    else if (sResult)
    {
        fprintf(stderr,
                "HANULIM ERROR: An error of type %d occured while trying to launch the server.\n",
                (int)sResult);
    }

    return sResult;
}
