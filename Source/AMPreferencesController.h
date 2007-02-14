//
//  AMPreferencesController.h
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

#import <Cocoa/Cocoa.h>
#import "KeyChain.h"
#import "AmuaUpdater.h"

/**
 * The controller class for the preferences window.
 * 
 * Username and webservice server are store in the application preferences file,
 * the password is store in the keychain.
 */
@interface AMPreferencesController : NSWindowController {

    /**
     * The username textfield
     */
	IBOutlet NSTextField *username;
        
    /**
     * The password textfield.
     */
    IBOutlet NSTextField *password;
        
    /**
     * The textfield for the webservice server hostname.
     */
	IBOutlet NSTextField *webServiceServer;
        
    /**
     * The preferences window.
     */
	IBOutlet NSPanel *window;
    
    /**
     * Check for updates checkbox.
     */ 
    IBOutlet NSButton *updatesCheckBox;
    
    /**
     * Check if Amua is default player checkbox.
     */
    IBOutlet NSButton *defaultCheckBox;
    
    /**
     * Select the log level.
     */
    IBOutlet NSPopUpButton *logLevel;
        
    /**
     * A reference to the application preferences object.
     */
	NSUserDefaults *preferences;
        
    /**
     * A reference to the keychain object.
     */
	KeyChain *keyChain;
}

/**
 * Constructor.
 */
- (id)init;

/**
 * Actions after the window did load..
 */
- (void)windowDidLoad;

/**
 * Actions before the window will close.
 */
- (void)windowWillClose:(NSNotification *)aNotification;

/**
 * Close the window without saving.
 */
- (IBAction)cancel:(id)sender;

/**
 * Store preferences and password and close window.
 */
- (IBAction)save:(id)sender;

/**
 * Set the default preferences (reset).
 */
- (IBAction)setDefaults:(id)sender;

/**
 * Load stored preferences and update the textfields.
 */
- (void)updateFields;

/**
 * Perform an update check.
 */
- (IBAction)checkForUpdates:(id)sender;

/**
 * Deconstructor.
 */
- (void)dealloc;

@end
