//
//  SongInformationPanel.h
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

#import <Cocoa/Cocoa.h>
#import "FloatingTextField.h"
#import "Debug.h"

/**
 * Implementation of the song information panel.
 * 
 * The panel may be used as tooltip window, visible only on mouseover, or as
 * floating window somewhere on the screen. It can be dragged around.
 */
@interface SongInformationPanel : NSPanel {

	/**
     * The textfield to display the album name.
     */
    IBOutlet FloatingTextField *album;
    
    /**
     * The textfield to display the artist name.
     */
    IBOutlet FloatingTextField *artist;
    
    /**
     * The textfield to display a footer text (station name, profile).
     */
    IBOutlet FloatingTextField *footer;
    
    /**
     * The album cover image.
     */
    IBOutlet NSImageView *image;
    
    /**
     * The textfield to display the played and remaining time.
     */
    IBOutlet NSTextField *time;
    
    /**
     * The textfield to display the track name.
     */
    IBOutlet FloatingTextField *track;
    
    /**
     * A separation line.
     */
	IBOutlet NSBox *line;
    
    /**
     * The already played time of the track.
     */
	int trackPosition;
    
    /**
     * The remaining time of the track.
     */
	int trackDuration;
    
    /**
     * A timer to update the already played time.
     */
	NSTimer *timer;
    
    /**
     * A flag for whether the panel is visible or not.
     */
	BOOL visible;
    
    /**
     * A flag whether the informations are new.
     */
    BOOL newSongInformations;
}


/**
 * Constructor.
 * 
 * @param contentRect 
 * @param styleMask 
 * @param backingType 
 * @param flag 
 */
- (id)initWithContentRect:(NSRect)contentRect
                styleMask:(unsigned int)styleMask
                  backing:(NSBackingStoreType)backingType
                    defer:(BOOL)flag;

/**
 * Constructor.
 * 
 * @param contentRect 
 * @param styleMask 
 * @param backingType 
 * @param flag 
 * @param aScreen
 */
- (id)initWithContentRect:(NSRect)contentRect
                styleMask:(unsigned int)styleMask
                  backing:(NSBackingStoreType)backingType
                    defer:(BOOL)flag
                   screen:(NSScreen *)aScreen;

/**
 * Show the panel.
 */
- (void)show;

/**
 * Hide the panel.
 */
- (void)hide;

/**
 * Update the informations on the panel.
 * 
 * @param inArtist The artist name.
 * @param inAlbum The album name.
 * @param inTrack The track name.
 * @param inImage The album cover image.
 * @param inRadioStation The radio station that is playing.
 * @param inRadioStationUser The user the station is feeding from (for profile
 *                           and personal radio).
 * @param inTrackPosition The played time.
 * @param inTrackDuration The remaining time to play.
 */
- (void)updateArtist:(NSString *)inArtist album:(NSString *)inAlbum track:(NSString *)inTrack
		albumImage:(NSImage *)inImage radioStation:(NSString *)inRadioStation
        radioStationUser:(NSString *)inRadioStationUser
		trackPosition:(int)inTrackPosition trackDuration:(int)inTrackDuration;

/**
 * Check whether the current song informations are new or have been set
 * multiple times.
 *
 * @return True if the informations are new.
 */
- (BOOL)hasNewSongInformations;

/**
 * Updates the already played time.
 */
- (void)updateTime:(id)sender;

/**
 * 
 */
- (void)autoPosition;

/**
 * Resize the panel by the size of the contained textfields.
 */
- (void)resize;

/**
 * Check whether the panel is visible or not.
 * 
 * @return YES if the panel is visible, NO otherwise.
 */
- (BOOL)visible;

@end
