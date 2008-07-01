/*
 * Hanulim
 * $Id$
 *
 * http://code.google.com/p/hanulim
 */

#import "HNCandidatesController.h"
#import "HNDataController.h"
#import "HNCandidates.h"
#import "HNDebug.h"


static HNCandidatesController *HNCandidatesControllerInstance = nil;


@implementation HNCandidatesController

+ (HNCandidatesController *)sharedInstance
{
    return HNCandidatesControllerInstance;
}

- (id)initWithServer:(IMKServer *)aServer
{
    self = [super init];

    if (self)
    {
        NSSortDescriptor *sSortDesc;
        NSArray          *sSortDescs;
        NSError          *sError;

        sError = [[HNDataController sharedInstance] addPersistentStoresInDomains:NSUserDomainMask];

        if (sError)
        {
            [[NSApplication sharedApplication] presentError:sError];
        }

        mPredicate    = [[NSPredicate predicateWithFormat:@"abbrev.abbrev == $ABBREV"] retain];
        mFetchRequest = [[NSFetchRequest alloc] init];
        mCandidates   = [[IMKCandidates alloc] initWithServer:aServer panelType:kIMKSingleRowSteppingCandidatePanel];

        sSortDesc     = [[NSSortDescriptor alloc] initWithKey:@"expansion" ascending:YES];
        sSortDescs    = [[NSArray alloc] initWithObjects:sSortDesc, nil];

        [mFetchRequest setEntity:[NSEntityDescription entityForName:@"Expansion" inManagedObjectContext:[[HNDataController sharedInstance] managedObjectContext]]];
        [mFetchRequest setSortDescriptors:sSortDescs];

        [sSortDesc release];
        [sSortDescs release];

        HNCandidatesControllerInstance = self;
    }

    return self;
}

- (void)dealloc
{
    [mCandidates release];
    [mFetchRequest release];
    [mPredicate release];

    [super dealloc];
}

- (NSArray *)candidatesForString:(NSString *)aString
{
    NSDictionary *sVariables;
    NSArray      *sResult;
    NSError      *sError;

    sVariables = [[NSDictionary alloc] initWithObjectsAndKeys:aString, @"ABBREV", nil];

    [mFetchRequest setPredicate:[mPredicate predicateWithSubstitutionVariables:sVariables]];

    [sVariables release];

    sResult = [[[HNDataController sharedInstance] managedObjectContext] executeFetchRequest:mFetchRequest error:&sError];

    if (sResult)
    {
        if ([sResult count])
        {
            return [HNCandidates candidatesWithExpansionManagedObjects:sResult];
        }
    }
    else
    {
        [[NSApplication sharedApplication] presentError:sError];
    }

    return nil;
}

- (void)show
{
    [mCandidates show:kIMKLocateCandidatesBelowHint];
}

- (void)hide
{
    [mCandidates hide];
}

- (void)showAnnotation:(NSString *)aAnnotation
{
    [mCandidates showAnnotation:[[[NSAttributedString alloc] initWithString:aAnnotation] autorelease]];
}

@end
