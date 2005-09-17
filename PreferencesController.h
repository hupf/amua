//
//  PreferencesController.h
//  Amua
//
//  Created by Mathis & Simon Hofer on 17.02.05.
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
#import "KeyChain.h"

@interface PreferencesController : NSWindowController
{
	IBOutlet NSPopUpButton *radioStation;
	IBOutlet NSTextField *username;
    IBOutlet NSTextField *password;
	IBOutlet NSTextField *webServiceServer;
	IBOutlet NSPanel *window;
	NSUserDefaults *preferences;
	KeyChain *keyChain;
}
- (void)windowDidLoad;
- (void)windowWillClose:(NSNotification *)aNotification;
- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)setDefaults:(id)sender;
- (void)updateFields;
- (void)dealloc;
@end
