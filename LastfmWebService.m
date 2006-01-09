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
		withStationUrl:(NSString *)url
		asUserAgent:(NSString *)userAgentIdentifier
{
	[super init];

	server = [webServiceServer copy];
	userAgent = [userAgentIdentifier copy];
	stationUrl = [url copy];
	
	// Activate CURLHandle
    [CURLHandle curlHelloSignature:@"XxXx" acceptAll:YES];
	
	return self;
}

- (void)createSessionForUser:(NSString *)username withPasswordHash:(NSString *)passwordMD5
{
	user = [username copy];
	
	// Establish session (e.g. request a sessionID)
	NSString *getSessionURL = [[[NSString alloc] initWithString:[[[[[[NSString stringWithString:@"http://"]
						stringByAppendingString:server]
						stringByAppendingString:@"/radio/handshake.php?version=1.1.2&platform=mac&debug=0&username="]
						stringByAppendingString:username]
						stringByAppendingString:@"&passwordmd5="]
						stringByAppendingString:passwordMD5]] autorelease];
	
	getSessionCURLHandle = [[CURLHandle alloc] initWithURL:[NSURL URLWithString:getSessionURL] cached:FALSE];
	
	[getSessionCURLHandle setFailsOnError:YES];
	[getSessionCURLHandle setFollowsRedirects:YES];
	[getSessionCURLHandle setUserAgent:userAgent];

	[getSessionCURLHandle addClient:self];
	[getSessionCURLHandle loadInBackground]; // Send and receive webpage
}

- (void)updateNowPlayingInformation
{
	// Request song information of the currently playing track
	NSString *nowPlayingURL = [[[NSString alloc] initWithString:[[[[[[NSString stringWithString:@"http://"]
						stringByAppendingString:baseHost]
						stringByAppendingString:basePath]
						stringByAppendingString:@"/np.php"]
						stringByAppendingString:@"?session="]
						stringByAppendingString:sessionID]] autorelease];
	
	nowPlayingCURLHandle = [[CURLHandle alloc] initWithURL:[NSURL URLWithString:nowPlayingURL] cached:FALSE];
	
	[nowPlayingCURLHandle setFailsOnError:YES];
    [nowPlayingCURLHandle setFollowsRedirects:YES];
	
    [nowPlayingCURLHandle setUserAgent:userAgent];
	
	[nowPlayingCURLHandle addClient:self];
	[nowPlayingCURLHandle loadInBackground]; // Send and receive webpage
}

- (void)executeControl:(NSString *)command
{
	// Execute a command
	NSString *controlURL = [[[NSString alloc] initWithString:[[[[[[[[NSString stringWithString:@"http://"]
						stringByAppendingString:baseHost]
						stringByAppendingString:basePath]
						stringByAppendingString:@"/control.php?session="]
						stringByAppendingString:sessionID]
						stringByAppendingString:@"&command="]
						stringByAppendingString:command]
						stringByAppendingString:@"&debug=0"]] autorelease];
	
	controlCURLHandle = [[CURLHandle alloc] initWithURL:[NSURL URLWithString:controlURL] cached:FALSE];
	
	[controlCURLHandle setFailsOnError:YES];
    [controlCURLHandle setFollowsRedirects:YES];
	
    [controlCURLHandle setUserAgent:userAgent];
	
	[controlCURLHandle addClient:self];
	[controlCURLHandle loadInBackground]; // Send and receive webpage
}

- (CURLHandle *)adjust:(NSString *)url
{
    if (!sessionID || !url)
	return nil;
    
    NSString *genericURL = [[[NSString alloc] initWithString:[[[[[[[NSString stringWithString:@"http://"]
						    stringByAppendingString:baseHost]
						    stringByAppendingString:basePath]
						    stringByAppendingString:@"/adjust.php?session="]
						    stringByAppendingString:sessionID]
						    stringByAppendingString:@"&url="]
						    stringByAppendingString:url]] autorelease];
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
		NSLog(@"tuning to: %@", stationUrl);
		[tuningCURLHandle loadInBackground];
    } else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"StartPlayingError" object:self];
    }
}

- (void)setDiscovery:(bool)state
{
    discoveryCURLHandle = [self adjust:
	[NSString stringWithFormat:@"lastfm://settings/discovery/%@", (state ? @"on" : @"off")]];
    
    if(discoveryCURLHandle) {
		NSLog(@"setting discovery to: %@", (state ? @"on" : @"off"));
		[discoveryCURLHandle loadInBackground];
    } else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SetDiscoveryError" object:self];
    }
}

- (NSString *)streamingServer;
{
	return streamingServer;
}

- (bool)streaming
{
	if (nowPlayingInformation != nil) {
		return [[nowPlayingInformation objectForKey:@"streaming"] isEqualToString:@"true"];
	} else {
		return false;
	}
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
	if (nowPlayingInformation != nil) {
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
	if (nowPlayingInformation != nil && ![[nowPlayingInformation objectForKey:@"stationfeed"] isEqualToString:user]) {
		// return user you stream from (only on private and personal radio)
		return [nowPlayingInformation objectForKey:@"stationfeed"];
	} else {
		return nil;
	}
}


/* CURL Handlers */

- (void)URLHandleResourceDidFinishLoading:(NSURLHandle *)sender
{
	// Compute response (e.g. loaded webpage)
	NSString *result = [[[NSString alloc] initWithData:[sender resourceData] encoding:NSUTF8StringEncoding] autorelease];
	NSMutableDictionary *parsedResult = [[NSMutableDictionary alloc] init];
	
	// Parse keys and values and put them into a NSDictionary
	NSArray *values = [result componentsSeparatedByString:@"\n"];
	int i;
	for (i=0; i< [values count]; i++) {
		NSRange equalPosition = [[values objectAtIndex:i] rangeOfString:@"="];
		if (equalPosition.length > 0) {
			[parsedResult setObject:[[values objectAtIndex:i] substringFromIndex:equalPosition.location+equalPosition.length]
					forKey:[[values objectAtIndex:i] substringToIndex:equalPosition.location]];
		}
	}
	
	if ([sender isEqual:getSessionCURLHandle]) { // Response for session-request
	
		if ([[parsedResult objectForKey:@"session"] isEqualToString:@"FAILED"]) {
			[parsedResult release];
			//[getSessionCURLHandle removeClient:self];
			//[getSessionCURLHandle release];
			getSessionCURLHandle = nil;
			[[NSNotificationCenter defaultCenter] postNotificationName:@"StartPlayingError" object:self];
		} else {
			sessionID = [[parsedResult objectForKey:@"session"] copy];
			streamingServer = [[parsedResult objectForKey:@"stream_url"] copy];
			baseHost = [[parsedResult objectForKey:@"base_url"] copy];
			basePath = [[parsedResult objectForKey:@"base_path"] copy];
			[parsedResult release];
			//[getSessionCURLHandle removeClient:self];
			//[getSessionCURLHandle release];
			getSessionCURLHandle = nil;
			[self tuneStation];
		}
		
	} else if ([sender isEqual:tuningCURLHandle]) { // Response for station tuning
	
		if ([[parsedResult objectForKey:@"response"] isEqualToString:@"OK"]) {
			[parsedResult release];
			//[tuningCURLHandle removeClient:self];
			//[tuningCURLHandle release];
			tuningCURLHandle = nil;
			[[NSNotificationCenter defaultCenter] postNotificationName:@"StartPlaying" object:self];
		} else {
			[parsedResult release];
			//[tuningCURLHandle removeClient:self];
			//[tuningCURLHandle release];
			tuningCURLHandle = nil;
			NSLog(@"Amua: Station tuning error");
			[[NSNotificationCenter defaultCenter] postNotificationName:@"StartPlaying" object:self];
		}
		
	} else if ([sender isEqual:nowPlayingCURLHandle]) { // Response for song information request
		
		//[nowPlayingCURLHandle removeClient:self];
		//[nowPlayingCURLHandle release];
		nowPlayingCURLHandle = nil;
		if (nowPlayingInformation != nil) {
			[nowPlayingInformation release];
		}
		nowPlayingInformation = parsedResult;
		if ([nowPlayingInformation objectForKey:@"albumcover_small"] != nil) {
			if (albumCover != nil) {
				[albumCover release];
			}
			albumCover = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[nowPlayingInformation objectForKey:@"albumcover_small"]]];
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateNowPlayingInformation" object:self];
		
	} else if ([sender isEqual:controlCURLHandle]) { // Response for executed command
	
		// We don't do anything, whether the sent command was successful or not
		//[controlCURLHandle removeClient:self];
		//[controlCURLHandle release];
		controlCURLHandle = nil;
		
	} else if ([sender isEqual:discoveryCURLHandle]) { // Response to changing discover setting
		
		discoveryCURLHandle = nil;

		// work around a bug in the lastfm server  
		[[self adjust:stationUrl] loadInBackground];
	}
	
	[sender release];
	[sender removeClient:self];
}

- (void)URLHandleResourceDidBeginLoading:(NSURLHandle *)sender {}

- (void)URLHandleResourceDidCancelLoading:(NSURLHandle *)sender
{
	if (sender == getSessionCURLHandle || sender == tuningCURLHandle) {
		[sender removeClient:self];
		[sender release];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"StartPlayingError" object:self];
	} else {
		[sender removeClient:self];
		[sender release];
	}
}

- (void)URLHandle:(NSURLHandle *)sender resourceDataDidBecomeAvailable:(NSData *)newBytes {}

- (void)URLHandle:(NSURLHandle *)sender resourceDidFailLoadingWithReason:(NSString *)reason
{
	if (sender == getSessionCURLHandle || sender == tuningCURLHandle) {
		[sender removeClient:self];
		[sender release];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"StartPlayingError" object:self];
	} else {
		[sender removeClient:self];
		[sender release];
	}
}


- (void)dealloc
{
	[server release];
	[stationUrl release];
	[user release];
	[userAgent release];
	[sessionID release];
	[streamingServer release];
	[nowPlayingInformation release];
	[albumCover release];
	
	[CURLHandle curlGoodbye];
	
	[super dealloc];
}

@end
