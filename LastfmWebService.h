//
//  LastfmWebService.h
//  Amua
//
//  Created by Mathis and Simon Hofer on 20.02.05.
//  Copyright 2005 Mathis & Simon Hofer.
//

#import <Cocoa/Cocoa.h>
#import "CURLHandle/CURLHandle.h"
#import "CURLHandle/CURLHandle+extras.h"


@interface LastfmWebService : NSObject {

	// The webservice server's hostname
	NSString *server;
	NSString *radioStation;
	NSString *userAgent;
	
	// The CURLHandle objects that will do the data transmission
    CURLHandle *getSessionCURLHandle;
	CURLHandle *nowPlayingCURLHandle;
	CURLHandle *controlCURLHandle;
	
	// URL's
	NSURL *getSessionURL;
	NSURL *nowPlayingURL;
	NSURL *controlURL;
	
	// Objects with fetched data
	NSString *sessionID;
	NSString *streamingServer;
	NSMutableDictionary *nowPlayingInformation;
	
}

- (id)initWithWebServiceServer:(NSString *)webServiceServer
		withRadioStation:(NSString *)radioStationType
		asUserAgent:(NSString *)userAgentIdentifier;
- (void)createSessionForUser:(NSString *)username withPasswordHash:(NSString *)passwordMD5;
- (void)updateNowPlayingInformation:(id)sender;
- (void)executeControl:(NSString *)command;
- (NSString *)streamingServer;
- (bool)streaming;
- (NSString *)nowPlayingArtist;
- (NSString *)nowPlayingTrack;
- (NSURL *)nowPlayingAlbumPage;
- (int)nowPlayingTrackDuration;
- (int)nowPlayingTrackProgress;
- (void)URLHandleResourceDidFinishLoading:(NSURLHandle *)sender;
- (void)URLHandleResourceDidBeginLoading:(NSURLHandle *)sender;
- (void)URLHandleResourceDidCancelLoading:(NSURLHandle *)sender;
- (void)URLHandle:(NSURLHandle *)sender resourceDataDidBecomeAvailable:(NSData *)newBytes;
- (void)URLHandle:(NSURLHandle *)sender resourceDidFailLoadingWithReason:(NSString *)reason;

@end
