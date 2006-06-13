//
//  LastfmWebService.m
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

#import "LastfmWebService.h"

@implementation LastfmWebService

- (id)initWithWebServiceServer:(NSString *)webServiceServer
           asUserAgent:(NSString *)userAgentIdentifier
           forUser:(NSString *)username withPasswordHash:(NSString *)passwordMD5;
{
	[super init];

	server = [webServiceServer retain];
	userAgent = [userAgentIdentifier retain];
	
    [self handshake:username withPasswordHash:passwordMD5];
    
	return self;
}


- (void)handshake:(NSString *)username withPasswordHash:(NSString *)passwordMD5
{
	user = [username retain];
	
	LOG([[NSString stringWithString:@"handshake with username: "]
		 stringByAppendingString: user]);
	
	NSString *getSessionURL = [NSString stringWithFormat:
        @"http://%@/radio/handshake.php?version=1.1.4&platform=mac&debug=0&username=%@&passwordmd5=%@",
        server,
        [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
        passwordMD5];

	getSessionCURLHandle = [[CURLHandle alloc]
    						initWithURL:[NSURL URLWithString:getSessionURL]
                            cached:FALSE];
	
	[getSessionCURLHandle setFailsOnError:YES];
	[getSessionCURLHandle setFollowsRedirects:YES];
	[getSessionCURLHandle setUserAgent:userAgent];

	[getSessionCURLHandle addClient:self];
    [getSessionCURLHandle loadInBackground];
    
}


- (void)updateNowPlayingInformation
{
	LOG(@"updating song information");
	NSString *nowPlayingURL = [NSString stringWithFormat:@"http://%@%@/np.php?session=%@&debug=0",
                                            baseHost, basePath, sessionID];

	nowPlayingCURLHandle = [[CURLHandle alloc]
    						initWithURL:[NSURL URLWithString:nowPlayingURL]
                            cached:FALSE];
	
	[nowPlayingCURLHandle setFailsOnError:YES];
    [nowPlayingCURLHandle setFollowsRedirects:YES];
	
    [nowPlayingCURLHandle setUserAgent:userAgent];
	
	[nowPlayingCURLHandle addClient:self];
	[nowPlayingCURLHandle loadInBackground]; // Send and receive webpage
}


- (void)executeControl:(NSString *)command
{
	if (!sessionID) {
		return;
    }
	
	LOG([[NSString stringWithString:@"executing command: "]
		 stringByAppendingString: command]);
	
	NSString *controlURL = [NSString stringWithFormat:@"http://%@%@/control.php?session=%@&command=%@&debug=0",
                                         baseHost, basePath, sessionID, command];
	
	controlCURLHandle = [[CURLHandle alloc]
    						initWithURL:[NSURL URLWithString:controlURL]
                            cached:FALSE];
	
	[controlCURLHandle setFailsOnError:YES];
    [controlCURLHandle setFollowsRedirects:YES];
	
    [controlCURLHandle setUserAgent:userAgent];
	
	[controlCURLHandle addClient:self];
	[controlCURLHandle loadInBackground]; // Send and receive webpage
    if (lastCommand != nil) {
        [lastCommand release];
    }
    lastCommand = [command retain];
}


- (CURLHandle *)adjust:(NSString *)url
{
    if (!sessionID || !url) {
		return nil;
    }
	
	LOG([[NSString stringWithString:@"tuning to station: "]
		 stringByAppendingString: url]);
    
    NSString *genericURL = [NSString stringWithFormat:@"http://%@%@/adjust.php?session=%@&url=%@&debug=0",
                                         baseHost, basePath, sessionID, url];
    CURLHandle *genericCURLHandle = [[CURLHandle alloc] initWithURL:
			    [NSURL URLWithString:genericURL] cached:FALSE];
    
    [genericCURLHandle setFailsOnError:YES];
    [genericCURLHandle setFollowsRedirects:YES];
    
    [genericCURLHandle setUserAgent:userAgent];
    
    [genericCURLHandle addClient:self];
    
    return genericCURLHandle;
}


- (void)tuneStation
{
    tuningCURLHandle = [self adjust:stationUrl];
    
    if(tuningCURLHandle) {
		[tuningCURLHandle loadInBackground];
    } else {
		ERROR(@"curl handle does not exist");
		[[NSNotificationCenter defaultCenter]
        	postNotificationName:@"ConnectionError" object:self];
    }
}


- (void)setDiscovery:(bool)state
{
    discoveryCURLHandle = [self adjust:
		[NSString stringWithFormat:@"lastfm://settings/discovery/%@",
        (state ? @"on" : @"off")]];
    
    if(discoveryCURLHandle) {
		LOG([[NSString stringWithString:@"set discovery mode to: "]
			stringByAppendingString:(state ? @"on" : @"off")]);
		[discoveryCURLHandle loadInBackground];
    } else {
		ERROR(@"curl handle does not exist");
		[[NSNotificationCenter defaultCenter]
        	postNotificationName:@"SetDiscoveryError" object:self];
    }
}


- (void)setTags:(NSString *)tags forData:(NSMutableDictionary *)data
{
    LOG([[NSString stringWithString:@"saving tags: "]
		 stringByAppendingString: tags]);
	
	NSString *tagURL = [NSString stringWithFormat:@"http://%@/player/tag.php",
        baseHost];
	
	tagsCURLHandle = [[CURLHandle alloc]
    						initWithURL:[NSURL URLWithString:tagURL]
                                 cached:FALSE];
	
    [data setObject:sessionID forKey:@"s"];
    [data setObject:tags forKey:@"tag"];
    
	[tagsCURLHandle setFailsOnError:YES];
    [tagsCURLHandle setFollowsRedirects:YES];
    [tagsCURLHandle setPostDictionary:data];
	
    [tagsCURLHandle setUserAgent:userAgent];
	
	[tagsCURLHandle addClient:self];
	[tagsCURLHandle loadInBackground];
}


- (void)setStationURL:(NSString *)url
{
    stationUrl = [url retain];
}


- (NSString *)stationURL
{
    return stationUrl;
}


- (NSString *)streamingServer;
{
	return streamingServer;
}


- (bool)isSubscriber
{
    return subscriber;
}


- (bool)streaming
{
	if (nowPlayingInformation != nil) {
		return [[nowPlayingInformation objectForKey:@"streaming"] isEqualToString:@"true"];
	} else {
		return NO;
	}
}


- (BOOL)lastCommandWasLove
{
    return lastCommand != nil && [lastCommand isEqualToString:@"love"];
}


- (NSString *)nowPlayingArtist
{
	if (nowPlayingInformation != nil) {
		return [nowPlayingInformation objectForKey:@"artist"];
	} else {
		return nil;
	}
}


- (NSString *)nowPlayingTrack
{
	if (nowPlayingInformation != nil) {
		return [nowPlayingInformation objectForKey:@"track"];
	} else {
		return nil;
	}
}


- (NSString *)nowPlayingAlbum
{
	if (nowPlayingInformation != nil) {
		return [nowPlayingInformation objectForKey:@"album"];
	} else {
		return nil;
	}
}


- (NSURL *)nowPlayingAlbumPage
{
	if (nowPlayingInformation != nil && [nowPlayingInformation objectForKey:@"album_url"] != nil) {
		return [NSURL URLWithString:[nowPlayingInformation objectForKey:@"album_url"]];
	} else {
		return nil;
	}
}


- (NSImage *)nowPlayingAlbumImage
{
	if (albumCover != nil) {
		return albumCover;
	} else {
		return nil;
	}
}


- (int)nowPlayingTrackDuration
{
	if (nowPlayingInformation != nil) {
		return [[nowPlayingInformation objectForKey:@"trackduration"] intValue];
	} else {
		return -1;
	}
}


- (int)nowPlayingTrackProgress
{
	if (nowPlayingInformation != nil) {
		return [[nowPlayingInformation objectForKey:@"trackprogress"] intValue];
	} else {
		return -1;
	}
}


- (NSString *)nowPlayingRadioStation
{
	if (nowPlayingInformation != nil) {
		return [nowPlayingInformation objectForKey:@"station"];
	} else {
		return nil;
	}
}


- (NSString *)nowPlayingRadioStationProfile
{
	if (nowPlayingInformation != nil
    	&& ![[nowPlayingInformation objectForKey:@"stationfeed"] isEqualToString:user]) {
		// return user you stream from (only on private and personal radio)
		return [nowPlayingInformation objectForKey:@"stationfeed"];
	} else {
		return nil;
	}
}


- (bool)discoveryMode
{
    if (nowPlayingInformation != nil) {
        return [[nowPlayingInformation objectForKey:@"discovery"] intValue] == 1;
    } else {
        return NO;
    }
}


- (bool)recordToProfile
{
    if (nowPlayingInformation != nil) {
        return [[nowPlayingInformation objectForKey:@"recordtoprofile"]
                    isEqualToString:@"1"];
    } else {
        return NO;
    }
}


/* CURL Handlers */

- (void)URLHandleResourceDidFinishLoading:(NSURLHandle *)sender
{
	// Compute response (e.g. loaded webpage)
	NSString *result = [[[NSString alloc]
    	initWithData:[sender resourceData]
        encoding:NSUTF8StringEncoding] autorelease];
	NSMutableDictionary *parsedResult = [[NSMutableDictionary alloc] init];
	
	// Parse keys and values and put them into a NSDictionary
	NSArray *values = [result componentsSeparatedByString:@"\n"];
	int i;
	for (i=0; i< [values count]; i++) {
		NSRange equalPosition = [[values objectAtIndex:i] rangeOfString:@"="];
		if (equalPosition.length > 0) {
			[parsedResult setObject:[[values objectAtIndex:i]
            	substringFromIndex:equalPosition.location+equalPosition.length]
					forKey:[[values objectAtIndex:i] substringToIndex:equalPosition.location]];
		}
	}
	
	if ([sender isEqual:getSessionCURLHandle]) { // Response for session-request
        
        if (sessionID != nil) {
            [sessionID release];
        }
        if (streamingServer != nil) {
            [streamingServer release];
            streamingServer = nil;
        }
        if (baseHost != nil) {
            [baseHost release];
            baseHost = nil;
        }
        if (basePath != nil) {
            [basePath release];
            basePath = nil;
        }
        
		if ([[[parsedResult objectForKey:@"session"] lowercaseString] isEqualToString:@"failed"]) {
			ERROR(@"handshake failed");
            subscriber = NO;
			getSessionCURLHandle = nil;
			[[NSNotificationCenter defaultCenter]
            	postNotificationName:@"HandshakeFailed" object:self];
		} else {
			sessionID = [[parsedResult objectForKey:@"session"] retain];
			streamingServer = [[parsedResult objectForKey:@"stream_url"] retain];
			baseHost = [[parsedResult objectForKey:@"base_url"] retain];
			basePath = [[parsedResult objectForKey:@"base_path"] retain];
            subscriber = (bool)[[parsedResult objectForKey:@"subscriber"] intValue]; 
			getSessionCURLHandle = nil;
			LOG([[NSString stringWithString:@"handshake done, sessionid: "]
				 stringByAppendingString:sessionID]);
            [[NSNotificationCenter defaultCenter]
            	postNotificationName:@"Handshake" object:self];
		}
		
	} else if ([sender isEqual:tuningCURLHandle]) { // Response for station tuning
        int error = [[parsedResult objectForKey:@"error"] intValue];
        tuningCURLHandle = nil;
		if (error == 0) {
			LOG(@"station tuned");
            [[NSNotificationCenter defaultCenter]
                postNotificationName:@"StationTuned" object:self];
		} else {
			ERROR(@"station tuning error");
            [[NSNotificationCenter defaultCenter]
                postNotificationName:@"StationError" object:self];
		}
		
	} else if ([sender isEqual:nowPlayingCURLHandle]) { // Response for song information request
		
		nowPlayingCURLHandle = nil;
		if (nowPlayingInformation != nil) {
            [nowPlayingInformation release];
        }
		if ([[[parsedResult objectForKey:@"streaming"] lowercaseString] isEqual:@"true"]) {
			nowPlayingInformation = [parsedResult retain];
            if (albumCover != nil) {
                [albumCover release];
                albumCover = nil;
            }
			if ([nowPlayingInformation objectForKey:@"albumcover_small"] != nil) {
				albumCover = [[NSImage alloc] initWithContentsOfURL:
                	[NSURL URLWithString:[nowPlayingInformation
                    	objectForKey:@"albumcover_small"]]];
			}
            
            if (albumCover == nil) {
                albumCover = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:@"nocover.png"]];
                WARNING(@"no valid cover found");
            }
			
			LOG(@"song information received");			
		} else {
            nowPlayingInformation = nil;
			ERROR(@"get song information: not streaming");
		}
        
        [[NSNotificationCenter defaultCenter]
            	postNotificationName:@"UpdateNowPlayingInformation" object:self];
	} else if ([sender isEqual:controlCURLHandle]) { // Response for executed command
	
		// We don't do anything, whether the sent command was successful or not
		controlCURLHandle = nil;
        [[NSNotificationCenter defaultCenter]
            	postNotificationName:@"CommandExecuted" object:self];
		
	} else if ([sender isEqual:discoveryCURLHandle]) { // Response to changing discover setting
		
		discoveryCURLHandle = nil;

	} else if ([sender isEqual:tagsCURLHandle]) { // Response to changing discover setting
		
        LOG(@"tag set");
		tagsCURLHandle = nil;
        [[NSNotificationCenter defaultCenter]
            	postNotificationName:@"TagSet" object:self];
        
	}
	
    [parsedResult release];
	[sender removeClient:self];	
	[sender release];
}


- (void)URLHandleResourceDidBeginLoading:(NSURLHandle *)sender {}


- (void)URLHandleResourceDidCancelLoading:(NSURLHandle *)sender
{
	ERROR(@"handle did cancel loading");
	if (sender == getSessionCURLHandle || sender == tuningCURLHandle) {
		[[NSNotificationCenter defaultCenter]
        	postNotificationName:@"ConnectionError" object:self];
	} else {
        [self stopLoading];
    }
}


- (void)URLHandle:(NSURLHandle *)sender resourceDataDidBecomeAvailable:(NSData *)newBytes {}


- (void)URLHandle:(NSURLHandle *)sender resourceDidFailLoadingWithReason:(NSString *)reason
{
	ERROR(@"handle did fail loading");
	if (sender == getSessionCURLHandle || sender == tuningCURLHandle) {
		[[NSNotificationCenter defaultCenter]
        	postNotificationName:@"ConnectionError" object:self];
	} else {
        [self stopLoading];
    }
}


- (void)stopLoading
{
    if (getSessionCURLHandle != nil) {
        [getSessionCURLHandle removeClient:self];
        [tuningCURLHandle release];
        getSessionCURLHandle = nil;
    }
    if (tuningCURLHandle != nil) {
        [tuningCURLHandle removeClient:self];
        [tuningCURLHandle release];
        tuningCURLHandle = nil;
    }
    if (nowPlayingCURLHandle != nil) {
        [nowPlayingCURLHandle removeClient:self];
        [nowPlayingCURLHandle release];
        nowPlayingCURLHandle = nil;
    }
    if (controlCURLHandle != nil) {
        [controlCURLHandle removeClient:self];
        [controlCURLHandle release];
        controlCURLHandle = nil;
    }
    if (discoveryCURLHandle != nil) {
        [discoveryCURLHandle removeClient:self];
        [discoveryCURLHandle release];
        discoveryCURLHandle = nil;
    }
    if (albumCover != nil) {
        [albumCover release];
        albumCover = nil;
    }
    if (nowPlayingInformation != nil) {
        [nowPlayingInformation release];
        nowPlayingInformation = nil;
    }
}


- (void)dealloc
{
    [self stopLoading];
    if (server != nil) {
        [server release];
    }
    if (stationUrl != nil) {
        [stationUrl release];
    }
    if (user != nil) {
        [user release];
    }
    if (userAgent != nil) {
        [userAgent release];
    }
    if (sessionID != nil) {
        [sessionID release];
    }
    if (streamingServer != nil) {
        [streamingServer release];
    }
    if (albumCover != nil) {
        [albumCover release];
    }
    if (lastCommand != nil) {
        [lastCommand release];
    }
	
	[super dealloc];
}

@end
