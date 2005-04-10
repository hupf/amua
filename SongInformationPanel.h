//
//  SongInformationPanel.h
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

#import <Cocoa/Cocoa.h>

@interface SongInformationPanel : NSPanel
{
    IBOutlet NSTextField *album;
    IBOutlet NSTextField *artist;
    IBOutlet NSTextField *footer;
    IBOutlet NSImageView *image;
    IBOutlet NSTextField *time;
    IBOutlet NSTextField *track;
	IBOutlet NSBox *line;
	int trackPosition;
	int trackDuration;
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
- (void)updateArtist:(NSString *)inArtist album:(NSString *)inAlbum track:(NSString *)inTrack
		albumImage:(NSImage *)inImage radioStation:(NSString *)inRadioStation radioStationUser:(NSString *)inRadioStationUser
		trackPosition:(int)inTrackPosition trackDuration:(int)inTrackDuration;
- (void)updateTime:(id)sender;
- (void)autoPosition;
- (void)resize;
- (BOOL)visible;
- (NSString *)shorten:(NSString *)string;

@end
