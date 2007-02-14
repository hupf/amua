//
//  AMSongInformation.m
//  Amua
//
//  Created by Mathis & Simon Hofer on 17.02.05.
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

#import "AMSongInformation.h"
#import "Debug.h"


@implementation AMSongInformation

- (id)initWithDictionary:(NSDictionary *)data
{
    self = [super init];
    artistName = [[NSString alloc] initWithString:([data objectForKey:@"artist"] != nil ? [data objectForKey:@"artist"] : @"")];
    albumName = [[NSString alloc] initWithString:([data objectForKey:@"album"] != nil ? [data objectForKey:@"album"] : @"")];
    trackName = [[NSString alloc] initWithString:([data objectForKey:@"track"] != nil ? [data objectForKey:@"track"] : @"")];
    if ([data objectForKey:@"trackduration"] != nil) {
        trackLength = [[data objectForKey:@"trackduration"] intValue];
    } else {
        trackLength = -1;
    }
    radioStation = [[NSString alloc] initWithString:([data objectForKey:@"station"] != nil ? [data objectForKey:@"station"] : @"")];
    radioStationFeed = [[NSString alloc] initWithString:([data objectForKey:@"stationfeed"] != nil ? [data objectForKey:@"stationfeed"] : @"")];
    coverImage = [data objectForKey:@"albumcover_small"] != nil ? [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[data objectForKey:@"albumcover_small"]]] : nil;
    if (coverImage == nil) {
        coverImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:@"nocover.png"]];
        AmuaLog(LOG_WARNING, @"no valid cover found");
    }
    creationDate = [[NSDate date] retain];
    
    return self;
}


- (NSString *)artist
{
    return artistName;
}


- (NSString *)album
{
    return albumName;
}


- (NSString *)track
{
    return trackName;
}


- (NSImage *)cover
{
    return coverImage;
}


- (int)length
{
    return trackLength;
}


- (int)progress
{
    int seconds = (int)[creationDate timeIntervalSinceNow];
    seconds = seconds < 0 ? -seconds : seconds;
    return seconds > trackLength ? trackLength : seconds;
}


- (NSString *)station
{
    return radioStation;
}


- (NSString *)stationFeed
{
    return radioStationFeed;
}


- (NSString *)shortString
{
    return [[artistName stringByAppendingString:@" - "] stringByAppendingString:trackName];
}


- (NSURL *)url
{
    if ([self hasURL]) {
        NSString *urlString = [NSString stringWithFormat:@"http://www.last.fm/music/%@/%@", 
                                  [artistName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                  [albumName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        return [NSURL URLWithString:urlString];
    } else {
        return nil;
    }
}


- (bool)hasURL
{
    return artistName != nil && ![artistName isEqualToString:@""] && 
           albumName != nil && ![albumName isEqualToString:@""];
}


- (bool)isEqualToSongInformation:(AMSongInformation *)songInfo
{
    return [artistName isEqualToString:[songInfo artist]] &&
           [albumName isEqualToString:[songInfo album]] &&
           [trackName isEqualToString:[songInfo track]] &&
           [radioStation isEqualToString:[songInfo station]] &&
           [radioStationFeed isEqualToString:[songInfo stationFeed]] && 
           trackLength == [songInfo length];
}


- (bool)isValid
{
    return artistName != nil && ![artistName isEqualToString:@""] && 
           trackName != nil && ![trackName isEqualToString:@""];
}


- (void)dealloc
{
    if (artistName != nil) {
        [artistName release];
    }
    if (albumName != nil) {
        [albumName release];
    }
    if (trackName != nil) {
        [trackName release];
    }
    if (coverImage != nil) {
        [coverImage release];
    }
    if (radioStation != nil) {
        [radioStation release];
    }
    if (radioStationFeed != nil) {
        [radioStationFeed release];
    }
    if (creationDate != nil) {
        [creationDate release];
    }
    [super dealloc];   
}

@end
