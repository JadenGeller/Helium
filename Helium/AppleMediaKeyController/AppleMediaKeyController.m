//
//  AppleMediaKeyController.m
//
//  Modified by Gaurav Khanna on 8/17/10.
//  SOURCE: http://github.com/sweetfm/SweetFM/blob/master/Source/HMediaKeys.m
//  SOURCE: http://stackoverflow.com/questions/2969110/cgeventtapcreate-breaks-down-mysteriously-with-key-down-events
//
//
//  Permission is hereby granted, free of charge, to any person 
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without restriction,
//  including without limitation the rights to use, copy, modify, 
//  merge, publish, distribute, sublicense, and/or sell copies of 
//  the Software, and to permit persons to whom the Software is 
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be 
//  included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR 
//  ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
//  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "AppleMediaKeyController.h"

NSString * const MediaKeyPlayPauseNotification = @"MediaKeyPlayPauseNotification";
NSString * const MediaKeyNextNotification = @"MediaKeyNextNotification";
NSString * const MediaKeyPreviousNotification = @"MediaKeyPreviousNotification";

#define NX_KEYSTATE_UP      0x0A
#define NX_KEYSTATE_DOWN    0x0B

@implementation AppleMediaKeyController

@synthesize eventPort = _eventPort;

CGEventRef tapEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {
    if(type == kCGEventTapDisabledByTimeout)
        CGEventTapEnable([[AppleMediaKeyController sharedController] eventPort], TRUE);
    
    if(type != NX_SYSDEFINED) 
        return event;

	NSEvent *nsEvent = [NSEvent eventWithCGEvent:event];
    
    if([nsEvent subtype] != 8) 
        return event;
    
    int data = [nsEvent data1];
    int keyCode = (data & 0xFFFF0000) >> 16;
    int keyFlags = (data & 0xFFFF);
    int keyState = (keyFlags & 0xFF00) >> 8;
    BOOL keyIsRepeat = (keyFlags & 0x1) > 0;
    
    if(keyIsRepeat) 
        return event;
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    switch (keyCode) {
        case NX_KEYTYPE_PLAY:
            if(keyState == NX_KEYSTATE_DOWN)
                [center postNotificationName:MediaKeyPlayPauseNotification object:nil];
            if(keyState == NX_KEYSTATE_UP || keyState == NX_KEYSTATE_DOWN)
                return NULL;
        break;
        case NX_KEYTYPE_FAST:
            if(keyState == NX_KEYSTATE_DOWN)
                [center postNotificationName:MediaKeyNextNotification object:nil];
            if(keyState == NX_KEYSTATE_UP || keyState == NX_KEYSTATE_DOWN)
                return NULL;
        break;
        case NX_KEYTYPE_REWIND:
            if(keyState == NX_KEYSTATE_DOWN)
                [center postNotificationName:MediaKeyPreviousNotification object:nil];
            if(keyState == NX_KEYSTATE_UP || keyState == NX_KEYSTATE_DOWN)
                return NULL;
        break;
    }
    return event;
}

- (id)init {
    if(self = [super init]) {
        CFRunLoopRef runLoop;

        _eventPort = CGEventTapCreate(kCGSessionEventTap,
                                      kCGHeadInsertEventTap,
                                      kCGEventTapOptionDefault,
                                      CGEventMaskBit(NX_SYSDEFINED),
                                      tapEventCallback,
                                      (__bridge void * _Nullable)(self));

        if(_eventPort == NULL) {
            NSLog(@"Fatal Error: Event Tap could not be created");
            return self;
        }

        _runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorSystemDefault, _eventPort, 0);

        if(_runLoopSource == NULL) {
            NSLog(@"Fatal Error: Run Loop Source could not be created");
            return self;
        }

        runLoop = CFRunLoopGetCurrent();

        if(runLoop == NULL) {
            NSLog(@"Fatal Error: Couldn't get current threads Run Loop");
            return self;
        }

        CFRunLoopAddSource(runLoop, _runLoopSource, kCFRunLoopCommonModes);
    }
    return self;
}

- (void)dealloc {
    CFRelease(_eventPort);
    CFRelease(_runLoopSource);
}

@end
