//
//  StationController.m
//  Amua
//
//  Created by Mathis & Simon Hofer on 09.12.05.
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

#import "StationController.h"

#define ARTIST_STATION_TYPE 1
#define USER_STATION_TYPE 2

@implementation StationController

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
		
		// change size and visibility of view
		NSRect rect = [stationDialogPanel frame];
		if ([[[stationType selectedItem] title] isEqualToString:@"Similar Artist Radio"]) {
			// resize to similar artist search box
			selectedStationType = ARTIST_STATION_TYPE;
			if (searchService != nil) {
				rect.origin.y += rect.size.height - 515;
				rect.size.height = 515;
			} else {
				rect.origin.y += rect.size.height - 183;
				rect.size.height = 183;
			}
			[stationDialogPanel setFrame:rect display:YES animate:YES];
			[artistView setHidden:NO];
			
			
		} else if ([[[stationType selectedItem] title] isEqualToString:@"Profile Radio"] ||
			// resize for profile or personal radio
			[[[stationType selectedItem] title] isEqualToString:@"Personal Radio"]) {
			selectedStationType = USER_STATION_TYPE;
			rect.origin.y += rect.size.height - 220;
			rect.size.height = 220;
			[stationDialogPanel setFrame:rect display:YES animate:YES];
			[userView setHidden:NO];
			
			
		}
		
		[self stationDataChanged:self];
	}
}

- (IBAction)showWindow:(id)sender
{
	[NSApp activateIgnoringOtherApps:YES];
	[self stationTypeChanged:stationType];
	[tabView selectFirstTabViewItem:self];
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
	[lastPlayedList setDataSource:recentStations];
}

- (NSString *)getStationURLFromSender:(id)sender
{
	NSString *stationUrl;
	if ([[[tabView selectedTabViewItem] label] isEqualToString:@"Select Station"]) {
		NSString *name, *type, *user, *radioType;
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
			
		}
		
		// store the station url in the last stations
		[recentStations addStation:stationUrl withType:type withName:name];
		[lastPlayedList setDataSource:recentStations];
	} else {
		stationUrl = [recentStations stationByIndex:[lastPlayedList selectedRow]];
		[recentStations moveToFront:[lastPlayedList selectedRow]];
		[lastPlayedList setDataSource:recentStations];
	}
	
	return stationUrl;
}

- (void)tabView:(NSTabView *)targetTabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	
	if ([tabViewItem isEqualTo:[targetTabView tabViewItemAtIndex:0]]) {
		[self stationTypeChanged:stationType];
	} else if ([tabViewItem isEqualTo:[targetTabView tabViewItemAtIndex:1]]) {
		NSRect rect = [stationDialogPanel frame];
		rect.origin.y += rect.size.height - 400;
		rect.size.height = 400;
		[lastPlayedView setHidden:YES];
		[stationDialogPanel setFrame:rect display:YES animate:YES];
		[lastPlayedView setHidden:NO];
	}
	
}

@end
