//
//  AMSongInformation.m
//  Amua
//
//  Created by Mathis & Simon Hofer on 28.11.06.
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

#import "AMSongInformation.h"
#import "Debug.h"


@implementation AMSongInformation

- (id)initWithDictionary:(NSDictionary *)data
{
    self = [super init];
    artistName = [[NSString alloc] initWithString:([data objectForKey:@"creator"] != nil ? [data objectForKey:@"creator"] : @"")];
    albumName = [[NSString alloc] initWithString:([data objectForKey:@"album"] != nil ? [data objectForKey:@"album"] : @"")];
    trackName = [[NSString alloc] initWithString:([data objectForKey:@"title"] != nil ? [data objectForKey:@"title"] : @"")];
    if ([data objectForKey:@"duration"] != nil) {
        trackLength = [[data objectForKey:@"duration"] intValue] / 1000;
    } else {
        trackLength = -1;
    }
    radioStation = [[NSString alloc] initWithString:([data objectForKey:@"station"] != nil ? [data objectForKey:@"station"] : @"")];
    location = [[NSString alloc] initWithString:([data objectForKey:@"location"] != nil ? [data objectForKey:@"location"] : @"")];
    coverImage = [data objectForKey:@"image"] != nil ? [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[data objectForKey:@"image"]]] : nil;
    if (coverImage == nil) {
        coverImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:@"nocover.png"]];
        AmuaLog(LOG_WARNING, @"no valid cover found");
    }
    creationStamp = AbsoluteToDuration(UpTime());
    
    return self;
}


- (void)setProgress:(int)progress
{
    creationStamp = AbsoluteToDuration(UpTime()) - progress*1000;
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
    Duration stamp = AbsoluteToDuration(UpTime());
    int seconds = (stamp - creationStamp)/1000;
    seconds = seconds < 0 ? -seconds : seconds;
    return seconds > trackLength ? trackLength : seconds;
}


- (NSString *)station
{
    return radioStation;
}


- (NSString *)location
{
    return location;
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
    if (location != nil) {
        [location release];
    }
    [super dealloc];   
}

@end
