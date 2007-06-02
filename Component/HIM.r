//#define UseExtendedThingResource 1
#define thng_RezTemplateVersion  1

#include <Carbon/Carbon.r>

#include "HIMScript.h"

resource 'thng' (kBaseResourceID, "Hanulim") {
    'tsvc',                                         // Type
    'inpm',                                         // SubType
    'kmdf',                                         // Manufacturer
    0, //0x8000 + kHIMScript * 0x100 + kHIMLanguage, /* 0000 8317 */
    0, //kAnyComponentFlagsMask, /* 0000 0000 */
    0, //'dlle',
    0, //kBaseResourceID,
    'STR ',                                         // Name Type
    kBaseResourceID,                                // Name ID
    'STR ',                                         // Info Type
    kBaseResourceID + 1,                            // Info ID
    0, //'ICON',                                         // Icon Type
    0, //kBaseResourceID,                                // Icon ID
    0x00010000,                                     // Version
    componentHasMultiplePlatforms,                  // Extension Flags
    0, //15872 + kHIMScript * 0x200,                     // Resource ID of Icon Family
    {
        0x8000 + kHIMScript * 0x100 + kHIMLanguage,
        'dlle',                                     // Entry point found by symbol name 'dlle' resource
        kBaseResourceID,                            // ID of 'dlle' resource
        platformPowerPCNativeEntryPoint,            // PowerPC Architecture
        0x8000 + kHIMScript * 0x100 + kHIMLanguage,
        'dlle',                                     // Entry point found by symbol name 'dlle' resource
        kBaseResourceID,                            // ID of 'dlle' resource
        platformIA32NativeEntryPoint,               // Intel Architecture
    }
};

resource 'dlle' (kBaseResourceID) {
    "HIMComponentDispatch"
};

resource 'STR ' (kBaseResourceID) {
    "Hanulim"
};

resource 'STR ' (kBaseResourceID + 1) {
    "Hanulim 1.1.  OSXDEV.ORG 2003-2007."
};

data 'cbnm' (0, "Component Bundle Name") {
    $"126f 7267 2e6f 7378 6465 762e 4861 6e75 6c69 6d"
};
