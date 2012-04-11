// Copyright (c) 2010 Spotify AB
#import "SPMediaKeyTap.h"
#import "NSObject+SPInvocationGrabbing.h" // https://gist.github.com/511181, in submodule

@interface SPMediaKeyTap ()
+ (NSSet *)defaultAvoidedMediaKeyProcesses;
-(BOOL)shouldInterceptMediaKeyEvents;
-(void)setShouldInterceptMediaKeyEvents:(BOOL)newSetting;
-(void)eventTapThread;
@end
static SPMediaKeyTap *singleton = nil;

static pascal OSStatus appSwitched (EventHandlerCallRef nextHandler, EventRef evt, void* userData);
static pascal OSStatus appTerminated (EventHandlerCallRef nextHandler, EventRef evt, void* userData);
static CGEventRef tapEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon);


// Inspired by http://gist.github.com/546311

@implementation SPMediaKeyTap

#pragma mark -
#pragma mark Setup and teardown
-(id)initWithDelegate:(id)delegate;
{
	_delegate = delegate;
	singleton = self;
	_mediaKeyAppList = [NSMutableArray new];
    _tapThreadRL=nil;
    _eventPort=nil;
    _eventPortSource=nil;
	return self;
}
-(void)dealloc;
{
	[self stopWatchingMediaKeys];
	[_mediaKeyAppList release];
	[super dealloc];
}

-(void)startWatchingMediaKeys;{
    // Prevent having multiple mediaKeys threads
    [self stopWatchingMediaKeys];
    
	[self setShouldInterceptMediaKeyEvents:YES];
	
	// Add an event tap to intercept the system defined media key events
	_eventPort = CGEventTapCreate(kCGSessionEventTap,
								  kCGHeadInsertEventTap,
								  kCGEventTapOptionDefault,
								  CGEventMaskBit(NX_SYSDEFINED),
								  tapEventCallback,
								  self);
	assert(_eventPort != NULL);
	
    _eventPortSource = CFMachPortCreateRunLoopSource(kCFAllocatorSystemDefault, _eventPort, 0);
	assert(_eventPortSource != NULL);
	
	// Let's do this in a separate thread so that a slow app doesn't lag the event tap
	[NSThread detachNewThreadSelector:@selector(eventTapThread) toTarget:self withObject:nil];
}
-(void)stopWatchingMediaKeys;
{
	// TODO<nevyn>: Shut down thread, remove event tap port and source
    
    if(_tapThreadRL){
        CFRunLoopStop(_tapThreadRL);
        _tapThreadRL=nil;
    }
    
    if(_eventPort){
        CFMachPortInvalidate(_eventPort);
        CFRelease(_eventPort);
        _eventPort=nil;
    }
    
    if(_eventPortSource){
        CFRelease(_eventPortSource);
        _eventPortSource=nil;
    }
}

#pragma mark -
#pragma mark Accessors

+(BOOL)usesGlobalMediaKeyTap
{
#ifdef _DEBUG
	// breaking in gdb with a key tap inserted sometimes locks up all mouse and keyboard input forever, forcing reboot
	return NO;
#else
	// XXX(nevyn): MediaKey event tap doesn't work on 10.4, feel free to figure out why if you have the energy.
	return 
		![[NSUserDefaults standardUserDefaults] boolForKey:kIgnoreMediaKeysDefaultsKey]
		&& floor(NSAppKitVersionNumber) >= 949/*NSAppKitVersionNumber10_5*/;
#endif
}

+ (NSSet *)defaultAvoidedMediaKeyProcesses
{
    static NSSet *returnSet = nil; 
    if (returnSet == nil) {
        NSURL *plistURL = [[NSBundle mainBundle] URLForResource:@"IgnoredAudioProcesses" withExtension:@"plist"];
        NSArray *storedArray = [NSArray arrayWithContentsOfURL:plistURL];
        returnSet = [[NSSet setWithArray:storedArray] retain];
    }

    return returnSet;
}


-(BOOL)shouldInterceptMediaKeyEvents;
{
	BOOL shouldIntercept = NO;
	@synchronized(self) {
		shouldIntercept = _shouldInterceptMediaKeyEvents;
	}
	return shouldIntercept;
}

-(void)pauseTapOnTapThread:(BOOL)yeahno;
{
	CGEventTapEnable(self->_eventPort, yeahno);
}
-(void)setShouldInterceptMediaKeyEvents:(BOOL)newSetting;
{
	BOOL oldSetting;
	@synchronized(self) {
		oldSetting = _shouldInterceptMediaKeyEvents;
		_shouldInterceptMediaKeyEvents = newSetting;
	}
	if(_tapThreadRL && oldSetting != newSetting) {
		id grab = [self grab];
		[grab pauseTapOnTapThread:newSetting];
		NSTimer *timer = [NSTimer timerWithTimeInterval:0 invocation:[grab invocation] repeats:NO];
		CFRunLoopAddTimer(_tapThreadRL, (CFRunLoopTimerRef)timer, kCFRunLoopCommonModes);
	}
}

#pragma mark 
#pragma mark -
#pragma mark Event tap callbacks

// Note: method called on background thread

static CGEventRef tapEventCallback2(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon)
{
    SPMediaKeyTap *self = refcon;
    if(type == kCGEventTapDisabledByTimeout) {
		NSLog(@"Media key event tap was disabled by timeout");
		CGEventTapEnable(self->_eventPort, TRUE);
		return event;
	} else if(type == kCGEventTapDisabledByUserInput) {
		// Was disabled manually by -[pauseTapOnTapThread]
		return event;
	}
	NSEvent *nsEvent = nil;
	@try {
		nsEvent = [NSEvent eventWithCGEvent:event];
	}
	@catch (NSException * e) {
		NSLog(@"Strange CGEventType: %d: %@", type, e);
		assert(0);
		return event;
	}

	if (type != NX_SYSDEFINED || [nsEvent subtype] != SPSystemDefinedEventMediaKeys)
		return event;

	int keyCode = (([nsEvent data1] & 0xFFFF0000) >> 16);
	if (keyCode != NX_KEYTYPE_PLAY && keyCode != NX_KEYTYPE_FAST && keyCode != NX_KEYTYPE_REWIND)
		return event;

	if (![self shouldInterceptMediaKeyEvents])
		return event;
    
    ProcessSerialNumber psn = {0, kNoProcess};
	unsigned char proc_name[512];
	ProcessInfoRec pir = {0};
	pir.processInfoLength = sizeof(pir);
	pir.processName = proc_name;
    
	OSErr err;
    
	while((err = GetNextProcess(&psn)) == noErr) {
		bzero(proc_name, 512 * sizeof(char));
		if ((err = GetProcessInformation(&psn, &pir)) == noErr) {
            for (NSString *audioProcess in [self.class defaultAvoidedMediaKeyProcesses]) {
                NSString *processName = [NSString stringWithUTF8String:(const char *)proc_name+1];
                if ([processName isEqualToString:audioProcess])
                    return event;
            }
		}		
	}
	
	[nsEvent retain]; // matched in handleAndReleaseMediaKeyEvent:
	[self performSelectorOnMainThread:@selector(handleAndReleaseMediaKeyEvent:) withObject:nsEvent waitUntilDone:NO];
	
	return NULL;
}

static CGEventRef tapEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon)
{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	CGEventRef ret = tapEventCallback2(proxy, type, event, refcon);
	[pool drain];
	return ret;
}


// event will have been retained in the other thread
-(void)handleAndReleaseMediaKeyEvent:(NSEvent *)event {
	[event autorelease];
	
	[_delegate mediaKeyTap:self receivedMediaKeyEvent:event];
}


-(void)eventTapThread;
{
	_tapThreadRL = CFRunLoopGetCurrent();
	CFRunLoopAddSource(_tapThreadRL, _eventPortSource, kCFRunLoopCommonModes);
	CFRunLoopRun();
}

#pragma mark Task switching callbacks

NSString *kMediaKeyUsingBundleIdentifiersDefaultsKey = @"SPApplicationsNeedingMediaKeys";
NSString *kIgnoreMediaKeysDefaultsKey = @"SPIgnoreMediaKeys";



@end
