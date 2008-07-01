/*
 * Hanulim
 * $Id$
 *
 * http://code.google.com/p/hanulim
 */

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>
#import "HNInputContext.h"
#import "HNCandidates.h"


@interface HNInputController : IMKInputController
{
    HNInputContext  mContext;
    HNCandidates   *mCandidates;
}

- (IBAction)toggleUsesSmartQuotationMarks:(id)sender;
- (IBAction)toggleHandlesCapsLockAsShift:(id)sender;
- (IBAction)toggleCommitsImmediately:(id)sender;
- (IBAction)toggleUsesDecomposedUnicode:(id)sender;

@end
