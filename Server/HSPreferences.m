#import "Hanulim.h"
#import "HSPreferences.h"


static NSString *PKKeyboardLayout = @"KeyboardLayout";
static NSString *PKFixImmediately = @"FixImmediately";
static NSString *PKSmartQuotationMarks = @"SmartQuotationMarks";
static NSString *PKHandleCapsLockAsShift = @"HandleCapsLockAsShift";
static NSString *PKInputConjoiningJamo = @"InputConjoiningJamo";


@interface HSPreferences (Private)

+ (int)intValueForKey:(NSString *)key defaultValue:(int)defaultValue;
+ (void)setIntValue:(int)value forKey:(NSString *)key;
+ (BOOL)boolValueForKey:(NSString *)key defaultValue:(BOOL)defaultValue;
+ (void)setBoolValue:(BOOL)value forKey:(NSString *)key;

@end

@implementation HSPreferences

+ (void)get:(HanulimPreferences *)pref {
    pref->keyboardLayout = [self intValueForKey:PKKeyboardLayout defaultValue:0];
    pref->fixImmediately = [self boolValueForKey:PKFixImmediately defaultValue:YES];
    pref->smartQuotationMarks = [self boolValueForKey:PKSmartQuotationMarks defaultValue:NO];
    pref->handleCapsLockAsShift = [self boolValueForKey:PKHandleCapsLockAsShift defaultValue:NO];
    pref->inputConjoiningJamo = [self boolValueForKey:PKInputConjoiningJamo defaultValue:NO];
}

+ (void)set:(HanulimPreferences *)pref {
    [self setIntValue:pref->keyboardLayout forKey:PKKeyboardLayout];
    [self setBoolValue:pref->fixImmediately forKey:PKFixImmediately];
    [self setBoolValue:pref->smartQuotationMarks forKey:PKSmartQuotationMarks];
    [self setBoolValue:pref->handleCapsLockAsShift forKey:PKHandleCapsLockAsShift];
    [self setBoolValue:pref->inputConjoiningJamo forKey:PKInputConjoiningJamo];
    CFPreferencesAppSynchronize(HanulimIdentifier);
}

@end


@implementation HSPreferences (Private)

+ (int)intValueForKey:(NSString *)key defaultValue:(int)defaultValue {
    CFNumberRef obj = CFPreferencesCopyAppValue((CFStringRef)key, HanulimIdentifier);
    int value = defaultValue;
    
    if (obj) {
        if (!CFNumberGetValue(obj, kCFNumberIntType, &value))
            value = defaultValue;
        CFRelease(obj);
    }
    return value;
}

+ (void)setIntValue:(int)value forKey:(NSString *)key {
    CFNumberRef obj = CFNumberCreate(NULL, kCFNumberIntType, &value);
    CFPreferencesSetAppValue((CFStringRef)key, obj, HanulimIdentifier);
    CFRelease(obj);
}

+ (BOOL)boolValueForKey:(NSString *)key defaultValue:(BOOL)defaultValue {
    CFBooleanRef obj = CFPreferencesCopyAppValue((CFStringRef)key, HanulimIdentifier);
    BOOL value = defaultValue;
    
    if (obj) {
        value = CFBooleanGetValue(obj);
        CFRelease(obj);
    }
    return value;
}

+ (void)setBoolValue:(BOOL)value forKey:(NSString *)key {
    CFPreferencesSetAppValue((CFStringRef)key, (value ? kCFBooleanTrue : kCFBooleanFalse), HanulimIdentifier);
}

@end
