//
//  AMPlayer.h
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

#import <Cocoa/Cocoa.h>
#import "AMWebserviceClient.h"
#import "AMRecentStations.h"
#import "AMSongInformation.h"
#import "AMiTunesPlayback.h"

@protocol AMPlayerDelegate, AMPlayback;

@interface AMPlayer : NSObject<AMWebserviceClientDelegate> {

    bool loginState;
    bool playingState;
    bool busyState;
    bool errorState;
    bool recordToProfileMode;
    bool subscriberMode;
    bool discoveryMode;
    
    AMWebserviceClient *service;
    AMSongInformation *playerSongInfo;
    NSObject<AMPlayback> *playback;
    NSString *playerStreamingURL;
    NSTimer *timer;
    NSString *stationURL;
    NSString *command;
    NSString *errorMessage;
    id<AMPlayerDelegate> playerDelegate;
    
}

- (id)initWithPlayback:(NSObject<AMPlayback> *)audioPlayback;
- (void)setDelegate:(id<AMPlayerDelegate>)delegate;
- (void)setPlayback:(NSObject<AMPlayback> *)audioPlayback;
- (void)connectToServer:(NSString *)server withUser:(NSString *)user withPasswordHash:(NSString *)passwordHash;
- (void)start:(NSString *)station;
- (void)stop;
- (void)love;
- (void)skip;
- (void)ban;
- (void)refreshSongInformation;
- (void)setDiscoveryMode:(bool)mode;
- (void)setRecordToProfileMode:(bool)mode;
- (AMSongInformation *)songInformation;
- (NSString *)streamURL;
- (NSString *)errorMessage;
- (bool)isInSubscriberMode;
- (bool)isInDiscoveryMode;
- (bool)isRecordingToProfile;
- (bool)isLoggedIn;
- (bool)isPlaying;
- (bool)isBusy;
- (bool)hasError;
- (void)dealloc;

- (void)webserviceHandshakeFinishedWithURL:(NSString *)streamingURL subscriberMode:(bool)isSubscriber;
- (void)webserviceHandshakeFailed;
- (void)webserviceSongInformationUpdateFinished:(AMSongInformation *)songInfo
                              withDiscoveryMode:(bool)discovery
                        withRecordToProfileMode:(bool)recordToProfile;
- (void)webserviceSongInformationUpdateFailed;
- (void)webserviceCommandExecutionFinished;
- (void)webserviceStationTuningFinished;
- (void)webserviceStationTuningFailed;
- (void)webserviceConnectionError;

- (void)fireTimer:(id)sender;

@end

@protocol AMPlayerDelegate

- (void)player:(AMPlayer *)player hasNewStation:(NSString *)stationURL;
- (void)player:(AMPlayer *)player hasNewSongInformation:(AMSongInformation *)songInfo;
- (void)player:(AMPlayer *)player hasFinishedHandshakeWithStreamingURL:(NSString *)streamingURL;
- (void)player:(AMPlayer *)player hasError:(NSString *)message;

@end

@protocol AMPlayback

- (void)startWithStreamURL:(NSString *)url;
- (void)stop;
- (bool)isPlaying;

@end
