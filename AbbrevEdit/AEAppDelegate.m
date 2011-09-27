/*
 * Hanulim
 * $Id$
 *
 * http://code.google.com/p/hanulim
 */

#import "AEAppDelegate.h"
#import "HNDataController.h"


@implementation AEAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[HNDataController sharedInstance] addPersistentStoresInDomains:NSUserDomainMask];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    NSManagedObjectContext      *sContext;
    NSError                     *sError;
    NSApplicationTerminateReply  sReply;

    sContext = [[HNDataController sharedInstance] managedObjectContext];
    sReply   = NSTerminateNow;

    if (sContext != nil)
    {
        if ([sContext commitEditing])
        {
            if ([sContext hasChanges] && ![sContext save:&sError])
            {
                // This error handling simply presents error information in a panel with an
                // "Ok" button, which does not include any attempt at error recovery (meaning,
                // attempting to fix the error.)  As a result, this implementation will
                // present the information to the user and then follow up with a panel asking
                // if the user wishes to "Quit Anyway", without saving the changes.

                // Typically, this process should be altered to include application-specific
                // recovery steps.

                BOOL sErrorResult = [[NSApplication sharedApplication] presentError:sError];

                if (sErrorResult == YES)
                {
                    sReply = NSTerminateCancel;
                }
                else
                {
                    int sAlertReturn = NSRunAlertPanel(nil, @"Could not save changes while quitting. Quit anyway?" , @"Quit anyway", @"Cancel", nil);

                    if (sAlertReturn == NSAlertAlternateReturn)
                    {
                        sReply = NSTerminateCancel;
                    }
                }
            }
        }
        else
        {
            sReply = NSTerminateCancel;
        }
    }

    return sReply;
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[[HNDataController sharedInstance] managedObjectContext] undoManager];
}

- (NSManagedObjectContext *)managedObjectContext
{
    return [[HNDataController sharedInstance] managedObjectContext];
}

- (IBAction)saveAction:(id)sender
{
    NSError *error;

    if (![[[HNDataController sharedInstance] managedObjectContext] save:&error])
    {
        [[NSApplication sharedApplication] presentError:error];
    }
}

@end
