//
//  LastfmWebService.m
//  Amua
//
//  Created by Mathis and Simon Hofer on 20.02.05.
//  Copyright 2005 Mathis & Simon Hofer.
//

#import "LastfmWebService.h"

#define USER_AGENT @"Mozilla/4.5 (compatible; Amua/0.1; Mac_PowerPC)"

@implementation LastfmWebService

- (id)initWithWebServiceServer:(NSString *)webServiceServer
		withRadioStation:(NSString *)radioStationType
		asUserAgent:(NSString *)userAgentIdentifier
{
	[super init];

	server = [webServiceServer copy];
	radioStation = [radioStationType copy];
	userAgent = [userAgentIdentifier copy];
	
	// Activate CURLHandle
    [CURLHandle curlHelloSignature:@"XxXx" acceptAll:YES];
		
	return self;
}

- (void)createSessionForUser:(NSString *)username withPasswordHash:(NSString *)passwordMD5
{
	getSessionURL = [[NSURL alloc] initWithString:[[[[[[[[NSString stringWithString:@"http://"]
						stringByAppendingString:server]
						stringByAppendingString:@"/radio/getsession.php?username="]
						stringByAppendingString:username]
						stringByAppendingString:@"&passwordmd5="]
						stringByAppendingString:passwordMD5]
						stringByAppendingString:@"&mode="]
						stringByAppendingString:radioStation]];
	
	getSessionCURLHandle = [[CURLHandle alloc] initWithURL:getSessionURL cached:FALSE];
	
	[getSessionCURLHandle setFailsOnError:YES];
    [getSessionCURLHandle setFollowsRedirects:YES];

    [getSessionCURLHandle setUserAgent:userAgent];
	
	[getSessionCURLHandle addClient:self];
	[getSessionCURLHandle loadInBackground];
}

- (void)updateNowPlayingInformation:(id)sender
{
	nowPlayingURL = [[NSURL alloc] initWithString:[[[[[NSString stringWithString:@"http://"]
						stringByAppendingString:server]
						stringByAppendingString:@"/radio/np.php"]
						stringByAppendingString:@"?session="]
						stringByAppendingString:sessionID]];
	
	nowPlayingCURLHandle = [[CURLHandle alloc] initWithURL:nowPlayingURL cached:FALSE];
	
	[nowPlayingCURLHandle setFailsOnError:YES];
    [nowPlayingCURLHandle setFollowsRedirects:YES];
	
    [nowPlayingCURLHandle setUserAgent:userAgent];
	
	[nowPlayingCURLHandle addClient:self];
	[nowPlayingCURLHandle loadInBackground];
}

- (void)executeControl:(NSString *)command
{
	controlURL = [[NSURL alloc] initWithString:[[[NSString stringWithString:@"http://"]
						stringByAppendingString:server]
						stringByAppendingString:@"/radio/control.php"]];
	
	controlCURLHandle = [[CURLHandle alloc] initWithURL:controlURL cached:FALSE];
	
	NSMutableDictionary *postVariables = [[[NSMutableDictionary alloc] init] autorelease];
	[postVariables setObject:sessionID forKey:@"session"];
	[postVariables setObject:command forKey:@"command"];
	
	[controlCURLHandle setPostDictionary:postVariables];
	
	[controlCURLHandle setFailsOnError:YES];
    [controlCURLHandle setFollowsRedirects:YES];
	
    [controlCURLHandle setUserAgent:userAgent];
	
	[controlCURLHandle addClient:self];
	[controlCURLHandle loadInBackground];
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

- (NSURL *)nowPlayingAlbumPage
{
	if (nowPlayingInformation != nil) {
		return [NSURL URLWithString:[nowPlayingInformation objectForKey:@"album_url"]];
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


/* CURL Handlers */

- (void)URLHandleResourceDidFinishLoading:(NSURLHandle *)sender
{
    NSString *result = [[[NSString alloc] initWithData:[sender resourceData] encoding:NSUTF8StringEncoding] autorelease];
	NSMutableDictionary *parsedResult = [[NSMutableDictionary alloc] init];
	
	// Parse keys and values
	NSArray *values = [result componentsSeparatedByString:@"\n"];
	int i;
	for (i=0; i< [values count]; i++) {
		NSRange equalPosition = [[values objectAtIndex:i] rangeOfString:@"="];
		if (equalPosition.length > 0) {
			[parsedResult setObject:[[values objectAtIndex:i] substringFromIndex:equalPosition.location+equalPosition.length]
					forKey:[[values objectAtIndex:i] substringToIndex:equalPosition.location]];
		}
	}
	
	if (sender == getSessionCURLHandle) {
		sessionID = [[parsedResult objectForKey:@"session"] copy];
		if ([parsedResult objectForKey:@"stream_url"] != nil) {
			streamingServer = [[parsedResult objectForKey:@"stream_url"] copy];
		}
		[parsedResult release];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"StartPlaying" object:self];
	} else if (sender == nowPlayingCURLHandle) {
	
		if (nowPlayingInformation != nil) {
			[nowPlayingInformation release];
		}
		nowPlayingInformation = parsedResult;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateNowPlayingInformation" object:self];
		
	} else if (sender == controlCURLHandle) {
		
		if ([[parsedResult objectForKey:@"response"] isEqualToString:@"OK"]) {
			NSLog(@"control ok");
		} else {
			NSLog(@"control failure");
		}
		
	}

	[sender removeClient:self];
}

- (void)URLHandleResourceDidBeginLoading:(NSURLHandle *)sender {}

- (void)URLHandleResourceDidCancelLoading:(NSURLHandle *)sender
{
    [getSessionCURLHandle removeClient:self];
}

- (void)URLHandle:(NSURLHandle *)sender resourceDataDidBecomeAvailable:(NSData *)newBytes {}

- (void)URLHandle:(NSURLHandle *)sender resourceDidFailLoadingWithReason:(NSString *)reason
{
    [getSessionCURLHandle removeClient:self];
}


- (void)dealloc
{
	[server release];
	[radioStation release];
	[userAgent release];
	[getSessionCURLHandle release];
	[nowPlayingCURLHandle release];
	[controlCURLHandle release];
	[getSessionURL release];
	[nowPlayingURL release];
	[controlURL release];
	[sessionID release];
	[streamingServer release];
	[nowPlayingInformation release];
	
	[super dealloc];
}

@end
