/* PreferencesController */

#import <Cocoa/Cocoa.h>

@interface PreferencesController : NSWindowController
{
    IBOutlet NSTextField *password;
    IBOutlet NSTextField *streamingServer;
    IBOutlet NSTextField *username;
    IBOutlet NSTextField *webServiceServer;
	IBOutlet NSPanel *window;
	NSUserDefaults *preferences;
}
- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (void)updateFields;
@end
