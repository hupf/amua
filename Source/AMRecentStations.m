//
//  SongInformationPanel.m
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

#import "AMRecentStations.h"

@implementation AMRecentStations

- (id)initWithPreferences:(NSUserDefaults *)prefs
{
	self = [super init];
    preferences = [prefs retain];
	NSArray *staticStations = [preferences objectForKey:@"recentStations"];
	if (staticStations == nil) {
		recentStations = [[NSMutableArray alloc] init];
	} else {
		recentStations = [[NSMutableArray alloc] initWithArray:staticStations];
	}
	return self;
}


- (void)addStation:(NSString *)stationUrl
{
    
    NSString *type=nil, *name=nil;
    // remove lastfm:// and split by /
    NSArray *array = [[stationUrl substringFromIndex:9] componentsSeparatedByString:@"/"];

    // make known stations human readable
    if ([[array objectAtIndex:0] isEqualToString:@"user"] && [array count] == 3) {
        if ([[array objectAtIndex:2] isEqualToString:@"neighbours"]) {
            name = [[array objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            type = @"Neighbour Radio";
        } else if ([[array objectAtIndex:2] isEqualToString:@"personal"]) {
            name = [[array objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            type = @"Personal Radio";
        } else if ([[array objectAtIndex:2] isEqualToString:@"loved"]) {
            name = [[array objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            type = @"Loved Tracks Radio";
        }
    } else if ([[array objectAtIndex:0] isEqualToString:@"globaltags"] && [array count] == 2) {
        name = [[array objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        type = @"Global Tags Radio";
    } else if ([[array objectAtIndex:0] isEqualToString:@"group"] && [array count] == 2) {
        name = [[array objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        type = @"Group Radio";
    } else if ([[array objectAtIndex:0] isEqualToString:@"artist"] && [array count] == 3 &&
               [[array objectAtIndex:2] isEqualToString:@"similarartists"]) {
        name = [[array objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        type = @"Similar Artist Radio";
    }
    
    if (name == nil || type == nil) {
        type = @"URL";
        name = stationUrl;
    }
    
    
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
    
    [self store];
}


- (NSString *)mostRecentStationURL
{
	return [[recentStations lastObject] objectForKey:@"url"];
}


- (NSString *)stationByIndex:(int)index
{
    NSDictionary *station = [recentStations objectAtIndex:[recentStations count]-1-index];
    if ([station objectForKey:@"name"] == nil || [[station objectForKey:@"name"] isEqualToString:@""] ||
        [station objectForKey:@"type"] == nil || [[station objectForKey:@"type"] isEqualToString:@""]) {
        return [station objectForKey:@"url"];
    } else {
        return [NSString stringWithFormat:@"%@: %@", [station objectForKey:@"type"],
                    [station objectForKey:@"name"]];
    }
}


- (NSString *)stationURLByIndex:(int)index
{
	return [[recentStations objectAtIndex:[recentStations count]-1-index] objectForKey:@"url"];
}


- (int)count
{
	return [recentStations count];
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
	[preferences release];
    [recentStations release];
    
    [super dealloc];
}

@end
