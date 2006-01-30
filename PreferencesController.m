//
//  PreferencesController.m
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

#import "PreferencesController.h"

@implementation PreferencesController

- (id)init
{
    if(self = [super initWithWindowNibName:@"Preferences"]) {
        [self setWindowFrameAutosaveName:@"PreferencesWindow"];
    }
	
	keyChain = [[KeyChain alloc] init];
	
    preferences = [[NSUserDefaults standardUserDefaults] retain];
    
    return self;
}


- (void)windowDidLoad
{
    [self updateFields];
    [window makeMainWindow];
}


- (void)windowWillClose:(NSNotification*)aNotification
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
	[preferences setObject:[webServiceServer stringValue] forKey:@"webServiceServer"];
    [preferences setBool:([defaultCheckBox state] == NSOnState)
    		     forKey:@"performDefaultPlayerCheck"];
    [preferences setBool:([updatesCheckBox state] == NSOnState)
    		     forKey:@"performUpdatesCheck"];
	
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
	NSString* file = [[NSBundle mainBundle]
        pathForResource:@"Defaults" ofType:@"plist"];

    NSDictionary* defaultPreferences = [NSDictionary dictionaryWithContentsOfFile:file];
	
	// Fill the fields with the factory defaults
	[username setStringValue:[defaultPreferences objectForKey:@"username"]];
	[password setStringValue:@""];
	[webServiceServer setStringValue:[defaultPreferences objectForKey:@"webServiceServer"]];
    if ([defaultPreferences valueForKey:@"performDefaultPlayerCheck"]) {
    	[defaultCheckBox setState:NSOnState];
    } else {
    	[defaultCheckBox setState:NSOffState];
    }
    if ([defaultPreferences valueForKey:@"performUpdatesCheck"]) {
    	[updatesCheckBox setState:NSOnState];
    } else {
    	[updatesCheckBox setState:NSOffState];
    }
}


- (void)updateFields
{
	// Fill the fields with the saved content from the harddisk
	[username setStringValue:[preferences stringForKey:@"username"]];
	[password setStringValue:[keyChain genericPasswordForService:@"Amua"
                                       account:[preferences stringForKey:@"username"]]];
	[webServiceServer setStringValue:[preferences stringForKey:@"webServiceServer"]];
    if ([preferences boolForKey:@"performDefaultPlayerCheck"]) {
    	[defaultCheckBox setState:NSOnState];
    } else {
    	[defaultCheckBox setState:NSOffState];
    }
    if ([preferences boolForKey:@"performUpdatesCheck"]) {
    	[updatesCheckBox setState:NSOnState];
    } else {
    	[updatesCheckBox setState:NSOffState];
    }
}

- (IBAction)checkForUpdates:(id)sender
{
	AmuaUpdater* updater = [[[AmuaUpdater alloc] init] autorelease];
    [updater setVerbose:YES];
	[updater checkForUpdates];
}


- (void)dealloc
{
    [preferences release];
    [super dealloc];
}

@end
