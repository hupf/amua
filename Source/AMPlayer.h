//
//  AMPlayer.h
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
#import "AMWebserviceClient.h"
#import "AMScrobbler.h"
#import "AMRecentStations.h"
#import "AMSongInformation.h"
#import "AMiTunesPlayback.h"

// @cond FORWARD_DECLARATION
@protocol AMPlayerDelegate, AMPlayback;
// @endcond

/**
 * @defgroup Player 
 * Classes and protocols referring to the player.
 */

/**
 * AMPlayer is the client representation of the Last.fm player.
 *
 * It can be used to start/control the stream and it automatically updates
 * song informations.
 * @ingroup Player
 */
@interface AMPlayer : NSObject<AMWebserviceClientDelegate> {

    bool loginState;
    bool playingState;
    bool busyState;
    bool errorState;
    bool skipSong;
    bool subscriberMode;
    bool discoveryMode;
    bool scrobbleMode;
    
    AMWebserviceClient *service;
    AMScrobbler *scrobbler;
    AMSongInformation *playerSongInfo;
    NSMutableArray *playlist;
    NSObject<AMPlayback> *playback;
    NSString *playerStreamingURL;
    NSTimer *timer;
    NSString *stationURL;
    NSString *command;
    NSString *errorMessage;
    id<AMPlayerDelegate> playerDelegate;
    
}

/**
 * Return an AMPlayer object initialized with an audio playback.
 * @param audioPlayback The audio playback used to play the audo stream.
 * @param discovery The initial discovery mode setting.
 * @param scrobble The initial scrobble mode setting.
 * @return The initialized AMPlayer.
 */
- (id)initWithPlayback:(NSObject<AMPlayback> *)audioPlayback discoveryMode:(BOOL)discovery scrobbleMode:(BOOL)scrobble;

/**
 * Set the delegate which is notified on player events.
 * @param delegate The delegate.
 * @see AMPlayerDelegate
 */
- (void)setDelegate:(id<AMPlayerDelegate>)delegate;

/**
 * Set the audio playback.
 * @param audioPlayback The audio playback which plays the audio stream.
 */
- (void)setPlayback:(NSObject<AMPlayback> *)audioPlayback;

/**
 * Perform a handshake with the Last.fm server using account data.
 *
 * On success player:hasFinishedHandshakeWithStreamingURL: is called on the 
 * player delegate, otherwise player:hasError:
 * @param server The server url.
 * @param user The username.
 * @param passwordHash The MD5 hash of the password.
 */
- (void)connectToServer:(NSString *)server withUser:(NSString *)user withPasswordHash:(NSString *)passwordHash;

/**
 * Start listening to a radio station.
 *
 * This method tunes to the station and initiates further actions like
 * song information update.
 * On success player:hasNewStation: is called on the player delegate, otherwise
 * player:hasError:
 * @param station A Last.fm station url (starting with lastfm://)
 */
- (void)start:(NSString *)station;

/**
 * Stop the player.
 */
- (void)stop;

/**
 * Love the current track.
 */
- (void)love;

/**
 * Skip to the next track.
 */
- (void)skip;

/**
 * Ban the current track.
 */
- (void)ban;

/**
 * Update the current song.
 * @param forceNext Force playback of the next song.
 */
- (void)updateSong:(BOOL)forceNext;

/**
 * Set the discovery mode setting.
 * @param mode YES = discovery mode on, NO = off.
 */
- (void)setDiscoveryMode:(bool)mode;

/**
 * Set the scrobble mode setting.
 * @param scrobble YES = on, NO = off.
 */
- (void)setScrobbleMode:(bool)scrobble;

/**
 * Get the current song information.
 * @return The current song information or nil if none available.
 */
- (AMSongInformation *)songInformation;

/**
 * Get the stream url.
 * @return the stream url if available else nil.
 */
- (NSString *)streamURL;

/**
 * Get the last error message.
 * @return The last error message if available.
 * @see hasError 
 */
- (NSString *)errorMessage;

/**
 * Check if the current user is a subscriber.
 * @return Subscriber status if the player is logged in.
 * @see isLoggedIn
 */
- (bool)isInSubscriberMode;

/**
 * Check if the player is in discovery mode.
 * @return Discovery mode setting if the player is logged in.
 * @see isLoggedIn
 */
- (bool)isInDiscoveryMode;

/**
 * Check if the player is scrobbling.
 * @return The scrobble mode setting.
 */
- (bool)isScrobbling;

/**
 * Check if the player is logged in to the server.
 * @return YES if the player is logged in else NO.
 */
- (bool)isLoggedIn;

/**
 * Check if the player is playing.
 * @return YES if the player is playing else NO.
 */
- (bool)isPlaying;

/**
 * Check if the player is busy.
 * @return YES if the player is performing a request else NO.
 */
- (bool)isBusy;

/**
 * Check if the player is in an error state.
 * @return YES if the player is in an error state else NO.
 */
- (bool)hasError;

- (void)dealloc;


// AMWebserviceDelegate implementation


- (void)webserviceHandshakeFinishedWithURL:(NSString *)streamingURL subscriberMode:(bool)isSubscriber;
- (void)webserviceHandshakeFailed;
- (void)webserviceCommandExecutionFinished;
- (void)webserviceStationTuningFinished;
- (void)webserviceStationTuningFailed;
- (void)webserviceConnectionError;

- (void)fireTimer:(id)sender;

@end


/**
 * AMPlayerDelegate is a protocol for classes that can register for events
 * of an AMPlayer object.
 * @ingroup Player
 */
@protocol AMPlayerDelegate

/**
 * Notification that the player has tuned to a new station.
 * @param player The player sending the notification.
 * @param stationURL The station url of the new station.
 */
- (void)player:(AMPlayer *)player hasNewStation:(NSString *)stationURL;

/**
 * Notification about new song information.
 * @param player The player sending the notification.
 * @param songInfo The new song information.
 */
- (void)player:(AMPlayer *)player hasNewSongInformation:(AMSongInformation *)songInfo;

/**
 * Notification about a finished handshake with the server.
 * @param player The player sending the notification.
 * @param streamingURL The url of the audio stream.
 */
- (void)player:(AMPlayer *)player hasFinishedHandshakeWithStreamingURL:(NSString *)streamingURL;

/**
 * Notification about a player error.
 * @param player The player sending the notification.
 * @param message The error message.
 */
- (void)player:(AMPlayer *)player hasError:(NSString *)message;

@end


/**
 * AMPlayback is the protocol for classes that can play audio streams.
 * @ingroup Player
 */
@protocol AMPlayback

/**
 * Start an audio stream.
 * @param url The url of the audio stream.
 */
- (void)playSong:(AMSongInformation *)songInfo;

/**
 * Stop the audio stream.
 */
- (void)stop;

/**
 * Return the progress of the playback for the current song.
 * @return The track progress in seconds.
 */
- (int)progress;

/**
 * Check if the audio playback is playing.
 * @return YES if it is playing else NO.
 */
- (bool)isPlaying;

@end
