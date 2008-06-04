/*
 * Hanulim
 * $Id$
 *
 * http://www.osxdev.org
 * http://code.google.com/p/hanulim
 */

#import <Cocoa/Cocoa.h>


/*
 * HNInputContextOption
 */
@interface NSObject (HNInputContextOption)

- (BOOL)usesSmartQuotationMarks;
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
    HNKeyboardLayout *mKeyboardLayout;
    id                mOptionDelegate;

    NSString         *mComposedString;
    NSString         *mFinishedString;

    int               mSingleQuot;
    int               mDoubleQuot;

    unsigned int      mKeyCount;
    unsigned short    mKeyBuffer[HNBufferSize];
} HNInputContext;


void HNICInitialize(HNInputContext *aContext);
void HNICFinalize(HNInputContext *aContext);

void HNICSetKeyboardLayout(HNInputContext *aContext, NSString *aName);
void HNICSetOptionDelegate(HNInputContext *aContext, id aDelegate);

BOOL HNICHandleEvent(HNInputContext *aContext, NSEvent *aEvent);

void HNICClear(HNInputContext *aContext);

NSString *HNICComposedString(HNInputContext *aContext);
NSString *HNICFinishedString(HNInputContext *aContext);
