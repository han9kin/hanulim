/*
 * Hanulim
 * $Id$
 *
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

- (void)initManagedObjectContext
{
    /*
     * ManagedObjectModel
     */
    mManagedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];

    /*
     * PersistentStoreCoordinator
     */
    mPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mManagedObjectModel];

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

- (void)addPersistentStoresInDomains:(NSSearchPathDomainMask)aDomainMask
{
    NSFileManager *sFileManager;
    NSString      *sBasePath;

    sFileManager = [[NSFileManager alloc] init];

    for (sBasePath in NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, aDomainMask, YES))
    {
        NSString *sPath = [[sBasePath stringByAppendingPathComponent:@"Hanulim"] stringByAppendingPathComponent:@"Abbrevs"];

        [sFileManager createDirectoryAtPath:sPath withIntermediateDirectories:YES attributes:nil error:NULL];

        for (NSString *sFile in [sFileManager contentsOfDirectoryAtPath:sPath error:NULL])
        {
            if ([[sFile pathExtension] isEqualToString:@"db"])
            {
                NSURL   *sURL = [NSURL fileURLWithPath:[sPath stringByAppendingPathComponent:sFile]];
                NSError *sError;

                if (![mPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:sURL options:nil error:&sError])
                {
                    NSLog(@"adding database file failed at (%@) error: %@", [sURL path], sError);
                }
            }
        }
    }
}

- (NSError *)addPersistentStoreAtPath:(NSString *)aPath
{
    NSError *sError;

    if (![mPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:aPath] options:nil error:&sError])
    {
        return sError;
    }

    return nil;
}

- (NSManagedObjectContext *)managedObjectContext
{
    return mManagedObjectContext;
}

@end
