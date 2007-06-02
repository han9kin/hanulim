#include "Hanulim.h"
#include "HIMPreferences.h"


HanulimPreferences gPreferences;


Boolean HIMOverloadConsonants()
{
    return gPreferences.mKeyboardLayout == kKeyboardLayout2;
}

Boolean HIMArchaicKeyboard()
{
    return gPreferences.mKeyboardLayout == kKeyboardLayout393;
}

Boolean HIMInputConjoiningJamo()
{
    return HIMArchaicKeyboard() ? true : gPreferences.mInputConjoiningJamo;
}
