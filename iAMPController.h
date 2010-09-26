#import <Cocoa/Cocoa.h>
#include <ApplicationServices/ApplicationServices.h>

@interface iAMPController : NSObject {
	IBOutlet NSMenu *statusMenu;
		
	long actions_1_sec_counter;
	long actions_60_sec_counter;
	long last_60_sec;
		
	NSStatusItem *statusItem;
	NSImage *statusImage;
}

- (void) registerEvent:(CGEventType)event;
- (void) updateSecCounter:(id)sender;
- (void) updateMinCounter:(id)sender;
- (void) resetCounts:(id)sender;

@end