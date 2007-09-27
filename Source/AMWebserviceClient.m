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

#define CLIENT_VERSION @"1.3.2.13"
#define CLIENT_PLATFORM @"mac"
#define CLIENT_LANGUAGE @"en"

#define HANDSHAKE_REQUEST @"handshake_request"
#define COMMAND_REQUEST @"command_request"
#define STATION_TUNING_REQUEST @"station_tuning_request"
#define UPDATE_PLAYLIST_REQUEST @"update_playlist_request"
#define DISCOVERY_MODE_REQUEST @"discovery_mode_request"
#define RECORD_TO_PROFILE_REQUEST @"record_to_profile_request"

@implementation AMWebserviceClient

- (id)init:(id<AMWebserviceClientDelegate>)webserviceDelegate
{
    self = [super init];
    delegate = webserviceDelegate;
    requestPool = [[NSMutableDictionary alloc] init];
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
	NSString *sessionURL = [NSString stringWithFormat:@"http://%@/radio/handshake.php?version=%@&platform=%@&username=%@&passwordmd5=%@&language=%@",
                                  server, CLIENT_VERSION, CLIENT_PLATFORM, [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], passwordMD5, CLIENT_LANGUAGE];
    [request startWithURL:[NSURL URLWithString:sessionURL]];
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
	NSString *commandURL = [NSString stringWithFormat:@"http://%@%@/control.php?session=%@&command=%@",
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
    NSString *url = [NSString stringWithFormat:@"http://%@%@/adjust.php?session=%@&url=%@&lang=%@",
        baseURL, basePath, sessionID, stationURL, CLIENT_LANGUAGE];
    [request startWithURL:[NSURL URLWithString:url]];
}


- (void)updatePlaylist:(BOOL)discoveryMode
{
    AMWebserviceRequest *request = [requestPool objectForKey:UPDATE_PLAYLIST_REQUEST];
    if (!request) {
        request = [AMWebserviceRequest xmlRequestWithDelegate:self];
        [requestPool setObject:request forKey:UPDATE_PLAYLIST_REQUEST];
    }
    
    if ([request isProcessing]) {
        [request cancel];
    }
    
    AmuaLog(LOG_MSG, @"updating playlist");
    NSString *url = [NSString stringWithFormat:@"http://%@%@/xspf.php?sk=%@&discovery=%@&desktop=%@",
        baseURL, basePath, sessionID, discoveryMode ? @"1" : @"0", CLIENT_VERSION];
    [request startWithURL:[NSURL URLWithString:url]];
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
        
        
    } else if (request == [requestPool objectForKey:UPDATE_PLAYLIST_REQUEST]) {
        // playlist update finished
        [requestPool removeObjectForKey:UPDATE_PLAYLIST_REQUEST];
        AMXMLNode *xml = (AMXMLNode *)data;
        if ([xml childElementsCount] > 0) {
            AMXMLNode *trackListNode = [xml childWithName:@"tracklist"];
            AMXMLNode *titleNode = [xml childWithName:@"title"];
            NSString *station = [titleNode content];
            if (trackListNode != nil && [trackListNode childElementsCount] > 0) {
                NSMutableArray *songs = [NSMutableArray arrayWithCapacity:[trackListNode childElementsCount]];
                int i;
                for (i=0; i<[trackListNode childElementsCount]; ++i) {
                    AMXMLNode *node = [trackListNode childElementAtIndex:i];
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    int j;
                    for (j=0; j<[node childElementsCount]; ++j) {
                        AMXMLNode *nodeChild = [node childElementAtIndex:j];
                        if ([nodeChild content] != nil) {
                            [dict setObject:[nodeChild content] forKey:[nodeChild name]];
                        }
                    }
                    
                    if (station != nil) {
                        NSMutableString *mutableStation = [station mutableCopy];
                        [mutableStation replaceOccurrencesOfString:@"+"
                                        withString:@" " options:NSLiteralSearch
                                        range:NSMakeRange(0, [mutableStation length])];
                        [dict setObject:[mutableStation stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"station"];
                    }
                    AMSongInformation *songInfo = [[AMSongInformation alloc] initWithDictionary:dict];
                    [songs addObject:songInfo];
                    [songInfo release];
                }
                
                AmuaLog(LOG_MSG, @"playlist updated");
                [delegate webservicePlaylistUpdateFinished:songs];
                return;
            }
        }
        
        AmuaLog(LOG_ERROR, @"playlist update failed");
        [delegate webservicePlaylistUpdateFailed];
    }
    
}


- (void)requestHasFailed:(AMWebserviceRequest *)request
{
    AmuaLog(LOG_ERROR, @"connection error");
    if (delegate) {
        [delegate webserviceConnectionError];
    }
}

@end
