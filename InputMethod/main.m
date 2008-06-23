/*
 * Hanulim
 * $Id$
 *
 * http://www.osxdev.org
 * http://code.google.com/p/hanulim
 */

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>
#import "HNCandidates.h"


static NSString *HNConnectionName = @"Hanulim_1_Connection";


int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool;
    IMKServer         *server;
    HNCandidates      *candidates;

    pool       = [[NSAutoreleasePool alloc] init];
    server     = [[IMKServer alloc] initWithName:HNConnectionName bundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]];
    candidates = [[HNCandidates alloc] initWithServer:server];

    [NSBundle loadNibNamed:@"MainMenu" owner:[NSApplication sharedApplication]];
    [[NSApplication sharedApplication] run];

    [candidates release];
    [server release];
    [pool release];

    return 0;
}
