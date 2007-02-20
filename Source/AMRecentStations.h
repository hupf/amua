//
//  RecentStations.h
//  Amua
//
//  Created by Mathis & Simon Hofer on 11.03.05.
//  Copyright 2005-2007 Mathis & Simon Hofer.
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
 * AMRecentStations is used to store recent stations.
 * @ingroup Player
 */
@interface AMRecentStations : NSObject {
	
	NSMutableArray *recentStations;
    NSUserDefaults *preferences;

}

/**
 * Return an initialized AMRecentStations object.
 * @param prefs The user preferences storing the recent stations.
 */
- (id)initWithPreferences:(NSUserDefaults *)prefs;

/**
 * Add a station to the recent stations.
 *
 * If the station is already in the list, it is moved to the front. Otherwise
 * it is inserted at the front of the list.
 * This method already updates the user preferences.
 * @param stationUrl The URL of the station.
 */
- (void)addStation:(NSString *)stationUrl;

/**
 * Return the URL of the most recent station.
 * @return The URL of the most recent station.
 */
- (NSString *)mostRecentStationURL;

/**
 * Return a station at a specific index.
 * 
 * If the index is out of bounds an NSRangeException is thrown.
 * @param index The index of the station.
 * @return A string identifying the station at position index.
 */
- (NSString *)stationByIndex:(int)index;

/**
 * Return a station URL at a specific index.
 * 
 * @param index The index of the station.
 * @return The station URL.
 */
- (NSString *)stationURLByIndex:(int)index;

/**
 * Return the number of stations available.
 * @return The number of stations in the recent stations list.
 */
- (int)count;

/**
 * Store the stations to the user preferences.
 */
- (void)store;

/**
 * Remove all stations.
 *
 * This method already updates the user preferences.
 */
- (void)clear;

- (void)dealloc;

@end
