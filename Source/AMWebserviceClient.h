//
//  AMWebserviceClient.h
//  Amua
//
//  Created by Mathis & Simon Hofer on 28.11.06.
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
#import "AMWebserviceRequest.h"
#import "AMSongInformation.h"
#import "AMLineTextParser.h"
#import "AMUtil.h"
#import "Debug.h"

@protocol AMWebserviceClientDelegate;

/**
 * @defgroup Webservice
 * Classes and protocols used for the webservice communication.
 */

/**
 * AMWebserviceClient is the local representation of the webservice.
 * @ingroup Webservice
 */
@interface AMWebserviceClient : NSObject<AMWebserviceRequestDelegate> {

    NSString *baseURL;
	NSString *basePath;
    NSString *sessionID;
    NSMutableDictionary *requestPool;
    id<AMWebserviceClientDelegate> delegate;

}

/**
 * Return an initialized AMWebserviceClient.
 * @param delegate The delegate which is notified about request results.
 */
- (id)init:(id<AMWebserviceClientDelegate>)delegate;

/**
 * Start a handshake with the server using account data.
 * @param server The server url.
 * @param username The username.
 * @param passwordMD5 The MD5 hash of the password.
 */
- (void)handshake:(NSString *)server withUser:(NSString *)username withPasswordHash:(NSString *)passwordMD5;

/**
 * Start a command execution.
 * @param command A command (e.g. love, skip, ban)
 */
- (void)executeCommand:(NSString *)command;

/**
 * Start a station tuning.
 * @param stationURL The Last.fm station url (starting with lastfm://)
 */
- (void)tuneToStation:(NSString *)stationURL;

/**
 * Fetch the next few tracks for the playlist.
 * @param discoveryMode The discovery mode setting.
 */
- (void)updatePlaylist:(BOOL)discoveryMode;

/**
 * Cancel all unfinished requests.
 */
- (void)cancelAllRequests;

- (void)dealloc;


// AMWebserviceRequestDelegate implementation


- (void)requestHasFinished:(AMWebserviceRequest *)request withData:(NSDictionary *)data;
- (void)requestHasFailed:(AMWebserviceRequest *)request;

@end


/**
 * AMWebserviceClientDelegate is a protocol for classes that can register
 * for AMWebserviceClient events.
 * @ingroup Webservice
 */
@protocol AMWebserviceClientDelegate

/**
 * Notification about a completed handshake request.
 * @param streamingURL The url of the audio stream.
 * @param isSubscriber A flag indicating the subscriber state of the user.
 */
- (void)webserviceHandshakeFinishedWithURL:(NSString *)streamingURL subscriberMode:(bool)isSubscriber;

/**
 * Notification about a handshake request failure.
 */
- (void)webserviceHandshakeFailed;

/**
 * Notification about a completed command execution.
 */
- (void)webserviceCommandExecutionFinished;

/**
 * Notification about a completed station tuning request.
 */
- (void)webserviceStationTuningFinished;

/**
 * Notification about a station tuning request failure.
 */
- (void)webserviceStationTuningFailed;

/**
 * Notification about a completed playlist update request.
 * @param songs The song info objects of the playlist songs.
 */
- (void)webservicePlaylistUpdateFinished:(NSArray *)songs;

/**
 * Notification about a playlist update failure.
 */
- (void)webservicePlaylistUpdateFailed;

/**
 * Notification about a connection error during a request.
 */
- (void)webserviceConnectionError;

@end
