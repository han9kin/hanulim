/*
 * Hanulim
 * $Id$
 *
 * http://code.google.com/p/hanulim
 */

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>


@interface HNCandidatesController : NSObject
{
    NSPredicate    *mPredicate;
    NSFetchRequest *mFetchRequest;
    IMKCandidates  *mCandidates;
}

+ (HNCandidatesController *)sharedInstance;

- (id)initWithServer:(IMKServer *)aServer;

- (NSArray *)candidatesForString:(NSString *)aString;

- (void)show;
- (void)hide;

- (void)showAnnotation:(NSString *)aAnnotation;

@end
