//
//  AMTagController.h
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
#import "Debug.h"

// TODO rewrite


@interface AMTagController : NSObject
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
     * The table displaying the current tags.
     */
    IBOutlet NSTableView *tagsTable;
    
    /**
     * The textfield that lets the user add more tags.
     */
    IBOutlet NSTextField *tagField;
    
    /**
     * The tag window.
     */
    IBOutlet NSWindow *tagWindow;
    
    /**
     * The spinner as progress indicator.
     */
    IBOutlet NSProgressIndicator *spinner;
    
    /**
     * The textfield that is used to display errors.
     */
    IBOutlet NSTextField *errorField;
    
    /**
     * The button that is used to add new tags.
     */
    IBOutlet NSButton *addButton;
    
    /**
     * The button that is used to remove tags.
     */
    IBOutlet NSButton *removeButton;
    
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
    NSMutableArray *userArtistTags;
    
    /**
     * A string containing the tags for the current album.
     */
    NSMutableArray *userAlbumTags;
    
    /**
     * A string containing the tags for the current track.
     */
    NSMutableArray *userTrackTags;
    
    /**
     * The array that is currently being edited.
     */
    NSMutableArray *currentTags;
    
    /**
     * A reference to the application preferences object.
     */
	NSUserDefaults *preferences;
    
    /**
     * The webservice communication object.
     */
	//LastfmWebService *webservice;
    
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
//- (void)setWebservice:(LastfmWebService *)service;

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
//- (void)searchFinished:(SearchService *)service;

/**
 * Display an error about a failed search.
 */
//- (void)searchFailed:(SearchService *)service;

/**
 * Update the track data.
 */
- (void)setNewTrack:(NSString *)inTrack fromAlbum:(NSString *)inAlbum andArtist:(NSString *)inArtist;

/**
 * Refresh the tags the user has set for the current data.
 */
- (void)refreshTags;

/**
 * Add the tags specified.
 */
- (IBAction)addTag:(id)sender;

/**
 * Remove the selected tags.
 */
- (IBAction)removeTag:(id)sender;

/**
 * Save the entered tags.
 */
- (IBAction)saveTags:(id)sender;

/**
 * The tags have been saved successfully.
 */
- (void)tagSaved:(id)sender;

/**
 * There has been an error saving the tags.
 */
- (void)tagError:(id)sender;

/**
 * Change the selected radio button.
 */
- (IBAction)changeRadioButton:(id)sender;

/**
 * Set the application preferences  object.
 */
- (void)setPreferences:(NSUserDefaults *)prefs;

/**
 * Get the item of a certain row.
 */
- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(int)rowIndex;

/**
 * Get the number of rows.
 */
- (int)numberOfRowsInTableView:(NSTableView *)aTableView;

/**
 * Convert an array to a comma separated string.
 */
- (NSString *)convertArrayToString:(NSArray *)array;

@end
