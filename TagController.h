//
//  TagController.h
//  Amua
//
//  Created by Mathis & Simon Hofer on 04.02.06.
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
#import "LastfmWebService.h"
#import "SearchService.h"

@interface TagController : NSObject
{
    /**
     * The radio button for the album.
     */
    IBOutlet NSButtonCell *albumButton;
    
    /**
     * The label displaying the current album.
     */
    IBOutlet NSTextField *albumLabel;
    
    /**
     * The radio button for the artist.
     */
    IBOutlet NSButtonCell *artistButton;
    
    /**
     * The label displaying the current artist.
     */
    IBOutlet NSTextField *artistLabel;
    
    /**
     * The radio button for the track.
     */
    IBOutlet NSButtonCell *trackButton;
    
    /**
     * The label displaying the current track.
     */
    IBOutlet NSTextField *trackLabel;
    
    /**
     * The save tags button.
     */
    IBOutlet NSButton *saveButton;
    
    /**
     * The matrix containing the radio buttons.
     */
    IBOutlet NSMatrix *radioButtons;
    
    /**
     * The combobox which lets the user specify his tags.
     */
    IBOutlet NSComboBox *tagCombo;
    
    /**
     * The tag window.
     */
    IBOutlet NSWindow *tagWindow;
    
    /**
     * The spinner as progress indicator.
     */
    IBOutlet NSProgressIndicator *spinner;
    
    /**
     * The current artist.
     */
    NSString *artist;
   
    /**
     * The current album.
     */
    NSString *album;
    
    /**
     * The current track.
     */
    NSString *track;
    
    /**
     * An array containing the tags (as dictionary with keys: name, url, count).
     */
    NSArray *userTags;
    
    /**
     * A string containing the tags for the current artist.
     */
    NSString *userArtistTags;
    
    /**
     * A string containing the tags for the current album.
     */
    NSString *userAlbumTags;
    
    /**
     * A string containing the tags for the current track.
     */
    NSString *userTrackTags;
    
    /**
     * A reference to the application preferences object.
     */
	NSUserDefaults *preferences;
    
    /**
     * The webservice communication object.
     */
	LastfmWebService *webservice;
    
    /**
     * A boolean indicating whether a saving action happens.
     */
    bool isSaving;
}


/**
 * Show the tag window.
 */
- (IBAction)showWindow:(id)sender;

/**
 * Hide the tag window.
 */
- (void)hideWindow;

/**
 * Set the webservice object.
 */
- (void)setWebservice:(LastfmWebService *)service;

/**
 * Release the webservice.
 */
- (void)releaseWebservice;

/**
 * Get the top tags of the user.
 */
- (void)searchTags;

/**
 * Display the search result.
 */
- (void)searchFinished:(SearchService *)service;

/**
 * Update the track data.
 */
- (void)setNewTrack:(NSString *)inTrack fromAlbum:(NSString *)inAlbum andArtist:(NSString *)inArtist;

/**
 * Refresh the tags the user has set for the current data.
 */
- (void)refreshTags;

/**
 * Save the entered tags.
 */
- (IBAction)saveTags:(id)sender;

/**
 * The tags have been saved successfully.
 */
- (void)tagSaved:(id)sender;

/**
 * Change the selected radio button.
 */
- (IBAction)changeRadioButton:(id)sender;

/**
 * Set the application preferences  object.
 */
- (void)setPreferences:(NSUserDefaults *)prefs;

/**
 * Delegate of the combobox datasource. Get the number of tags available.
 */
- (int)numberOfItemsInComboBox:(NSComboBox *)aComboBox;

/**
 * Delegate of the combobox datasource. Get the tag at a certain index.
 */
- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(int)index;

/**
 * Delegate of the combobox datasource. Complete an entered string.
 */
- (NSString *)comboBox:(NSComboBox *)aComboBox completedString:(NSString *)uncompletedString;

@end
