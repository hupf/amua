//
//  AMScrobbler.m
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

#import "AMScrobbler.h"

#define HANDSHAKE_REQUEST @"handshake_request"
#define ANNOUNCE_REQUEST @"announce_request"
#define SCROBBLE_REQUEST @"scrobble_request"

@implementation AMScrobbler

- (id)init
{
    self = [super init];
    queue = [[NSMutableArray alloc] init];
    queueLock =[[NSRecursiveLock alloc] init];
    requestBarrier = 0;
    requestPool = [[NSMutableDictionary alloc] init];
    return self;
}


- (void)handshakeWithUser:(NSString *)scrobbleUser withPasswordHash:(NSString *)scrobblePassMD5
{
    if (username != nil) {
        [username release];
    }
    username = [scrobbleUser copy];
    if (passwordMD5 != nil) {
        [passwordMD5 release];
    }
    passwordMD5 = [scrobblePassMD5 copy];
    [self rehandshake];
}


- (void)rehandshake
{
    if (sessionID != nil) {
        [sessionID release];
        sessionID = nil;
    }
        
    AMWebserviceRequest *request = [requestPool objectForKey:HANDSHAKE_REQUEST];
    if (!request) {
        request = [[[AMWebserviceRequest alloc] initWithDelegate:self andParser:[[[AMLineTextParser alloc] init] autorelease]] autorelease];
        [requestPool setObject:request forKey:HANDSHAKE_REQUEST];
    } else if ([request isProcessing]) {
        [request cancel];
    }
    
	AmuaLog(LOG_MSG, [[NSString stringWithString:@"Scrobbler: handshake with username: "]
		 stringByAppendingString: username]);
    NSString *user = [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    int timestamp = [[NSDate date] timeIntervalSince1970];
    NSString *sessionURL = [NSString stringWithFormat:@"http://post.audioscrobbler.com/?hs=true&p=1.2&c=%@&v=%@&u=%@&t=%d&a=%@",
        @"amu", @"0.1", user, timestamp, md5hash([NSString stringWithFormat:@"%@%d", passwordMD5, timestamp])];
    [request startWithURL:[NSURL URLWithString:sessionURL]];
}


- (void)announceSongInfo:(AMSongInformation *)info
{
    if (sessionID != nil) {
        AMWebserviceRequest *request = [requestPool objectForKey:ANNOUNCE_REQUEST];
        if (!request) {
            request = [[[AMWebserviceRequest alloc] initWithDelegate:self andParser:[[[AMLineTextParser alloc] init] autorelease]] autorelease];
            [requestPool setObject:request forKey:ANNOUNCE_REQUEST];
        } else if ([request isProcessing]) {
            [request cancel];
        }
        
        NSString *data = [NSString stringWithFormat:@"s=%@&a=%@&t=%@&b=%@&l=%d&n=&m=",
            sessionID,
            [[info artist] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
            [[info track] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
            [[info album] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
            [info length]];
        AmuaLogf(LOG_MSG, @"Scrobbler: listening announcement: %@", data);
        [request startWithURL:[NSURL URLWithString:nowPlayingURL] withData:data];
    }
}


- (void)scrobbleSongInfo:(AMSongInformation *)info
{
    NSString *trackAction;
    bool queueing = NO;
    switch ([info action]) {
        case AMLoveAction:
            trackAction = @"L";
            break;
        case AMSkipAction:
            trackAction = @"S";
            queueing = YES;
            break;
        case AMBanAction:
            trackAction = @"B";
            queueing = YES;
            break;
        default:
            trackAction = @"";
    }
    
    NSString *data = [NSString stringWithFormat:@"&a[0]=%@&t[0]=%@&i[0]=%d&o[0]=%@&r[0]=%@&l[0]=%d&b[0]=%@&n[0]=%@&m[0]=%@",
        [[info artist] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
        [[info track] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],  
        (int)[[NSDate date] timeIntervalSince1970] - [info progress],
        [NSString stringWithFormat:@"L%@", [info trackAuth]],
        trackAction,
        [info length],
        [[info album] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
        @"",
        @""];
    
    [info retain];
    [queueLock lock];
    queueing = queueing || requestBarrier > 0 || sessionID == nil;
    [queue addObject:data];
    
    if (queueing) {
        AmuaLogf(LOG_MSG, @"Scrobbler: queueing: %@", data);
    } else {
        AmuaLogf(LOG_MSG, @"Scrobbler: sending (with queued: %d): %@", [queue count], data);
        NSMutableString *vars = [NSMutableString stringWithFormat:@"s=%@%@", sessionID, data];
        requestBarrier = [queue count];
        int i;
        for (i=0; i<requestBarrier; ++i) {
            NSMutableString *string = [NSMutableString stringWithString:[queue objectAtIndex:i]];
            [string replaceOccurrencesOfString:@"[0]="
                                    withString:[NSString stringWithFormat:@"[%d]=", i+1]
                                       options:NSLiteralSearch
                                         range:NSMakeRange(0, [string length])];
            [vars appendString:string];
        }
        
        AMWebserviceRequest *request = [requestPool objectForKey:SCROBBLE_REQUEST];
        if (!request) {
            request = [[[AMWebserviceRequest alloc] initWithDelegate:self andParser:[[[AMLineTextParser alloc] init] autorelease]] autorelease];
            [requestPool setObject:request forKey:SCROBBLE_REQUEST];
        } else if ([request isProcessing]) {
            [request cancel];
        }
        
        [requestPool setObject:request forKey:SCROBBLE_REQUEST];
        [request startWithURL:[NSURL URLWithString:submissionURL] withData:vars];
    }
    [queueLock unlock];
    [info release];
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
    
    [queueLock lock];
    [queue removeAllObjects];
    requestBarrier = 0;
    [queueLock unlock];
    
    [requestPool removeAllObjects];
}


- (void)dealloc
{
    if (requestPool != nil) {
        [requestPool release];
    }
    if (queue != nil) {
        [queue release];
    }
    if (queueLock != nil) {
        [queueLock release];
    }
    if (sessionID != nil) {
        [sessionID release];
    }
    if (nowPlayingURL != nil) {
        [nowPlayingURL release];
    }
    if (submissionURL != nil) {
        [submissionURL release];
    }
    if (username != nil) {
        [username release];
    }
    if (passwordMD5 != nil) {
        [passwordMD5 release];
    }
    
    [super dealloc];
}


// AMWebserviceRequest delegate implementation


- (void)requestHasFinished:(AMWebserviceRequest *)request withData:(NSDictionary *)data
{
    if (request == [requestPool objectForKey:HANDSHAKE_REQUEST]) {
        // scrobble handshake finished
        NSArray *arrayData = (NSArray *)data;
        [requestPool removeObjectForKey:HANDSHAKE_REQUEST];
        if ([arrayData count] == 0 || ![@"OK" isEqualToString:[arrayData objectAtIndex:0]]) {
            AmuaLog(LOG_ERROR, @"Scrobbler: handshake failed. Not scrobbling");
        } else {
            if (sessionID != nil) {
                [sessionID release];
            }
			sessionID = [[arrayData objectAtIndex:1] retain];
            if (nowPlayingURL != nil) {
                [nowPlayingURL release];
            }
            nowPlayingURL = [[arrayData objectAtIndex:2] retain];
            if (submissionURL != nil) {
                [submissionURL release];
            }
            submissionURL = [[arrayData objectAtIndex:3] retain];
            AmuaLogf(LOG_MSG, @"Scrobbler: handshake finished, sessionId: %@", sessionID);
        }
        
        
    } else if (request == [requestPool objectForKey:ANNOUNCE_REQUEST]) {
        [requestPool removeObjectForKey:ANNOUNCE_REQUEST];
        NSArray *arrayData = (NSArray *)data;
        if ([arrayData count] == 0 || ![@"OK" isEqualToString:[arrayData objectAtIndex:0]]) {
            AmuaLog(LOG_ERROR, @"Scrobbler: song announcement failed");
            [self rehandshake];
        }
        
        
    } else if (request == [requestPool objectForKey:SCROBBLE_REQUEST]) {
        [requestPool removeObjectForKey:SCROBBLE_REQUEST];
        NSArray *arrayData = (NSArray *)data;
        [queueLock lock];
        if ([arrayData count] == 0 || ![@"OK" isEqualToString:[arrayData objectAtIndex:0]]) {
            AmuaLog(LOG_ERROR, @"Scrobbler: song scrobbling failed");
            [self rehandshake];
        } else {
            int i;
            for (i=0; i<requestBarrier; ++i) {
                [queue removeObjectAtIndex:0];
            }
        }
        requestBarrier = 0;
        [queueLock unlock];
    }
}


- (void)requestHasFailed:(AMWebserviceRequest *)request
{
    [queueLock lock];
    requestBarrier = 0;
    [queueLock unlock];
    AmuaLog(LOG_ERROR, @"Scrobbler: connection error");
}

@end
