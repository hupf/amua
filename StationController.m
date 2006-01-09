//
//  StationController.m
//  Amua
//
//  Created by Mathis & Simon Hofer on 09.12.05.
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

#import "StationController.h"

#define ARTIST_STATION_TYPE 1
#define USER_STATION_TYPE 2
#define CUSTOM_STATION_TYPE 3

@implementation StationController

- (void)awakeFromNib
{
	[artistSimilarResultList setTarget:amuaController];
	[artistSimilarResultList setDoubleAction:@selector(play:)];
}

- (IBAction)stationDataChanged:(id)sender
{
	switch (selectedStationType) {
		case USER_STATION_TYPE:
			if ([userCheckBox state] == 1) {
				[username setEnabled:YES];
				[username setStringValue:@""];
			} else {
				[username setEnabled:NO];
				[username setStringValue:[preferences stringForKey:@"username"]];
			}
			break;
	}
}

- (IBAction)stationTypeChanged:(id)sender
{
	if (stationType == sender) {
		
		// hide all views
		[artistView setHidden:YES];
		[userView setHidden:YES];
		[customURLView setHidden:YES];
		
		// change size and visibility of view
		NSRect rect = [stationDialogPanel frame];
		if ([[stationType selectedItem] isEqual:[stationType itemAtIndex:0]]) {
			// resize to similar artist search box
			selectedStationType = ARTIST_STATION_TYPE;
			if (searchService != nil) {
				rect.origin.y += rect.size.height - 465;
				rect.size.height = 465;
			} else {
				rect.origin.y += rect.size.height - 125;
				rect.size.height = 125;
			}
			[stationDialogPanel setFrame:rect display:YES animate:YES];
			[artistView setHidden:NO];
			[artistSearchField selectText:self];
			
			
		} else if ([[stationType selectedItem] isEqual:[stationType itemAtIndex:1]] ||
			[[stationType selectedItem] isEqual:[stationType itemAtIndex:2]]) {
			// resize for profile or personal radio
			selectedStationType = USER_STATION_TYPE;
			rect.origin.y += rect.size.height - 180;
			rect.size.height = 180;
			[stationDialogPanel setFrame:rect display:YES animate:YES];
			[userView setHidden:NO];
			
			
		} else if ([[stationType selectedItem] isEqual:[stationType itemAtIndex:3]]) {
			// resize for custom URL radio
			selectedStationType = CUSTOM_STATION_TYPE;
			rect.origin.y += rect.size.height - 125;
			rect.size.height = 125;
			[stationDialogPanel setFrame:rect display:YES animate:YES];
			[customURLView setHidden:NO];
			[customURLField selectText:self];
			
		}
		
		[self stationDataChanged:self];
	}
}

- (IBAction)showWindow:(id)sender
{
	[NSApp activateIgnoringOtherApps:YES];
	[self stationTypeChanged:stationType];
	[stationDialogPanel makeKeyAndOrderFront:nil];
}

- (void)hideWindow
{
	[stationDialogPanel orderOut:self];
}

- (IBAction)search:(id)sender
{
	[artistSearchButton setHidden:true];
	[artistSearchIndicator setHidden:false];
	[artistSearchIndicator startAnimation:self];
	[artistSearchField setEnabled:false];
	NSString *searchString = [artistSearchField stringValue];
	if (searchService != nil) {
		[searchService release];
	}
	searchService = [[StationSearchService alloc]
						initWithWebServiceServer:[preferences stringForKey:@"webServiceServer"]
						asUserAgent:[preferences stringForKey:@"userAgent"]];
	[searchService searchSimilarArtist:searchString withSender:self];
}

- (void)searchFinished:(StationSearchService *)service
{
	NSString *mainResultText = [searchService getMainResultText];
	if (mainResultText == nil) {
		mainResultText = @"There is no exact match";
		[artistImage setImage:nil];
	} else {
		mainResultText = [[NSString stringWithString:@"Exact Match: "]
							stringByAppendingString:[searchService getMainResultText]];
		NSLog(@"%@", [searchService getImageUrl]);
		NSImage *image = [[NSImage alloc] initWithContentsOfURL:[searchService getImageUrl]];
		
		// resize the image, why the heck doesn't that work automatically?
		float width, height;
		width = [image size].width;
		height = [image size].height;
		float max = width;
		if (max < height)
			max = height;
		width *= 100/max;
		height *= 100/max;
		[image setSize:NSMakeSize(width, height)];
		[image setScalesWhenResized:YES];
		
		[artistImage setImage:image];
	}
	
	[artistMainResultField setStringValue:mainResultText];
	[artistSimilarResultList setDataSource:searchService];
	if ([searchService getMainResultText] == nil) {
		[artistResultBox setHidden: true];
		[artistNoResultBox setHidden: false];
	} else {
		[artistResultBox setHidden: false];
		[artistNoResultBox setHidden: true];
	}
	
	[artistSearchButton setHidden:false];
	[artistSearchIndicator setHidden:true];
	[artistSearchIndicator stopAnimation:self];
	[artistSearchField setEnabled:true];
	[self stationTypeChanged:stationType];
}

- (void)setPreferences:(NSUserDefaults *)prefs
{
	preferences = [prefs retain];
}

- (void)setRecentStations:(RecentStations *)stations
{
	recentStations = [stations retain];
}

- (NSString *)getStationURLFromSender:(id)sender
{
	NSString *stationUrl, *name, *type, *user, *radioType;
    switch (selectedStationType) {
        case ARTIST_STATION_TYPE:
            if ([(NSButton *)sender isEqualTo:artistPlayMatchButton]) {
                name = [searchService getMainResultText];
                NSString *artistString = [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                stationUrl = [[[NSString stringWithString:@"lastfm://artist/"]
                                    stringByAppendingString:artistString]
                                    stringByAppendingString:@"/similarartists"];
            } else {
                name = [searchService getSearchResultWithIndex:[artistSimilarResultList selectedRow]];
                NSString *artistString = [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                stationUrl = [[[NSString stringWithString:@"lastfm://artist/"]
                                    stringByAppendingString:artistString]
                                    stringByAppendingString:@"/similarartists"];
            }
            type = @"Similar Artist Radio";
            break;
            
        case USER_STATION_TYPE:
            if ([userCheckBox state] == 1) {
                user = [username stringValue];
            } else {
                user = [preferences stringForKey:@"username"];
            }
            
            if ([[[stationType selectedItem] title] isEqualToString:@"Profile Radio"]) {
                radioType = @"/profile";
                type = @"Profile Radio";
            } else if ([[[stationType selectedItem] title] isEqualToString:@"Personal Radio"])  {
                radioType = @"/personal";
                type = @"Personal Radio";
            }
            stationUrl = [[[NSString stringWithString:@"lastfm://user/"]
                                    stringByAppendingString:user]
                                    stringByAppendingString:radioType];
            name = user;
            break;
            
        case CUSTOM_STATION_TYPE:
            
            stationUrl = [customURLField stringValue];
            name = [customURLField stringValue];
            type = @"Custom URL";
            break;
        
    }
    
    // store the station url in the last stations
    [recentStations addStation:stationUrl withType:type withName:name];
	
	return stationUrl;
}

@end
