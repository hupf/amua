//
//  AmuaController.h
//  Amua
//
//  Created by Mathis & Simon Hofer on 17.02.05.
//  Copyright 2005-2006 Mathis & Simon Hofer.
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
#import <openssl/md5.h>
#import "AmuaView.h"
#import "AmuaUpdater.h"
#import "PreferencesController.h"
#import "LastfmWebService.h"
#import "SongInformationPanel.h"
#import "StationController.h"
#import "RecentStations.h"
#import "KeyChain.h"
#import "Notification.h"

/**
 * The maximum number of characters for the song text before it is cropped.
 */
#define MAX_SONGTEXT_LENGTH 30


// From Mozilla Firefox source code, use to check default player
// (see browser/components/shell/src/nsMacShellService.cpp):
// These Launch Services functions are undocumented. We're using them since they're
// the only way to set the default opener for URLs / file extensions.

// Returns the CFURL for application currently set as the default opener for the
// given URL scheme. appURL must be released by the caller.
extern OSStatus _LSCopyDefaultSchemeHandlerURL(CFStringRef scheme, CFURLRef *appURL);
extern OSStatus _LSSetDefaultSchemeHandlerURL(CFStringRef scheme, CFURLRef appURL);
extern OSStatus _LSSaveAndRefresh(void);
// Callers should pass 0 as both inType and inCreator in order to set the default opener
// without modifing those.
extern OSStatus _LSSetWeakBindingForType(OSType inType,
                                         OSType inCreator,
                                         CFStringRef inExtension,
                                         LSRolesMask inRoleMask,
                                         const FSRef *inBindingRef);


@class StationController; // Forward declaration

/**
 * The main controller class of Amua.
 * 
 * It contains methods to start playing and stop the stream as well as methods
 * that use the song information panel to display the currently played song.
 */
@interface AmuaController : NSObject {

    /**
     * The status item that will be added to the system status bar.
     */
    NSStatusItem *statusItem;
	
	/**
     * The custom view of the statusItem.
     */
	AmuaView *view;
	
	/**
     * The menu that will be displayed by the status item.
     */
	IBOutlet NSMenu *menu;
	
	/**
     * The menu item for changing the behavior of the tooltip.
     */
	IBOutlet NSMenuItem *tooltipMenuItem;
	
    /**
     * The menu item to toggle the discovery mode.
     */
	IBOutlet NSMenuItem *discoveryMenuItem;
    
    /**
     * The menu item to toggle the record to profile mode.
     */
	IBOutlet NSMenuItem *recordtoprofileMenuItem;
    
    /**
     * The submenu that contains the recent played stations.
     */
	IBOutlet NSMenu *playRecentMenu;
	
	/**
     * The menu item for clearing the recent played stations menu.
     */
	IBOutlet NSMenuItem *clearRecentMenuItem;
	
	/**
     * A reference to the NSApplication, used to put the about window to front.
     */
	IBOutlet NSApplication *application;
	
    /**
     * The panel that shows artist, album and song information.
     */
	IBOutlet SongInformationPanel *songInformationPanel;
	
    /**
     * The "Play station..." window controller.
     */
	IBOutlet StationController *stationController;
	
    /**
     * Manages the list of the recently played stations.
     */
	RecentStations *recentStations;
	
	/**
     * The preferences window controller.
     */
	PreferencesController *preferencesController;
	
	/**
     * The preferences tracking object.
     */
    NSUserDefaults *preferences;
	
    /**
     * The webservice communication object.
     */
	LastfmWebService *webService;
	
	/**
     * A boolean to check playing status.
     */
	bool playing;
	
	/**
     * A timer that will get actual song information.
     */
	NSTimer *timer;
	
	/**
     * A boolean indicating that the mouse is over the icon.
     */
	bool mouseIsOverIcon;
	
	/**
     * The object to write and read passwort to and from the keychain.
     */
	KeyChain *keyChain;
	
	/**
     * A boolean indicating if the Tooltip is always visible.
     */
	bool alwaysDisplayTooltip;
    
    /**
     * The notification for the default Last.fm player check.
     */
    Notification *defaultPlayerNotification;
}

/**
 * Constructor.
 */
- (id)init;

/**
 * Actions after loading interface builder file.
 */
- (void)awakeFromNib;

/**
 * Start playing/streaming a station from a given URL.
 * 
 * This method changes Amua to the playing state.
 * 
 * @param url The URL of the station.
 */
- (void)playUrl:(NSString *)url;

/**
 * Start playing/streaming a station that is set by the station controller.
 * 
 * This method changes Amua to the playing state.
 * 
 * @param sender Defines which station to start.
 */
- (void)play:(id)sender;

/**
 * Start playing/streaming a station from the recent stations list.
 * 
 * This method changes Amua to the playing state.
 * 
 * @param sender Defines which station to start.
 */
- (void)playRecentStation:(id)sender;

/**
 * Start playing/streaming the most recently played station.
 * 
 * This method changes Amua to the playing state.
 */
- (void)playMostRecent:(id)sender;

/**
 * Stop the currently playing stream.
 * 
 * This method changes Amua to the stop state (e.g. not playing).
 */
- (void)stop:(id)sender;

/**
 * Set the currently playing song as "loved".
 */
- (void)loveSong:(id)sender;

/**
 * Skips the currently playing song.
 * 
 * A timer is set that fires after five seconds, to fetch the song informations
 * of the new song.
 */
- (void)skipSong:(id)sender;

/**
 * Bans the currently playing song from the profile.
 * 
 * A timer is set that fires after five seconds, to fetch the song informations
 * of the new song.
 */
- (void)banSong:(id)sender;

/**
 * Clear the list of the recent stations in the menu.
 */
- (IBAction)clearRecentStations:(id)sender;

/**
 * Open the main Last.fm page.
 */
- (IBAction)openLastfmHomepage:(id)sender;

/**
 * Open the user's Last.fm profile page.
 */
- (IBAction)openPersonalPage:(id)sender;

/**
 * Open the preferences window.
 */
- (IBAction)openPreferences:(id)sender;

/**
 * Open the page of the currently played album.
 */
- (void)openAlbumPage:(id)sender;

/**
 * Open the about window.
 */
- (IBAction)openAboutPanel:(id)sender;

/**
 * Toggle the detach song information panel option.
 */
- (void)changeTooltipSettings:(id)sender;

/**
 * Show the song information panel alias tooltip.
 * 
 * The tooltip window is either displayed on mouse over the status bar icon or,
 * if the detach song panel option is set, at the last known position on the
 * screen.
 */
- (void)showTooltip:(id)sender;

/**
 * Hide the song information panel alias tooltip.
 */
- (void)hideTooltip:(id)sender;

/**
 * Toggles the discovery mode.
 * 
 * In discovery mode, only unheard songs are played.
 */
- (void)changeDiscoverySettings:(id)sender;

/**
 * Toggles the record to profile mode.
 * 
 * In record to profile mode, the played songs are not recorded to the profile.
 */
- (void)changeRecordToProfileSettings:(id)sender;

/**
 * Dynamically update the Amua menu.
 * 
 * This method updates the Amua menu depending on the state (playing, stopped).
 */
- (void)updateMenu;

/**
 * Updates the recently played songs menu.
 * 
 * Uses the RecentStations object to read the actual recent played songs.
 */
- (void)updateRecentPlayedMenu;

/**
 * Updates the timer to fire after the current song.
 */
- (void)updateTimer;

/**
 * If timer is fired, fetch new song information.
 */
- (void)fireTimer:(id)sender;

/**
 * Update menu after preferences have changed.
 */
- (void)handlePreferencesChanged:(NSNotification *)aNotification;

/**
 * Start playback.
 * 
 * A timer is set that fires after five seconds, to fetch the song informations
 * of the new song.
 */
- (void)handleStartPlaying:(NSNotification *)aNotification;

/**
 * Get fetched song informations and update the song information panel.
 */
- (void)handleUpdateNowPlayingInformation:(NSNotification *)aNotification;

/**
 * Add error to menu if start playing failed.
 */
- (void)handleStartPlayingError:(NSNotification *)aNotification;

/**
 * Generates the MD5 hash of a string.
 * 
 * @param clearTextString A string to generate a MD5 hash from.
 * @return The calculated MD5 hash.
 */
- (NSString *)md5:(NSString *)clearTextString;

/**
 * Open a given URL.
 * 
 * @param event An event descriptor that contains the URL.
 * @param replyEvent Not used.
 */
- (void)handleOpenUrl:(NSAppleEventDescriptor *)event
						withReplyEvent:(NSAppleEventDescriptor *)replyEvent;

/**
 * Stop playing if Amua quits.
 */
- (void)applicationWillTerminate:(NSNotification *)aNotification;

/**
 * Check if Amua is registered as default application for the lastfm:// protocol.
 * 
 * This method is from Mozilla Firefox source code (see browser/components/shell/src/nsMacShellService.cpp).
 * It uses some undocumented functions of the Mac OS X's launch services to
 * get the registered default application for the lastfm:// protocol.
 * 
 * @return True if Amua is default Last.fm player.
 */
- (bool)isDefaultLastfmPlayer;

/**
 * Set Amua as default player for the lastfm:// protocol.
 * 
 * This method is from Mozilla Firefox source code (see browser/components/shell/src/nsMacShellService.cpp).
 * It uses some undocumented functions of the Mac OS X's launch services to
 * register Amua as default application for the lastfm:// protocol.
 */
- (void)setDefaultLastfmPlayer;

/**
 * Action for the default Last.fm player notification.
 */
- (void)defaultPlayerNotificationResult:(id)sender;

@end
