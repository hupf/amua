//
//  AmuaController.h
//  Amua
//
//  Created by Mathis & Simon Hofer on 17.02.05.
//  Copyright 2005 Mathis & Simon Hofer.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//  
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//

#import <Cocoa/Cocoa.h>
#import <SSCrypto/SSCrypto.h>
#import "AmuaView.h"
#import "AmuaUpdater.h"
#import "PreferencesController.h"
#import "LastfmWebService.h"
#import "SongInformationPanel.h"
#import "StationController.h"
#import "RecentStations.h"
#import "KeyChain.h"

#define MAX_SONGTEXT_LENGTH 30

@interface AmuaController : NSObject
{
	
    // The status item that will be added to the system status bar
    NSStatusItem *statusItem;
	
	// The custom view of the statusItem
	AmuaView *view;
	
	// The menu that will be displayed by the status item
	IBOutlet NSMenu *menu;
	
	// The menu item for changing the behavior of the tooltip
	IBOutlet NSMenuItem *tooltipMenuItem;
	
	// A reference to the NSApplication, used to put the about window to front
	IBOutlet NSApplication *application;
	
	IBOutlet SongInformationPanel *songInformationPanel;
	
	IBOutlet StationController *stationController;
	
	RecentStations *recentStations;
	
	// The preferences window controller
	PreferencesController *preferencesController;
	
	// Preferences tracking object
    NSUserDefaults *preferences;
	
	LastfmWebService *webService;
	
	// A boolean to check playing status
	bool playing;
	
	// A timer that will get actual song information
	NSTimer *timer;
	
	// A boolean indicating that the mouse is over the icon
	bool mouseIsOverIcon;
	
	// Object to write and read passwort to and from keychain
	KeyChain *keyChain;
	
	// A boolean indicating if the Tooltip is always visible
	bool alwaysDisplayTooltip;
	
}
- (void)play:(id)sender;
- (void)playMostRecent:(id)sender;
- (void)stop:(id)sender;
- (void)loveSong:(id)sender;
- (void)skipSong:(id)sender;
- (void)banSong:(id)sender;
- (IBAction)openLastfmHomepage:(id)sender;
- (IBAction)openPersonalPage:(id)sender;
- (IBAction)openPreferences:(id)sender;
- (void)openAlbumPage:(id)sender;
- (IBAction)openAboutPanel:(id)sender;
- (void)changeTooltipSettings:(id)sender;
- (void)showTooltip:(id)sender;
- (void)hideTooltip:(id)sender;
- (void)updateMenu;
- (void)updateTimer;
- (void)fireTimer:(id)sender;
- (void)handlePreferencesChanged:(NSNotification *)aNotification;
- (void)handleStartPlaying:(NSNotification *)aNotification;
- (void)handleUpdateNowPlayingInformation:(NSNotification *)aNotification;
- (void)handleStartPlayingError:(NSNotification *)aNotification;
- (NSString *)md5:(NSString *)clearTextString;
- (void)applicationWillTerminate:(NSNotification *)aNotification;
@end
