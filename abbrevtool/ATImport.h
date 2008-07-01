/*
 * Hanulim
 * $Id$
 *
 * http://code.google.com/p/hanulim
 */

#import <Cocoa/Cocoa.h>


@interface ATImport : NSObject
{
    NSPredicate     *mPredicateAbbrev;
    NSPredicate     *mPredicateExpansion;
    NSFetchRequest  *mFetchReqAbbrev;
    NSFetchRequest  *mFetchReqExpansion;

    BOOL             mUsesFilter;

    int              mProcessCount;
    int              mImportCount;
}

@end
