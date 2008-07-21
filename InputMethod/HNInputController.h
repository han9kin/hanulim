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

@end
