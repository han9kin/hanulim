/*
 * Hanulim
 * $Id$
 *
 * http://www.osxdev.org
 * http://code.google.com/p/hanulim
 */

#import "HNDataController.h"


static HNDataController *HNDataControllerInstance = nil;


@implementation HNDataController

+ (HNDataController *)sharedInstance
{
    if (!HNDataControllerInstance)
    {
        HNDataControllerInstance = [[HNDataController alloc] init];
    }

    return HNDataControllerInstance;
}

- (NSString *)applicationSupportFolder
{
    NSFileManager *sFileManager;
    NSArray       *sBasePaths;
    NSString      *sBasePath;
    NSString      *sPath;

    sFileManager = [NSFileManager defaultManager];
    sBasePaths   = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    sBasePath    = ([sBasePaths count] > 0) ? [sBasePaths objectAtIndex:0] : NSTemporaryDirectory();
    sPath        = [sBasePath stringByAppendingPathComponent:@"Hanulim"];

    if (![sFileManager fileExistsAtPath:sPath isDirectory:NULL])
    {
        [sFileManager createDirectoryAtPath:sPath attributes:nil];
    }

    return sPath;
}

- (NSURL *)abbrevsDataFileURL
{
    return [NSURL fileURLWithPath:[[self applicationSupportFolder] stringByAppendingPathComponent:@"Abbrevs.db"]];
}

- (void)initManagedObjectContext
{
    NSError *sError;

    /*
     * ManagedObjectModel
     */
    mManagedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];

    /*
     * PersistentStoreCoordinator
     */
    mPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mManagedObjectModel];

    if (![mPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self abbrevsDataFileURL] options:nil error:&sError])
    {
        [[NSApplication sharedApplication] presentError:sError];
    }

    /*
     * ManagedObjectContext
     */
    mManagedObjectContext = [[NSManagedObjectContext alloc] init];
    [mManagedObjectContext setPersistentStoreCoordinator:mPersistentStoreCoordinator];
}

- (id)init
{
    self = [super init];

    if (self)
    {
        [self initManagedObjectContext];
    }

    return self;
}

- (void)dealloc
{
    [mManagedObjectContext release];
    [mPersistentStoreCoordinator release];
    [mManagedObjectModel release];

    [super dealloc];
}

- (NSManagedObjectContext *)managedObjectContext
{
    return mManagedObjectContext;
}

@end
