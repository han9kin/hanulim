/*
 * Hanulim
 * $Id$
 *
 * http://www.osxdev.org
 * http://code.google.com/p/hanulim
 */

#import "HNAppController.h"


static NSString *HNUsesSmartQuotationMarksKey = @"usesSmartQuotationMarks";
static NSString *HNHandlesCapsLockAsShiftKey  = @"handlesCapsLockAsShift";
static NSString *HNCommitsImmediatelyKey      = @"commitsImmediately";
static NSString *HNUsesDecomposedUnicodeKey   = @"usesDecomposedUnicode";


static HNAppController *HNAppControllerInstance = nil;


@implementation HNAppController

+ (HNAppController *)sharedInstance
{
    return HNAppControllerInstance;
}

- (void)awakeFromNib
{
    NSUserDefaults *sDefaults = [NSUserDefaults standardUserDefaults];

    mUsesSmartQuotationMarks  = [sDefaults boolForKey:HNUsesSmartQuotationMarksKey];
    mHandlesCapsLockAsShift   = [sDefaults boolForKey:HNHandlesCapsLockAsShiftKey];
    mCommitsImmediately       = [sDefaults boolForKey:HNCommitsImmediatelyKey];
    mUsesDecomposedUnicode    = [sDefaults boolForKey:HNUsesDecomposedUnicodeKey];

    [smartQuotationMarkMenu setState:(mUsesSmartQuotationMarks ? NSOnState : NSOffState)];
    [capsLockMenu           setState:(mHandlesCapsLockAsShift  ? NSOnState : NSOffState)];
    [commitMenu             setState:(mCommitsImmediately      ? NSOnState : NSOffState)];
    [decomposedUnicodeMenu  setState:(mUsesDecomposedUnicode   ? NSOnState : NSOffState)];

    HNAppControllerInstance = self;
}

- (NSMenu *)menu
{
    return menu;
}

- (void)toggleUsesSmartQuotationMarks
{
    mUsesSmartQuotationMarks = mUsesSmartQuotationMarks ? NO : YES;

    [[NSUserDefaults standardUserDefaults] setBool:mUsesSmartQuotationMarks forKey:HNUsesSmartQuotationMarksKey];

    [smartQuotationMarkMenu setState:(mUsesSmartQuotationMarks ? NSOnState : NSOffState)];
}

- (void)toggleHandlesCapsLockAsShift
{
    mHandlesCapsLockAsShift = mHandlesCapsLockAsShift ? NO : YES;

    [[NSUserDefaults standardUserDefaults] setBool:mHandlesCapsLockAsShift forKey:HNHandlesCapsLockAsShiftKey];

    [capsLockMenu setState:(mHandlesCapsLockAsShift ? NSOnState : NSOffState)];
}

- (void)toggleCommitsImmediately
{
    mCommitsImmediately = mCommitsImmediately ? NO : YES;

    [[NSUserDefaults standardUserDefaults] setBool:mCommitsImmediately forKey:HNCommitsImmediatelyKey];

    [commitMenu setState:(mCommitsImmediately ? NSOnState : NSOffState)];
}

- (void)toggleUsesDecomposedUnicode
{
    mUsesDecomposedUnicode = mUsesDecomposedUnicode ? NO : YES;

    [[NSUserDefaults standardUserDefaults] setBool:mUsesDecomposedUnicode forKey:HNUsesDecomposedUnicodeKey];

    [decomposedUnicodeMenu setState:(mUsesDecomposedUnicode ? NSOnState : NSOffState)];
}

@end

@implementation HNAppController (HNInputContextOption)

- (BOOL)usesSmartQuotationMarks
{
    return mUsesSmartQuotationMarks;
}

- (BOOL)handlesCapsLockAsShift
{
    return mHandlesCapsLockAsShift;
}

- (BOOL)commitsImmediately
{
    return mCommitsImmediately;
}

- (BOOL)usesDecomposedUnicode
{
    return mUsesDecomposedUnicode;
}

@end
