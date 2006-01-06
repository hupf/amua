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
#define LIMIT 10
#import <Cocoa/Cocoa.h>



@interface RecentStations : NSObject {

	NSMutableArray *recentStations;
    NSUserDefaults *preferences;

}

- (id)initWithPreferences:(NSUserDefaults *)prefs;
- (void)addStation:(NSString *)stationUrl withType:(NSString *)type withName:(NSString *)name;
- (NSString *)mostRecentStation;
- (NSDictionary *)stationByIndex:(int)index;
- (NSString *)stationURLByIndex:(int)index;
- (int)stationsCount;
- (void)moveToFront:(int)index;
- (void)store;
- (void)clear;
- (BOOL)stationsAvailable;
- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn
    row:(int)rowIndex;
- (int)numberOfRowsInTableView:(NSTableView *)aTableView;

@end
