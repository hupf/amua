#import "AmuaController.h"

@implementation AmuaController

-(id)init
{
    // Read in the XML file with the default preferences
	NSString * file = [[NSBundle mainBundle]
        pathForResource:@"Defaults" ofType:@"plist"];

    NSDictionary * defaultPreferences = [NSDictionary dictionaryWithContentsOfFile:file];
	
	preferences = [[NSUserDefaults standardUserDefaults] retain];
    [preferences registerDefaults:defaultPreferences];
	
	return self;
}

- (void)awakeFromNib
{
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];

    [statusItem setTitle:[NSString stringWithFormat:@"%C",0x266A]];
    [statusItem setHighlightMode:YES];
    [statusItem setMenu:menu];
    [statusItem setEnabled:YES];
}

- (IBAction)loveSong:(id)sender
{
}

- (IBAction)skipSong:(id)sender
{
}

- (IBAction)banSong:(id)sender
{
}

- (IBAction)playStop:(id)sender
{
	/* TODO:
		- get username and password from preferences
		- create new session
		- start playing with following applescript command:
			'tell application "iTunes" \n open location "' + URL + '" \n end tell'
		- update user interface
	*/
}

- (IBAction)openLastfmHomepage:(id)sender
{
	NSURL *url = [NSURL URLWithString:@"http://www.last.fm/"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)openPersonalPage:(id)sender
{
	NSString *prefix = @"http://www.last.fm/user/";
    NSURL *url = [NSURL URLWithString:[prefix stringByAppendingString:[preferences stringForKey:@"username"]]];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)openPreferences:(id)sender
{
    if(!preferencesController)
        preferencesController=[[PreferencesController alloc] init];

    //[preferenceController takeValue:[self lastResult] forKey:@"lastResult"];
    
    //if([songQueue count] != 0)
    //    [preferenceController takeValue:[songQueue objectAtIndex:0] forKey:@"songData"];

    [NSApp activateIgnoringOtherApps:YES];
    [[preferencesController window] makeKeyAndOrderFront:nil];
}

@end
