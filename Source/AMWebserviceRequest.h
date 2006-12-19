//
//  AMWebserviceRequest.h
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
#import "AMPlainTextParser.h"
#import "AMXMLParser.h"

@protocol AMWebserviceRequestDelegate, AMWebserviceRequestParser;

@interface AMWebserviceRequest : NSObject {
    
    NSURLConnection *connection;
    NSMutableData *receivedData;
    id<AMWebserviceRequestDelegate> dataDelegate;
    NSObject<AMWebserviceRequestParser> *parser;
    
}

+ (id)plainRequestWithDelegate:(id<AMWebserviceRequestDelegate>)delegate;
+ (id)xmlRequestWithDelegate:(id<AMWebserviceRequestDelegate>)delegate;
- (id)initWithDelegate:(id<AMWebserviceRequestDelegate>)delegate andParser:(NSObject<AMWebserviceRequestParser> *)resultParser;
- (void)startWithURL:(NSURL *)url andData:(NSDictionary *)data;
- (void)startWithURL:(NSURL *)url;
- (void)cancel;
- (bool)isProcessing;
- (void)dealloc;

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse;
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

@end

@protocol AMWebserviceRequestDelegate

- (void)requestHasFinished:(AMWebserviceRequest *)request withData:(NSObject *)data;
- (void)requestHasFailed:(AMWebserviceRequest *)request;

@end

@protocol AMWebserviceRequestParser

- (NSObject *)parseData:(NSData *)data;

@end
