//
//  SongInformationPanel.m
//  Amua
//
//  Created by Mathis & Simon Hofer on 11.03.05.
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

#import "RecentStations.h"

@implementation RecentStations

- (id)initWithPreferences:(NSUserDefaults *)preferences
{
	[super init];
	NSArray* staticStations = [preferences objectForKey:@"recentStations"];
	if (staticStations == nil) {
		recentStations = [[NSMutableArray alloc] init];
	} else {
		recentStations = [[NSMutableArray alloc] initWithArray:staticStations];
	}
	return self;
}

- addStation:(NSString *)stationUrl withType:(NSString *)type withName:(NSString *)name
{
	NSMutableDictionary *stationObject = [[[NSMutableDictionary alloc] init] autorelease];
	[stationObject setObject:stationUrl forKey:@"url"];
	[stationObject setObject:name forKey:@"name"];
	[stationObject setObject:type forKey:@"type"];
	
	int i;
	for (i=0; i < [recentStations count];) {
		if ([[[recentStations objectAtIndex:i] objectForKey:@"url"] isEqualToString:stationUrl]) {
			[recentStations removeObjectAtIndex:i];
		} else {
			 i++;
		}
	}
	[recentStations addObject:stationObject];
	
	if ([recentStations count] > LIMIT) {
		NSArray *array = [recentStations subarrayWithRange:NSMakeRange([recentStations count]-LIMIT, LIMIT)];
		[recentStations release];
		recentStations = [[NSMutableArray alloc] initWithArray:array];
	}
}

-(BOOL)stationsAvailable
{
	return [recentStations count] <= 0;
}

-(NSString *)mostRecentStation
{
	return [[recentStations lastObject] objectForKey:@"url"];
}

-(NSString *)stationByIndex:(int)index
{
	return [[recentStations objectAtIndex:[recentStations count]-1-index] objectForKey:@"url"];
}

-moveToFront:(int)index
{
	NSDictionary *temp = [recentStations objectAtIndex:[recentStations count]-1-index];
	[recentStations removeObjectAtIndex:[recentStations count]-1-index];
	[recentStations addObject: temp];
}

-storeInPreferences:(NSUserDefaults *)preferences
{
	[preferences setObject:recentStations forKey:@"recentStations"];
}


- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn
    row:(int)rowIndex
{
	NSDictionary* rowElement = [recentStations objectAtIndex:[recentStations count]-1-rowIndex];
	if ([[[aTableColumn headerCell] stringValue] isEqualToString:@"Radio Type"]) {
		return [rowElement objectForKey:@"type"];
	} else {
		return [rowElement objectForKey:@"name"];
	}
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [recentStations count];
}

@end
