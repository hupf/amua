//
//  AmuaController.m
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

#import "AmuaController.h"

@implementation AmuaController

-(id)init
{
    // Read in the XML file with the default preferences
	NSString *file = [[NSBundle mainBundle]
        pathForResource:@"Defaults" ofType:@"plist"];

    NSDictionary *defaultPreferences = [NSDictionary dictionaryWithContentsOfFile:file];
	
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
	
	return self;
}

- (void)awakeFromNib
{	
	// Add an menu item to the status bar
	statusItem = [[[NSStatusBar systemStatusBar]
					statusItemWithLength:NSSquareStatusItemLength] retain];
	view = [[AmuaView alloc] initWithFrame:[[statusItem view] frame] statusItem:statusItem menu:menu];
	[statusItem setView:view];
	
	// listen to mouse events of AmoaView
	[view addMouseOverListener];
	
	[self updateMenu];
}

- (void)play:(id)sender
{
	playing = YES;
	[self updateMenu];
	
	// Determine radio station type
	NSString *radioStation;
	switch ([[preferences stringForKey:@"radioStation"] intValue]) {
		case 0:
			radioStation = @"profile";
		break;
		case 1:
			radioStation = @"personal";
		break;
		case 2:
			radioStation = @"random";
	}
	
	// Create web service object
	webService = [[LastfmWebService alloc]
					initWithWebServiceServer:[preferences stringForKey:@"webServiceServer"]
					withRadioStation:radioStation
					asUserAgent:[preferences stringForKey:@"userAgent"]];
	[webService createSessionForUser:[preferences stringForKey:@"username"]
		withPasswordHash:[self md5:[preferences stringForKey:@"password"]]];
}

- (void)stop:(id)sender
{
	playing = NO;
	[self updateMenu];

	[webService release];
	
	// Tell iTunes it should stop playing.
	// Change this command if you want to control another player that is apple-scriptable.
	NSString *scriptSource = @"tell application \"iTunes\" \n playpause \n end tell";
	NSAppleScript *script = [[NSAppleScript alloc] initWithSource:scriptSource];
	[script executeAndReturnError:nil];
	
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
	[timer release];
	timer = [[NSTimer scheduledTimerWithTimeInterval:(5) target:webService
				selector:@selector(updateNowPlayingInformation:) userInfo:nil repeats:NO] retain];
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
	[timer release];
	timer = [[NSTimer scheduledTimerWithTimeInterval:(5) target:webService
				selector:@selector(updateNowPlayingInformation:) userInfo:nil repeats:NO] retain];
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

- (void)showTooltip:(id)sender
{

	NSString *artist = [webService nowPlayingArtist];
	NSString *album = [webService nowPlayingAlbum];
	NSString *title = [webService nowPlayingTrack];
	NSImage *tooltipImage = [webService nowPlayingAlbumImage];
	
	if (artist && album && title && tooltipImage && playing) {
		// format the tooltip content
		NSDictionary *labelAttributes = [[[NSDictionary dictionaryWithObjectsAndKeys:[NSFont boldSystemFontOfSize:10], NSFontAttributeName, nil] retain] autorelease];
		NSDictionary *textAttributes = [[[NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:10], NSFontAttributeName, nil] retain] autorelease];
		NSAttributedString *artistLabel = [[[NSAttributedString alloc] initWithString:@"Artist\t" attributes:labelAttributes] autorelease];
		NSAttributedString *albumLabel = [[[NSAttributedString alloc] initWithString:@"\nAlbum\t" attributes:labelAttributes] autorelease];
		NSAttributedString *titleLabel = [[[NSAttributedString alloc] initWithString:@"\nTitle\t\t" attributes:labelAttributes] autorelease];
		NSAttributedString *artistText = [[[NSAttributedString alloc] initWithString:artist attributes:textAttributes] autorelease];
		NSAttributedString *albumText = [[[NSAttributedString alloc] initWithString:album attributes:textAttributes] autorelease];
		NSAttributedString *titleText = [[[NSAttributedString alloc] initWithString:title attributes:textAttributes] autorelease];
		NSMutableAttributedString *tooltipTitle = [[[NSMutableAttributedString alloc] init] autorelease];
		[[[[[[tooltipTitle appendAttributedString:artistLabel]
							appendAttributedString:artistText]
							appendAttributedString:albumLabel]
							appendAttributedString:albumText]
							appendAttributedString:titleLabel]
							appendAttributedString:titleText];
								
		NSString *radioStation = [webService nowPlayingRadioStation];
		NSAttributedString *tooltipBody;
		if ([radioStation isEqualToString:@"Profile Radio"]) {
			tooltipBody = [[[NSAttributedString alloc] initWithString:[[radioStation stringByAppendingString:@" feeding from "]
								stringByAppendingString:[webService nowPlayingRadioStationProfile]]] autorelease];
		} else {
			tooltipBody = [[[NSAttributedString alloc] initWithString:radioStation] autorelease];
		}
		
		// get mouse location
		NSPoint point = [NSEvent mouseLocation];
		
		// create the tooltip window
		[AITooltipUtilities showTooltipWithTitle:tooltipTitle
												body:tooltipBody
												image:tooltipImage 
												imageOnRight:NO
												onWindow:nil
												atPoint:point
												orientation:TooltipBelow];
	}
	mouseIsOverIcon = YES;

}

- (void)hideTooltip:(id)sender
{
	// remove the tooltip window
	[AITooltipUtilities showTooltipWithString:@"" onWindow:nil atPoint:NSMakePoint(0,0) orientation:nil];
	mouseIsOverIcon = NO;
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
		
		NSMenuItem *play = [menu itemWithTitle:@"Play"];
		if (play == nil) {
		
			// Remove all menu items until stop item if it exists
			int stopIndex = [menu indexOfItemWithTitle:@"Stop"];
			int i;
			for (i=0; i<=stopIndex; i++) {
				[menu removeItemAtIndex:0];
			}
			
			play = [[[NSMenuItem alloc] initWithTitle:@"Play"
						action:@selector(play:) keyEquivalent:@""] autorelease];
			[play setTarget:self];
			[menu insertItem:play atIndex:0];
			
		}
		
		// Deactivate play menu item if no username/password or no web service
		// server is set, activate it otherwise
		if ([[preferences stringForKey:@"username"] isEqualToString:@""] ||
			[[preferences stringForKey:@"password"] isEqualToString:@""] ||
			[[preferences stringForKey:@"webServiceServer"] isEqualToString:@""]) {
			
			[play setAction:nil];
			[play setEnabled:NO];
			
			NSMenuItem *hint = [[[NSMenuItem alloc] initWithTitle:@"Hint: Check Preferences"
									action:nil keyEquivalent:@""] autorelease];
			[hint setEnabled:NO];
			[menu insertItem:hint atIndex:0];
			
			[menu insertItem:[NSMenuItem separatorItem] atIndex:1];
			
		} else {
			[play setAction:@selector(play:)];
			[play setEnabled:YES];
			[play setTitle:@"Play"];
			
			// Remove hint item if it exists
			int hintIndex = [menu indexOfItemWithTitle:@"Hint: Check Preferences"];
			if (hintIndex != -1) {
				[menu removeItemAtIndex:hintIndex];
				[menu removeItemAtIndex:hintIndex];
			}
		}
		
	} else { // Playing state
	
		NSMenuItem *stop = [menu itemWithTitle:@"Play"];
		
		if (stop != nil) { // Were in stop state previously
			
			// Remove all menu items until (without) play item
			int playIndex = [menu indexOfItemWithTitle:@"Play"];
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
				
				[nowPlayingTrack setTitle:[[[webService nowPlayingArtist] stringByAppendingString:@" - "]
											stringByAppendingString:[webService nowPlayingTrack]]];
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

- (void)updateTimer
{
	// Set the timer to fire after the currently playing song will be finished.
	// If no song is playing or the song is almost finished, fire it in five seconds.
	int remainingTime = [webService nowPlayingTrackDuration] - [webService nowPlayingTrackProgress];
	if (remainingTime < 5) {
		remainingTime = 5;
	}
	
	[timer release];
	timer = [[NSTimer scheduledTimerWithTimeInterval:(remainingTime) target:webService
				selector:@selector(updateNowPlayingInformation:) userInfo:nil repeats:NO] retain];
}

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
	
	// Set the timer so that in five seconds the new song information will be fetched
	timer = [[NSTimer scheduledTimerWithTimeInterval:(5) target:webService
				selector:@selector(updateNowPlayingInformation:) userInfo:nil repeats:NO] retain];
}

- (void)handleUpdateNowPlayingInformation:(NSNotification *)aNotification
{
	[self updateTimer];
	[self updateMenu];
	
	// show updated tooltip if necessary 
	if (![view menuIsVisible]) {
		if (mouseIsOverIcon) {
			[self showTooltip:self];
		}
	}
}

- (void)handleStartPlayingError:(NSNotification *)aNotification
{
	playing = NO;
	[self updateMenu];
	
	NSMenuItem *error = [[[NSMenuItem alloc] initWithTitle:@"Connection Error"
								action:nil keyEquivalent:@""] autorelease];
	[error setEnabled:NO];
	[menu insertItem:error atIndex:0];
	
	[menu insertItem:[NSMenuItem separatorItem] atIndex:1];
}

- (NSString *)md5:(NSString *)clearTextString
{
	// Why the heck can't they provide a simple and stupid md5() method!?
	NSData *seedData = [[SSCrypto getKeyDataWithLength:32] retain];
    SSCrypto *crypto = [[[SSCrypto alloc] initWithSymmetricKey:seedData] autorelease];
	[crypto setClearTextWithString:clearTextString];
	
	// And why does NSData make such a f****** fancy output!? What for? To parse it out again???
	NSString *md5Hash = [[crypto digest:@"MD5"] description];
	md5Hash = [[[[NSString stringWithString:[md5Hash substringWithRange:NSMakeRange(1, 8)]]
					stringByAppendingString:[md5Hash substringWithRange:NSMakeRange(10, 8)]]
					stringByAppendingString:[md5Hash substringWithRange:NSMakeRange(19, 8)]]
					stringByAppendingString:[md5Hash substringWithRange:NSMakeRange(28, 8)]];
	[crypto release];
	[seedData release];
	
	return md5Hash;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	if (playing) {
		[self stop:self];
	}
}

@end
