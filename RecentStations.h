//
//  RecentStations.h
//  Amua
//
//  Created by Mathis & Simon Hofer on 11.03.05.
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

#define LIMIT 10

/**
 * Class to handle the recently played station list.
 */
@interface RecentStations : NSObject {
	
    /**
     * An array that contains the list of the recent stations.
     */
	NSMutableArray *recentStations;
    
    /**
     * A reference to the application preferences object.
     */
    NSUserDefaults *preferences;

}

/**
 * Constructor.
 * 
 * @param prefs The application preferences object.
 */
- (id)initWithPreferences:(NSUserDefaults *)prefs;

/**
 * Add a station to the list of the recently played stations.
 * 
 * @param stationUrl The URL of the station.
 * @param type The type of the station.
 * @param name The name of the station.
 */
- (void)addStation:(NSString *)stationUrl withType:(NSString *)type withName:(NSString *)name;

/**
 * Get the URL of the most recent station.
 * 
 * @return The URL of the most recent station.
 */
- (NSString *)mostRecentStation;

/**
 * Get a station by list index.
 * 
 * @param index The index of the station to get.
 * @return A dictionary containing the station data ("url", "name" and "type").
 */
- (NSDictionary *)stationByIndex:(int)index;

/**
 * Get a station URL by list index
 * 
 * @param index The index of the station to get.
 * @return The URL of the station.
 */
- (NSString *)stationURLByIndex:(int)index;

/**
 * Get the amount of stations in the recent stations list.
 * 
 * @return The amount of stations in the recent stations list.
 */
- (int)stationsCount;

/**
 * Move the station on a given index to the top of the list.
 * 
 * @param index  The index of the station to move to the top of the list.
 */
- (void)moveToFront:(int)index;

/**
 * Store the list of the recently played station to the application preferences file.
 */
- (void)store;

/**
 * Clear the list of the recently played stations.
 */
- (void)clear;

/**
 * Check if stations are in the list.
 * 
 * @return YES if there are station in the list, NO otherwise.
 */
- (BOOL)stationsAvailable;

@end
