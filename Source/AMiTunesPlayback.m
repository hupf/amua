//
//  AMPlayback.m
//  Amua
//
//  Created by Mathis & Simon Hofer on 12.12.05.
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

#import "AMiTunesPlayback.h"


@implementation AMiTunesPlayback

- (id)init
{
    self = [super init];
    playingState = NO;
    return self;
}


- (void)startWithStreamURL:(NSString *)url
{
    NSString *scriptSource = [NSString stringWithFormat:@"tell application \"iTunes\" \n open location \"%@\" \n end tell", url];
    NSAppleScript *script = [[[NSAppleScript alloc] initWithSource:scriptSource] autorelease];
    [script executeAndReturnError:nil];
    playingState = YES;
}


- (void)stop
{
    NSString *scriptSource = 
    @"tell application \"Finder\"\n\
    \tif (get name of every process) contains \"iTunes\" then\n\
    \t\ttell application \"iTunes\"\n\t\t\tstop\n\t\tend tell\n\
    \tend if\nend tell";
    NSAppleScript *script = [[[NSAppleScript alloc] initWithSource:scriptSource] autorelease];
    [script executeAndReturnError:nil];
    playingState = NO;
}


- (bool)isPlaying
{
    return playingState;
}

@end
