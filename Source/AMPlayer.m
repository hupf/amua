//
//  AMPlayer.m
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

#import "AMPlayer.h"

@implementation AMPlayer

- (id)initWithPlayback:(NSObject<AMPlayback> *)audioPlayback discoveryMode:(BOOL)mode
{
    self = [super init];
    loginState = NO;
    busyState = NO;
    errorState = NO;
    discoveryMode = mode;
    timer = nil;
    service = [[AMWebserviceClient alloc] init:self];
    playback = [audioPlayback retain];
    
    return self;
}


- (void)setDelegate:(id<AMPlayerDelegate>)delegate
{
    playerDelegate = delegate;
}


- (void)setPlayback:(NSObject<AMPlayback> *)audioPlayback
{
    if (playback != nil) {
        [playback release];
    }
    playback = [audioPlayback retain];
}


- (void)connectToServer:(NSString *)server withUser:(NSString *)user withPasswordHash:(NSString *)passwordHash;
{
    [service cancelAllRequests];
    if ([playback isPlaying]) {
        [playback stop];
    }
    loginState = NO;
    busyState = YES;
    errorState = NO;
    [service handshake:server withUser:user withPasswordHash:passwordHash];
}


- (void)start:(NSString *)station
{
    busyState = YES;
    if (stationURL != nil) {
        [stationURL release];
    }
    stationURL = [station copy];
    [service tuneToStation:station];
}


- (void)stop
{
    busyState = NO;
    if (timer != nil) {
        [timer performSelectorOnMainThread:@selector(invalidate) withObject:nil waitUntilDone:YES];
		timer = nil;
	}
    if (playerSongInfo != nil) {
        [playerSongInfo release];
        playerSongInfo = nil;
    }
    if (playlist != nil) {
        [playlist release];
        playlist = nil;
    }
    
    [playback stop];
}


- (void)love
{
    if ([playback isPlaying]) {
        if (command != nil) {
            [command release];
        }
        command = [[NSString alloc] initWithString:@"love"];
        [service executeCommand:@"love"];
    }
}


- (void)skip
{
    if ([playback isPlaying]) {
        [self updateSong:YES];
    }
}


- (void)ban
{
    if ([playback isPlaying]) {
        if (command != nil) {
            [command release];
        }
        command = [[NSString alloc] initWithString:@"ban"];
        [service executeCommand:@"ban"];
    }
}


- (void)updateSong:(BOOL)forceNext
{
    if ([playlist count] == 0) {
        skipSong = forceNext;
        [service updatePlaylist:discoveryMode];
    } else {
        int progress = [playback progress];
        if (forceNext || playerSongInfo == nil || progress < 0 || progress >= [playerSongInfo length]) {
            if (playerSongInfo != nil) {
                [playerSongInfo release];
            }
            playerSongInfo = [[playlist objectAtIndex:0] retain];
            [playlist removeObjectAtIndex:0];
            [playback startWithStreamURL:[playerSongInfo location]];
            [playerSongInfo setProgress:0];
            [playerDelegate player:self hasNewSongInformation:playerSongInfo];
        } else {
            [playerSongInfo setProgress:progress];
        }
        
        if (timer != nil) {
            [timer invalidate];
            timer = nil;
        }
        
        int remainingTime = [playerSongInfo length] - [playerSongInfo progress]+1;
        timer = [[NSTimer scheduledTimerWithTimeInterval:(remainingTime) target:self
                          selector:@selector(fireTimer:) userInfo:nil repeats:NO] retain];
    }
}


- (void)setDiscoveryMode:(bool)mode
{
    if (subscriberMode) {
        discoveryMode = mode;
        skipSong = YES;
        [service updatePlaylist:mode];
    } else {
        discoveryMode = NO;
    }
}


- (AMSongInformation *)songInformation
{
    return playerSongInfo;
}


- (NSString *)streamURL
{
    return playerStreamingURL;
}


- (NSString *)errorMessage
{
    return errorMessage;
}


- (bool)isInSubscriberMode
{
    return subscriberMode;
}


- (bool)isInDiscoveryMode
{
    return discoveryMode;
}


- (bool)isLoggedIn
{
    return loginState;
}


- (bool)isPlaying
{
    return [playback isPlaying];
}


- (bool)isBusy
{
    return busyState;
}


- (bool)hasError
{
    return errorState;
}


- (void)dealloc
{
    if (service != nil) {
        [service release];
    }
    if (playerSongInfo != nil) {
        [playerSongInfo release];
    }
    if (playlist != nil) {
        [playlist release];
    }
    if (playback != nil) {
        [playback release];
    }
    if (playerStreamingURL != nil) {
        [playerStreamingURL release];
    }
    if (timer != nil) {
        [timer invalidate];
    }
    if (stationURL != nil) {
        [stationURL release];
    }
    if (command != nil) {
        [command release];
    }
    if (errorMessage != nil) {
        [errorMessage release];
    }

    [super dealloc];
}





// AMWebserviceClient delegate implementation


- (void)webserviceHandshakeFinishedWithURL:(NSString *)streamingURL subscriberMode:(bool)isSubscriber
{
    if (playerStreamingURL != nil) {
        [playerStreamingURL release];
    }
    playerStreamingURL = [streamingURL copy];
    subscriberMode = isSubscriber;
    busyState = NO;
    loginState = YES;
    errorState = NO;
    if (playerDelegate != nil) {
        [playerDelegate player:self hasFinishedHandshakeWithStreamingURL:playerStreamingURL];
    }
}


- (void)webserviceHandshakeFailed
{
    busyState = NO;
    loginState = NO;
    if ([playback isPlaying]) {
        [self stop];
    }
    errorState = YES;
    if (errorMessage != nil) {
        [errorMessage release];
    }
    errorMessage = [[NSString alloc] initWithString:@"Login Failed"];
    
    if (playerDelegate != nil) {
        [playerDelegate player:self hasError:errorMessage];
    }
}


- (void)webserviceCommandExecutionFinished
{
    if (![command isEqualToString:@"love"]) {
        [self updateSong:YES];
    }
}


- (void)webserviceStationTuningFinished
{
    errorState = NO;
    [playerDelegate player:self hasNewStation:stationURL];
    skipSong = YES;
    [service updatePlaylist:discoveryMode];
}


- (void)webserviceStationTuningFailed
{
    busyState = NO;
    if ([playback isPlaying]) {
        [self stop];
    }
    errorState = YES;
    if (errorMessage != nil) {
        [errorMessage release];
    }
    errorMessage = [[NSString alloc] initWithString:@"Station Not Streamable"];
    
    if (playerDelegate != nil) {
        [playerDelegate player:self hasError:errorMessage];
    }
}


- (void)webservicePlaylistUpdateFinished:(NSArray *)songs
{
    busyState = NO;
    if (playlist != nil) {
        [playlist release];
    }
    playlist = [[NSMutableArray alloc] initWithArray:songs];
    [self updateSong:skipSong];
    skipSong = NO;
}


- (void)webservicePlaylistUpdateFailed
{
    busyState = NO;
    if ([playback isPlaying]) {
        [self stop];
    }
    errorState = YES;
    if (errorMessage != nil) {
        [errorMessage release];
    }
    errorMessage = [[NSString alloc] initWithString:@"Playlist Update Failed"];
    
    if (playerDelegate != nil) {
        [playerDelegate player:self hasError:errorMessage];
    }
}


- (void)webserviceConnectionError
{
    busyState = NO;
    loginState = NO;
    if ([playback isPlaying]) {
        [self stop];
    }
    errorState = YES;
    if (errorMessage != nil) {
        [errorMessage release];
    }
    errorMessage = [[NSString alloc] initWithString:@"Connection Error"];
    
    if (playerDelegate != nil) {
        [playerDelegate player:self hasError:errorMessage];
    }
}


- (void)fireTimer:(id)sender
{
    [self updateSong:NO];
}

@end
