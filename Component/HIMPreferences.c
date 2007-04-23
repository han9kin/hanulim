#include "Hanulim.h"
#include "HIMPreferences.h"

HanulimPreferences preferences;


Boolean HIMOverloadConsonants() {
    return preferences.keyboardLayout == kKeyboardLayout2;
}

Boolean HIMArchaicKeyboard() {
    return preferences.keyboardLayout == kKeyboardLayout393;
}

Boolean HIMInputConjoiningJamo() {
    return HIMArchaicKeyboard() ? true : preferences.inputConjoiningJamo;
}
