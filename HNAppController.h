/*
 * Hanulim
 * $Id$
 *
 * http://www.osxdev.org
 * http://code.google.com/p/hanulim
 */

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>


@interface HNAppController : NSObject
{
    IBOutlet NSMenu     *menu;

    IBOutlet NSMenuItem *smartQuotationMarkMenu;
    IBOutlet NSMenuItem *capsLockMenu;
    IBOutlet NSMenuItem *commitMenu;
    IBOutlet NSMenuItem *decomposedUnicodeMenu;


    BOOL mUsesSmartQuotationMarks;
    BOOL mHandlesCapsLockAsShift;
    BOOL mCommitsImmediately;
    BOOL mUsesDecomposedUnicode;
}

+ (HNAppController *)sharedInstance;

- (NSMenu *)menu;

- (void)toggleUsesSmartQuotationMarks;
- (void)toggleHandlesCapsLockAsShift;
- (void)toggleCommitsImmediately;
- (void)toggleUsesDecomposedUnicode;

@end
