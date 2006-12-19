//
//  AMWebserviceClient.h
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
#import "AMWebserviceRequest.h"
#import "AMSongInformation.h"
#import "Debug.h"

@protocol AMWebserviceClientDelegate;

@interface AMWebserviceClient : NSObject<AMWebserviceRequestDelegate> {

    NSString *baseURL;
	NSString *basePath;
    NSString *sessionID;
    AMSongInformation *songInfo;
    NSMutableDictionary *requestPool;
    id<AMWebserviceClientDelegate> delegate;

}

- (id)init:(id<AMWebserviceClientDelegate>)delegate;
- (void)handshake:(NSString *)server withUser:(NSString *)username withPasswordHash:(NSString *)passwordMD5;
- (void)updateSongInformation;
- (void)executeCommand:(NSString *)command;
- (void)tuneToStation:(NSString *)stationURL;
- (void)setDiscoveryMode:(bool)state;
- (void)setRecordToProfileMode:(bool)state;
- (void)cancelAllRequests;
- (void)dealloc;

- (void)requestHasFinished:(AMWebserviceRequest *)request withData:(NSDictionary *)data;
- (void)requestHasFailed:(AMWebserviceRequest *)request;

@end

@protocol AMWebserviceClientDelegate

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

@end
