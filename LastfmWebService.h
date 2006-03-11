//
//  LastfmWebService.h
//  Amua
//
//  Created by Mathis & Simon Hofer on 20.02.05.
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
#import "Debug.h"


/**
 * Communication class for controlling the stream and fetching song information.
 * 
 * This class uses the CURLHandle framework for the HTTP communication with the
 * Last.fm webservice.
 */
@interface LastfmWebService : NSObject <NSURLHandleClient> {

	/**
     * The webservice server's hostname.
     */
	NSString *server;
    
    /**
     * User agent name that is sent with the HTML header.
     */
	NSString *userAgent;
    
    /**
     * The name of the Last.fm user.
     */
    NSString *user;
    
    /**
     * The URL of the station to play (tune in).
     */
	NSString *stationUrl;
	
	/**
     * The CURLHandle object for the data transmission of the get session commands.
     */
    CURLHandle *getSessionCURLHandle;
    
	/**
     * The CURLHandle object for fetching informations about the playing song.
     */
    CURLHandle *nowPlayingCURLHandle;
    
	/**
     * The CURLHandle object for the data transmission of various control commands.
     */
	CURLHandle *controlCURLHandle;
    
	/**
     * The CURLHandle object for the data transmission of tuning to a station commands.
     */
	CURLHandle *tuningCURLHandle;
    
	/**
     * The CURLHandle object to set the discovery mode.
     */
	CURLHandle *discoveryCURLHandle;
	
	/**
     * Will contain the session id after a session has been established.
     */
	NSString *sessionID;
    
    /**
     * Will contain the hostname of the streaming server after a session has been established.
     */
	NSString *streamingServer;
    
    /**
     * The host that is returned after handshake.
     * 
     * Used to send further commands.
     */
	NSString *baseHost;
    
    /**
     * The path on the baseHost that is returned after handshake.
     * 
     * Used to send further commands.
     */
	NSString *basePath;
    
    /**
     * Will contain informations about the playing song after information has been received.
     */
	NSMutableDictionary *nowPlayingInformation;
    
    /**
     * Will contain the album cover image of the playing song after information has been received.
     */
	NSImage *albumCover;
    
    /**
     * If true the song information will be refreshed on the next action
     */
    bool refreshSongInformation;
	
}

/**
 * Constructor with given server and station URL.
 * 
 * @param webServiceServer The host to connect to.
 * @param url The station URL to connect to.
 * @param userAgentIdentifier The user agent string.
 */
- (id)initWithWebServiceServer:(NSString *)webServiceServer
		asUserAgent:(NSString *)userAgentIdentifier
        forUser:(NSString *)username withPasswordHash:(NSString *)passwordMD5;

/**
 * Establish session for a given user (request a sessionID).
 * 
 * @param username The username of the user to identify.
 * @param passwordMD5 The MD5 hash of the user's password.
 */
- (void)handshake:(NSString *)username withPasswordHash:(NSString *)passwordMD5;

/**
 * Request song information of the currently playing track.
 */
- (void)updateNowPlayingInformation;

/**
 * Execute a given control command.
 * 
 * @param command A command to execute (possible commands are skip, ban, love,
 *                rtp and nortp).
 */
- (void)executeControl:(NSString *)command;

/**
 * Execute a command to adjust (tune in) to a given station URL.
 */
- (CURLHandle *)adjust:(NSString *)url;

/**
 * Tune in to the station defined by stationUrl.
 */
- (void)tuneStation;

/**
 * Set the discovery mode on or off.
 * 
 * @param state YES to switch it on, NO to switch it off.
 */
- (void)setDiscovery:(bool)state;

/**
 * Set the station
 *
 * @param stationUrl The last.fm url of the station
 */
- (void)setStationURL:(NSString *)url;

/**
 * Get the hostname of the streaming server as returned by the session command.
 * 
 * @return The hostname of the streaming server.
 */
- (NSString *)streamingServer;

/**
 * Check if currently in streaming state.
 * 
 * @return YES if streaming, NO otherwise.
 */
- (bool)streaming;

/**
 * Get the artist name of the current song.
 * 
 * This information is only available after updateNowPlayingInformation has been
 * called. Otherwise nil is returned.
 * 
 * @return The artist name of the current song.
 */
- (NSString *)nowPlayingArtist;

/**
 * Get the track name of the current song.
 * 
 * This information is only available after updateNowPlayingInformation has been
 * called. Otherwise nil is returned.
 * 
 * @return The track name of the current song.
 */
- (NSString *)nowPlayingTrack;

/**
 * Get the album name of the current song.
 * 
 * This information is only available after updateNowPlayingInformation has been
 * called. Otherwise nil is returned.
 * 
 * @return The album name of the current song.
 */
- (NSString *)nowPlayingAlbum;

/**
 * Get the album URL of the current song.
 * 
 * This information is only available after updateNowPlayingInformation has been
 * called. Otherwise nil is returned.
 * 
 * @return The album URL of the current song.
 */
- (NSURL *)nowPlayingAlbumPage;

/**
 * Get the album cover image of the current song.
 * 
 * This information is only available after updateNowPlayingInformation has been
 * called. Otherwise nil is returned.
 * 
 * @return The album cover image of the current song.
 */
- (NSImage *)nowPlayingAlbumImage;

/**
 * Get the duration of the current track.
 * 
 * This information is only available after updateNowPlayingInformation has been
 * called. Otherwise -1 is returned.
 * 
 * @return The duration of the current track in seconds.
 */
- (int)nowPlayingTrackDuration;

/**
 * Get the already played time of the current track.
 * 
 * This information is only available after updateNowPlayingInformation has been
 * called. Otherwise -1 is returned.
 * 
 * @return The already played time of the current track in seconds.
 */
- (int)nowPlayingTrackProgress;

/**
 * Get the currently playing station name.
 * 
 * This information is only available after updateNowPlayingInformation has been
 * called. Otherwise nil is returned.
 * 
 * @return The currently playing station name.
 */
- (NSString *)nowPlayingRadioStation;

/**
 * Get the profile name of the currently playing station.
 * 
 * This information is only available after updateNowPlayingInformation has been
 * called and if station type is profile or personal radio. Otherwise nil is returned.
 * 
 * @return The profile name of the currently playing station.
 */
- (NSString *)nowPlayingRadioStationProfile;

/**
 * Parse the values out of the HTTP result and do necessary actions.
 */
- (void)URLHandleResourceDidFinishLoading:(NSURLHandle *)sender;

- (void)URLHandleResourceDidBeginLoading:(NSURLHandle *)sender;

- (void)URLHandleResourceDidCancelLoading:(NSURLHandle *)sender;

/**
 * Nothing to be done.
 */
- (void)URLHandle:(NSURLHandle *)sender resourceDataDidBecomeAvailable:(NSData *)newBytes;

/**
 * Display error.
 */
- (void)URLHandle:(NSURLHandle *)sender resourceDidFailLoadingWithReason:(NSString *)reason;

/**
 * Deconstructor.
 */
- (void)dealloc;

@end
