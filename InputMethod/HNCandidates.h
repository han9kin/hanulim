/*
 * Hanulim
 * $Id$
 *
 * http://www.osxdev.org
 * http://code.google.com/p/hanulim
 */

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>


@interface HNCandidates : NSObject
{
    IMKCandidates *mCandidates;
}

+ (HNCandidates *)sharedInstance;

- (id)initWithServer:(IMKServer *)aServer;

- (void)show;
- (void)hide;

- (NSArray *)candidatesForString:(NSString *)aString;

@end
