//
//  AMSongInformationPanel.h
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
#import "AMSongInformation.h"
#import "AMTextField.h"
#import "Debug.h"

@interface AMSongInformationPanel : NSPanel {

    IBOutlet AMTextField *track;
    IBOutlet AMTextField *album;
    IBOutlet AMTextField *artist;
    IBOutlet NSTextField *time;
    IBOutlet AMTextField *footer;
    IBOutlet NSImageView *image;
    
    AMSongInformation *info;
	NSTimer *timer;
	BOOL visible;

}



- (id)initWithContentRect:(NSRect)contentRect
                styleMask:(unsigned int)styleMask
                  backing:(NSBackingStoreType)backingType
                    defer:(BOOL)flag;
- (id)initWithContentRect:(NSRect)contentRect
                styleMask:(unsigned int)styleMask
                  backing:(NSBackingStoreType)backingType
                    defer:(BOOL)flag
                   screen:(NSScreen *)aScreen;
- (void)show;
- (void)hide;
- (void)updateWithSongInformation:(AMSongInformation *)songInfo;
- (void)cleanUp;
- (void)updateTime:(id)sender;
- (void)autoPosition;
- (void)resize;
- (BOOL)isVisible;
- (void)dealloc;

@end
