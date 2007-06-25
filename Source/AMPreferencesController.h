//
//  AMPreferencesController.h
//  Amua
//
//  Created by Mathis & Simon Hofer on 17.02.05.
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
#import "KeyChain.h"
#import "AmuaUpdater.h"

/**
 * AMPreferencesController represents a controller for the preferences window.
 * 
 * Username and webservice server are store in the application preferences file,
 * the password is stored in the keychain.
 * @ingroup Controller
 */
@interface AMPreferencesController : NSWindowController {

	IBOutlet NSTextField *username;
    IBOutlet NSTextField *password;
	IBOutlet NSTextField *webServiceServer;
   	IBOutlet NSPanel *window;
    IBOutlet NSButton *updatesCheckBox;
    IBOutlet NSButton *defaultCheckBox;
    IBOutlet NSPopUpButton *logLevel;
	NSUserDefaults *preferences;
	KeyChain *keyChain;
}


- (id)init;
- (void)windowDidLoad;
- (void)windowWillClose:(NSNotification *)aNotification;

/**
 * Update the window with the stored user preferences.
 */
- (void)updateFields;

- (void)dealloc;
- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)setDefaults:(id)sender;
- (IBAction)checkForUpdates:(id)sender;

@end
