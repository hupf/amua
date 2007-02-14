//
//  AmuaUpdater.h
//  Amua
//
//  Created by Mathis & Simon Hofer on 06.03.05.
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
#import "AMNotification.h"
#import "AMWebserviceRequest.h"

/**
 * The class that checks for and handles Amua updates.
 */
@interface AmuaUpdater : NSObject<AMWebserviceRequestDelegate> {
	
    /**
     * A reference to the application preferences object.
     */
	NSUserDefaults *preferences;
    
	AMWebserviceRequest *updateRequest;
    
    /**
     * Always show a message, even if no update is available.
     */
    bool verbose;
    
    /**
     * The notification dialog to notify the user about the current updates.
     */
    AMNotification *notification;
    
    /**
     * The URL where the update is located.
     */
    NSURL *updateUrl;

}

/**
 * Constructor.
 */
- (id)init;

/**
 * Set verbose mode.
 */
- (void)setVerbose:(bool)v;

/**
 * Send request to check if new updates are available.
 */
- (void)checkForUpdates;

/**
 * The method that is called by the Notification object when dialog has been clicked.
 */
- (void)finishCheckForUpdates:(id)sender;

/**
 * Upgrade the Amua preferences file to the newest version.
 */
- (void)upgradeConfigFile;

- (void)requestHasFinished:(AMWebserviceRequest *)request withData:(NSObject *)data;
- (void)requestHasFailed:(AMWebserviceRequest *)request;

/**
 * Deconstructor.
 */
- (void)dealloc;

@end
