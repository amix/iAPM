#import "iAMPController.h"

@implementation iAMPController

CGEventRef callback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *vp) {
	@try {
		iAMPController* controller = (iAMPController*)vp;
		[controller registerEvent:type];
	}
	@catch (NSException *exception) {
		NSLog(@"callback: Caught %@: %@", [exception name], [exception reason]);
	}
    return event; 
}

- (void) registerEvent:(CGEventType)event_type
{
	actions_1_sec_counter += 1;
	actions_60_sec_counter += 1;
}

- (void) updateSecCounter:(id)sender {
	long actions_last_1_sec = (actions_1_sec_counter * 60);
		
	NSString *s_title;
	if(last_60_sec != 0) {
		s_title = [NSString stringWithFormat:@"%u (%u)", last_60_sec, actions_last_1_sec];
	}
	else {
		s_title = [NSString stringWithFormat:@"... (%u)", actions_last_1_sec];
	}
	[statusItem setTitle:s_title];
	
	actions_1_sec_counter = 0;
}

- (void) updateMinCounter:(id)sender {
	last_60_sec = actions_60_sec_counter;
	actions_60_sec_counter = 0;
}

- (void) resetCounts:(id)sender {
	actions_60_sec_counter = 0;
	actions_1_sec_counter = 0;
	last_60_sec = 0;
	[self updateSecCounter:sender];
}


- (void) awakeFromNib {
	//Initialize counters
	actions_1_sec_counter = 0;
	last_60_sec = 0;
	actions_60_sec_counter = 0;
	
	//Setup status item
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	
	NSBundle *bundle = [NSBundle mainBundle];
	
	statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon" ofType:@"png"]];
	
	[statusItem setImage:statusImage];
	[statusItem setTitle:@"..."];
	
	[statusItem setMenu:statusMenu];
	[statusItem setToolTip:@"iAPM"];
	[statusItem setHighlightMode:YES];
	
	//Register an event tap
	CFMachPortRef eventTap;  
    CFRunLoopSourceRef runLoopSource; 
	
    eventTap = CGEventTapCreate(kCGSessionEventTap,
								kCGHeadInsertEventTap, 
								0, 
								CGEventMaskBit(kCGEventLeftMouseDown) |
								CGEventMaskBit(kCGEventRightMouseDown) | 
								CGEventMaskBit(kCGEventKeyDown) | 
								CGEventMaskBit(kCGEventScrollWheel) | 
								CGEventMaskBit(kCGEventOtherMouseDown), 
								callback, 
								self);
    runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
    CGEventTapEnable(eventTap, true);
	
	//Update the UI and second counter every 1 sec
	NSTimer *sec_timer;
	sec_timer = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateSecCounter:) userInfo:nil repeats:YES] retain];
	[sec_timer fire];
	
	//Update the 60 sec counter every 60 sec...
	NSTimer *min_timer;
	min_timer = [[NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(updateMinCounter:) userInfo:nil repeats:YES] retain];
	[min_timer fire];
}

- (void) dealloc {
	[statusImage release];
	[super dealloc];
}

@end