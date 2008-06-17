/*
 * Hanulim
 * $Id$
 *
 * http://www.osxdev.org
 * http://code.google.com/p/hanulim
 */

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>


static NSString *HNConnectionName = @"Hanulim_1_Connection";


int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    IMKServer         *server;

    server = [[IMKServer alloc] initWithName:HNConnectionName bundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]];

    [NSBundle loadNibNamed:@"MainMenu" owner:[NSApplication sharedApplication]];

    [[NSApplication sharedApplication] run];

    [pool release];

    return 0;
}
