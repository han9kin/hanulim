#import "Hanulim.h"
#import "HSPreferences.h"


static NSString *PKFixImmediately        = @"FixImmediately";
static NSString *PKSmartQuotationMarks   = @"SmartQuotationMarks";
static NSString *PKHandleCapsLockAsShift = @"HandleCapsLockAsShift";
static NSString *PKInputConjoiningJamo   = @"InputConjoiningJamo";


@interface HSPreferences (Private)

+ (int)intValueForKey:(NSString *)aKey defaultValue:(int)aDefaultValue;
+ (void)setIntValue:(int)aValue forKey:(NSString *)aKey;
+ (BOOL)boolValueForKey:(NSString *)aKey defaultValue:(BOOL)aDefaultValue;
+ (void)setBoolValue:(BOOL)aValue forKey:(NSString *)aKey;

@end

@implementation HSPreferences

+ (void)get:(HanulimPreferences *)aPref
{
    aPref->mFixImmediately        = [self boolValueForKey:PKFixImmediately defaultValue:YES];
    aPref->mSmartQuotationMarks   = [self boolValueForKey:PKSmartQuotationMarks defaultValue:NO];
    aPref->mHandleCapsLockAsShift = [self boolValueForKey:PKHandleCapsLockAsShift defaultValue:NO];
    aPref->mInputConjoiningJamo   = [self boolValueForKey:PKInputConjoiningJamo defaultValue:NO];
}

+ (void)set:(HanulimPreferences *)aPref
{
    [self setBoolValue:aPref->mFixImmediately forKey:PKFixImmediately];
    [self setBoolValue:aPref->mSmartQuotationMarks forKey:PKSmartQuotationMarks];
    [self setBoolValue:aPref->mHandleCapsLockAsShift forKey:PKHandleCapsLockAsShift];
    [self setBoolValue:aPref->mInputConjoiningJamo forKey:PKInputConjoiningJamo];

    CFPreferencesAppSynchronize(HanulimIdentifier);
}

@end


@implementation HSPreferences (Private)

+ (int)intValueForKey:(NSString *)aKey defaultValue:(int)aDefaultValue
{
    CFNumberRef sObj   = CFPreferencesCopyAppValue((CFStringRef)aKey, HanulimIdentifier);
    int         sValue = aDefaultValue;

    if (sObj)
    {
        if (!CFNumberGetValue(sObj, kCFNumberIntType, &sValue))
        {
            sValue = aDefaultValue;
        }

        CFRelease(sObj);
    }

    return sValue;
}

+ (void)setIntValue:(int)aValue forKey:(NSString *)aKey
{
    CFNumberRef sObj = CFNumberCreate(NULL, kCFNumberIntType, &aValue);

    CFPreferencesSetAppValue((CFStringRef)aKey, sObj, HanulimIdentifier);

    CFRelease(sObj);
}

+ (BOOL)boolValueForKey:(NSString *)aKey defaultValue:(BOOL)aDefaultValue
{
    CFBooleanRef sObj   = CFPreferencesCopyAppValue((CFStringRef)aKey, HanulimIdentifier);
    BOOL         sValue = aDefaultValue;

    if (sObj)
    {
        sValue = CFBooleanGetValue(sObj);

        CFRelease(sObj);
    }

    return sValue;
}

+ (void)setBoolValue:(BOOL)aValue forKey:(NSString *)aKey
{
    CFPreferencesSetAppValue((CFStringRef)aKey,
                             (aValue ? kCFBooleanTrue : kCFBooleanFalse),
                             HanulimIdentifier);
}

@end
