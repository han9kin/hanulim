/*
 * Hanulim
 * $Id$
 *
 * http://code.google.com/p/hanulim
 */

#import "HNUserDefaults.h"
#import "HNDebug.h"


static NSString *HNUsesSmartQuotationMarksKey     = @"usesSmartQuotationMarks";
static NSString *HNInputsBackSlashInsteadOfWonKey = @"inputsBackSlashInsteadOfWon";
static NSString *HNHandlesCapsLockAsShiftKey      = @"handlesCapsLockAsShift";
static NSString *HNCommitsImmediatelyKey          = @"commitsImmediately";
static NSString *HNUsesDecomposedUnicodeKey       = @"usesDecomposedUnicode";


static HNUserDefaults *HNUserDefaultsInstance = nil;


@implementation HNUserDefaults

+ (HNUserDefaults *)sharedInstance
{
    if (!HNUserDefaultsInstance)
    {
        HNUserDefaultsInstance = [[self alloc] init];
    }

    return HNUserDefaultsInstance;
}

- (void)loadUserDefaults
{
    NSUserDefaults *sDefaults    = [NSUserDefaults standardUserDefaults];

    mUsesSmartQuotationMarks     = [sDefaults boolForKey:HNUsesSmartQuotationMarksKey];
    mInputsBackSlashInsteadOfWon = [sDefaults boolForKey:HNInputsBackSlashInsteadOfWonKey];
    mHandlesCapsLockAsShift      = [sDefaults boolForKey:HNHandlesCapsLockAsShiftKey];
    mCommitsImmediately          = [sDefaults boolForKey:HNCommitsImmediatelyKey];
    mUsesDecomposedUnicode       = [sDefaults boolForKey:HNUsesDecomposedUnicodeKey];
}

- (void)userDefaultsDidChange:(NSNotification *)aNotification
{
    HNLog(@"HNUserDefaults -userDefaultsDidChange:");

    [self loadUserDefaults];
}

- (id)init
{
    self = [super init];

    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsDidChange:) name:NSUserDefaultsDidChangeNotification object:[NSUserDefaults standardUserDefaults]];

        [self loadUserDefaults];
    }

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super dealloc];
}

- (BOOL)usesSmartQuotationMarks
{
    return mUsesSmartQuotationMarks;
}

- (BOOL)inputsBackSlashInsteadOfWon
{
    return mInputsBackSlashInsteadOfWon;
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
