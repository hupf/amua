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
	
	keyChain = [[KeyChain alloc] init];
	
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
	[preferences setObject:[username stringValue] forKey:@"username"];
	[preferences setInteger:[radioStation indexOfSelectedItem] forKey:@"radioStation"];
	[preferences setObject:[stationUser stringValue] forKey:@"stationUser"];
	[preferences setObject:[webServiceServer stringValue] forKey:@"webServiceServer"];
	
	[preferences synchronize];
	
	// Save password to the keychain
	if(![[password stringValue] isEqualToString:@""])
    {
        [keyChain setGenericPassword:[password stringValue]
					forService:@"Amua"
					account:[preferences stringForKey:@"username"]];
	}
	
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
	[username setStringValue:[defaultPreferences objectForKey:@"username"]];
	[password setStringValue:@""];
	[radioStation selectItemAtIndex:[[defaultPreferences objectForKey:@"radioStation"] intValue]];
	[stationUser setStringValue:[defaultPreferences objectForKey:@"stationUser"]];
	[stationDifferentUser setState:NSOffState];
	[stationUser setStringValue:[defaultPreferences objectForKey:@"stationUser"]];
	[stationUser setEnabled:NO];
	[webServiceServer setStringValue:[defaultPreferences objectForKey:@"webServiceServer"]];
}

- (void)updateFields
{
	// Fill the fields with the saved content from the harddisk
	[username setStringValue:[preferences stringForKey:@"username"]];
	[password setStringValue:[keyChain genericPasswordForService:@"Amua"
                                       account:[preferences stringForKey:@"username"]]];
	[radioStation selectItemAtIndex:[preferences integerForKey:@"radioStation"]];
	if ([[preferences stringForKey:@"stationUser"] isEqualToString:@""] ||
			[[preferences stringForKey:@"stationUser"] isEqualToString:[preferences stringForKey:@"username"]]) {
		[stationDifferentUser setState:NSOffState];
		[stationUser setStringValue:@""];
		[stationUser setEnabled:NO];
	} else {
		[stationDifferentUser setState:NSOnState];
		[stationUser setStringValue:[preferences stringForKey:@"stationUser"]];
		[stationUser setEnabled:YES];
	}
	[webServiceServer setStringValue:[preferences stringForKey:@"webServiceServer"]];
}

- (IBAction)stationUserToggle:(id)sender
{
	if ([stationDifferentUser state] == NSOnState) {
		[stationUser setEnabled:YES];
	} else {
		[stationUser setStringValue:@""];
		[stationUser setEnabled:NO];
	}
}

- (IBAction)stationChanged:(id)sender
{
	if ([[radioStation titleOfSelectedItem] isEqualToString:@"Random Radio"]) {
		[stationDifferentUser setEnabled:NO];
		[stationDifferentUser setState:NSOffState];
		[stationUser setEnabled:NO];
		[stationUser setStringValue:@""];
	} else {
		[stationDifferentUser setEnabled:YES];
		if ([stationDifferentUser state] == NSOnState) {
			[stationUser setEnabled:YES];
		} else {
			[stationUser setEnabled:NO];
		}
	}
}

- (void)dealloc
{
    [preferences release];
    [super dealloc];
}

@end
