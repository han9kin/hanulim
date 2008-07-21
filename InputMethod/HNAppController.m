/*
 * Hanulim
 * $Id$
 *
 * http://code.google.com/p/hanulim
 */

#import "HNAppController.h"


static HNAppController *HNAppControllerInstance = nil;


@implementation HNAppController

+ (HNAppController *)sharedInstance
{
    return HNAppControllerInstance;
}

- (void)awakeFromNib
{
    HNAppControllerInstance = self;
}

- (NSMenu *)menu
{
    return menu;
}

@end
