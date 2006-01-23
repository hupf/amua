//
//  AmuaController.m
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

#import "AmuaController.h"

@implementation AmuaController

-(id)init
{
    // Read in the XML file with the default preferences
	NSString *file = [[NSBundle mainBundle]
        pathForResource:@"Defaults" ofType:@"plist"];

    NSDictionary *defaultPreferences = [NSDictionary dictionaryWithContentsOfFile:file];
	
	keyChain = [[KeyChain alloc] init];
	
	preferences = [[NSUserDefaults standardUserDefaults] retain];
    [preferences registerDefaults:defaultPreferences];
	
	// Register handle for requested menu updates from PreferencesController
	[[NSNotificationCenter defaultCenter] addObserver:self
				selector:@selector(handlePreferencesChanged:)
				name:@"PreferencesChanged" object:nil];
	
	// Register handle for requested start playing from LastfmWebService
	[[NSNotificationCenter defaultCenter] addObserver:self
				selector:@selector(handleStartPlaying:)
				name:@"StartPlaying" object:nil];
				
	// Register handle for connection errors
	[[NSNotificationCenter defaultCenter] addObserver:self
				selector:@selector(handleStartPlayingError:)
				name:@"StartPlayingError" object:nil];
	
	// Register handle for requested update of
	// actual playing song information from LastfmWebService
	[[NSNotificationCenter defaultCenter] addObserver:self
				selector:@selector(handleUpdateNowPlayingInformation:)
				name:@"UpdateNowPlayingInformation"	object:nil];
	
	// Register handle for mousentered event
	[[NSNotificationCenter defaultCenter] addObserver:self
				selector:@selector(showTooltip:)
				name:@"mouseEntered" object:nil];
				
	// Register handle for mousexited event
	[[NSNotificationCenter defaultCenter] addObserver:self
				selector:@selector(hideTooltip:)
				name:@"mouseExited" object:nil];
				
	// Register handle for mousedown event
	[[NSNotificationCenter defaultCenter] addObserver:self
				selector:@selector(hideTooltip:)
				name:@"mouseDown" object:nil];
	
	playing = NO;
	
	[[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
		andSelector:@selector(handleOpenUrl:withReplyEvent:)
		forEventClass:kInternetEventClass
		andEventID:kAEGetURL];
	
	return self;
}


- (void)awakeFromNib
{	
	// Check if a new version of Amua is available
	AmuaUpdater *updater = [[[AmuaUpdater alloc] init] autorelease];
	if ((BOOL)[[preferences stringForKey:@"showPossibleUpdateDialog"] intValue]) {
		[updater checkForUpdates];
	}
    
    // Check if Amua is the default player for the lastfm:// protocol
    bool isDefault = [self isDefaultLastfmPlayer];
    NSLog(isDefault?@"default":@"not default");
    if (!isDefault) {
    	int alertAction = NSRunAlertPanel(@"Default Last.fm Player",
        					@"Amua is not currently set as your default Last.fm player. " \
                             "Would you like to make it your default Last.fm player?",
        					@"Yes", @"No", nil);
		NSLog(@"%i", alertAction);
        if (alertAction == 1) {
        	// Set Amua as default Last.fm player.
			[self setDefaultLastfmPlayer];
		}
    }

	// Add an menu item to the status bar
	statusItem = [[[NSStatusBar systemStatusBar]
					statusItemWithLength:NSSquareStatusItemLength] retain];
	view = [[AmuaView alloc] initWithFrame:[[statusItem view] frame] statusItem:statusItem menu:menu];
	[statusItem setView:view];
	
	alwaysDisplayTooltip = (BOOL)[[preferences stringForKey:@"alwaysDisplayTooltip"] intValue];
	[tooltipMenuItem setState:alwaysDisplayTooltip];
	if (!alwaysDisplayTooltip) {
		// listen to mouse events of AmuaView
		[view addMouseOverListener];
	}
	
	[discoveryMenuItem setState:[preferences boolForKey:@"discoveryMode"]];
	[recordtoprofileMenuItem setState:[preferences boolForKey:@"recordToProfile"]];
	
	recentStations = [[RecentStations alloc] initWithPreferences:preferences];
	[stationController setRecentStations:recentStations];
	[stationController setPreferences:preferences];
	
	[self updateMenu];
    [self updateRecentPlayedMenu];

}


- (void)playUrl:(NSString *)url
{
	NSString *scriptSource = @"tell application \"iTunes\" \n stop \n end tell";
	NSAppleScript *script = [[NSAppleScript alloc] initWithSource:scriptSource];
	[script executeAndReturnError:nil];
    
	playing = YES;
	[self updateMenu];

	// Create web service object
	if (webService != nil) {
		[webService release];
	}
	webService = [[LastfmWebService alloc]
					initWithWebServiceServer:[preferences stringForKey:@"webServiceServer"]
					withStationUrl:url
					asUserAgent:[preferences stringForKey:@"userAgent"]];
	[webService createSessionForUser:[preferences stringForKey:@"username"]
		withPasswordHash:[self md5:[keyChain genericPasswordForService:@"Amua"
										account:[preferences stringForKey:@"username"]]]];

}


- (void)play:(id)sender
{
	NSString *stationUrl = [stationController getStationURLFromSender:sender];
	[stationController hideWindow];
	[self playUrl:stationUrl];
    [self updateRecentPlayedMenu];
}


- (void)playRecentStation:(id)sender
{
    int index = [playRecentMenu indexOfItem:sender];
    NSString *stationUrl = [NSString stringWithString:[recentStations stationURLByIndex:index]];
    NSLog(@"%i %@", index, stationUrl);
    [recentStations moveToFront:index];
	[self playUrl: stationUrl];
	[stationController hideWindow];
    [self updateRecentPlayedMenu];
}


// menu actions
- (void)playMostRecent:(id)sender
{
	NSString *scriptSource = @"tell application \"iTunes\" \n stop \n end tell";
	NSAppleScript *script = [[NSAppleScript alloc] initWithSource:scriptSource];
	[script executeAndReturnError:nil];
    
	playing = YES;
	[self updateMenu];
	
	NSString *stationUrl = [recentStations mostRecentStation];
	[self playUrl:stationUrl];
}


- (void)stop:(id)sender
{
	playing = NO;
	[self updateMenu];

	if (webService != nil) {
		[timer invalidate];
		[timer release];
		timer = nil;
		[webService release];
		webService = nil;
	}
	
	// Tell iTunes it should stop playing.
	// Change this command if you want to control another player that is apple-scriptable.
	NSString *scriptSource = @"tell application \"iTunes\" \n stop \n end tell";
	NSAppleScript *script = [[NSAppleScript alloc] initWithSource:scriptSource];
	[script executeAndReturnError:nil];
	
	if (alwaysDisplayTooltip) {
		NSPoint location = [songInformationPanel frame].origin;
		[preferences setObject:NSStringFromPoint(location) forKey:@"tooltipPosition"];
		[preferences synchronize];
	}
	
	[self hideTooltip:self];
}


- (void)loveSong:(id)sender
{
	[webService executeControl:@"love"];
}


- (void)skipSong:(id)sender
{
	[webService executeControl:@"skip"];
	
	// Deactivate some menu items that should not be pressed
	// until new song is streaming
	NSMenuItem *nowPlayingTrack = [menu itemAtIndex:0];
	[nowPlayingTrack setAction:nil];
	[nowPlayingTrack setEnabled:NO];
	
	NSMenuItem *love = [menu itemAtIndex:2];
	[love setAction:nil];
	[love setEnabled:NO];
	
	NSMenuItem *skip = [menu itemAtIndex:3];
	[skip setAction:nil];
	[skip setEnabled:NO];
	
	NSMenuItem *ban = [menu itemAtIndex:4];
	[ban setAction:nil];
	[ban setEnabled:NO];
	
	// Set the timer so that in five seconds the new song information will be fetched
	if (timer != nil) {
		[timer release];
	}
	timer = [[NSTimer scheduledTimerWithTimeInterval:(5) target:self
				selector:@selector(fireTimer:) userInfo:nil repeats:NO] retain];
}


- (void)banSong:(id)sender
{
	[webService executeControl:@"ban"];
	
	// Deactivate some menu items that should not be pressed
	// until new song is streaming
	NSMenuItem *nowPlayingTrack = [menu itemAtIndex:0];
	[nowPlayingTrack setAction:nil];
	[nowPlayingTrack setEnabled:NO];
	
	NSMenuItem *love = [menu itemAtIndex:2];
	[love setAction:nil];
	[love setEnabled:NO];
	
	NSMenuItem *skip = [menu itemAtIndex:3];
	[skip setAction:nil];
	[skip setEnabled:NO];
	
	NSMenuItem *ban = [menu itemAtIndex:4];
	[ban setAction:nil];
	[ban setEnabled:NO];
	
	// Set the timer so that in five seconds the new song information will be fetched
	if (timer != nil) {
		[timer release];
	}
	timer = [[NSTimer scheduledTimerWithTimeInterval:(5) target:self
				selector:@selector(fireTimer:) userInfo:nil repeats:NO] retain];
}


- (IBAction)clearRecentStations:(id)sender
{
	[recentStations clear];
    [self updateRecentPlayedMenu];
    int index = [menu indexOfItemWithTitle:@"Play Most Recent Station"];
    if (index >= 0) {
    	[[menu itemAtIndex:index] setAction:nil];
        [[menu itemAtIndex:index] setEnabled:NO];
    }
}


- (IBAction)openLastfmHomepage:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.last.fm/"]];
}


- (IBAction)openPersonalPage:(id)sender
{
	NSString *prefix = @"http://www.last.fm/user/";
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[prefix
			stringByAppendingString:[preferences stringForKey:@"username"]]]];
}


- (IBAction)openPreferences:(id)sender
{
    if(!preferencesController) {
        preferencesController = [[PreferencesController alloc] init];
	}

    [NSApp activateIgnoringOtherApps:YES];
    [[preferencesController window] makeKeyAndOrderFront:nil];
}


- (void)openAlbumPage:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[webService nowPlayingAlbumPage]];
}


- (IBAction)openAboutPanel:(id)sender
{
	[application orderFrontStandardAboutPanel:self];
	[application arrangeInFront:self];
}


// tooltip methods
- (void)changeTooltipSettings:(id)sender
{ 
	if ([tooltipMenuItem state] == NSOnState) {
		alwaysDisplayTooltip = NO;
		[tooltipMenuItem setState:NSOffState];
		NSPoint location = [songInformationPanel frame].origin;
		if (location.x != 0 && location.y != 0) {
			[preferences setObject:NSStringFromPoint(location) forKey:@"tooltipPosition"];
			[preferences synchronize];
		}
		[self hideTooltip:self];
		[view addMouseOverListener];
	} else {
		alwaysDisplayTooltip = YES;
		[tooltipMenuItem setState:NSOnState];
		[self showTooltip:self];
		[view removeMouseOverListener];
	}
	
}


- (void)showTooltip:(id)sender
{

	if (webService != nil) {
	
		NSString *artist = [webService nowPlayingArtist];
		NSString *album = [webService nowPlayingAlbum];
		NSString *title = [webService nowPlayingTrack];
		NSImage *image = [webService nowPlayingAlbumImage];
		
		if (artist && album && title && image && playing) {
									
			// set the tooltip location
			NSPoint point;
			if (alwaysDisplayTooltip) {
				point = NSPointFromString([preferences stringForKey:@"tooltipPosition"]);
				if (point.x == 0 && point.y == 0) {
					point = [NSEvent mouseLocation];
				}
				[songInformationPanel setFrameOrigin:point];
			} else {
				// get mouse location
				point = [NSEvent mouseLocation];
				if (!mouseIsOverIcon || [songInformationPanel visible]) {
					[songInformationPanel autoPosition];
				}
			}
			
			[songInformationPanel show];
		}
	
	}
	
	mouseIsOverIcon = YES;

}


- (void)hideTooltip:(id)sender
{
	// remove the tooltip window
	if (!alwaysDisplayTooltip || !playing) {
		[songInformationPanel hide];
	}
	mouseIsOverIcon = NO;
}


- (void)changeDiscoverySettings:(id)sender
{ 
    if ([discoveryMenuItem state] == NSOnState) {
		[discoveryMenuItem setState:NSOffState];
		[preferences setBool:FALSE forKey:@"discoveryMode"];
		[preferences synchronize];
		[webService setDiscovery:FALSE];
    } else {
		[discoveryMenuItem setState:NSOnState];
		[preferences setBool:TRUE forKey:@"discoveryMode"];
		[preferences synchronize];
		[webService setDiscovery:TRUE];
    }
    
}


- (void)changeRecordToProfileSettings:(id)sender
{ 
    if ([recordtoprofileMenuItem state] == NSOnState) {
		[recordtoprofileMenuItem setState:NSOffState];
		[preferences setBool:FALSE forKey:@"recordToProfile"];
		[preferences synchronize];
		[webService executeControl:@"nortp"];
    } else {
		[preferences setBool:TRUE forKey:@"recordToProfile"];
		[preferences synchronize];
		[recordtoprofileMenuItem setState:NSOnState];
		[webService executeControl:@"rtp"];
    }
    
}


- (void)updateMenu
{
	// Disable personal page menu item if no username is set
	NSMenuItem *personalPage = [menu itemWithTitle:@"Personal Page"];
	if ([[preferences stringForKey:@"username"] isEqualToString:@""]) {
		[personalPage setAction:nil];
		[personalPage setEnabled:NO];
	} else {
		[personalPage setAction:@selector(openPersonalPage:)];
		[personalPage setEnabled:YES];
	}
	
	if (!playing) { // Stop state
		
		NSMenuItem *play = [menu itemWithTitle:@"Play Most Recent Station"];
		NSMenuItem *playDialog = [menu itemWithTitle:@"Play Station..."];
		if (play == nil) {
		
			// Remove all menu items until stop item if it exists
			int stopIndex = [menu indexOfItemWithTitle:@"Stop"];
			int i;
			for (i=0; i<=stopIndex; i++) {
				[menu removeItemAtIndex:0];
			}
			
			play = [[[NSMenuItem alloc] initWithTitle:@"Play Most Recent Station"
						action:@selector(playMostRecent:) keyEquivalent:@""] autorelease];
			[play setTarget:self];
			[menu insertItem:play atIndex:0];
			[playDialog setTarget:self];
			
		}
		
		// Deactivate play menu item if no username/password or no web service
		// server is set, activate it otherwise
		if ([[preferences stringForKey:@"username"] isEqualToString:@""] ||
			[[keyChain genericPasswordForService:@"Amua"
					account:[preferences stringForKey:@"username"]] isEqualToString:@""] ||
			[[preferences stringForKey:@"webServiceServer"] isEqualToString:@""]) {
			
			[play setAction:nil];
			[play setEnabled:NO];
			[playDialog setAction:nil];
			[playDialog setEnabled:NO];
			
			NSMenuItem *hint = [[[NSMenuItem alloc] initWithTitle:@"Hint: Check Preferences"
									action:nil keyEquivalent:@""] autorelease];
			[hint setEnabled:NO];
			[menu insertItem:hint atIndex:0];
			
			[menu insertItem:[NSMenuItem separatorItem] atIndex:1];
			
		} else {
			if ([recentStations stationsAvailable]) {
				[play setAction:@selector(playMostRecent:)];
				[play setEnabled:YES];
			} else {
				[play setAction:nil];
				[play setEnabled:NO];
			}
			[play setTitle:@"Play Most Recent Station"];
			[playDialog setTarget:stationController];
			[playDialog setAction:@selector(showWindow:)];
			[playDialog setEnabled:YES];
			
			
			// Remove hint item if it exists
			int hintIndex = [menu indexOfItemWithTitle:@"Hint: Check Preferences"];
			if (hintIndex != -1) {
				[menu removeItemAtIndex:hintIndex];
				[menu removeItemAtIndex:hintIndex];
			}
		}
		
	} else { // Playing state
	
		NSMenuItem *stop = [menu itemWithTitle:@"Play Most Recent Station"];
		
		if (stop != nil) { // Were in stop state previously
			
			// Remove all menu items until (without) play item
			int playIndex = [menu indexOfItemWithTitle:@"Play Most Recent Station"];
			int i;
			for (i=0; i<playIndex; i++) {
				[menu removeItemAtIndex:0];
			}
			
			// Create menu items that are needed in play state
			NSMenuItem *nowPlayingTrack = [[[NSMenuItem alloc] initWithTitle:@"Connecting..."
												action:nil keyEquivalent:@""] autorelease];
			[nowPlayingTrack setTarget:self];
			[nowPlayingTrack setEnabled:NO];
			[menu insertItem:nowPlayingTrack atIndex:0];
			
			[menu insertItem:[NSMenuItem separatorItem] atIndex:1];
			
			NSMenuItem *love = [[[NSMenuItem alloc] initWithTitle:@"Love"
									action:nil keyEquivalent:@""] autorelease];
			[love setTarget:self];
			[love setEnabled:NO];
			[menu insertItem:love atIndex:2];
			
			NSMenuItem *skip = [[[NSMenuItem alloc] initWithTitle:@"Skip"
									action:nil keyEquivalent:@""] autorelease];
			[skip setTarget:self];
			[skip setEnabled:NO];
			[menu insertItem:skip atIndex:3];
			
			NSMenuItem *ban = [[[NSMenuItem alloc] initWithTitle:@"Ban"
									action:nil keyEquivalent:@""] autorelease];
			[ban setTarget:self];
			[ban setEnabled:NO];
			[menu insertItem:ban atIndex:4];
			
			[menu insertItem:[NSMenuItem separatorItem] atIndex:5];
			
			[stop setTitle:@"Stop"];
			[stop setAction:@selector(stop:)];
			
		} else { // Already were in play state previously
			
			NSMenuItem *nowPlayingTrack = [menu itemAtIndex:0];
			NSMenuItem *love = [menu itemAtIndex:2];
			NSMenuItem *skip = [menu itemAtIndex:3];
			NSMenuItem *ban = [menu itemAtIndex:4];
			
			// Enable the menu items for song information, love, skip and ban
			// if it is streaming, disable them otherwise.
			if ([webService streaming]) {
				
				NSString *songText = [[[webService nowPlayingArtist] stringByAppendingString:@" - "]
											stringByAppendingString:[webService nowPlayingTrack]];
				if ([songText length] > MAX_SONGTEXT_LENGTH) {
					// Shorten the songtext
					songText = [[songText substringToIndex:MAX_SONGTEXT_LENGTH] stringByAppendingString:@"..."];
				}
				
				[nowPlayingTrack setTitle:songText];
				[nowPlayingTrack setAction:@selector(openAlbumPage:)];
				[nowPlayingTrack setEnabled:YES];
				
				[love setAction:@selector(loveSong:)];
				[love setEnabled:YES];
				
				[skip setAction:@selector(skipSong:)];
				[skip setEnabled:YES];
				
				[ban setAction:@selector(banSong:)];
				[ban setEnabled:YES];
				
			} else {
			
				[nowPlayingTrack setTitle:@"Connecting..."];
				[nowPlayingTrack setAction:nil];
				[nowPlayingTrack setEnabled:NO];
				
				[love setAction:nil];
				[love setEnabled:NO];
				
				[skip setAction:nil];
				[skip setEnabled:NO];
				
				[ban setAction:nil];
				[ban setEnabled:NO];
				
			}
			
		}
		
	}
}


- (void)updateRecentPlayedMenu
{
	while ([playRecentMenu itemAtIndex:0] != clearRecentMenuItem) {
    	[playRecentMenu removeItemAtIndex:0];
    }
    
	if ([recentStations stationsAvailable]) {
    	[clearRecentMenuItem setEnabled:YES];
        [clearRecentMenuItem setTarget:self];
        [clearRecentMenuItem setAction:@selector(clearRecentStations:)];
        [playRecentMenu insertItem:[NSMenuItem separatorItem] atIndex:0];
        
        int i;
        for (i=[recentStations stationsCount]-1; i>=0; i--) {
        	NSDictionary *station = [[[recentStations stationByIndex:i] retain] autorelease];
            NSString *title = [[[NSString alloc] initWithString:[[[station objectForKey:@"type"]
            			stringByAppendingString:@": "] stringByAppendingString:[station objectForKey:@"name"]]]
                        autorelease];
        	NSMenuItem *stationItem = [[[NSMenuItem alloc] initWithTitle:title
            		action:@selector(playRecentStation:) keyEquivalent:@""] autorelease];
			[stationItem setTarget:self];
			[stationItem setEnabled:YES];
			[playRecentMenu insertItem:stationItem atIndex:0];
        }
    } else {
    	[clearRecentMenuItem setEnabled:NO];
        [clearRecentMenuItem setAction:nil];
    }
}


- (void)updateTimer
{
	// Set the timer to fire after the currently playing song will be finished.
	// If no song is playing or the song is almost finished, fire it in five seconds.
	int remainingTime = [webService nowPlayingTrackDuration] - [webService nowPlayingTrackProgress];
	if (remainingTime < 5) {
		remainingTime = 5;
	}
	
	if (timer != nil) {
		[timer release];
	}
	timer = [[NSTimer scheduledTimerWithTimeInterval:(remainingTime) target:self
				selector:@selector(fireTimer:) userInfo:nil repeats:NO] retain];
}


- (void)fireTimer:(id)sender
{
	if (webService != nil) {
		[webService updateNowPlayingInformation];
	}
}



// Handlers
- (void)handlePreferencesChanged:(NSNotification *)aNotification
{
	[self updateMenu];
}


- (void)handleStartPlaying:(NSNotification *)aNotification
{
	// Tell iTunes it should start playing.
	// Change this command if you want to control another player that is apple-scriptable.
	NSString *scriptSource = [[@"tell application \"iTunes\" \n open location \""
								stringByAppendingString:[webService streamingServer]]
								stringByAppendingString:@"\" \n end tell"];
	NSAppleScript *script = [[NSAppleScript alloc] initWithSource:scriptSource];
	[script executeAndReturnError:nil];
    
    [webService updateNowPlayingInformation];
	
	[webService setDiscovery:[preferences boolForKey:@"discoveryMode"]];
	[webService executeControl:([preferences boolForKey:@"discoveryMode"] ? @"rtp" : @"nortp")];
	
	// Set the timer so that in five seconds the new song information will be fetched
	timer = [[NSTimer scheduledTimerWithTimeInterval:(5) target:self
				selector:@selector(fireTimer:) userInfo:nil repeats:NO] retain];
}


- (void)handleUpdateNowPlayingInformation:(NSNotification *)aNotification
{
	[self updateTimer];
	[self updateMenu];
	
	NSString *artist = [webService nowPlayingArtist];
	NSString *album = [webService nowPlayingAlbum];
	NSString *title = [webService nowPlayingTrack];
	NSImage *image = [webService nowPlayingAlbumImage];
	
	NSString *radioStation = [webService nowPlayingRadioStation];
	if (artist && album && title && image && playing) {
		[songInformationPanel updateArtist:artist album:album track:title
			albumImage:image radioStation:radioStation radioStationUser:[webService nowPlayingRadioStationProfile]
			trackPosition:[webService nowPlayingTrackProgress] trackDuration:[webService nowPlayingTrackDuration]];
	}
		
	// show updated tooltip if necessary 
	if ((![view menuIsVisible] && mouseIsOverIcon) || alwaysDisplayTooltip) {
		if (alwaysDisplayTooltip) {
			NSPoint location = [songInformationPanel frame].origin;
			if (location.x != 0 && location.y != 0) {
				[preferences setObject:NSStringFromPoint(location) forKey:@"tooltipPosition"];
			}
		}
		[self showTooltip:self];
	}
}


- (void)handleStartPlayingError:(NSNotification *)aNotification
{
	playing = NO;
	[self updateMenu];
	
	if (webService != nil) {
		[webService release];
		webService = nil;
	}
	
	NSMenuItem *error = [[[NSMenuItem alloc] initWithTitle:@"Connection Error"
								action:nil keyEquivalent:@""] autorelease];
	[error setEnabled:NO];
	[menu insertItem:error atIndex:0];
	
	[menu insertItem:[NSMenuItem separatorItem] atIndex:1];
}


- (NSString *)md5:(NSString *)clear
{
    unsigned long long md[MD5_DIGEST_LENGTH]; // 128 bit
    
    MD5((unsigned char *)[clear UTF8String], strlen([clear UTF8String]), (unsigned char *)md);
    
    return [NSString stringWithFormat:@"%qx%qx", md[0], md[1]];
}


- (void)handleOpenUrl:(NSAppleEventDescriptor *)event
						withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
	NSString *filename = [[event paramDescriptorForKeyword: keyDirectObject]
								stringValue];
	if ([filename hasPrefix:@"lastfm"]) {
		[self playUrl:filename];
		[recentStations addStation:filename withType:@"Link" withName:filename];
		[self updateRecentPlayedMenu];
	}
}


- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	if (playing) {
		[self stop:self];
	}
	
	[preferences setInteger:(int)alwaysDisplayTooltip forKey:@"alwaysDisplayTooltip"];
}


- (bool)isDefaultLastfmPlayer
{
	// This method is from Mozilla Firefox source code
    // (see browser/components/shell/src/nsMacShellService.cpp).
    
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
		NSLog(@"isDefaultLastfmPlayer: failure in plist");
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
	// This method is from Mozilla Firefox source code
    // (see browser/components/shell/src/nsMacShellService.cpp).
    
	CFURLRef amuaURL = CFBundleCopyBundleURL(CFBundleGetMainBundle());
                NSLog((NSString*)CFCopyDescription(amuaURL));
	
	_LSSetDefaultSchemeHandlerURL(CFSTR("lastfm"), amuaURL);
	_LSSaveAndRefresh();
	
	CFRelease(amuaURL);
}

@end
