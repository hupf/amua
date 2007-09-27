//
//  AMPlayback.m
//  Amua
//
//  Created by Mathis & Simon Hofer on 12.12.06.
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

#import "AMiTunesPlayback.h"

// script which removes the old stream
#define REMOVE_SCRIPT @"try \n set t to (some URL track of library playlist 1 whose address is \"%@\") \n delete t \n end try"

// script which reads the track progress
#define PROGRESS_SCRIPT @"tell application \"iTunes\" \n try \n set t to (some URL track of library playlist 1 whose address is \"%@\") \n if (player state is playing) and (database ID of t is database ID of current track) then \n player position \n else \n -1 \n end if \n on error \n -1 \n end try \n end tell"

// scripts which starts the playback
#define START_SCRIPT @"tell application \"iTunes\" \n %@ \n open location \"%@\" \n end tell"

// script which stops the playback
#define STOP_SCRIPT @"tell application \"Finder\"\n if (get name of every process) contains \"iTunes\" then \n tell application \"iTunes\" \n %@ \n stop \n end tell \n end if\n end tell"


@implementation AMiTunesPlayback

- (id)init
{
    self = [super init];
    playingState = NO;
    return self;
}    


- (void)startWithStreamURL:(NSString *)url
{
    AmuaLogf(LOG_MSG, @"starting stream: %@", url);
    NSString *remove = streamURL != nil ? [NSString stringWithFormat:REMOVE_SCRIPT, streamURL] : @"";
    NSString *scriptSource = [NSString stringWithFormat:START_SCRIPT, remove, url];
    NSAppleScript *script = [[[NSAppleScript alloc] initWithSource:scriptSource] autorelease];
    [script executeAndReturnError:nil];
    playingState = YES;
    
    if (streamURL != nil) {
        [streamURL release];
    }
    streamURL = [url copy];
}


- (void)stop
{
    NSString *remove = streamURL != nil ? [NSString stringWithFormat:REMOVE_SCRIPT, streamURL] : @"";
    NSString *scriptSource = [NSString stringWithFormat:STOP_SCRIPT, remove];
    NSAppleScript *script = [[[NSAppleScript alloc] initWithSource:scriptSource] autorelease];
    [script executeAndReturnError:nil];
    playingState = NO;
    
    if (streamURL != nil) {
        [streamURL release];
        streamURL = nil;
    }
}


- (int)progress
{
    if (streamURL > 0) {
        NSString *scriptSource = [NSString stringWithFormat:PROGRESS_SCRIPT, streamURL];
        NSAppleScript *script = [[[NSAppleScript alloc] initWithSource:scriptSource] autorelease];
        NSAppleEventDescriptor *descriptor = [script executeAndReturnError:nil];
        return [descriptor int32Value];
    } else {
        return -1;
    }
}


- (bool)isPlaying
{
    return playingState;
}


- (void)dealloc
{
    if (streamURL != nil) {
        [streamURL release];
    }
    
    [super dealloc];
}

@end
