/*
 * Hanulim
 * $Id$
 *
 * http://code.google.com/p/hanulim
 */

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>


@interface HNAppController : NSObject
{
    IBOutlet NSMenu *menu;
}

+ (HNAppController *)sharedInstance;

- (NSMenu *)menu;

@end
