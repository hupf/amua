//
//  SongInformationPanel.m
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

#import "RecentStations.h"

@implementation RecentStations

- (id)initWithPreferences:(NSUserDefaults *)prefs
{
	[super init];
    preferences = [prefs retain];
	NSArray* staticStations = [preferences objectForKey:@"recentStations"];
	if (staticStations == nil) {
		recentStations = [[NSMutableArray alloc] init];
	} else {
		recentStations = [[NSMutableArray alloc] initWithArray:staticStations];
	}
	return self;
}

- (void)addStation:(NSString *)stationUrl withType:(NSString *)type withName:(NSString *)name
{
	NSMutableDictionary *stationObject = [[[NSMutableDictionary alloc] init] autorelease];
	[stationObject setObject:[stationUrl retain] forKey:@"url"];
	[stationObject setObject:[name retain] forKey:@"name"];
	[stationObject setObject:[type retain] forKey:@"type"];
	
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
    
    [self store];
}

- (BOOL)stationsAvailable
{
	return [recentStations count] > 0;
}

- (NSString *)mostRecentStation
{
	return [[recentStations lastObject] objectForKey:@"url"];
}

- (NSDictionary *)stationByIndex:(int)index
{
	return [recentStations objectAtIndex:[recentStations count]-1-index];
}

- (NSString *)stationURLByIndex:(int)index
{
	return [[recentStations objectAtIndex:[recentStations count]-1-index] objectForKey:@"url"];
}

- (int)stationsCount
{
	return [recentStations count];
}

- (void)moveToFront:(int)index
{
	if (index > 0) {
		NSDictionary *temp = [[[recentStations objectAtIndex:[recentStations count]-1-index] retain] autorelease];
		[recentStations removeObjectAtIndex:[recentStations count]-1-index];
		[recentStations addObject:temp];
	    [self store];
    }
}

- (void)store
{
	[preferences setObject:recentStations forKey:@"recentStations"];
    [preferences synchronize];
}

- (void)clear
{
	[recentStations removeAllObjects];
    [self store];
}

- (void)dealloc
{
	[super dealloc];
	[preferences release];
    [recentStations release];
}

@end
