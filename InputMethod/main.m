/*
 * Hanulim
 * $Id$
 *
 * http://code.google.com/p/hanulim
 */

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>
#import "HNCandidatesController.h"


int main(int argc, const char *argv[])
{
    NSAutoreleasePool      *sPool;
    NSBundle               *sBundle;
    NSString               *sConnectionName;
    IMKServer              *sServer;
    HNCandidatesController *sCandidatesController;

    sPool                 = [[NSAutoreleasePool alloc] init];

    sBundle               = [NSBundle mainBundle];
    sConnectionName       = [[sBundle infoDictionary] objectForKey:@"InputMethodConnectionName"];

    sServer               = [[IMKServer alloc] initWithName:sConnectionName bundleIdentifier:[sBundle bundleIdentifier]];
    sCandidatesController = [[HNCandidatesController alloc] initWithServer:sServer];

    [NSBundle loadNibNamed:@"MainMenu" owner:[NSApplication sharedApplication]];

    [[NSApplication sharedApplication] run];

    [sCandidatesController release];
    [sServer release];
    [sPool release];

    return 0;
}
