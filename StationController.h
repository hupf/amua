//
//  StationController.h
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

#import <Cocoa/Cocoa.h>
#import "StationSearchService.h"
#import "RecentStations.h"

@interface StationController : NSObject
{
	IBOutlet NSPanel *stationDialogPanel;
    IBOutlet NSImageView *artistImage;
    IBOutlet NSTextField *artistMainResultField;
    IBOutlet NSBox *artistNoResultBox;
    IBOutlet NSBox *artistResultBox;
    IBOutlet NSTextField *artistSearchField;
	IBOutlet NSButton *artistSearchButton;
	IBOutlet NSProgressIndicator *artistSearchIndicator;
    IBOutlet NSTableView *artistSimilarResultList;
    IBOutlet NSView *artistView;
	IBOutlet NSButton *artistPlayMatchButton;
	IBOutlet NSScrollView *lastPlayedView;
    IBOutlet NSTableView *lastPlayedList;
    IBOutlet NSPopUpButton *stationType;
    IBOutlet NSTabView *tabView;
    IBOutlet NSButton *userCheckBox;
    IBOutlet NSTextField *username;
    IBOutlet NSView *userView;
	IBOutlet NSView *customURLView;
	IBOutlet NSTextField *customURLField;
	
	StationSearchService *searchService;
	NSUserDefaults *preferences;
	int selectedStationType;
	RecentStations *recentStations;
}

- (IBAction)stationDataChanged:(id)sender;
- (IBAction)stationTypeChanged:(id)sender;
- (IBAction)showWindow:(id)sender;
- (void)hideWindow;
- (IBAction)search:(id)sender;
- (void)setPreferences:(NSUserDefaults *)prefs;
- (void)setRecentStations:(RecentStations *)recentStations;
- (NSString *)getStationURLFromSender:(id)sender;
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem;

@end
