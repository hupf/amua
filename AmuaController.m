//
//  AmuaController.m
//  Amua
//
//  Created by Mathis and Simon Hofer on 17.02.05.
//  Copyright 2005 Mathis & Simon Hofer.
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
	
	// Register handle for requested update of
	// actual playing song information from LastfmWebService
	[[NSNotificationCenter defaultCenter] addObserver:self
				selector:@selector(handleUpdateNowPlayingInformation:)
				name:@"UpdateNowPlayingInformation"	object:nil];
				
	playing = NO;
	
	return self;
}

- (void)awakeFromNib
{
	statusItem = [[[NSStatusBar systemStatusBar]
					statusItemWithLength:NSSquareStatusItemLength] retain];

    [statusItem setTitle:[NSString stringWithFormat:@"%C",0x266A]]; // Fancy note as icon
    [statusItem setHighlightMode:YES];
    [statusItem setMenu:menu];
    [statusItem setEnabled:YES];
	
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
	
	NSString *scriptSource = @"tell application \"iTunes\" \n playpause \n end tell";
	NSAppleScript *script = [[NSAppleScript alloc] initWithSource:scriptSource];
	[script executeAndReturnError:nil];
}

- (void)loveSong:(id)sender
{
	[webService executeControl:@"love"];
	
	[timer release];
	timer = [[NSTimer scheduledTimerWithTimeInterval:(5) target:webService
				selector:@selector(updateNowPlayingInformation:) userInfo:nil repeats:NO] retain];
}

- (void)skipSong:(id)sender
{
	[webService executeControl:@"skip"];
	
	NSMenuItem *nowPlayingTrack = [menu itemAtIndex:0];
	[nowPlayingTrack setAction:nil];
	[nowPlayingTrack setEnabled:NO];
	
	[timer release];
	timer = [[NSTimer scheduledTimerWithTimeInterval:(5) target:webService
				selector:@selector(updateNowPlayingInformation:) userInfo:nil repeats:NO] retain];
}

- (void)banSong:(id)sender
{
	[webService executeControl:@"ban"];
	
	NSMenuItem *nowPlayingTrack = [menu itemAtIndex:0];
	[nowPlayingTrack setAction:nil];
	[nowPlayingTrack setEnabled:NO];
	
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

- (void)updateMenu
{
	// Disable personal page link if no username is set
	NSMenuItem *personalPage = [menu itemWithTitle:@"Personal Page"];
	if ([[preferences stringForKey:@"username"] isEqualToString:@""]) {
		[personalPage setAction:nil];
		[personalPage setEnabled:NO];
	} else {
		[personalPage setAction:@selector(openPersonalPage:)];
		[personalPage setEnabled:YES];
	}
	
	if (!playing) {
		
		NSMenuItem *play = [menu itemWithTitle:@"Play"];
		if (play == nil) {
			// Remove all menu items till stop item if it exists
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
		
		if ([[preferences stringForKey:@"username"] isEqualToString:@""] ||
			[[preferences stringForKey:@"password"] isEqualToString:@""] ||
			[[preferences stringForKey:@"webServiceServer"] isEqualToString:@""]) {
			[play setAction:nil];
			[play setEnabled:NO];
			
			NSMenuItem *hint = [[[NSMenuItem alloc] initWithTitle:@"Hint: Check Preferences"
									action:nil keyEquivalent:@""] autorelease];
			[hint setEnabled:NO];
			[menu insertItem:[NSMenuItem separatorItem] atIndex:0];
			[menu insertItem:hint atIndex:0];
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
		
	} else {
	
		NSMenuItem *stop = [menu itemWithTitle:@"Play"];
		
		if (stop != nil) {
			
			NSMenuItem *nowPlayingTrack = [[[NSMenuItem alloc] initWithTitle:@"Loading..."
												action:nil keyEquivalent:@""] autorelease];
			[nowPlayingTrack setTarget:self];
			[nowPlayingTrack setEnabled:NO];
			[menu insertItem:nowPlayingTrack atIndex:0];
			
			[menu insertItem:[NSMenuItem separatorItem] atIndex:1];
			
			NSMenuItem *love = [[[NSMenuItem alloc] initWithTitle:@"Love"
									action:@selector(loveSong:) keyEquivalent:@""] autorelease];
			[love setTarget:self];
			[menu insertItem:love atIndex:2];
			NSMenuItem *skip = [[[NSMenuItem alloc] initWithTitle:@"Skip"
									action:@selector(skipSong:) keyEquivalent:@""] autorelease];
			[skip setTarget:self];
			[menu insertItem:skip atIndex:3];
			NSMenuItem *ban = [[[NSMenuItem alloc] initWithTitle:@"Ban"
									action:@selector(banSong:) keyEquivalent:@""] autorelease];
			[ban setTarget:self];
			[menu insertItem:ban atIndex:4];
			
			[menu insertItem:[NSMenuItem separatorItem] atIndex:5];
			
			[stop setTitle:@"Stop"];
			[stop setAction:@selector(stop:)];
			
		} else {
			
			NSMenuItem *nowPlayingTrack = [menu itemAtIndex:0];
			if ([webService streaming]) {
				[nowPlayingTrack setTitle:[[[webService nowPlayingArtist] stringByAppendingString:@" - "]
											stringByAppendingString:[webService nowPlayingTrack]]];
				[nowPlayingTrack setAction:@selector(openAlbumPage:)];
				[nowPlayingTrack setEnabled:YES];
			} else {
				[nowPlayingTrack setEnabled:NO];
			}
			
		}
		
		
	}
}

- (void)updateTimer
{
	int remainingTime = [webService nowPlayingTrackDuration] - [webService nowPlayingTrackProgress];
	if (remainingTime < 5) {
		remainingTime = 5;
	}
	NSLog(@"%i", remainingTime);
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
	NSString *scriptSource = [[@"tell application \"iTunes\" \n open location \""
								stringByAppendingString:[webService streamingServer]]
								stringByAppendingString:@"\" \n end tell"];
	NSAppleScript *script = [[NSAppleScript alloc] initWithSource:scriptSource];
	[script executeAndReturnError:nil];
	
	timer = [[NSTimer scheduledTimerWithTimeInterval:(5) target:webService
				selector:@selector(updateNowPlayingInformation:) userInfo:nil repeats:NO] retain];
}

- (void)handleUpdateNowPlayingInformation:(NSNotification *)aNotification
{
	[self updateTimer];
	[self updateMenu];
}

- (NSString *)md5:(NSString *)clearTextString
{
	// Why the heck can't they provide a simple and stupid md5() method!?
	NSData *seedData = [[SSCrypto getKeyDataWithLength:32] retain];
    SSCrypto *crypto = [[[SSCrypto alloc] initWithSymmetricKey:seedData] autorelease];
	[crypto setClearTextWithString:clearTextString];
	
	// And why does NSData make such a fancy output!? What for? To parse it out again???
	NSString *md5Hash = [[crypto digest:@"MD5"] description];
	md5Hash = [[[[NSString stringWithString:[md5Hash substringWithRange:NSMakeRange(1, 8)]]
					stringByAppendingString:[md5Hash substringWithRange:NSMakeRange(10, 8)]]
					stringByAppendingString:[md5Hash substringWithRange:NSMakeRange(19, 8)]]
					stringByAppendingString:[md5Hash substringWithRange:NSMakeRange(28, 8)]];
	[crypto release];
	[seedData release];
	
	return md5Hash;
}

@end
