//
//  PreferencesController.m
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

#import "PreferencesController.h"

@implementation PreferencesController

-(id)init
{
    if(self = [super initWithWindowNibName:@"Preferences"]) {
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

-(void)windowWillClose:(NSNotification *)aNotification
{
	// Update the fields for the next time the window will be opened
	[self updateFields];
}

- (IBAction)cancel:(id)sender
{
	[[self window] performClose:nil];
}

- (IBAction)save:(id)sender
{
	// Save the actual field contents to harddisk
	[preferences setInteger:[radioStation indexOfSelectedItem] forKey:@"radioStation"];
	[preferences setInteger:[recordToProfile state] forKey:@"recordToProfile"];
	[preferences setObject:[username stringValue] forKey:@"username"];
	[preferences setObject:[password stringValue] forKey:@"password"]; // TODO: security!
	[preferences setObject:[webServiceServer stringValue] forKey:@"webServiceServer"];
	
	[preferences synchronize];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PreferencesChanged" object:self];
		
	[[self window] performClose:nil];
}

- (IBAction)setDefaults:(id)sender
{	
	// Read in the XML file with the default preferences
	NSString *file = [[NSBundle mainBundle]
        pathForResource:@"Defaults" ofType:@"plist"];

    NSDictionary *defaultPreferences = [NSDictionary dictionaryWithContentsOfFile:file];
	
	// Fill the fields with the factory defaults
	[radioStation selectItemAtIndex:[[defaultPreferences objectForKey:@"radioStation"] intValue]];
	[recordToProfile setState:[[defaultPreferences objectForKey:@"recordToProfile"] intValue]];
	[username setStringValue:[defaultPreferences objectForKey:@"username"]];
	[password setStringValue:[defaultPreferences objectForKey:@"password"]];
	[webServiceServer setStringValue:[defaultPreferences objectForKey:@"webServiceServer"]];
}

- (void)updateFields
{
	// Fill the fields with the saved content from the harddisk
	[radioStation selectItemAtIndex:[preferences integerForKey:@"radioStation"]];
	[recordToProfile setState:[preferences integerForKey:@"recordToProfile"]];
	[username setStringValue:[preferences stringForKey:@"username"]];
	[password setStringValue:[preferences stringForKey:@"password"]];
	[webServiceServer setStringValue:[preferences stringForKey:@"webServiceServer"]];
}

- (void)dealloc
{
    [preferences release];
    [super dealloc];
}

@end
