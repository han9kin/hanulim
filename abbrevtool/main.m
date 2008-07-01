/*
 * Hanulim
 * $Id$
 *
 * http://code.google.com/p/hanulim
 */

#import <Foundation/Foundation.h>


@interface NSObject (AbbrevToolCommand)

- (void)doWithArguments:(NSArray *)aArgs;

@end


int main(int argc, const char *argv[])
{
    NSAutoreleasePool *sPool;
    NSArray           *sArgs;
    NSString          *sCmd;
    Class              sClass;

    sPool = [[NSAutoreleasePool alloc] init];
    sArgs = [[NSProcessInfo processInfo] arguments];

    if ([sArgs count] > 1)
    {
        sCmd   = [sArgs objectAtIndex:1];
        sClass = NSClassFromString([NSString stringWithFormat:@"AT%@", [sCmd capitalizedString]]);

        if (sClass)
        {
            [[[[sClass alloc] init] autorelease] doWithArguments:[sArgs subarrayWithRange:NSMakeRange(2, [sArgs count] - 2)]];
        }
        else
        {
            NSLog(@"unknown command: %@", sCmd);
        }
    }

    [sPool release];

    return 0;
}
