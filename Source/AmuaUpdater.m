//
//  AmuaUpdater.m
//  Amua
//
//  Created by Mathis & Simon Hofer on 06.03.05.
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

#import "AmuaUpdater.h"

@implementation AmuaUpdater

- (id)init
{
    self = [super init];
	NSString *file = [[NSBundle mainBundle]
        pathForResource:@"Defaults" ofType:@"plist"];

    NSDictionary *defaultPreferences = [NSDictionary dictionaryWithContentsOfFile:file];
	
	preferences = [[NSUserDefaults standardUserDefaults] retain];
    [preferences registerDefaults:defaultPreferences];
	
	[self upgradeConfigFile];
    
    verbose = NO;
    updateUrl = nil;
	
	return self;
}


- (void)setVerbose:(bool)v
{
	verbose = v;
}


- (void)checkForUpdates
{
    updateRequest = [[AMWebserviceRequest plainRequestWithDelegate:self] retain];
    [updateRequest startWithURL:[NSURL URLWithString:[preferences stringForKey:@"updateURL"]]];
    self = [self retain];
}


- (void)finishCheckForUpdates:(id)sender
{
	if (sender == notification) {
    	if ([notification clickedButton] == YES_BUTTON_CLICKED) {
        	[[NSWorkspace sharedWorkspace] openURL:updateUrl];
        }
        [updateUrl release];
        updateUrl = nil;
        
        [preferences setBool:[notification dismissState] forKey:@"performUpdatesCheck"];
    }
    
	[sender release];
}


- (void)upgradeConfigFile
{
	// Upgrade from version 0.3 (that had no version attribute) to version 0.4
	if ([preferences objectForKey:@"version"] == nil) {
		// Remove password from plist file and add it to keychain
		if ([preferences objectForKey:@"password"] != nil) {
			KeyChain *keyChain = [[[KeyChain alloc] init] autorelease];
			[keyChain setGenericPassword:[preferences stringForKey:@"password"]
						forService:@"Amua"
						account:[preferences stringForKey:@"username"]];
			[preferences removeObjectForKey:@"password"];
		}
		
		[preferences setObject:@"0.4" forKey:@"version"];
		[preferences setInteger:1 forKey:@"showPossibleUpdateDialog"];
		[preferences synchronize];
	}
	
	// Upgrade from version 0.4 to 0.5
	if ([[preferences objectForKey:@"version"] isEqualToString:@"0.4"]) {
		// No changes in configuration file
        
		[preferences setObject:@"0.5" forKey:@"version"];
		[preferences setInteger:1 forKey:@"showPossibleUpdateDialog"];
		[preferences synchronize];
	}
    
	// Upgrade from version 0.5 to 0.5.1
	if ([[preferences objectForKey:@"version"] isEqualToString:@"0.5"]) {
		// Add preferences values for discovery mode and record to profile
        [preferences setBool:NO forKey:@"discoveryMode"];
        [preferences setBool:YES forKey:@"recordToProfile"];
        // Add flag for default player check and updates check
        [preferences setBool:YES forKey:@"performDefaultPlayerCheck"];
        [preferences setBool:YES forKey:@"performUpdatesCheck"];
        [preferences removeObjectForKey:@"showPossibleUpdateDialog"];
		
        [preferences setObject:@"0.5.1" forKey:@"version"];
		[preferences synchronize];
	}
    
    // Upgrade from version 0.5.1 to 0.5.2
	if ([[preferences objectForKey:@"version"] isEqualToString:@"0.5.1"]) {
		// No changes in configuration file
		
        [preferences setObject:@"0.5.2" forKey:@"version"];
		[preferences synchronize];
	}
    
    // Upgrade from version 0.5.2 to 0.5.3
	if ([[preferences objectForKey:@"version"] isEqualToString:@"0.5.2"]) {
		[preferences setObject:@"ws.audioscrobbler.com" forKey:@"webServiceServer"];
        [preferences setObject:@"0.5.3" forKey:@"version"];
		[preferences synchronize];
	}
    
    // Upgrade from version 0.5.3 to 0.5.4
	if ([[preferences objectForKey:@"version"] isEqualToString:@"0.5.3"]) {
        // no changes
        
        [preferences setObject:@"0.5.4" forKey:@"version"];
		[preferences synchronize];
	}
    
    // Upgrade from version 0.5.4 to 0.5.5
	if ([[preferences objectForKey:@"version"] isEqualToString:@"0.5.4"]) {
        // no changes
        
        [preferences setObject:@"0.5.5" forKey:@"version"];
		[preferences synchronize];
	}
    
    // Upgrade from version 0.5.5 to 0.5.6
	if ([[preferences objectForKey:@"version"] isEqualToString:@"0.5.5"]) {
        // no changes
        
        [preferences setObject:@"0.5.6" forKey:@"version"];
		[preferences synchronize];
	}
    
    if ([[preferences objectForKey:@"version"] isEqualToString:@"0.5.6"]) {
        // no changes
        
        [preferences setObject:@"0.5.7" forKey:@"version"];
		[preferences synchronize];
	}
	
	// Make sure, the version is written into the user's preferences file, also
	// if it's not an upgrade but a new installation
	[preferences setObject:[preferences objectForKey:@"version"] forKey:@"version"];
	[preferences synchronize];
}


- (void)requestHasFinished:(AMWebserviceRequest *)request withData:(NSObject *)data
{
    NSDictionary *parsedData = (NSDictionary *)data;
    
    // check if the online version is more recent
	if (parsedData != nil && ![[parsedData objectForKey:@"version"] isEqualToString:[preferences stringForKey:@"version"]]) {
    	updateUrl = [[NSURL alloc] initWithString:[parsedData objectForKey:@"URL"]];
		NSString *body = [[@"Amua " stringByAppendingString:[parsedData objectForKey:@"version"]]
								stringByAppendingString:@" is available. Would you like to download the new version?"];
        notification = [[AMNotification alloc] initWithTitle:@"Amua Update" withDescription:body
                                           withDismissText:@"Always check for updates at startup"
                                              dismissState:[preferences boolForKey:@"performUpdatesCheck"]
                                             yesButtonText:@"Get New Version"
                                              noButtonText:@"Not yet"
                                                    action:@selector(finishCheckForUpdates:)
                                                    target:self];
		[notification display];
	} else if (verbose) {
    	NSRunAlertPanel(@"Amua", @"Your version is up to date.", @"OK", nil, nil);
    }
    
    if (updateRequest != nil) {
        [updateRequest release];
        updateRequest = nil;
    }
    
    [self release];
}


- (void)requestHasFailed:(AMWebserviceRequest *)request
{
    if (updateRequest != nil) {
        [updateRequest release];
        updateRequest = nil;
    }
    
    [self release];
}


- (void)dealloc
{
	[preferences release];
    if (updateUrl != nil) {
    	[updateUrl release];
    }
    
	[super dealloc];
}

@end
