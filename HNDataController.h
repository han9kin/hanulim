/*
 * Hanulim
 * $Id$
 *
 * http://www.osxdev.org
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

- (NSManagedObjectContext *)managedObjectContext;

@end
