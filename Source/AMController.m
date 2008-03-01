//
//  AMController.m
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

#import "AMController.h"

// @cond PRIVATE_DECLARATION
@interface AMController (PRIVATE)

- (void)addMenuItems;
- (void)addRecentStationMenuItems:(NSMenuItem *)superItem;

@end
// @endcond

@implementation AMController

+ (AMController *)sharedController
{
    return (AMController *)[NSApp delegate];
}

- (id)init
{
    AmuaSetLogType(AMUA_MAX_LOG_LEVEL);
    
    // Read in the XML file with the default preferences
	NSString *file = [[NSBundle mainBundle]
        pathForResource:@"Defaults" ofType:@"plist"];
    
    NSDictionary *defaultPreferences = [NSDictionary dictionaryWithContentsOfFile:file];
	
	keyChain = [[KeyChain alloc] init];
	
	preferences = [[NSUserDefaults standardUserDefaults] retain];
    [preferences registerDefaults:defaultPreferences];
    AmuaSetLogType([preferences integerForKey:@"logLevel"]);
	
	// Register handle for requested menu updates from PreferencesController
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePreferencesChanged:)
                                                 name:@"AmuaPreferencesChanged" object:nil];
    
	// Register handle for mousentered event
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMouseEntered:)
                                                 name:@"AmuaStatusItemMouseEntered" object:nil];
				
	// Register handle for mousexited event
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMouseExited:)
                                                 name:@"AmuaStatusItemMouseExited" object:nil];
				
	// Register handle for mousedown event
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMouseDown:)
                                                 name:@"AmuaStatusItemMouseDown" object:nil];
    
    // start handshake with webservice
    player = [[AMPlayer alloc] initWithPlayback:[[[AMiTunesPlayback alloc] init] autorelease]
                                  discoveryMode:[preferences boolForKey:@"discoveryMode"]
                                   scrobbleMode:[preferences boolForKey:@"scrobbleMode"]];
    
    [player setDelegate:self];
    [player connectToServer:[preferences stringForKey:@"webServiceServer"] 
         withUser:[preferences stringForKey:@"username"] 
         withPasswordHash:md5hash([keyChain genericPasswordForService:@"Amua" 
                                         account:[preferences stringForKey:@"username"]])];
	
	return self;
}


- (void)awakeFromNib
{	  
	// Check if a new version of Amua is available
	AmuaUpdater *updater = [[[AmuaUpdater alloc] init] autorelease];
	if ([preferences boolForKey:@"performUpdatesCheck"]) {
		[updater checkForUpdates];
	}
    
    // Check if Amua is the default player for the lastfm:// protocol
    if ([preferences boolForKey:@"performDefaultPlayerCheck"] && ![self isDefaultLastfmPlayer]) {
        defaultPlayerNotification = [[AMNotification alloc] initWithTitle:@"Default Last.fm Player"
                                                        withDescription:@"Amua is not currently set as your default Last.fm player. " \
											 "Would you like to make it your default Last.fm player?"
                                                        withDismissText:@"Always perform this check when starting Amua"
                                                           dismissState:[preferences boolForKey:@"performDefaultPlayerCheck"]
                                                                 action:@selector(defaultPlayerNotificationResult:)
                                                                 target:self];
		[defaultPlayerNotification display];
    }
    
	// Add a menu item to the status bar
    menu = [[NSMenu alloc] init];
	view = [[AMStatusBarView alloc] initWithMenu:menu];
    recentStationsMenu = [[NSMenu alloc] init];
	
	
	alwaysDisplayTooltip = (BOOL)[[preferences stringForKey:@"alwaysDisplayTooltip"] intValue];
	if (!alwaysDisplayTooltip) {
		// listen to mouse events of AmuaView
		[view addMouseOverListener];
	} else {
        // set info panel position altough it is not visible, otherwise
        // the stored position would be overridden
        NSPoint point = NSPointFromString([preferences stringForKey:@"tooltipPosition"]);
        if (point.x == 0 && point.y == 0) {
            point = [NSEvent mouseLocation];
        }
        [songInfoPanel setFrameOrigin:point];
    }
		
	recentStations = [[AMRecentStations alloc] initWithPreferences:preferences];
    
    if ([[preferences stringForKey:@"username"] isEqualToString:@""] ||
        [[keyChain genericPasswordForService:@"Amua"
                                     account:[preferences stringForKey:@"username"]] isEqualToString:@""] ||
        [[preferences stringForKey:@"webServiceServer"] isEqualToString:@""]) {
        [self openPreferences:self];
    }
    
    [GrowlApplicationBridge setGrowlDelegate:self];
    
    [self updateMenu];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	if ([player isPlaying]) {
		[player stop];
	}
	[preferences setInteger:(int)alwaysDisplayTooltip forKey:@"alwaysDisplayTooltip"];
    [preferences synchronize];
}


- (void)updateMenu
{
    int i;
    while ([menu numberOfItems] > 0) {
        [menu removeItemAtIndex:0];
    }
    
    [self addMenuItems];
	[menu update];
}


- (void)addMenuItems
{
    NSMenuItem *item = nil;
    
    // Message menu item
    if ([player hasError] || [player isBusy]) {
        NSString *message = nil;
        if ([player hasError]) {
            message = [[NSString stringWithString:@"Error: "] 
                                 stringByAppendingString:[player errorMessage]];
        }  else if (![player isLoggedIn]) {
            message = @"Logging in...";
        } else {
            message = @"Connecting...";
        }
        
        item = [[[NSMenuItem alloc] initWithTitle:message
                      action:nil keyEquivalent:@""] autorelease];
        [item setTarget:self];
        [item setEnabled:NO];
        [menu addItem:item];
        
        // separator menu item
        [menu addItem:[NSMenuItem separatorItem]];
        
        if ([player hasError] && ![player isLoggedIn]) {
            item = [[[NSMenuItem alloc] initWithTitle:@"Try Again"
                          action:@selector(tryAgain:) keyEquivalent:@""] autorelease];
            [item setTarget:self];
            [menu addItem:item];
            [menu addItem:[NSMenuItem separatorItem]];
        }
    } else if ([player isPlaying]) {
        // Album Details menu item
        item = [[[NSMenuItem alloc] initWithTitle:@"Album Details"
                                           action:@selector(openAlbumPage:) keyEquivalent:@""] autorelease];
        [item setTarget:self];
        if ([[player songInformation] hasURL]) {
            [item setEnabled:YES];
        } else {
            [item setAction:nil];
            [item setEnabled:NO];
        }
        [menu addItem:item];
        [menu addItem:[NSMenuItem separatorItem]];
    }
    
    if ([player isPlaying]) {
        
        // Tag As... menu item
        /*item = [[[NSMenuItem alloc] initWithTitle:@"Tag As..."
                      action:@selector(openTagAsPanel:) keyEquivalent:@""] autorelease];
        [item setTarget:self];
        [menu addItem:item];
        
        
        // separator menu item
        [menu addItem:[NSMenuItem separatorItem]];*/
        
        
        // Love menu item
        item = [[[NSMenuItem alloc] initWithTitle:@"Love"
                      action:@selector(love:) keyEquivalent:@""] autorelease];
        [item setTarget:self];
        [menu addItem:item];
        
        // Skip menu item
        item = [[[NSMenuItem alloc] initWithTitle:@"Skip"
                      action:@selector(skip:) keyEquivalent:@""] autorelease];
        [item setTarget:self];
        [menu addItem:item];
        
        // Ban menu item
        item = [[[NSMenuItem alloc] initWithTitle:@"Ban"
                      action:@selector(ban:) keyEquivalent:@""] autorelease];
        [item setTarget:self];
        [menu addItem:item];
        
        
        // separator menu item
        [menu addItem:[NSMenuItem separatorItem]];
        
        
        // Stop menu item
        item = [[[NSMenuItem alloc] initWithTitle:@"Stop"
                      action:@selector(stop:) keyEquivalent:@""] autorelease];
        [item setTarget:self];
        [menu addItem:item];
        
        
        // separator menu item
        [menu addItem:[NSMenuItem separatorItem]];
    } else {
        // Play Most Recent Station menu item
        item = [[[NSMenuItem alloc] initWithTitle:@"Play Most Recent Station"
                      action:@selector(playMostRecent:) keyEquivalent:@""] autorelease];
        if ([player isLoggedIn] && [recentStations count] > 0) {
            [item setTarget:self];
            [item setEnabled:YES];
        } else {
            [item setAction:nil];
            [item setEnabled:NO];
        }
        [menu addItem:item];
        
        
        // separator menu item
        [menu addItem:[NSMenuItem separatorItem]];
    }
    
    // Play Station... menu item
    item = [[[NSMenuItem alloc] initWithTitle:@"Play Station..."
                  action:@selector(openPlayStationPanel:) keyEquivalent:@""] autorelease];
    if ([player isLoggedIn]) {
        [item setTarget:self];
        [item setEnabled:YES];
    } else {
        [item setAction:nil];
        [item setEnabled:NO];
    }
    [menu addItem:item];
    
    
    // Play Recent Station menu item
    item = [[[NSMenuItem alloc] initWithTitle:@"Play Recent Station"
                  action:nil keyEquivalent:@""] autorelease];
    if ([player isLoggedIn]) {
        [item setTarget:self];
        [item setEnabled:YES];
    } else {
        [item setEnabled:NO];
    }
    [menu addItem:item];
    [self addRecentStationMenuItems:item];
    
    
    // separator
    [menu addItem:[NSMenuItem separatorItem]];
    
    // Scrobble Mode menu item
    if ([player isLoggedIn]) {
        item = [[[NSMenuItem alloc] initWithTitle:@"Scrobbling"
                                           action:@selector(changeScrobbleSettings:) keyEquivalent:@""] autorelease];
        [item setTarget:self];
        [item setEnabled:YES];
        [item setState:[player isScrobbling] ? NSOnState : NSOffState];
        [menu addItem:item];
    }
    
    // Discovery Mode menu item
    if ([player isLoggedIn] && [player isInSubscriberMode]) {
        item = [[[NSMenuItem alloc] initWithTitle:@"Discovery Mode"
                      action:@selector(changeDiscoverySettings:) keyEquivalent:@""] autorelease];
        if ([player isPlaying]) {
            [item setTarget:self];
            [item setEnabled:YES];
        } else {
            [item setAction:nil];
            [item setEnabled:NO];
        }
        [item setState:[player isInDiscoveryMode] ? NSOnState : NSOffState];
        [menu addItem:item];
    }
    
    // Detach Song Info menu item
    item = [[[NSMenuItem alloc] initWithTitle:@"Detach Song Info"
                  action:@selector(changeDetachSongInfoSettings:) keyEquivalent:@""] autorelease];
    [item setEnabled:YES];
    [item setState:alwaysDisplayTooltip ? NSOnState : NSOffState];
    [item setTarget:self];
    [menu addItem:item];
    
    
    // separator
    [menu addItem:[NSMenuItem separatorItem]];
    
    
    // Last.fm Homeage menu item
    item = [[[NSMenuItem alloc] initWithTitle:@"Last.fm Homepage"
                  action:@selector(openLastfmHomepage:) keyEquivalent:@""] autorelease];
    [item setTarget:self];
    [menu addItem:item];
    
    // Personal Page menu item
    item = [[[NSMenuItem alloc] initWithTitle:@"Personal Page"
                  action:@selector(openPersonalPage:) keyEquivalent:@""] autorelease];
    if ([player isLoggedIn]) {
        [item setTarget:self];
        [item setEnabled:YES];
    } else {
        [item setAction:nil];
        [item setEnabled:NO];
    }
    [menu addItem:item];
    
    
    // separator
    [menu addItem:[NSMenuItem separatorItem]];
    
    
    // About menu item
    item = [[[NSMenuItem alloc] initWithTitle:@"About"
                  action:@selector(openAboutPanel:) keyEquivalent:@""] autorelease];
    [item setTarget:self];
    [menu addItem:item];
    
    // Preferences... menu item
    item = [[[NSMenuItem alloc] initWithTitle:@"Preferences..."
                  action:@selector(openPreferences:) keyEquivalent:@""] autorelease];
    [item setTarget:self];
    [menu addItem:item];
    
    
    // separator
    [menu addItem:[NSMenuItem separatorItem]];
    
    
    // Quit menu item
    item = [[[NSMenuItem alloc] initWithTitle:@"Quit"
                  action:@selector(terminate:) keyEquivalent:@""] autorelease];
    [item setTarget:application];
    [menu addItem:item];
}


- (void)addRecentStationMenuItems:(NSMenuItem *)groupItem
{
    while ([recentStationsMenu numberOfItems] > 0) {
        [recentStationsMenu removeItemAtIndex:0];
    }
    
    int i;
    for (i=0; i<[recentStations count]; i++) {
        NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:[recentStations stationByIndex:i]
                                  action:@selector(playRecentStation:) keyEquivalent:@""] autorelease];
        [item setTarget:self];
        [recentStationsMenu addItem:item];
    }
    
    if ([recentStations count] > 0) {
        [recentStationsMenu addItem:[NSMenuItem separatorItem]];
    }
    
    NSMenuItem *clearItem = [[[NSMenuItem alloc] initWithTitle:@"Clear"
                                   action:@selector(clearRecentStations:) keyEquivalent:@""] autorelease];
    [clearItem setTarget:self];
    [recentStationsMenu addItem:clearItem];
    
    [menu setSubmenu:recentStationsMenu forItem:groupItem];
}


- (void)showSongInfoPanel
{
	if ([player isPlaying] && [player songInformation] != nil) {       
            // set the tooltip location
            if (alwaysDisplayTooltip && ![songInfoPanel isVisible]) {
                NSPoint point = NSPointFromString([preferences stringForKey:@"tooltipPosition"]);
                if (point.x == 0 && point.y == 0) {
                    point = [NSEvent mouseLocation];
                }
                [songInfoPanel setFrameOrigin:point];
            } else if ([view isMouseOver] && ![songInfoPanel isVisible]) {
                [songInfoPanel autoPosition];
            }
            
            [songInfoPanel show];
        
	} else {
        [songInfoPanel hide];
    }
}


- (void)hideSongInfoPanel
{
	// remove the tooltip window
	if (!alwaysDisplayTooltip || ![player isPlaying]) {
		[songInfoPanel hide];
	}
}


// helper methods


- (bool)isDefaultLastfmPlayer
{
	bool isDefault = true;
    
	// Since neither Launch Services nor Internet Config actually differ between 
	// bundles which have the same bundle identifier (That is, if we set our
	// bundle's URL as the default handler, Launch Service might return the
	// URL of another firefox bundle as the defualt http handler), we are
	// comparing the bundles' identifiers rather than their URLs.
    
	CFStringRef amuaID = CFBundleGetIdentifier(CFBundleGetMainBundle());
	if (!amuaID) {
		// CFBundleGetIdentifier is expected to return NULL only if the specified
		// bundle doesn't have a bundle identifier in its plist. In this case, that
		// means a failure, since our bundle does have an identifier.
		AmuaLog(LOG_ERROR, @"isDefaultLastfmPlayer: failure in plist");
	}
    
	CFRetain(amuaID);
    
	// Get the default http handler URL
	CFURLRef defaultLastfmPlayerURL;
	OSStatus err = _LSCopyDefaultSchemeHandlerURL(CFSTR("lastfm"),
                                                  &defaultLastfmPlayerURL);
	if (err == noErr) {
		// Get a reference to the bundle (based on its URL)
		CFBundleRef defaultLastfmPlayerBundle = CFBundleCreate(NULL, 
                                                               defaultLastfmPlayerURL);
		if (defaultLastfmPlayerBundle) {
			CFStringRef defaultLastfmPlayerID = CFBundleGetIdentifier(defaultLastfmPlayerBundle);
			if (defaultLastfmPlayerID) {
				CFRetain(defaultLastfmPlayerID);
				// and compare it to our bundle identifier
				isDefault = CFStringCompare(amuaID, defaultLastfmPlayerID, 0)
                    == kCFCompareEqualTo;
				CFRelease(defaultLastfmPlayerID);
			}
			else {
				// If the default browser bundle doesn't have an identifier in its plist,
				// it's not our bundle
				isDefault = false;
			}
            
			CFRelease(defaultLastfmPlayerBundle);
		}
        
		CFRelease(defaultLastfmPlayerURL);
	}
    
	// release the idetifiers strings
	CFRelease(amuaID);
    
	return isDefault;
}


- (void)setDefaultLastfmPlayer
{
	CFURLRef amuaURL = CFBundleCopyBundleURL(CFBundleGetMainBundle());
	_LSSetDefaultSchemeHandlerURL(CFSTR("lastfm"), amuaURL);
	_LSSaveAndRefresh();
	CFRelease(amuaURL);
}


- (void)defaultPlayerNotificationResult:(id)sender
{
	if (sender == defaultPlayerNotification) {
    	if ([defaultPlayerNotification clickedButton] == YES_BUTTON_CLICKED) {
        	[self setDefaultLastfmPlayer];
        }
        
        [preferences setBool:[defaultPlayerNotification dismissState]
                      forKey:@"performDefaultPlayerCheck"];
        [preferences synchronize];
    }
    
    [sender release];
}


- (NSDictionary *) registrationDictionaryForGrowl
{
    NSArray *notifications = [NSArray arrayWithObject:GROWL_NOTIFICATION_TRACK_CHANGE];
    return ([NSDictionary dictionaryWithObjectsAndKeys:
                 notifications, GROWL_NOTIFICATIONS_ALL,
                 notifications, GROWL_NOTIFICATIONS_DEFAULT, nil]);
}


- (void)handleOpenUrl:(NSAppleEventDescriptor *)event
       withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
	NSString *filename = [[event paramDescriptorForKeyword: keyDirectObject]
								stringValue];
	if ([filename hasPrefix:@"lastfm"]) {
		[player start:filename];
        [self updateMenu];
	}
}


// Notification handler implementation


- (void)handlePreferencesChanged:(NSNotification *)notification
{
    if ([player isPlaying]) {
        [player stop];
    }
    
    AmuaSetLogType([preferences integerForKey:@"logLevel"]);
    [player connectToServer:[preferences stringForKey:@"webServiceServer"] 
         withUser:[preferences stringForKey:@"username"] 
         withPasswordHash:md5hash([keyChain genericPasswordForService:@"Amua" 
                                         account:[preferences stringForKey:@"username"]])];
    [self updateMenu];
}


- (void)handleMouseEntered:(NSNotification *)notification
{
    [self showSongInfoPanel];
}


- (void)handleMouseExited:(NSNotification *)notification
{
    [self hideSongInfoPanel];
}


- (void)handleMouseDown:(NSNotification *)notification
{
    [self hideSongInfoPanel];
}


// Song information implementation

- (BOOL)isPlaying
{
    return [player isPlaying];
}

- (void)displaySongInformation
{
    if (![player isPlaying])
	return;
    
    AMSongInformation *songInfo = [player songInformation];
    
    NSString *growlDescription = [NSString stringWithFormat:@"%@\n%@", [songInfo album], [songInfo artist]];
    [GrowlApplicationBridge notifyWithTitle:[songInfo track] description:growlDescription
			   notificationName:GROWL_NOTIFICATION_TRACK_CHANGE
				   iconData:[[songInfo cover] TIFFRepresentation] priority:0.0 isSticky:NO
			       clickContext:nil];
}

// AMPlayerDelegate implementation


- (void)player:(AMPlayer *)player hasNewStation:(NSString *)stationURL
{
    [view displayError:NO];
    [recentStations addStation:stationURL];
    [self updateMenu];
}


- (void)player:(AMPlayer *)player hasNewSongInformation:(AMSongInformation *)songInfo
{
    [view displayError:NO];
    [songInfoPanel updateWithSongInformation:songInfo];
    
    [self displaySongInformation];
    [self updateMenu];
    
    if ((![view isMenuVisible] && [view isMouseOver]) || alwaysDisplayTooltip) {
		if (alwaysDisplayTooltip) {
			NSPoint location = [songInfoPanel frame].origin;
			if (location.x != 0 && location.y != 0) {
				[preferences setObject:NSStringFromPoint(location) forKey:@"tooltipPosition"];
			}
		}
		[self showSongInfoPanel];
	}
}


- (void)player:(AMPlayer *)player hasFinishedHandshakeWithStreamingURL:(NSString *)streamingURL
{
    [view displayError:NO];
    [self updateMenu];
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
          andSelector:@selector(handleOpenUrl:withReplyEvent:)
          forEventClass:kInternetEventClass andEventID:kAEGetURL];
}


- (void)player:(AMPlayer *)player hasError:(NSString *)message
{
    [view displayError:YES];
    [self updateMenu];
}


// IBActions


- (IBAction)openAlbumPage:(id)sender
{
    if ([[player songInformation] hasURL]) {
        [[NSWorkspace sharedWorkspace] openURL:[[player songInformation] url]];
    }
}


- (IBAction)tryAgain:(id)sender
{
    [player connectToServer:[preferences stringForKey:@"webServiceServer"] 
         withUser:[preferences stringForKey:@"username"] 
         withPasswordHash:md5hash([keyChain genericPasswordForService:@"Amua" 
                                         account:[preferences stringForKey:@"username"]])];
    [self updateMenu];
}


- (IBAction)openTagAsPanel:(id)sender
{/* TODO implement */}


- (IBAction)playMostRecent:(id)sender
{
    [player start:[recentStations mostRecentStationURL]];
    [self updateMenu];
}


- (IBAction)openPlayStationPanel:(id)sender
{
    if(!stationController) {
        stationController = [[AMStationController alloc] initWithPlayer:player];
	}
    
    [NSApp activateIgnoringOtherApps:YES];
    [[stationController window] makeKeyAndOrderFront:nil];
}


- (IBAction)playRecentStation:(id)sender
{
    int index = [recentStationsMenu indexOfItem:sender];
    if (index >= 0 && index < [recentStations count]) {
        [player start:[recentStations stationURLByIndex:index]];
    }
    [self updateMenu];
}


- (IBAction)clearRecentStations:(id)sender
{
    [recentStations clear];
    [self updateMenu];
}


- (IBAction)stop:(id)sender
{
    [player stop];
    [self updateMenu];
    [songInfoPanel cleanUp];
}


- (IBAction)love:(id)sender
{
    [player love];
}


- (IBAction)skip:(id)sender
{
    [player skip];
}


- (IBAction)ban:(id)sender
{
    [player ban];
}


- (IBAction)changeDiscoverySettings:(id)sender
{
    NSMenuItem *item = (NSMenuItem *)sender;
    BOOL discoveryMode = [item state] != NSOnState;
    [item setState:discoveryMode ? NSOnState : NSOffState];
    [player setDiscoveryMode:discoveryMode];
    [preferences setBool:discoveryMode forKey:@"discoveryMode"];
}


- (IBAction)changeScrobbleSettings:(id)sender
{
    NSMenuItem *item = (NSMenuItem *)sender;
    BOOL scrobbleMode = [item state] != NSOnState;
    [item setState:scrobbleMode ? NSOnState : NSOffState];
    [player setScrobbleMode:scrobbleMode];
    [preferences setBool:scrobbleMode forKey:@"scrobbleMode"];
}


- (IBAction)changeDetachSongInfoSettings:(id)sender
{
    // TODO implement better
    alwaysDisplayTooltip = !alwaysDisplayTooltip;
    if (alwaysDisplayTooltip) {
        [self showSongInfoPanel];
    } else {
        NSPoint location = [songInfoPanel frame].origin;
        [self hideSongInfoPanel];
        if (location.x != 0 && location.y != 0) {
            [preferences setObject:NSStringFromPoint(location) forKey:@"tooltipPosition"];
        }
    }
    [self updateMenu];
}


- (IBAction)openLastfmHomepage:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.last.fm"]];
}


- (IBAction)openPersonalPage:(id)sender
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.last.fm/user/%@",
                                           [preferences stringForKey:@"username"]]];
    [[NSWorkspace sharedWorkspace] openURL:url];
}


- (IBAction)openPreferences:(id)sender
{
    if(!preferencesController) {
        preferencesController = [[AMPreferencesController alloc] init];
	}
    
    [NSApp activateIgnoringOtherApps:YES];
    [[preferencesController window] makeKeyAndOrderFront:nil];
}


- (IBAction)openAboutPanel:(id)sender
{
    [application orderFrontStandardAboutPanel:self];
	[application arrangeInFront:self];
}

@end
