//
//  AMController.h
//  Amua
//
//  Created by Mathis & Simon Hofer on 17.02.05.
//  Copyright 2005-2007 Mathis & Simon Hofer.
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

/**
 * @mainpage Amua Code Documentation
 *
 * @image html Amua.png
 *
 * <center>http://amua.sourceforge.net</center>
 */

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>
#import "AMPlayer.h"
#import "AMRecentStations.h"
#import "AMStatusBarView.h"
#import "AMSongInformationPanel.h"
#import "AMPreferencesController.h"
#import "AMStationController.h"
#import "AMUtil.h"
#import "KeyChain.h"

#define GROWL_NOTIFICATION_TRACK_CHANGE @"Track Change"

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

/**
 * @defgroup Controller
 * Classes refering to controllers.
 *
 * Controllers are used as a connection between the graphical components
 * and the application logic.
 */

/**
 * AMController represents the main application controller.
 * @ingroup Controller
 */
@interface AMController : NSObject<AMPlayerDelegate, GrowlApplicationBridgeDelegate> {
    
    AMPlayer *player;
    AMRecentStations *recentStations;
    AMStatusBarView *view;
    NSUserDefaults *preferences;
    NSMenu *menu;
    NSMenu *recentStationsMenu;
    KeyChain *keyChain;
    
    bool alwaysDisplayTooltip;
    
    AMPreferencesController *preferencesController;
    AMStationController *stationController;
    AMNotification *defaultPlayerNotification;
    IBOutlet AMSongInformationPanel *songInfoPanel;
    IBOutlet NSApplication *application;

}

+ (AMController *)sharedController;

- (id)init;
- (void)awakeFromNib;
- (void)applicationWillTerminate:(NSNotification *)aNotification;

/**
 * Update the status bar menu.
 */
- (void)updateMenu;

- (bool)isDefaultLastfmPlayer;
- (void)setDefaultLastfmPlayer;
- (void)defaultPlayerNotificationResult:(id)sender;
- (NSDictionary *)registrationDictionaryForGrowl;

- (void)handleOpenUrl:(NSAppleEventDescriptor *)event
       withReplyEvent:(NSAppleEventDescriptor *)replyEvent;
- (void)handlePreferencesChanged:(NSNotification *)notification;
- (void)handleMouseEntered:(NSNotification *)notification;
- (void)handleMouseExited:(NSNotification *)notification;
- (void)handleMouseDown:(NSNotification *)notification;

- (void)player:(AMPlayer *)player hasNewStation:(NSString *)stationURL;
- (void)player:(AMPlayer *)player hasNewSongInformation:(AMSongInformation *)songInfo;
- (void)player:(AMPlayer *)player hasFinishedHandshakeWithStreamingURL:(NSString *)streamingURL;
- (void)player:(AMPlayer *)player hasError:(NSString *)message;

- (BOOL)isPlaying;
- (void)displaySongInformation;

- (IBAction)openAlbumPage:(id)sender;
- (IBAction)tryAgain:(id)sender;
- (IBAction)openTagAsPanel:(id)sender;
- (IBAction)playMostRecent:(id)sender;
- (IBAction)openPlayStationPanel:(id)sender;
- (IBAction)playRecentStation:(id)sender;
- (IBAction)clearRecentStations:(id)sender;
- (IBAction)stop:(id)sender;
- (IBAction)love:(id)sender;
- (IBAction)skip:(id)sender;
- (IBAction)ban:(id)sender;
- (IBAction)changeDiscoverySettings:(id)sender;
- (IBAction)changeScrobbleSettings:(id)sender;
- (IBAction)changeDetachSongInfoSettings:(id)sender;
- (IBAction)openLastfmHomepage:(id)sender;
- (IBAction)openPersonalPage:(id)sender;
- (IBAction)openPreferences:(id)sender;
- (IBAction)openAboutPanel:(id)sender;

@end
