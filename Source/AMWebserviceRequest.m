//
//  AMWebserviceRequest.m
//  Amua
//
//  Created by Mathis & Simon Hofer on 30.11.06.
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

#import "AMWebserviceRequest.h"

/// @cond PRIVATE_DECLARATION
@interface AMWebserviceRequest (PRIVATE)

- (void)startWithRequest:(NSURLRequest *)request;

@end
/// @endcond


@implementation AMWebserviceRequest

+ (id)plainRequestWithDelegate:(id<AMWebserviceRequestDelegate>)delegate
{
    return [[[AMWebserviceRequest alloc] initWithDelegate:delegate andParser:[[[AMPlainTextParser alloc] init] autorelease]] autorelease];
}


+ (id)xmlRequestWithDelegate:(id<AMWebserviceRequestDelegate>)delegate
{
    return [[[AMWebserviceRequest alloc] initWithDelegate:delegate andParser:[[[AMXMLParser alloc] init] autorelease]] autorelease];
}


- (id)initWithDelegate:(id<AMWebserviceRequestDelegate>)delegate andParser:(NSObject<AMWebserviceRequestParser> *)resultParser
{
    self = [super init];
    dataDelegate = delegate;
    parser = [resultParser retain];
    receivedData = nil;
    return self;
}


- (void)startWithURL:(NSURL *)url andData:(NSDictionary *)data
{
    NSMutableString *string = [NSMutableString stringWithString:@""];
    NSString *temp;
    NSEnumerator *en = [data keyEnumerator];
    bool prependAnd = NO;
    while (temp = [en nextObject]) {
        if (prependAnd) {
            [string appendString:@"&"];
        }
        [string appendString:[temp stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [string appendString:@"="];
        [string appendString:[[data valueForKey:temp] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        prependAnd = YES;
    }
    NSMutableURLRequest* post = [NSMutableURLRequest requestWithURL:url];
    [post setHTTPMethod:@"POST"];
    [post setHTTPBody:[string dataUsingEncoding:NSUTF8StringEncoding]];
    [self startWithRequest:post];
}


- (void)startWithURL:(NSURL *)url
{
    [self startWithRequest:[NSURLRequest requestWithURL:url]];
}


- (void)startWithRequest:(NSURLRequest *)request
{
    if (connection != nil) {
        [connection release];
        connection = nil;
    }
    if (receivedData != nil) {
        [receivedData release];
        receivedData = nil;
    }
    
    receivedData = [[NSMutableData data] retain];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}


- (void)cancel
{
    if (connection) {
        [connection cancel];
        [connection release];
        connection = nil;
    }
    if (receivedData != nil) {
        [receivedData release];
        receivedData = nil;
    }
}


- (bool)isProcessing
{
    return connection != nil;
}


- (void)dealloc
{
    if (connection != nil) {
        [connection release];
        connection = nil;
    }
    if (receivedData != nil) {
        [receivedData release];
        receivedData = nil;
    }
    if (parser != nil) {
        [parser release];
        parser = nil;
    }
    
    [super dealloc];
}


// NSURLConnection delegate implementation


- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (dataDelegate != nil) {
        [dataDelegate requestHasFailed:self];
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}


- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    return nil;
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSObject *parsedData = [parser parseData:receivedData];
    
    if (dataDelegate) {
        [dataDelegate requestHasFinished:self withData:parsedData];
    }
}

@end
