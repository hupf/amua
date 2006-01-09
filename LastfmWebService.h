//
//  LastfmWebService.h
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

#import <Cocoa/Cocoa.h>
#import <CURLHandle/CURLHandle.h>
#import <CURLHandle/CURLHandle+extras.h>


@interface LastfmWebService : NSObject <NSURLHandleClient> {

	// The webservice server's hostname
	NSString *server;
	NSString *userAgent;
	NSString *user;
	NSString *stationUrl;
	
	// The CURLHandle objects that will do the data transmission
    CURLHandle *getSessionCURLHandle;
	CURLHandle *nowPlayingCURLHandle;
	CURLHandle *controlCURLHandle;
	CURLHandle *tuningCURLHandle;
	CURLHandle *discoveryCURLHandle;
	
	// Objects with fetched data
	NSString *sessionID;
	NSString *streamingServer;
	NSString *baseHost;
	NSString *basePath;
	NSMutableDictionary *nowPlayingInformation;
	NSImage *albumCover;
	
}

- (id)initWithWebServiceServer:(NSString *)webServiceServer
		withStationUrl:(NSString *)url
		asUserAgent:(NSString *)userAgentIdentifier;
- (void)createSessionForUser:(NSString *)username withPasswordHash:(NSString *)passwordMD5;
- (void)setDiscovery:(bool)state;
- (void)updateNowPlayingInformation;
- (void)executeControl:(NSString *)command;
- (NSString *)streamingServer;
- (bool)streaming;
- (NSString *)nowPlayingArtist;
- (NSString *)nowPlayingTrack;
- (NSString *)nowPlayingAlbum;
- (NSURL *)nowPlayingAlbumPage;
- (NSImage *)nowPlayingAlbumImage;
- (NSString *)nowPlayingRadioStation;
- (NSString *)nowPlayingRadioStationProfile;
- (int)nowPlayingTrackDuration;
- (int)nowPlayingTrackProgress;
- (void)URLHandleResourceDidFinishLoading:(NSURLHandle *)sender;
- (void)URLHandleResourceDidBeginLoading:(NSURLHandle *)sender;
- (void)URLHandleResourceDidCancelLoading:(NSURLHandle *)sender;
- (void)URLHandle:(NSURLHandle *)sender resourceDataDidBecomeAvailable:(NSData *)newBytes;
- (void)URLHandle:(NSURLHandle *)sender resourceDidFailLoadingWithReason:(NSString *)reason;

@end
