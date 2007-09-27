//
//  AMiTunesPlayback.h
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

#import <Cocoa/Cocoa.h>
#import "AMPlayer.h"

@protocol AMPlayback;

/**
 * AMiTunesPlayback represents an AMPlayback that starts the stream in iTunes using 
 * AppleScript.
 * @ingroup Player
 */
@interface AMiTunesPlayback : NSObject<AMPlayback> {
    
    bool playingState;
    NSString *streamURL;
    
}

- (void)startWithStreamURL:(NSString *)url;
- (void)stop;
- (int)progress;
- (bool)isPlaying;
- (void)dealloc;

@end
