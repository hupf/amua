//
//  AmuaController.h
//  Amua
//
//  Created by Mathis and Simon Hofer on 17.02.05.
//  Copyright 2005 Mathis & Simon Hofer.
//

#import <Cocoa/Cocoa.h>
#import "PreferencesController.h"
#import "LastfmWebService.h"
#import "SSCrypto/SSCrypto.h"

@interface AmuaController : NSObject
{
	
    // The status item that will be added to the system status bar
    NSStatusItem *statusItem;
	
	// The menu that will be displayed by the status item
	IBOutlet NSMenu *menu;
	
	// The preferences window controller
	PreferencesController *preferencesController;
	
	// Preferences tracking object
    NSUserDefaults *preferences;
	
	LastfmWebService *webService;
	
	// A boolean to check playing status
	bool playing;
	
	// A timer that will get actual song information
	NSTimer *timer;
	
}
- (void)play:(id)sender;
- (void)stop:(id)sender;
- (void)loveSong:(id)sender;
- (void)skipSong:(id)sender;
- (void)banSong:(id)sender;
- (IBAction)openLastfmHomepage:(id)sender;
- (IBAction)openPersonalPage:(id)sender;
- (IBAction)openPreferences:(id)sender;
- (void)openAlbumPage:(id)sender;
- (void)updateMenu;
- (void)updateTimer;
- (void)handlePreferencesChanged:(NSNotification *)aNotification;
- (void)handleStartPlaying:(NSNotification *)aNotification;
- (void)handleUpdateNowPlayingInformation:(NSNotification *)aNotification;
- (NSString *)md5:(NSString *)clearTextString;
@end
