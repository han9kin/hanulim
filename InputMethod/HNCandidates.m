/*
 * Hanulim
 * $Id$
 *
 * http://code.google.com/p/hanulim
 */

#import "HNCandidates.h"


@implementation HNCandidates

+ (id)candidatesWithExpansionManagedObjects:(NSArray *)aExpansionRecords
{
    return [[[self alloc] initWithExpansionManagedObjects:aExpansionRecords] autorelease];
}

- (id)initWithExpansionManagedObjects:(NSArray *)aExpansionRecords
{
    self = [super init];

    if (self)
    {
        mExpansions  = [[aExpansionRecords valueForKey:@"expansion"] retain];
        mAnnotations = [[NSDictionary alloc] initWithObjects:[aExpansionRecords valueForKey:@"annotation"] forKeys:mExpansions];
    }

    return self;
}

- (void)dealloc
{
    [mExpansions release];
    [mAnnotations release];

    [super dealloc];
}

- (NSArray *)expansions
{
    return mExpansions;
}

- (NSString *)annotationForString:(NSString *)aString
{
    id sAnnotation = [mAnnotations objectForKey:aString];

    if ([sAnnotation isKindOfClass:[NSString class]] && [sAnnotation length])
    {
        return sAnnotation;
    }
    else
    {
        return nil;
    }
}

@end
