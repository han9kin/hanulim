/*
 * Hanulim
 * $Id$
 *
 * http://code.google.com/p/hanulim
 */

#import <Cocoa/Cocoa.h>


@interface HNDataController : NSObject
{
    NSPersistentStoreCoordinator *mPersistentStoreCoordinator;
    NSManagedObjectModel         *mManagedObjectModel;
    NSManagedObjectContext       *mManagedObjectContext;
}

+ (HNDataController *)sharedInstance;

- (void)addPersistentStoresInDomains:(NSSearchPathDomainMask)aDomainMask;
- (NSError *)addPersistentStoreAtPath:(NSString *)aPath;

- (NSManagedObjectContext *)managedObjectContext;

@end
