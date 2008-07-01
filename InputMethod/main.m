/*
 * Hanulim
 * $Id$
 *
 * http://code.google.com/p/hanulim
 */

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>
#import "HNCandidatesController.h"


static NSString *HNConnectionName = @"Hanulim_1_Connection";


int main(int argc, const char *argv[])
{
    NSAutoreleasePool      *sPool;
    IMKServer              *sServer;
    HNCandidatesController *sCandidatesController;

    sPool                 = [[NSAutoreleasePool alloc] init];
    sServer               = [[IMKServer alloc] initWithName:HNConnectionName bundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]];
    sCandidatesController = [[HNCandidatesController alloc] initWithServer:sServer];

    [NSBundle loadNibNamed:@"MainMenu" owner:[NSApplication sharedApplication]];
    [[NSApplication sharedApplication] run];

    [sCandidatesController release];
    [sServer release];
    [sPool release];

    return 0;
}
