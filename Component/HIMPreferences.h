#ifndef HIMPreferences_h
#define HIMPreferences_h

#include <Carbon/Carbon.h>

enum {
    kKeyboardLayout2 = 0,
    kKeyboardLayout3,
    kKeyboardLayout390,
    kKeyboardLayout393
};


extern HanulimPreferences preferences;


Boolean HIMOverloadConsonants();
Boolean HIMArchaicKeyboard();
Boolean HIMInputConjoiningJamo();

#endif
