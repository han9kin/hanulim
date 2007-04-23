#ifndef Hanulim_h
#define Hanulim_h

#define HanulimIdentifier       CFSTR("org.osxdev.Hanulim")
#define HanulimServerIdentifier CFSTR("org.osxdev.Hanulim.Server")
#define HanulimServerAppName    CFSTR("HanulimServer.app")


struct HanulimPreferences {
    unsigned short keyboardLayout;
    unsigned char fixImmediately;
    unsigned char smartQuotationMarks;
    unsigned char handleCapsLockAsShift;
    unsigned char inputConjoiningJamo;
};

typedef struct HanulimPreferences HanulimPreferences;


enum {
    HanulimMessageActivated = 100,
    HanulimMessageDeactivated,
    HanulimMessageGetPreferences,
    HanulimMessageSetPreferences
};

#endif
