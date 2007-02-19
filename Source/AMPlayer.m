//
//  AMPlayer.m
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

#import "AMPlayer.h"

@implementation AMPlayer

- (id)initWithPlayback:(NSObject<AMPlayback> *)audioPlayback
{
    self = [super init];
    loginState = NO;
    busyState = NO;
    errorState = NO;
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
        if (command != nil) {
            [command release];
        }
        command = [[NSString alloc] initWithString:@"skip"];
        [service executeCommand:@"skip"];
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


- (void)refreshSongInformation
{
    if ([playback isPlaying]) {
        busyState = YES;
        [service updateSongInformation];
    }
}


- (void)setDiscoveryMode:(bool)mode
{
    if (subscriberMode) {
        discoveryMode = mode;
        [service setDiscoveryMode:discoveryMode];
    } else {
        discoveryMode = NO;
    }
}


- (void)setRecordToProfileMode:(bool)mode
{
    recordToProfileMode = mode;
    [service setRecordToProfileMode:recordToProfileMode];
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


- (bool)isRecordingToProfile
{
    return recordToProfileMode;
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


- (void)webserviceSongInformationUpdateFinished:(AMSongInformation *)songInfo
                              withDiscoveryMode:(bool)discovery
                        withRecordToProfileMode:(bool)recordToProfile;
{
    busyState = NO;
    bool isNew = playerSongInfo == nil || ![playerSongInfo isEqualToSongInformation:songInfo];
    if (isNew) {
        if (playerSongInfo != nil) {
            [playerSongInfo release];
            playerSongInfo = nil;
        }
        if ([songInfo isValid]) {
            playerSongInfo = [songInfo retain];
            recordToProfileMode = recordToProfile;
            discoveryMode = discovery;
        } else {
            AmuaLog(LOG_WARNING, @"invalid song information");
        }
    } else {
        AmuaLog(LOG_WARNING, @"old song information");
    }
    
    int remainingTime = [playerSongInfo length] - [playerSongInfo progress] - 5;
    if (remainingTime < 5) {
        remainingTime = 5;
    }
	
	if (timer != nil) {
        [timer invalidate];
        timer = nil;
	}
    timer = [[NSTimer scheduledTimerWithTimeInterval:(remainingTime) target:self
                  selector:@selector(fireTimer:) userInfo:nil repeats:NO] retain];
    
    if (isNew && playerDelegate != nil) {
        [playerDelegate player:self hasNewSongInformation:playerSongInfo];
    }
}


- (void)webserviceSongInformationUpdateFailed
{
    if (timer != nil) {
        [timer invalidate];
        timer = nil;
	}
    timer = [[NSTimer scheduledTimerWithTimeInterval:(5) target:self
                  selector:@selector(fireTimer:) userInfo:nil repeats:NO] retain];
}


- (void)webserviceCommandExecutionFinished
{
    if (![command isEqualToString:@"love"]) {
        [self refreshSongInformation];
    }
}


- (void)webserviceStationTuningFinished
{
    errorState = NO;
    
    if (![playback isPlaying]) {
        [playback startWithStreamURL:playerStreamingURL];
    }
    
    if (playerDelegate != nil) {
        [playerDelegate player:self hasNewStation:stationURL];
    }
    
    [self refreshSongInformation];
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
    [self refreshSongInformation];
}

@end
