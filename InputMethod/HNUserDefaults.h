/*
 * Hanulim
 * $Id$
 *
 * http://code.google.com/p/hanulim
 */

#import <Cocoa/Cocoa.h>
#import "HNInputContext.h"


@interface HNUserDefaults : NSObject <HNICUserDefaults>
{
    BOOL mUsesSmartQuotationMarks;
    BOOL mInputsBackSlashInsteadOfWon;
    BOOL mHandlesCapsLockAsShift;
    BOOL mCommitsImmediately;
    BOOL mUsesDecomposedUnicode;
}

+ (HNUserDefaults *)sharedInstance;

@end
