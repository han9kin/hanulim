/*
 * Hanulim
 * $Id$
 *
 * http://code.google.com/p/hanulim
 */

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>


/*
 * HNICUserDefaults
 */
@protocol HNICUserDefaults

- (BOOL)usesSmartQuotationMarks;
- (BOOL)inputsBackSlashInsteadOfWon;
- (BOOL)handlesCapsLockAsShift;
- (BOOL)commitsImmediately;
- (BOOL)usesDecomposedUnicode;

@end


/*
 * HNInputContext
 */
#define HNBufferSize 1024

typedef struct HNKeyboardLayout HNKeyboardLayout;

typedef struct HNInputContext
{
    HNKeyboardLayout     *mKeyboardLayout;
    id<HNICUserDefaults>  mUserDefaults;

    NSString             *mComposedString;

    int                   mSingleQuot;
    int                   mDoubleQuot;

    unsigned int          mKeyCount;
    unsigned short        mKeyBuffer[HNBufferSize];
} HNInputContext;


void HNICInitialize(HNInputContext *aContext);
void HNICFinalize(HNInputContext *aContext);

void HNICSetKeyboardLayout(HNInputContext *aContext, NSString *aName);
void HNICSetUserDefaults(HNInputContext *aContext, id<HNICUserDefaults> aUserDefaults);

BOOL HNICHandleKey(HNInputContext *aContext, NSString *aString, NSInteger aKeyCode, NSUInteger aModifiers, id<IMKTextInput> aClient);

void HNICCommitComposition(HNInputContext *aContext, id<IMKTextInput> aClient);
void HNICUpdateComposition(HNInputContext *aContext, id<IMKTextInput> aClient);
void HNICCancelComposition(HNInputContext *aContext);

NSString *HNICComposedString(HNInputContext *aContext);
