#ifndef Hanulim_h
#define Hanulim_h


#define HanulimIdentifier       CFSTR("org.osxdev.Hanulim")
#define HanulimServerIdentifier CFSTR("org.osxdev.Hanulim.Server")
#define HanulimServerAppName    CFSTR("HanulimServer.app")


struct HanulimPreferences
{
    unsigned short mKeyboardLayout;
    unsigned char  mFixImmediately;
    unsigned char  mSmartQuotationMarks;
    unsigned char  mHandleCapsLockAsShift;
    unsigned char  mInputConjoiningJamo;
};

typedef struct HanulimPreferences HanulimPreferences;


enum
{
    HanulimMessageActivated = 100,
    HanulimMessageDeactivated,
    HanulimMessageGetPreferences,
    HanulimMessageSetPreferences
};


#endif
