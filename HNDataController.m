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

- (NSError *)addPersistentStoresInDomains:(NSSearchPathDomainMask)aDomainMask
{
    NSFileManager *sFileManager;
    NSArray       *sBasePaths;
    NSString      *sBasePath;
    NSString      *sPath;
    NSArray       *sFiles;
    NSString      *sFile;
    NSURL         *sURL;
    NSError       *sError;

    sFileManager = [NSFileManager defaultManager];
    sBasePaths   = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, aDomainMask, YES);

    for (sBasePath in sBasePaths)
    {
        sPath = [sBasePath stringByAppendingPathComponent:@"Hanulim"];

        if (![sFileManager fileExistsAtPath:sPath isDirectory:NULL])
        {
            [sFileManager createDirectoryAtPath:sPath attributes:nil];
        }

        sPath = [sPath stringByAppendingPathComponent:@"Abbrevs"];

        if (![sFileManager fileExistsAtPath:sPath isDirectory:NULL])
        {
            [sFileManager createDirectoryAtPath:sPath attributes:nil];
        }

        sFiles = [sFileManager directoryContentsAtPath:sPath];

        for (sFile in sFiles)
        {
            if ([[sFile pathExtension] isEqualToString:@"db"])
            {
                sURL = [NSURL fileURLWithPath:[sPath stringByAppendingPathComponent:sFile]];

                if (![mPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:sURL options:nil error:&sError])
                {
                    return sError;
                }
            }
        }
    }

    return nil;
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
