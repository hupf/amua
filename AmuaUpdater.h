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
#import <CURLHandle/CURLHandle.h>
#import <CURLHandle/CURLHandle+extras.h>
#import "KeyChain.h"

/**
 * The class that checks for and handles Amua updates.
 */
@interface AmuaUpdater : NSObject <NSURLHandleClient> {
	
    /**
     * A reference to the application preferences object.
     */
	NSUserDefaults* preferences;
    
	/**
     * The CURLHandle object for the data transmission to look for updates.
     */
	CURLHandle* updaterCURLHandle;
    
    /**
     * Always show a message, even if no update is available.
     */
    bool verbose;

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
 * Upgrade the Amua preferences file to the newest version.
 */
- (void)upgradeConfigFile;

/**
 * If a new update is available, inform the user.
 */
- (void)URLHandleResourceDidFinishLoading:(NSURLHandle*)sender;

/**
 * Nothing to be done.
 */
- (void)URLHandleResourceDidBeginLoading:(NSURLHandle*)sender;

/**
 * No error message.
 */
- (void)URLHandleResourceDidCancelLoading:(NSURLHandle*)sender;

/**
 * Nothing to be done.
 */
- (void)URLHandle:(NSURLHandle *)sender resourceDataDidBecomeAvailable:(NSData*)newBytes;

/**
 * No error message.
 */
- (void)URLHandle:(NSURLHandle *)sender resourceDidFailLoadingWithReason:(NSString*)reason;

/**
 * Deconstructor.
 */
- (void)dealloc;

@end
