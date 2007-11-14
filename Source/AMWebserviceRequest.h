//
//  AMWebserviceRequest.h
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

#import <Cocoa/Cocoa.h>
#import "AMPlainTextParser.h"
#import "AMXMLParser.h"

// @cond FORWARD_DECLARATION
@protocol AMWebserviceRequestDelegate, AMWebserviceRequestParser;
// @endcond

/**
 * AMWebserviceRequest represents a specific webservice request.
 * @ingroup Webservice
 */
@interface AMWebserviceRequest : NSObject {
    
    NSURLConnection *connection;
    NSMutableData *receivedData;
    id<AMWebserviceRequestDelegate> dataDelegate;
    NSObject<AMWebserviceRequestParser> *parser;
    
}

/**
 * Create a AMWebserviceRequest object using a plain text result parser.
 * @param delegate The request delegate that is notified about the request result.
 * @see AMPlainTextParser
 */
+ (id)plainRequestWithDelegate:(id<AMWebserviceRequestDelegate>)delegate;

/**
 * Create a AMWebserviceRequest object using a xml result parser.
 * @param delegate The request delegate that is notified about the request result.
 * @see AMXMLParser
 */
+ (id)xmlRequestWithDelegate:(id<AMWebserviceRequestDelegate>)delegate;

/**
 * Initialize a AMWebserviceRequest with a delegate and a result parser.
 * @param delegate The request delegate that is notified about the request result.
 * @param resultParser A parser that is used to parse the request result.
 */
- (id)initWithDelegate:(id<AMWebserviceRequestDelegate>)delegate andParser:(NSObject<AMWebserviceRequestParser> *)resultParser;

/**
 * Start a POST HTTP request.
 * @param url The request url.
 * @param data The data (concatenated with &).
 */
- (void)startWithURL:(NSURL *)url withData:(NSString *)data;

/**
 * Start a GET HTTP requeset.
 * @param url The request url.
 */
- (void)startWithURL:(NSURL *)url;

/**
 * Cancel the request.
 */
- (void)cancel;

/**
 * Check if the request is in process.
 * @return if the request is in process.
 */
- (bool)isProcessing;
- (void)dealloc;


// NSURLConnection delegate implementation


- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse;
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

@end


/**
 * AMWebserviceRequestDelegate is a protocol for classes that can be notified
 * about AMWebserviceRequest results.
 * @ingroup Webservice
 */
@protocol AMWebserviceRequestDelegate

/**
 * Notification about a request result.
 * @param request The notifier request.
 * @param data The parsed result data.
 */
- (void)requestHasFinished:(AMWebserviceRequest *)request withData:(NSObject *)data;

/**
 * Notification about a request failure.
 * @param request The notifier request.
 */
- (void)requestHasFailed:(AMWebserviceRequest *)request;

@end


/**
 * AMWebserviceRequestParser is a protocol for classes that are able to parse
 * a AMWebservicRequest result.
 * @ingroup Webservice
 */
@protocol AMWebserviceRequestParser

/**
 * Parse request result data.
 * @param data The data which should be parsed.
 */
- (NSObject *)parseData:(NSData *)data;

@end
