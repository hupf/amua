//
//  AMScrobbler.h
//  Amua
//
//  Created by Mathis & Simon Hofer on 11.10.07.
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


/**
 * AMScrobbler is the class which offers track submission to
 * audioscrobbler system.
 * @ingroup Webservice
 */
@interface AMScrobbler : NSObject<AMWebserviceRequestDelegate> {

    NSString *username;
    NSString *passwordMD5;
    NSString *sessionID;
    NSString *nowPlayingURL;
    NSString *submissionURL;
    NSMutableArray *queue;
    NSLock *queueLock;
    int requestBarrier;
    NSMutableDictionary *requestPool;
    
}

- (id)init;

/**
 * Start a audioscrobbler handshake.
 * @param scrobbleUser The username.
 * @param scrobblePassMD5 The MD5 hash of the password.
 */
- (void)handshakeWithUser:(NSString *)scrobbleUser withPasswordHash:(NSString *)scrobblePassMD5;

/**
 * Redo the handshake.
 */
- (void)rehandshake;

/**
 * Announce a song that is currently being played.
 * @param info The song info.
 */
- (void)announceSongInfo:(AMSongInformation *)info;

/**
 * Submit a song.
 * @param info The song info.
 */
- (void)scrobbleSongInfo:(AMSongInformation *)info;

- (void)cancelAllRequests;


// AMWebserviceRequestDelegate implementation


- (void)requestHasFinished:(AMWebserviceRequest *)request withData:(NSDictionary *)data;
- (void)requestHasFailed:(AMWebserviceRequest *)request;

@end
