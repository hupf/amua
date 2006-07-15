//
//  SearchService.m
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

#import "SearchService.h"

@implementation SearchService

- (id)initWithWebServiceServer:(NSString *)webServiceServer
			       asUserAgent:(NSString *)userAgentIdentifier
{
	[super init];
	server = [webServiceServer copy];
	userAgent = [userAgentIdentifier copy];
	return self;
}


- (void)searchSimilarArtist:(NSString *)artist
{
    type = ARTIST_SEARCH;
	if (lastSearch != nil) {
		[lastSearch release];
	}
    if (searchHandle != nil) {
        [searchHandle release];
    }
    
    
	lastSearch = [[NSString stringWithString:[[[[NSString stringWithString:@"http://"]
						stringByAppendingString:server]
						stringByAppendingString:@"/1.0/get.php?resource=artist&document=similar&format=xml&artist="]
						stringByAppendingString:[artist stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] retain];
    
	increaserElementName = @"artist";
	mainElementName = @"similarartists";
    streamableCheck = YES;
    
    AmuaLog(LOG_MSG, @"searching similar artist");
    AmuaLog(LOG_MSG, lastSearch);
    
    searchHandle = [[CURLHandle alloc] initWithURL:[NSURL URLWithString:lastSearch]
                        cached:FALSE];
    [searchHandle setFailsOnError:YES];
    [searchHandle setFollowsRedirects:YES];
    [searchHandle setUserAgent:userAgent];
	[searchHandle addClient:self];
    [searchHandle loadInBackground];
}


- (void)searchUserTags:(NSString *)user
{
    type = USER_TAGS_SEARCH;
	if (lastSearch != nil) {
		[lastSearch release];
	}
    if (searchHandle != nil) {
        [searchHandle release];
    }
    
    
	lastSearch = [[NSString stringWithFormat:@"http://%@/1.0/user/%@/tags.xml?debug=0",
                        server, [user stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] retain];
    
	increaserElementName = @"tag";
	mainElementName = @"toptags";
    streamableCheck = NO;
    
    AmuaLog(LOG_MSG, @"searching user tags");
    AmuaLog(LOG_MSG, lastSearch);
    
    searchHandle = [[CURLHandle alloc] initWithURL:[NSURL URLWithString:lastSearch]
                                            cached:FALSE];
    [searchHandle setFailsOnError:YES];
    [searchHandle setFollowsRedirects:YES];
    [searchHandle setUserAgent:userAgent];
	[searchHandle addClient:self];
    [searchHandle loadInBackground];
}


- (void)searchUserTags:(NSString *)user forArtist:(NSString *)artist
{
    type = USER_TAGS_ARTIST_SEARCH;
    if (lastSearch != nil) {
		[lastSearch release];
	}
    if (searchHandle != nil) {
        [searchHandle release];
    }
    
    
	lastSearch = [[NSString stringWithFormat:@"http://%@/1.0/user/%@/artisttags.xml?artist=%@&debug=0",
        server, [user stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
        [artist stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] retain];
    
	increaserElementName = @"tag";
	mainElementName = @"artisttags";
    streamableCheck = NO;
    
    AmuaLog(LOG_MSG, @"searching user artist tags");
    AmuaLog(LOG_MSG, lastSearch);
    
    searchHandle = [[CURLHandle alloc] initWithURL:[NSURL URLWithString:lastSearch]
                                            cached:FALSE];
    [searchHandle setFailsOnError:YES];
    [searchHandle setFollowsRedirects:YES];
    [searchHandle setUserAgent:userAgent];
	[searchHandle addClient:self];
    [searchHandle loadInBackground];
}


- (void)searchUserTags:(NSString *)user forArtist:(NSString *)artist andAlbum:(NSString *)album
{
    type = USER_TAGS_ALBUM_SEARCH;
    if (lastSearch != nil) {
		[lastSearch release];
	}
    if (searchHandle != nil) {
        [searchHandle release];
    }
    
    
	lastSearch = [[NSString stringWithFormat:@"http://%@/1.0/user/%@/albumtags.xml?artist=%@&album=%@&debug=0",
        server, [user stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
        [artist stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
        [album stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] retain];
    
	increaserElementName = @"tag";
	mainElementName = @"albumtags";
    streamableCheck = NO;
    
    AmuaLog(LOG_MSG, @"searching user artist/album tags");
    AmuaLog(LOG_MSG, lastSearch);
    
    searchHandle = [[CURLHandle alloc] initWithURL:[NSURL URLWithString:lastSearch]
                                            cached:FALSE];
    [searchHandle setFailsOnError:YES];
    [searchHandle setFollowsRedirects:YES];
    [searchHandle setUserAgent:userAgent];
	[searchHandle addClient:self];
    [searchHandle loadInBackground];
}


- (void)searchUserTags:(NSString *)user forArtist:(NSString *)artist andTrack:(NSString *)track
{
    type = USER_TAGS_TRACK_SEARCH;
    if (lastSearch != nil) {
		[lastSearch release];
	}
    if (searchHandle != nil) {
        [searchHandle release];
    }
    
    
	lastSearch = [[NSString stringWithFormat:@"http://%@/1.0/user/%@/tracktags.xml?artist=%@&track=%@&debug=0",
        server, [user stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
        [artist stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
        [track stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] retain];
    
	increaserElementName = @"tag";
	mainElementName = @"tracktags";
    streamableCheck = NO;
    
    AmuaLog(LOG_MSG, @"searching user artist/track tags");
    AmuaLog(LOG_MSG, lastSearch);
    
    searchHandle = [[CURLHandle alloc] initWithURL:[NSURL URLWithString:lastSearch]
                                            cached:FALSE];
    [searchHandle setFailsOnError:YES];
    [searchHandle setFollowsRedirects:YES];
    [searchHandle setUserAgent:userAgent];
	[searchHandle addClient:self];
    [searchHandle loadInBackground];
}


- (int)getType
{
    return type;
}


- (NSString *)getMainResultText
{
	if (mainResultEntry != nil && (!streamableCheck || [[mainResultEntry objectForKey:@"streamable"] isEqualToString:@"1"])) {
		return [mainResultEntry objectForKey:@"artist"];
	} else {
		return nil;
	}
}


- (NSString *)getSearchResultWithIndex:(int)index
{
	if (result != nil && (!streamableCheck || [[[result objectAtIndex:index] objectForKey:@"streamable"] isEqualToString:@"1"])) {
		return [[result objectAtIndex:index] objectForKey:@"name"];
	} else {
		return nil;
	}
}


- (NSArray *)getSearchResult
{
    return result;
}


- (NSURL *)getImageUrl
{
	if (mainResultEntry != nil) {
		return [NSURL URLWithString:[mainResultEntry objectForKey:@"picture"]];
	} else {
		return nil;
	}
}


- (void)URLHandleResourceDidFinishLoading:(NSURLHandle *)sender
{
    NSString *data = [[[NSString alloc]
    	initWithData:[sender resourceData]
            encoding:NSUTF8StringEncoding] autorelease];
    AmuaLog(LOG_MSG, @"search finished");
    NSXMLParser *addressParser = [[NSXMLParser alloc] initWithData:
                                [data dataUsingEncoding:NSUTF8StringEncoding]];
    [addressParser setDelegate:self];
    [addressParser setShouldResolveExternalEntities:YES];
	
	BOOL success = [addressParser parse];
    if (!success) {
        AmuaLog(LOG_ERROR, @"search: could not parse xml file: %@",
            [[addressParser parserError] localizedDescription]);
    }
	
	// this special call is necessary to make sure the searchFinished method
	// is called in the main thread (for drawing reasons)
    if ( [delegate respondsToSelector:@selector(searchFinished:)] ) {
        [delegate performSelectorOnMainThread:@selector(searchFinished:)
                                   withObject:self waitUntilDone:YES];
    } else {
        AmuaLog(LOG_ERROR, @"delegate of SearchService doesn't react to the searchFinished method!");
    }
    
    if (sender == searchHandle) {
        searchHandle = nil;
    }
    
    [sender removeClient:self];
    [sender release];
}


- (void)URLHandleResourceDidBeginLoading:(NSURLHandle *)sender
{}


- (void)URLHandleResourceDidCancelLoading:(NSURLHandle *)sender
{
    AmuaLog(LOG_ERROR, @"search: could not load result");
    [sender removeClient:self];
    
    if ([delegate respondsToSelector:@selector(searchFinished:)]) {
        [delegate performSelectorOnMainThread:@selector(searchFailed:)
                                   withObject:self waitUntilDone:YES];
    } else {
        AmuaLog(LOG_ERROR, @"delegate of SearchService doesn't react to the searchFailed method!");
    }
}


- (void)URLHandle:(NSURLHandle *)sender resourceDataDidBecomeAvailable:(NSData *)newBytes
{}


- (void)URLHandle:(NSURLHandle *)sender resourceDidFailLoadingWithReason:(NSString *)reason
{
    AmuaLog(LOG_ERROR, @"search: an error occured during loading process");
    [sender removeClient:self];

    if ([delegate respondsToSelector:@selector(searchFinished:)]) {
        [delegate performSelectorOnMainThread:@selector(searchFailed:)
                                   withObject:self waitUntilDone:YES];
    } else {
        AmuaLog(LOG_ERROR, @"delegate of SearchService doesn't react to the searchFailed method!");
    }
}


- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	if (result != nil) {
		[result release];
	}
	
	result = [[NSMutableArray alloc] init];
	tempValue = [[NSString alloc] init];
	temp = [[NSMutableDictionary alloc] init];
}


- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    [mainElementName release];
    [increaserElementName release];
    [tempValue release];
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
	                                namespaceURI:(NSString *)namespaceURI
									qualifiedName:(NSString *)qualifiedName
									attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:increaserElementName]) {
		parsingData = YES;
	}
	
	if ([elementName isEqualToString:mainElementName]) {
		mainResultEntry = [attributeDict copy];
	}
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
                                    namespaceURI:(NSString *)namespaceURI
                                    qualifiedName:(NSString *)qName
{
	if ([elementName isEqualToString:increaserElementName]) {
		parsingData = NO;
		if (!streamableCheck || [[temp objectForKey:@"streamable"] isEqualToString:@"1"]) {
			[result addObject:[temp copy]];
		}
		[temp release];
		temp = [[NSMutableDictionary alloc] init];
	}
	
	if (parsingData == YES) {
		int i;
		int start = 0;
		int end = 0;
		for (i=0; i < [tempValue length]; i++) {
			char c = [tempValue characterAtIndex:i];
			if (c != '\n' && c != '\t' && c != ' ') {
				end = i+1;
				if (start == 0) {
					start = i;
				}
			}
			
		}
		
		[temp setObject:[[tempValue substringToIndex:end] substringFromIndex:start] forKey:elementName];
        [tempValue release];
		tempValue = [[NSString alloc] init];
	}
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (parsingData == YES) {
		tempValue = [[tempValue stringByAppendingString:string] retain];
	}
}


- (id)delegate {
    return delegate;
}


- (void)setDelegate:(id)newDelegate {
    delegate = newDelegate;  
}


- (void)dealloc
{
    if (owner != nil) {
        [owner release];
    }
    if (searchHandle != nil) {
        [searchHandle release];
    }
    if (lastSearch != nil) {
        [lastSearch release];
    }
    
    [server release];
    [userAgent release];
    [super dealloc];
}

@end
