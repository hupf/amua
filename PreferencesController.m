#import "PreferencesController.h"

@implementation PreferencesController

-(id)init
{
    if(self=[super initWithWindowNibName:@"Preferences"]){
        [self setWindowFrameAutosaveName:@"PreferencesWindow"];
    }

    preferences = [[NSUserDefaults standardUserDefaults] retain];
    
    return self;
}

-(void)windowDidLoad
{
    [self updateFields];
    [window makeMainWindow];
}

- (IBAction)cancel:(id)sender
{
	[[self window] performClose:nil];
}

- (IBAction)save:(id)sender
{
	[preferences setObject:[username stringValue] forKey:@"username"];
	[preferences setObject:[password stringValue] forKey:@"password"]; // TODO: security!
	[preferences setObject:[webServiceServer stringValue] forKey:@"webServiceServer"];
	[preferences setObject:[streamingServer stringValue] forKey:@"streamingServer"];
	
	[preferences synchronize];
	
	[[self window] performClose:nil];
}

- (void)updateFields
{
	[username setStringValue:[preferences stringForKey:@"username"]];
	[password setStringValue:[preferences stringForKey:@"password"]];
	[webServiceServer setStringValue:[preferences stringForKey:@"webServiceServer"]];
	[streamingServer setStringValue:[preferences stringForKey:@"streamingServer"]];
}

- (void)dealloc
{
    [preferences release];
    [super dealloc];
}

@end
