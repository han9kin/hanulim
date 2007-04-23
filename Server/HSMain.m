#import <Cocoa/Cocoa.h>
#import "HSMessageReceive.h"


int main(int argc, const char *argv[])
{
    [NSApplication sharedApplication];
    HSRegisterServerToRunLoop([[NSRunLoop currentRunLoop] getCFRunLoop]);
    [NSApp run];
    return 0;
}
