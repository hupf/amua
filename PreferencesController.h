//
//  PreferencesController.h
//  Amua
//
//  Created by Mathis and Simon Hofer on 17.02.05.
//  Copyright 2005 Mathis & Simon Hofer.
//

#import <Cocoa/Cocoa.h>

@interface PreferencesController : NSWindowController
{
	IBOutlet NSPopUpButton *radioStation;
	IBOutlet NSButton *recordToProfile;
	IBOutlet NSTextField *username;
    IBOutlet NSTextField *password;
	IBOutlet NSTextField *webServiceServer;
    IBOutlet NSTextField *streamingServer;
	IBOutlet NSPanel *window;
	NSUserDefaults *preferences;
}
- (void)windowDidLoad;
- (void)windowWillClose:(NSNotification *)aNotification;
- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)setDefaults:(id)sender;
- (void)updateFields;
- (void)dealloc;
@end
