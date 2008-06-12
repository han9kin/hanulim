/*
 * Hanulim
 * $Id$
 *
 * http://www.osxdev.org
 * http://code.google.com/p/hanulim
 */

#import "HNAppController.h"
#import "HNInputController.h"
#import "HNDebug.h"


@implementation HNInputController

- (id)initWithServer:(IMKServer *)server delegate:(id)delegate client:(id)inputClient
{
    HNLog(@"HNInputController -initWithServer:delegate:client:");

    self = [super initWithServer:server delegate:delegate client:inputClient];

    if (self)
    {
        HNICInitialize(&mContext);
        HNICSetOptionDelegate(&mContext, [HNAppController sharedInstance]);
    }

    return self;
}

- (void)dealloc
{
    HNLog(@"HNInputController -dealloc");

    HNICFinalize(&mContext);

    [super dealloc];
}

- (NSMenu *)menu
{
    HNLog(@"HNInputController -menu");

    return [[HNAppController sharedInstance] menu];
}

- (IBAction)toggleUsesSmartQuotationMarks:(id)sender
{
    [[HNAppController sharedInstance] toggleUsesSmartQuotationMarks];
}

- (IBAction)toggleHandlesCapsLockAsShift:(id)sender
{
    [[HNAppController sharedInstance] toggleHandlesCapsLockAsShift];
}

- (IBAction)toggleCommitsImmediately:(id)sender
{
    [[HNAppController sharedInstance] toggleCommitsImmediately];
}

- (IBAction)toggleUsesDecomposedUnicode:(id)sender
{
    [[HNAppController sharedInstance] toggleUsesDecomposedUnicode];
}

@end

@implementation HNInputController (IMKStateSetting)

- (void)activateServer:(id)sender
{
    HNLog(@"HNInputController<IMKStateSetting> -activateServer:");

    [super activateServer:sender];
}

- (void)deactivateServer:(id)sender
{
    HNLog(@"HNInputController<IMKStateSetting> -deactivateServer:");

    [super deactivateServer:sender];
}

- (void)showPreferences:(id)sender
{
    HNLog(@"HNInputController<IMKStateSetting> -showPreferences:");

    [super showPreferences:sender];
}

- (NSUInteger)recognizedEvents:(id)sender
{
    HNLog(@"HNInputController<IMKStateSetting> -recognizedEvents:");

    if (HNICComposedString(&mContext))
    {
        return NSKeyDownMask | NSLeftMouseDownMask | NSRightMouseDownMask | NSOtherMouseDownMask;
    }
    else
    {
        return NSKeyDownMask;
    }
}

- (NSDictionary *)modes:(id)sender
{
    id ret;

    HNLog(@"HNInputController<IMKStateSetting> -modes:");

    ret = [super modes:sender];

    HNLog(@" => %@", ret);

    return ret;
}

- (id)valueForTag:(long)tag client:(id)sender
{
    id ret = [super valueForTag:tag client:sender];

    HNLog(@"HNInputController<IMKStateSetting> -valueForTag:%d => %@", tag, ret);

    return ret;
}

- (void)setValue:(id)value forTag:(long)tag client:(id)sender
{
    HNLog(@"HNInputController<IMKStateSetting> -setValue:%@ forTag:%d client:", value, tag);

    if (tag == kTSMDocumentInputModePropertyTag)
    {
        HNICSetKeyboardLayout(&mContext, value);
    }
}

@end

@implementation HNInputController (IMKServerInput)

- (BOOL)handleEvent:(NSEvent *)event client:(id)sender
{
    HNLog(@"HNInputController<IMKServerInput> -handleEvent:client:");
    HNLog(@" <= %@", event);

    if ([event type] == NSKeyDown)
    {
        BOOL      sHandled = HNICHandleEvent(&mContext, event);
        NSString *sString  = HNICFinishedString(&mContext);

        if (sString)
        {
            HNLog(@" inputText: (%@)", sString);

            [sender insertText:sString replacementRange:NSMakeRange(NSNotFound, NSNotFound)];

            [self updateComposition];
        }
        else if (sHandled)
        {
            [self updateComposition];
        }

        HNLog(@" => %@", sHandled ? @"YES" : @"NO");

        return sHandled;
    }
    else
    {
        [self commitComposition:sender];

        HNLog(@" => UNHANDLED NO");

        return NO;
    }
}

- (void)commitComposition:(id)sender
{
    NSString *sString = HNICComposedString(&mContext);

    HNLog(@"HNInputController<IMKServerInput> -commitComposition:");

    if (sString)
    {
        HNLog(@" inputText: (%@)", sString);

        [sender insertText:sString replacementRange:NSMakeRange(NSNotFound, NSNotFound)];

        HNICClear(&mContext);
    }
}

- (id)composedString:(id)sender
{
    NSString *sString = HNICComposedString(&mContext);

    HNLog(@"HNInputController<IMKServerInput> -composedString: (%@)", sString ? sString : @"");

    return sString ? sString : @"";
}

- (NSAttributedString *)originalString:(id)sender
{
    HNLog(@"HNInputController<IMKServerInput> -originalString:");

    return nil;
}

- (NSArray *)candidates:(id)sender
{
    HNLog(@"HNInputController<IMKServerInput> -candidates:");

    return nil;
}

@end

@implementation HNInputController (IMKMouseHandling)

- (BOOL)mouseDownOnCharacterIndex:(NSUInteger)index coordinate:(NSPoint)point withModifier:(NSUInteger)flags continueTracking:(BOOL *)keepTracking client:(id)sender
{
    HNLog(@"HNInputController<IMKMouseHandling> -mouseDown");

    [self commitComposition:sender];

    return NO;
}

@end
