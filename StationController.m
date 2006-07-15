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

#define ARTIST_RADIO 0
#define NEIGHBOUR_RADIO 1
#define PERSONAL_RADIO 2
#define CUSTOM_URL_RADIO 3

@implementation StationController

- (void)awakeFromNib
{
	[artistSimilarResultList setTarget:amuaController];
	[artistSimilarResultList setDoubleAction:@selector(play:)];
}


- (IBAction)stationDataChanged:(id)sender
{
	switch (selectedStationType) {
        case NEIGHBOUR_RADIO:
		case PERSONAL_RADIO:
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


- (void)setSubscriberMode:(bool)subscriber
{
    [stationType setAutoenablesItems:NO];
    if (subscriber) {
        [[stationType itemAtIndex:PERSONAL_RADIO] setEnabled:YES];
    } else {
        [[stationType itemAtIndex:PERSONAL_RADIO] setEnabled:NO];
    }
}


- (IBAction)stationTypeChanged:(id)sender
{
	if (stationType == sender) {
        
        // if item is disabled select fist selectable item
        int i;
        for (i=0; ![[stationType selectedItem] isEnabled] && i<[[stationType itemArray] count]; i++) {
            [stationType selectItemAtIndex:i];
        }
		
		// hide all views
		[artistView setHidden:YES];
		[userView setHidden:YES];
		[customURLView setHidden:YES];
		
		// change size and visibility of view
		NSRect rect = [stationDialogPanel frame];
		if ([[stationType selectedItem] isEqual:[stationType itemAtIndex:ARTIST_RADIO]]) {
			// resize to similar artist search box
			selectedStationType = ARTIST_RADIO;
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
			
			
		} else if ([[stationType selectedItem] isEqual:[stationType itemAtIndex:NEIGHBOUR_RADIO]]) {
            // resize for profile or personal radio
			selectedStationType = NEIGHBOUR_RADIO;
			rect.origin.y += rect.size.height - 180;
			rect.size.height = 180;
			[stationDialogPanel setFrame:rect display:YES animate:YES];
			[userView setHidden:NO];
            
        } else if ([[stationType selectedItem] isEqual:[stationType itemAtIndex:PERSONAL_RADIO]]) {
			// resize for profile or personal radio
			selectedStationType = PERSONAL_RADIO;
			rect.origin.y += rect.size.height - 180;
			rect.size.height = 180;
			[stationDialogPanel setFrame:rect display:YES animate:YES];
			[userView setHidden:NO];
			
			
		} else if ([[stationType selectedItem] isEqual:[stationType itemAtIndex:CUSTOM_URL_RADIO]]) {
			// resize for custom URL radio
			selectedStationType = CUSTOM_URL_RADIO;
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
	searchService = [[SearchService alloc]
						initWithWebServiceServer:[preferences stringForKey:@"webServiceServer"]
						asUserAgent:[preferences stringForKey:@"userAgent"]];
    [searchService setDelegate:self];
	[searchService searchSimilarArtist:searchString];
}


- (void)searchFinished:(SearchService *)service
{
    if (searchResult != nil) {
        [searchResult release];
    }
    searchResult = [[service getSearchResult] retain];
	NSString *mainResultText = [searchService getMainResultText];
	if (mainResultText == nil) {
		mainResultText = @"There is no exact match";
		[artistImage setImage:nil];
	} else {
		mainResultText = [[NSString stringWithString:@"Exact Match: "]
							stringByAppendingString:[searchService getMainResultText]];
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
	[artistSimilarResultList setDataSource:self];
	if ([searchService getMainResultText] == nil) {
        [messageField setStringValue:@"There were no matches"];
		[artistResultBox setHidden: YES];
		[artistNoResultBox setHidden: NO];
	} else {
		[artistResultBox setHidden: NO];
		[artistNoResultBox setHidden: YES];
	}
	
	[artistSearchButton setHidden:NO];
	[artistSearchIndicator setHidden:YES];
	[artistSearchIndicator stopAnimation:self];
	[artistSearchField setEnabled:true];
	[self stationTypeChanged:stationType];
}

- (void)searchFailed:(SearchService *)service
{
    [artistMainResultField setStringValue:@"Search failed."];
    [artistSimilarResultList setDataSource:nil];
    [messageField setStringValue:@"Connection error"];
    [artistResultBox setHidden: YES];
    [artistNoResultBox setHidden: NO];
    [artistSearchButton setHidden:NO];
	[artistSearchIndicator setHidden:YES];
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
	NSString *stationUrl=nil, *user=nil, *radioType=nil;
    switch (selectedStationType) {
        case ARTIST_RADIO:
            if ([(NSButton *)sender isEqualTo:artistPlayMatchButton]) {
                NSString *name = [searchService getMainResultText];
                NSString *artistString = [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                stationUrl = [[[NSString stringWithString:@"lastfm://artist/"]
                                    stringByAppendingString:artistString]
                                    stringByAppendingString:@"/similarartists"];
            } else {
                NSString *name = [searchService getSearchResultWithIndex:[artistSimilarResultList selectedRow]];
                NSString *artistString = [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                stationUrl = [[[NSString stringWithString:@"lastfm://artist/"]
                                    stringByAppendingString:artistString]
                                    stringByAppendingString:@"/similarartists"];
            }
            break;
        
        case NEIGHBOUR_RADIO:
        case PERSONAL_RADIO:
            if ([userCheckBox state] == 1) {
                user = [username stringValue];
            } else {
                user = [preferences stringForKey:@"username"];
            }
            
            if (selectedStationType == NEIGHBOUR_RADIO) {
                radioType = @"/neighbours";
            } else if (selectedStationType == PERSONAL_RADIO)  {
                radioType = @"/personal";
            }
            stationUrl = [[[NSString stringWithString:@"lastfm://user/"]
                                    stringByAppendingString:[user stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                                    stringByAppendingString:radioType];
            break;
            
        case CUSTOM_URL_RADIO:
            stationUrl = [customURLField stringValue];
            break;
        
    }
	
	return stationUrl;
}


- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(int)rowIndex
{
	if (searchResult != nil) {
		return [[searchResult objectAtIndex:rowIndex] objectForKey:@"name"];
	} else {
		return nil;
	}
}


- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [searchResult count];
}

@end
