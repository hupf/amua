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

- (id)init
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
	
    // Register handle for handshake notification from LastfmWebService
	[[NSNotificationCenter defaultCenter] addObserver:self
                selector:@selector(handleHandshake:)
                name:@"Handshake" object:nil];
    
    // Register handle for failed handshake notification from LastfmWebService
    [[NSNotificationCenter defaultCenter] addObserver:self
                selector:@selector(handleHandshakeFailed:)
                name:@"HandshakeFailed" object:nil];
    
    // Register handle for connection error notification from LastfmWebService
    [[NSNotificationCenter defaultCenter] addObserver:self
                selector:@selector(handleConnectionError:)
                name:@"ConnectionError" object:nil];
    
	// Register handle for requested start playing from LastfmWebService
	[[NSNotificationCenter defaultCenter] addObserver:self
				selector:@selector(handleStationTuned:)
				name:@"StationTuned" object:nil];
    
    // Register handle for station errors
    [[NSNotificationCenter defaultCenter] addObserver:self
                selector:@selector(handleStationError:)
                name:@"StationError" object:nil];
				
	// Register handle for connection errors
	[[NSNotificationCenter defaultCenter] addObserver:self
				selector:@selector(handleStartPlayingError:)
				name:@"StartPlayingError" object:nil];
	
	// Register handle for requested update of
	// actual playing song information from LastfmWebService
	[[NSNotificationCenter defaultCenter] addObserver:self
				selector:@selector(handleUpdateNowPlayingInformation:)
				name:@"UpdateNowPlayingInformation"	object:nil];
    
    // Register handle for successful command notification from LastfmWebService
    [[NSNotificationCenter defaultCenter] addObserver:self
                selector:@selector(handleCommandExecuted:)
                name:@"CommandExecuted"	object:nil];
    
	
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
    
    // start handshake with webservice
    [self connectToServer];
	
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
    	//[defaultPlayerPanel makeKeyAndOrderFront:nil];
        defaultPlayerNotification = [[Notification alloc] initWithTitle:@"Default Last.fm Player"
        					withDescription:@"Amua is not currently set as your default Last.fm player. " \
											 "Would you like to make it your default Last.fm player?"
                            withDismissText:@"Always perform this check when starting Amua"
                            dismissState:[preferences boolForKey:@"performDefaultPlayerCheck"]
                            action:@selector(defaultPlayerNotificationResult:)
                            target:self];
		[defaultPlayerNotification display];
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
	} else {
        // set info panel position altough it is not visible, otherwise
        // the stored position would be overridden
        NSPoint point = NSPointFromString([preferences stringForKey:@"tooltipPosition"]);
        if (point.x == 0 && point.y == 0) {
            point = [NSEvent mouseLocation];
        }
        [songInformationPanel setFrameOrigin:point];
    }
	
	[discoveryMenuItem setState:[preferences boolForKey:@"discoveryMode"]];
	[recordtoprofileMenuItem setState:[preferences boolForKey:@"recordToProfile"]];
	
	recentStations = [[RecentStations alloc] initWithPreferences:preferences];
	[stationController setRecentStations:recentStations];
	[stationController setPreferences:preferences];
	
	[self updateMenu];
    
    if ([[preferences stringForKey:@"username"] isEqualToString:@""] ||
        [[keyChain genericPasswordForService:@"Amua"
                                     account:[preferences stringForKey:@"username"]] isEqualToString:@""] ||
        [[preferences stringForKey:@"webServiceServer"] isEqualToString:@""]) {
        [self openPreferences:self];
    }

}


- (void)playUrl:(NSString *)url
{
    if (!playing) {
        NSString *scriptSource = @"tell application \"iTunes\" \n stop \n end tell";
        NSAppleScript *script = [[NSAppleScript alloc] initWithSource:scriptSource];
        [script executeAndReturnError:nil];
    }
    
	connecting = YES;
	[self updateMenu];

	// Create web service object
	if (webService == nil || [webService streamingServer] == nil) {
        if (webService != nil) {
            [webService release];
        }
        [self connectToServer];
	}
	
    [webService setStationURL:url];
    [webService tuneStation];
}


- (void)play:(id)sender
{
	NSString *stationUrl = [stationController getStationURLFromSender:sender];
	[stationController hideWindow];
	[self playUrl:stationUrl];
}


- (void)playRecentStation:(id)sender
{
    int index = [playRecentMenu indexOfItem:sender];
    NSString *stationUrl = [NSString stringWithString:[recentStations stationURLByIndex:index]];
	[self playUrl: stationUrl];
	[stationController hideWindow];
}


- (void)playMostRecent:(id)sender
{
	NSString *stationUrl = [recentStations mostRecentStation];
	[self playUrl:stationUrl];
}


- (void)stop:(id)sender
{
	playing = NO;
    connecting = NO;
	[self updateMenu];

	if (timer != nil) {
		[timer invalidate];
		[timer release];
		timer = nil;
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
	
	NSMenuItem*love = [menu itemAtIndex:2];
	[love setAction:nil];
	[love setEnabled:NO];
	
	NSMenuItem *skip = [menu itemAtIndex:3];
	[skip setAction:nil];
	[skip setEnabled:NO];
	
	NSMenuItem *ban = [menu itemAtIndex:4];
	[ban setAction:nil];
	[ban setEnabled:NO];
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
}


- (void)connectToServer
{
    loginPhase = YES;
    if (webService != nil) {
        [webService release];
    }
    webService = [[LastfmWebService alloc]
					initWithWebServiceServer:[preferences stringForKey:@"webServiceServer"]
                    asUserAgent:[preferences stringForKey:@"userAgent"]
                    forUser:[preferences stringForKey:@"username"]
                    withPasswordHash:[self md5:
                        [keyChain genericPasswordForService:@"Amua"
                            account:[preferences stringForKey:@"username"]]]];
}


- (void)tryAgain:(id)sender
{
    [self connectToServer];
    [self updateMenu];
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

	if (playing && webService != nil) {
			
        if ([webService nowPlayingArtist] != nil && [webService nowPlayingTrack] != nil) {
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
        } else {
            [songInformationPanel hide];
        }
        
	} else {
        [songInformationPanel hide];
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
    if ([webService isSubscriber]) {
        if ([discoveryMenuItem state] == NSOnState) {
            [discoveryMenuItem setState:NSOffState];
            [preferences setBool:FALSE forKey:@"discoveryMode"];
            [preferences synchronize];
            if (webService != nil) {
                [webService setDiscovery:FALSE];
            }
        } else {
            [discoveryMenuItem setState:NSOnState];
            [preferences setBool:TRUE forKey:@"discoveryMode"];
            [preferences synchronize];
            if (webService != nil) {
                [webService setDiscovery:TRUE];
            }
        }
    }
}


- (void)changeRecordToProfileSettings:(id)sender
{ 
    if ([recordtoprofileMenuItem state] == NSOnState) {
		[recordtoprofileMenuItem setState:NSOffState];
		[preferences setBool:FALSE forKey:@"recordToProfile"];
		[preferences synchronize];
        if (webService != nil) {
            [webService executeControl:@"nortp"];
        }
    } else {
		[preferences setBool:TRUE forKey:@"recordToProfile"];
		[preferences synchronize];
		[recordtoprofileMenuItem setState:NSOnState];
        if (webService != nil) {
            [webService executeControl:@"rtp"];
        }
    }
}


- (void)updateMenu
{
    // remove all variable entries
    NSMenuItem *play = [menu itemWithTitle:@"Play Most Recent Station"];
    NSMenuItem *stop = [menu itemWithTitle:@"Stop"];
    NSMenuItem *playDialog = [menu itemWithTitle:@"Play Station..."];
    int bound = -1;
    if (play != nil) {
        bound = [menu indexOfItemWithTitle:@"Play Most Recent Station"];
    } else if (stop != nil) {
        bound = [menu indexOfItemWithTitle:@"Stop"];        
    }
    int i;
    for (i=0; i<=bound; i++) {
        [menu removeItemAtIndex:0];
    }
    
	// Disable personal page menu item if no username is set
	NSMenuItem *personalPage = [menu itemWithTitle:@"Personal Page"];
	if ([[preferences stringForKey:@"username"] isEqualToString:@""]) {
		[personalPage setAction:nil];
		[personalPage setEnabled:NO];
	} else {
		[personalPage setAction:@selector(openPersonalPage:)];
		[personalPage setEnabled:YES];
	}
    
    // Disable discovery entry
    [discoveryMenuItem setAction:nil];
    [discoveryMenuItem setEnabled:NO];
    [discoveryMenuItem setTarget:self];
    if (webService != nil && ![webService isSubscriber]) {
        [discoveryMenuItem setState:NSOffState];
    }
    
    // Disable record to profile entry if no connection available
    if (webService == nil) {
        [recordtoprofileMenuItem setAction:nil];
        [recordtoprofileMenuItem setEnabled:NO];
        [recordtoprofileMenuItem setTarget:self];
    } else {
        [recordtoprofileMenuItem setAction:@selector(changeRecordToProfileSettings:)];
        [recordtoprofileMenuItem setEnabled:YES]; 
        [recordtoprofileMenuItem setTarget:self];
    }
	
	if (!playing && !connecting) { // Stop state

        // add play most recent station button
        play = [[[NSMenuItem alloc] initWithTitle:@"Play Most Recent Station"
						action:@selector(playMostRecent:) keyEquivalent:@""] autorelease];
        [play setTarget:self];
        [menu insertItem:play atIndex:0];
        [playDialog setTarget:self];
        [play setAction:nil];
        [play setEnabled:NO];
        [playDialog setAction:nil];
        [playDialog setEnabled:NO];
		
		// Deactivate play menu item if no username/password or no web service
		// server is set, activate it otherwise
		if ([[preferences stringForKey:@"username"] isEqualToString:@""] ||
			[[keyChain genericPasswordForService:@"Amua"
					account:[preferences stringForKey:@"username"]] isEqualToString:@""] ||
			[[preferences stringForKey:@"webServiceServer"] isEqualToString:@""]) {

			NSMenuItem *hint = [[[NSMenuItem alloc] initWithTitle:@"Hint: Check Preferences"
                                        action:nil keyEquivalent:@""] autorelease];
			[hint setEnabled:NO];
			[menu insertItem:hint atIndex:0];
            [menu insertItem:[NSMenuItem separatorItem] atIndex:1];
            
        } else if (loginPhase) {
            NSMenuItem *hint = [[[NSMenuItem alloc] initWithTitle:@"Loging in..."
                                        action:nil keyEquivalent:@""] autorelease];
            [hint setEnabled:NO];
            [menu insertItem:hint atIndex:0];
            [menu insertItem:[NSMenuItem separatorItem] atIndex:1];
        } else if (webService == nil) {
			NSMenuItem *hint = [[[NSMenuItem alloc] initWithTitle:userMessage
									action:nil keyEquivalent:@""] autorelease];
			[hint setEnabled:NO];
			[menu insertItem:hint atIndex:0];
            [menu insertItem:[NSMenuItem separatorItem] atIndex:1];
            
            NSMenuItem *reconnect = [[[NSMenuItem alloc] initWithTitle:@"Try Again"
                                    action:@selector(tryAgain:) keyEquivalent:@""] autorelease];
            [reconnect setEnabled:YES];
            [reconnect setTarget:self];
			[menu insertItem:reconnect atIndex:2];
			
			[menu insertItem:[NSMenuItem separatorItem] atIndex:3];
			
        } else {
            if (userMessage != nil) {
                NSMenuItem *hint = [[[NSMenuItem alloc] initWithTitle:userMessage
                                                               action:nil keyEquivalent:@""] autorelease];
                [hint setEnabled:NO];
                [menu insertItem:hint atIndex:0];
                [menu insertItem:[NSMenuItem separatorItem] atIndex:1];
            }
            
            if ([webService isSubscriber]) {
                [discoveryMenuItem setAction:@selector(changeDiscoverySettings:)];
                [discoveryMenuItem setEnabled:YES]; 
                [discoveryMenuItem setTarget:self];
            }
            
			if ([recentStations stationsAvailable]) {
				[play setAction:@selector(playMostRecent:)];
				[play setEnabled:YES];
			} else {
				[play setAction:nil];
				[play setEnabled:NO];
			}
			[playDialog setTarget:stationController];
			[playDialog setAction:@selector(showWindow:)];
			[playDialog setEnabled:YES];
		}
		
	} else { // Playing state
			
        // Create menu items that are needed in play state
        NSMenuItem *nowPlayingTrack = [[[NSMenuItem alloc] initWithTitle:@"Connecting..."
												action:nil keyEquivalent:@""] autorelease];
        [nowPlayingTrack setTarget:self];
        [nowPlayingTrack setEnabled:NO];
			
        [menu insertItem:[NSMenuItem separatorItem] atIndex:0];
			
        NSMenuItem *love = [[[NSMenuItem alloc] initWithTitle:@"Love"
									action:nil keyEquivalent:@""] autorelease];
        [love setTarget:self];
        [love setEnabled:NO];
        [menu insertItem:love atIndex:1];
			
        NSMenuItem *skip = [[[NSMenuItem alloc] initWithTitle:@"Skip"
									action:nil keyEquivalent:@""] autorelease];
        [skip setTarget:self];
        [skip setEnabled:NO];
        [menu insertItem:skip atIndex:2];
			
        NSMenuItem *ban = [[[NSMenuItem alloc] initWithTitle:@"Ban"
									action:nil keyEquivalent:@""] autorelease];
        [ban setTarget:self];
        [ban setEnabled:NO];
        [menu insertItem:ban atIndex:3];
			
        [menu insertItem:[NSMenuItem separatorItem] atIndex:4];
		
        stop = [[[NSMenuItem alloc] initWithTitle:@"Stop"
                                           action:@selector(stop:) keyEquivalent:@""] autorelease];
        [stop setTarget:self];
        [stop setEnabled:YES];
        [menu insertItem:stop atIndex:5];
        
        if ([webService isSubscriber]) {
            [discoveryMenuItem setAction:@selector(changeDiscoverySettings:)];
            [discoveryMenuItem setEnabled:YES]; 
            [discoveryMenuItem setTarget:self];
        }

			
        // Enable the menu items for song information, love, skip and ban
        // if it is streaming
        if (webService != nil && [webService streaming] && playing) {
				
            NSString *songText = [[[webService nowPlayingArtist] stringByAppendingString:@" - "]
											stringByAppendingString:[webService nowPlayingTrack]];
            if ([songText length] > MAX_SONGTEXT_LENGTH) {
                // Shorten the songtext
                songText = [[songText substringToIndex:MAX_SONGTEXT_LENGTH] stringByAppendingString:@"..."];
            }
				
            [nowPlayingTrack setTitle:songText];
            if ([webService nowPlayingAlbumPage]) {
                [nowPlayingTrack setAction:@selector(openAlbumPage:)];
                [nowPlayingTrack setEnabled:YES];
            } else {
                [nowPlayingTrack setAction:nil];
                [nowPlayingTrack setEnabled:NO];
            }
            
            [love setAction:@selector(loveSong:)];
            [love setEnabled:YES];
            
            [skip setAction:@selector(skipSong:)];
            [skip setEnabled:YES];
            
            [ban setAction:@selector(banSong:)];
            [ban setEnabled:YES];
				
        }
        
        [menu insertItem:nowPlayingTrack atIndex:0];
		
	}
    
    [self updateRecentPlayedMenu];
	
	[menu update];
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
            if (webService == nil || loginPhase) {
                [stationItem setAction:nil];
                [stationItem setEnabled:NO];
            } else {
                [stationItem setEnabled:YES];
            }
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
	if (remainingTime < 5 || ![songInformationPanel hasNewSongInformations]) {
		remainingTime = 5;
	}
	
	if (timer != nil) {
		[timer release];
        timer = nil;
	}
    if (playing || connecting) {
		timer = [[NSTimer scheduledTimerWithTimeInterval:(remainingTime) target:self
				selector:@selector(fireTimer:) userInfo:nil repeats:NO] retain];
    }
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
    [self connectToServer];
	[self updateMenu];
}


- (void)handleHandshake:(NSNotification *)aNotification
{
    loginPhase = NO;
    userMessage = nil;
    [stationController setSubscriberMode:[webService isSubscriber]];
    [self updateMenu];
}


- (void)handleHandshakeFailed:(NSNotification *)aNotification
{
    connecting = NO;
	playing = NO;
    loginPhase = NO;
    
    if (webService != nil) {
        [webService release];
        webService = nil;
    }
    
    if (userMessage != nil) {
        [userMessage release];
    }
    userMessage = [[NSString alloc] initWithString:@"Status: Login Failed"];
    
	[self updateMenu];
}


- (void)handleStationTuned:(NSNotification *)aNotification
{
    [recentStations addStation:[webService stationURL]];
    if (!playing) {
        // Tell iTunes it should start playing.
        // Change this command if you want to control another player
        // that is apple-scriptable.
        NSString *scriptSource = [[@"tell application \"iTunes\" \n open location \""
								stringByAppendingString:[webService streamingServer]]
								stringByAppendingString:@"\" \n end tell"];
        NSAppleScript *script = [[NSAppleScript alloc] initWithSource:scriptSource];
        [script executeAndReturnError:nil];
    }
    
    connecting = NO;
    userMessage = nil;
    
    playing = YES;
    [webService updateNowPlayingInformation];
}


- (void)handleStationError:(NSNotification *)aNotification
{
    if (playing) {
        [self stop:self];
    }
    connecting = NO;
    
    if (userMessage != nil) {
        [userMessage release];
    }
    userMessage = [[NSString alloc] initWithString:@"Error: Station Not Streamable"];
    
	[self updateMenu];
}


- (void)handleUpdateNowPlayingInformation:(NSNotification *)aNotification
{
	NSString *artist = [webService nowPlayingArtist];
	NSString *album = [webService nowPlayingAlbum];
	NSString *title = [webService nowPlayingTrack];
	NSImage *image = [webService nowPlayingAlbumImage];
	
	NSString *radioStation = [webService nowPlayingRadioStation];
    if ([webService streaming]) {
        [songInformationPanel updateArtist:artist album:album track:title
                                albumImage:image radioStation:radioStation
                          radioStationUser:[webService nowPlayingRadioStationProfile]
                             trackPosition:[webService nowPlayingTrackProgress]
                             trackDuration:[webService nowPlayingTrackDuration]];
        // updated discovery setting from song information
        if ([webService isSubscriber]) {
            [discoveryMenuItem setState:[webService discoveryMode]];
        	[preferences setBool:[webService discoveryMode] forKey:@"discoveryMode"];
            [preferences synchronize];
    	}
        // verify that record to profile setting is correct
    	if ([webService recordToProfile] != [preferences boolForKey:@"recordToProfile"]) {
        	[webService executeControl:([preferences boolForKey:@"recordToProfile"] ? @"rtp" : @"nortp")];
    	}
    } else {
        WARNING(@"updating song information failed.");
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
    
    [self updateTimer];
	[self updateMenu];
}


- (void)handleCommandExecuted:(NSNotification *)aNotification
{
    userMessage = nil;
    if (![webService lastCommandWasLove]) {
        [webService updateNowPlayingInformation];
    }
}


- (void)handleConnectionError:(NSNotification *)aNotification
{
    if (playing) {
        [self stop:self];
    }
    
    connecting = NO;
	playing = NO;
    loginPhase = NO;
    
    if (webService != nil) {
        [webService release];
        webService = nil;
    }
    
    if (userMessage != nil) {
        [userMessage release];
    }
    userMessage = [[NSString alloc] initWithString:@"Status: Broken Connection"];
    
	[self updateMenu];
}


- (NSString *)md5:(NSString *)clear
{
    unsigned long long md[MD5_DIGEST_LENGTH]; // 128 bit
    
    MD5((unsigned char *)[clear UTF8String], strlen([clear UTF8String]), (unsigned char *)md);
    
    NSMutableString *md0 = [NSMutableString stringWithFormat:@"%qx", md[0]];
    NSMutableString *md1 = [NSMutableString stringWithFormat:@"%qx", md[1]];
    int z1 = 16 - [md0 length];
    int z2 = 16 - [md1 length];
    while (z1 > 0) {
        [md0 insertString:@"0" atIndex:0];
        z1--;
    }
    while (z2 > 0) {
        [md1 insertString:@"0" atIndex:0];
        z2--;
    }
    return [md0 stringByAppendingString:md1];
}


- (void)handleOpenUrl:(NSAppleEventDescriptor *)event
						withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
	NSString *filename = [[event paramDescriptorForKeyword: keyDirectObject]
								stringValue];
	if ([filename hasPrefix:@"lastfm"]) {
		[self playUrl:filename];
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
		ERROR(@"isDefaultLastfmPlayer: failure in plist");
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

@end
