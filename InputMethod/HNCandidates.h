/*
 * Hanulim
 * $Id$
 *
 * http://code.google.com/p/hanulim
 */

#import <Cocoa/Cocoa.h>


@interface HNCandidates : NSObject
{
    NSArray      *mExpansions;
    NSDictionary *mAnnotations;
}

+ (id)candidatesWithExpansionManagedObjects:(NSArray *)aExpansionRecords;

- (id)initWithExpansionManagedObjects:(NSArray *)aExpansionRecords;

- (NSArray *)expansions;
- (NSString *)annotationForString:(NSString *)aString;

@end
