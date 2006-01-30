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
#import "AmuaController.h"
#import "StationSearchService.h"
#import "RecentStations.h"

@class AmuaController; // Forward declaration

/**
 * The controller class for the station select window.
 */
@interface StationController : NSObject {
	
	/**
     * A reference to the main controller object.
     */
	IBOutlet AmuaController* amuaController;
    
	/**
     * The panel.
     */
    IBOutlet NSPanel* stationDialogPanel;
    
	/**
     * The artist image that is displayed with the similar artist station search result.
     */
    IBOutlet NSImageView* artistImage;
    
	/**
     * 
     */
    IBOutlet NSTextField* artistMainResultField;
    
	/**
     * The box for no search result for the similar artist station search.
     */
    IBOutlet NSBox* artistNoResultBox;
    
	/**
     * The box with the result of the similar artist station search.
     */
    IBOutlet NSBox* artistResultBox;
    
	/**
     * The textfield for the similar artist station search expression.
     */
    IBOutlet NSTextField* artistSearchField;
    
	/**
     * The search button for the similar artist station search.
     */
	IBOutlet NSButton* artistSearchButton;
    
	/**
     * The process indicator for the similar artist station search.
     */
	IBOutlet NSProgressIndicator* artistSearchIndicator;
    
	/**
     * The list for the search results of the similar artist station search.
     */
    IBOutlet NSTableView* artistSimilarResultList;
    
	/**
     * The view that groups the elements of the similar artist station search.
     */
    IBOutlet NSView* artistView;
    
	/**
     * The play button for the similar artist station search.
     */
	IBOutlet NSButton* artistPlayMatchButton;
    
	/**
     * The popup menu to select the station type.
     */
    IBOutlet NSPopUpButton* stationType;
    
	/**
     * The checkbox for the personal and profile station search.
     * 
     * If the box is unchecked, the default user is taken.
     */
    IBOutlet NSButton* userCheckBox;
    
	/**
     * The username textfield for the personal and profile station search.
     */
    IBOutlet NSTextField* username;
    
	/**
     * The view that groups the elements of the personal and profile station search.
     */
    IBOutlet NSView* userView;
    
	/**
     * The view that groups the elements of the custom URL station.
     */
	IBOutlet NSView* customURLView;
    
	/**
     * The textfield for the URL of the custom URL station.
     */
	IBOutlet NSTextField* customURLField;
	
	/**
     * A reference to the station search service object.
     */
	StationSearchService* searchService;
    
    /**
     * A reference to the application preferences object.
     */
	NSUserDefaults* preferences;
    
	/**
     * The selected station type.
     */
	int selectedStationType;
    
	/**
     * A reference to the recent stations object.
     */
	RecentStations* recentStations;
}

/**
 * Actions after station data changed.
 */
- (IBAction)stationDataChanged:(id)sender;

/**
 * Shows the right station select view.
 */
- (IBAction)stationTypeChanged:(id)sender;

/**
 * Show the station select window.
 */
- (IBAction)showWindow:(id)sender;

/**
 * Hide the station select window.
 */
- (void)hideWindow;

/**
 * Perform search.
 */
- (IBAction)search:(id)sender;

/**
 * Display the search result.
 */
- (void)searchFinished:(StationSearchService*)service;

/**
 * Set the application preferences  object.
 */
- (void)setPreferences:(NSUserDefaults*)prefs;

/**
 * Update the array with the recent stations.
 */
- (void)setRecentStations:(RecentStations*)recentStations;

/**
 * Used in play method of AmuaController to know what station should be played.
 */
- (NSString*)getStationURLFromSender:(id)sender;

@end
