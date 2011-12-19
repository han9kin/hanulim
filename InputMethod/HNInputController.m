/*
 * Hanulim
 * $Id$
 *
 * http://code.google.com/p/hanulim
 */

#import "HNAppController.h"
#import "HNInputController.h"
#import "HNCandidatesController.h"
#import "HNUserDefaults.h"
#import "HNDebug.h"


@implementation HNInputController

- (id)initWithServer:(IMKServer *)server delegate:(id)delegate client:(id)inputClient
{
    HNLog(@"HNInputController(%@) -initWithServer:(%@) delegate:(%@) client:(%@)", self, server, delegate, inputClient);

    self = [super initWithServer:server delegate:delegate client:inputClient];

    if (self)
    {
        HNICInitialize(&mContext);
        HNICSetUserDefaults(&mContext, [HNUserDefaults sharedInstance]);

        mCandidates = nil;
    }

    return self;
}

- (void)dealloc
{
    HNLog(@"HNInputController(%@) -dealloc", self);

    HNICFinalize(&mContext);

    [mCandidates release];

    [super dealloc];
}

- (void)annotationSelected:(NSAttributedString *)annotationString forCandidate:(NSAttributedString *)candidateString
{
    HNLog(@"HNInputController(%@) -annotationSelected:(%@) forCandidate:(%@)", self, [annotationString string], [candidateString string]);
}

- (void)candidateSelectionChanged:(NSAttributedString *)candidateString
{
    NSString *sAnnotation = [mCandidates annotationForString:[candidateString string]];

    HNLog(@"HNInputController(%@) -candidateSelectionChanged:(%@)", self, [candidateString string]);

    if (sAnnotation)
    {
        [[HNCandidatesController sharedInstance] showAnnotation:sAnnotation];
    }
}

- (void)candidateSelected:(NSAttributedString *)candidateString
{
    HNLog(@"HNInputController(%@) -candidateSelected:(%@)", self, [candidateString string]);

    HNLog(@"HNInputController(%@) ## inputText:(%@)", self, [candidateString string]);

    [[self client] insertText:[candidateString string] replacementRange:NSMakeRange(NSNotFound, NSNotFound)];

    HNICCancelComposition(&mContext);
}

- (void)hidePalettes
{
    HNLog(@"HNInputController(%@) -hidePalettes", self);

    [mCandidates release];
    mCandidates = nil;

    [super hidePalettes];
}

- (NSMenu *)menu
{
    HNLog(@"HNInputController(%@) -menu", self);

    return [[HNAppController sharedInstance] menu];
}

@end


@implementation HNInputController (IMKStateSetting)

- (NSUInteger)recognizedEvents:(id)sender
{
    NSUInteger sEventMask;

    if (HNICComposedString(&mContext))
    {
        sEventMask = NSKeyDownMask | NSLeftMouseDownMask | NSRightMouseDownMask | NSOtherMouseDownMask;
    }
    else
    {
        sEventMask = NSKeyDownMask;
    }

    HNLog(@"HNInputController(%@) <IMKStateSetting>-recognizedEvents:(%@) => %lx", self, sender, (unsigned long)sEventMask);

    return sEventMask;
}

- (void)setValue:(id)value forTag:(long)tag client:(id)sender
{
    HNLog(@"HNInputController(%@) <IMKStateSetting>-setValue:(%@) forTag:(%ld) client:(%@)", self, value, tag, sender);

    if (tag == kTSMDocumentInputModePropertyTag)
    {
        HNICSetKeyboardLayout(&mContext, value);
    }
}

@end

@implementation HNInputController (IMKServerInput)

- (BOOL)inputText:(NSString *)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender
{
    BOOL      sHandled        = NO;
    BOOL      sShowCandidates = NO;
    NSString *sString;

    HNLog(@"HNInputController(%@) <IMKServerInput>-inputText:(%@) key:(%ld) modifiers:(%lu) client:(%@) [%@]", self, string, (long)keyCode, (unsigned long)flags, sender, [sender bundleIdentifier]);

    if (((flags & NSDeviceIndependentModifierFlagsMask) == NSAlternateKeyMask) && ([string characterAtIndex:0] == 0x0d))
    {
        sString = HNICComposedString(&mContext);

        if (sString)
        {
            [mCandidates release];
            mCandidates = [[[HNCandidatesController sharedInstance] candidatesForString:sString] retain];

            if (mCandidates)
            {
                sShowCandidates = YES;
                sHandled        = YES;
            }
            else 
            {
                /*
                 * 사전에서 검색이 안되었을 경우 처리 하지 않도록 함
                 */
                sShowCandidates = NO;
                sHandled        = YES;
            }
        }
    }
    else
    {
        sHandled = HNICHandleKey(&mContext, string, keyCode, flags, sender);

        [mCandidates release];
        mCandidates = nil;
    }

    if (sShowCandidates)
    {
        [[HNCandidatesController sharedInstance] show];
    }
    else
    {
        [[HNCandidatesController sharedInstance] hide];
    }

    HNLog(@"HNInputController(%@) => %@", self, sHandled ? @"YES" : @"NO");

    return sHandled;
}

- (void)commitComposition:(id)sender
{
    HNLog(@"HNInputController(%@) <IMKServerInput>-commitComposition:(%@)", self, sender);

    HNICCommitComposition(&mContext, sender);
}

- (NSArray *)candidates:(id)sender
{
    NSArray *sRet;

    HNLog(@"HNInputController(%@) <IMKServerInput>-candidates:(%@)", self, sender);

    sRet = [mCandidates expansions];

    HNLog(@"HNInputController(%@) => %@", self, sRet);

    return sRet;
}

@end

@implementation HNInputController (IMKMouseHandling)

- (BOOL)mouseDownOnCharacterIndex:(NSUInteger)index coordinate:(NSPoint)point withModifier:(NSUInteger)flags continueTracking:(BOOL *)keepTracking client:(id)sender
{
    HNLog(@"HNInputController(%@) <IMKMouseHandling>-mouseDown:", self);

    HNICCommitComposition(&mContext, sender);

    return NO;
}

@end
