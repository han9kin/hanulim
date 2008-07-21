/*
 * Hanulim
 * $Id$
 *
 * http://code.google.com/p/hanulim
 */

#import <Cocoa/Cocoa.h>


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
    NSString             *mFinishedString;

    int                   mSingleQuot;
    int                   mDoubleQuot;

    unsigned int          mKeyCount;
    unsigned short        mKeyBuffer[HNBufferSize];
} HNInputContext;


void HNICInitialize(HNInputContext *aContext);
void HNICFinalize(HNInputContext *aContext);

void HNICSetKeyboardLayout(HNInputContext *aContext, NSString *aName);
void HNICSetUserDefaults(HNInputContext *aContext, id<HNICUserDefaults> aUserDefaults);

BOOL HNICHandleEvent(HNInputContext *aContext, NSEvent *aEvent);

void HNICClear(HNInputContext *aContext);

NSString *HNICComposedString(HNInputContext *aContext);
NSString *HNICFinishedString(HNInputContext *aContext);
