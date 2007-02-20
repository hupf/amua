//
//  AMWebserviceClient.m
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

#import "AMWebserviceClient.h"

#define HANDSHAKE_REQUEST @"handshake_request"
#define SONG_INFORMATION_REQUEST @"song_information_request"
#define COMMAND_REQUEST @"command_request"
#define STATION_TUNING_REQUEST @"station_tuning_request"
#define DISCOVERY_MODE_REQUEST @"discovery_mode_request"
#define RECORD_TO_PROFILE_REQUEST @"record_to_profile_request"

@implementation AMWebserviceClient

- (id)init:(id<AMWebserviceClientDelegate>)webserviceDelegate
{
    self = [super init];
    delegate = webserviceDelegate;
    requestPool = [[NSMutableDictionary alloc] init];
    songInfo = nil;
    return self;
}


- (void)handshake:(NSString *)server withUser:(NSString *)username 
                             withPasswordHash:(NSString *)passwordMD5
{
    AMWebserviceRequest *request = [requestPool objectForKey:HANDSHAKE_REQUEST];
    if (!request) {
        request = [AMWebserviceRequest plainRequestWithDelegate:self];
        [requestPool setObject:request forKey:HANDSHAKE_REQUEST];
    }

    if ([request isProcessing]) {
        [request cancel];
    }
        
	AmuaLog(LOG_MSG, [[NSString stringWithString:@"handshake with username: "]
		 stringByAppendingString: username]);
	NSString *sessionURL = [NSString stringWithFormat:@"http://%@/radio/handshake.php?version=1.1.4&platform=mac&debug=0&username=%@&passwordmd5=%@",
                                  server, [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], passwordMD5];
    [request startWithURL:[NSURL URLWithString:sessionURL]];
}


- (void)updateSongInformation
{
    AMWebserviceRequest *request = [requestPool objectForKey:SONG_INFORMATION_REQUEST];
    if (!request) {
        request = [AMWebserviceRequest plainRequestWithDelegate:self];
        [requestPool setObject:request forKey:SONG_INFORMATION_REQUEST];
    }

    if ([request isProcessing]) {
        [request cancel];
    }
    
    AmuaLog(LOG_MSG, @"updating song information");
	NSString *songInformationURL = [NSString stringWithFormat:@"http://%@%@/np.php?session=%@&debug=0",
        baseURL, basePath, sessionID];
	[request startWithURL:[NSURL URLWithString:songInformationURL]];
}


- (void)executeCommand:(NSString *)command
{
    AMWebserviceRequest *request = [requestPool objectForKey:COMMAND_REQUEST];
    if (!request) {
        request = [AMWebserviceRequest plainRequestWithDelegate:self];
        [requestPool setObject:request forKey:COMMAND_REQUEST];
    }
    
    if ([request isProcessing]) {
        [request cancel];
    }
    
    AmuaLogf(LOG_MSG, @"executing command: %@", command);
	NSString *commandURL = [NSString stringWithFormat:@"http://%@%@/control.php?session=%@&command=%@&debug=0",
        baseURL, basePath, sessionID, command];
    [request startWithURL:[NSURL URLWithString:commandURL]];
}


- (void)tuneToStation:(NSString *)stationURL
{
    AMWebserviceRequest *request = [requestPool objectForKey:STATION_TUNING_REQUEST];
    if (!request) {
        request = [AMWebserviceRequest plainRequestWithDelegate:self];
        [requestPool setObject:request forKey:STATION_TUNING_REQUEST];
    }
    
    if ([request isProcessing]) {
        [request cancel];
    }
    
    AmuaLogf(LOG_MSG, @"tuning to station: %@", stationURL);
    NSString *url = [NSString stringWithFormat:@"http://%@%@/adjust.php?session=%@&url=%@&debug=0",
        baseURL, basePath, sessionID, stationURL];
    [request startWithURL:[NSURL URLWithString:url]];
}


- (void)setDiscoveryMode:(bool)state
{
    [self tuneToStation:[NSString stringWithFormat:@"lastfm://settings/discovery/%@", (state ? @"on" : @"off")]];
}


- (void)setRecordToProfileMode:(bool)state
{
    [self executeCommand:state ? @"rtp" : @"nortp"];
}


- (void)cancelAllRequests
{
    NSEnumerator *keys = [requestPool keyEnumerator];
    NSObject *requestKey;
    while (requestKey = [keys nextObject]) {
        AMWebserviceRequest *request = [requestPool objectForKey:requestKey];
        if (request != nil && [request isProcessing]) {
            [request cancel];
        }
    }
    
    [requestPool removeAllObjects];
}


- (void)dealloc
{
    if (baseURL != nil) {
        [baseURL release];
    }
    if (basePath != nil) {
        [basePath release];
    }
    if (sessionID != nil) {
        [sessionID release];
    }
    if (songInfo != nil) {
        [songInfo release];
    }
    if (requestPool != nil) {
        [requestPool release];
    }
    
    [super dealloc];
}


// AMWebserviceRequest delegate implementation


- (void)requestHasFinished:(AMWebserviceRequest *)request withData:(NSDictionary *)data
{
    if (request == [requestPool objectForKey:HANDSHAKE_REQUEST]) {
        // handshake finished
        [requestPool removeObjectForKey:HANDSHAKE_REQUEST];
        if ([data objectForKey:@"session"] == nil || [[[data objectForKey:@"session"] lowercaseString] isEqualToString:@"failed"]) {
            AmuaLog(LOG_ERROR, @"handshake failed");
            if (delegate) {
                [delegate webserviceHandshakeFailed];
            }
		} else {
            if (sessionID != nil) {
                [sessionID release];
            }
			sessionID = [[data objectForKey:@"session"] retain];
            if (baseURL != nil) {
                [baseURL release];
            }
			baseURL = [[data objectForKey:@"base_url"] retain];
            if (basePath != nil) {
                [basePath release];
            }
			basePath = [[data objectForKey:@"base_path"] retain];
            bool subscriberMode = (bool)[[data objectForKey:@"subscriber"] intValue];
			AmuaLogf(LOG_MSG, @"handshake done, sessionid: %@", sessionID);
            if (delegate) {
                [delegate webserviceHandshakeFinishedWithURL:[data objectForKey:@"stream_url"] subscriberMode:subscriberMode];
            }
		}
        
        
    } else if (request == [requestPool objectForKey:SONG_INFORMATION_REQUEST]) {
        // song information update finished
        [requestPool removeObjectForKey:SONG_INFORMATION_REQUEST];
        if ([[[data objectForKey:@"streaming"] lowercaseString] isEqual:@"true"]) {
            AMSongInformation *songInformation = [[[AMSongInformation alloc] initWithDictionary:data] autorelease];
			AmuaLog(LOG_MSG, @"song information received");
            if (delegate) {
                [delegate webserviceSongInformationUpdateFinished:songInformation 
                          withDiscoveryMode:(bool)[[data objectForKey:@"discovery"] intValue] 
                          withRecordToProfileMode:(bool)[[data objectForKey:@"recordtoprofile"] intValue]];
            }
		} else {
			AmuaLog(LOG_ERROR, @"song information: not streaming");
            if (delegate) {
                [delegate webserviceSongInformationUpdateFailed];
            }
		}
        
        
    } else if (request == [requestPool objectForKey:COMMAND_REQUEST]) {
        // command execution finished
        [requestPool removeObjectForKey:COMMAND_REQUEST];
        if (delegate) {
            [delegate webserviceCommandExecutionFinished];
        }
        
        
    } else if (request == [requestPool objectForKey:STATION_TUNING_REQUEST]) {
        // station tuning finished
        [requestPool removeObjectForKey:STATION_TUNING_REQUEST];
        int error = [[data objectForKey:@"error"] intValue];
		if (error == 0) {
			AmuaLog(LOG_MSG, @"station tuned");
            if (delegate) {
                [delegate webserviceStationTuningFinished];
            }
		} else {
			AmuaLog(LOG_ERROR, @"station tuning error");
            if (delegate) {
                [delegate webserviceStationTuningFailed];
            }
		}
    }
}


- (void)requestHasFailed: (AMWebserviceRequest *)request
{
    AmuaLog(LOG_ERROR, @"connection error");
    if (delegate) {
        [delegate webserviceConnectionError];
    }
}

@end
