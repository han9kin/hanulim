/*
 * Hanulim
 * $Id$
 *
 * http://www.osxdev.org
 * http://code.google.com/p/hanulim
 */

#import "HNCandidates.h"
#import "HNDataController.h"
#import "HNDebug.h"


static HNCandidates *HNCandidatesInstance = nil;


@implementation HNCandidates

+ (HNCandidates *)sharedInstance
{
    return HNCandidatesInstance;
}

- (id)initWithServer:(IMKServer *)aServer
{
    self = [super init];

    if (self)
    {
        mCandidates = [[IMKCandidates alloc] initWithServer:aServer panelType:kIMKSingleRowSteppingCandidatePanel];

        HNCandidatesInstance = self;
    }

    return self;
}

- (void)dealloc
{
    [mCandidates release];

    [super dealloc];
}

- (void)show
{
    [mCandidates show:kIMKLocateCandidatesBelowHint];
}

- (void)hide
{
    [mCandidates hide];
}

- (NSArray *)candidatesForString:(NSString *)aString
{
    NSManagedObjectContext *sContext    = [[HNDataController sharedInstance] managedObjectContext];
    NSSortDescriptor       *sSortDesc   = [[[NSSortDescriptor alloc] initWithKey:@"expansion" ascending:YES] autorelease];
    NSFetchRequest         *sRequest    = [[[NSFetchRequest alloc] init] autorelease];
    NSArray                *sResult;
    NSError                *sError;

    [sRequest setEntity:[NSEntityDescription entityForName:@"Expansion" inManagedObjectContext:sContext]];
    [sRequest setPredicate:[NSPredicate predicateWithFormat:@"abbrev.abbrev = %@", aString]];
    [sRequest setSortDescriptors:[NSArray arrayWithObject:sSortDesc]];

    sResult = [sContext executeFetchRequest:sRequest error:&sError];

    if (sResult)
    {
        if ([sResult count])
        {
            return [sResult valueForKey:@"expansion"];
        }
    }
    else
    {
        [[NSApplication sharedApplication] presentError:sError];
    }

    return nil;
}

@end
