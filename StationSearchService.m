//
//  StationSearchService.m
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

#import "StationSearchService.h"

@implementation StationSearchService

- (id)initWithWebServiceServer:(NSString *)webServiceServer
			       asUserAgent:(NSString *)userAgentIdentifier
{
	[super init];
	server = [webServiceServer copy];
	userAgent = [userAgentIdentifier copy];
	return self;
}


- (void)searchSimilarArtist:(NSString *)artist withSender:(NSObject *)anOwner
{
	if (lastSearch != nil) {
		[lastSearch release];
	}
    if (searchHandle != nil) {
        [searchHandle release];
    }
    if (owner != nil) {
        [owner release];
    }
    
    
	lastSearch = [[NSString stringWithString:[[[[NSString stringWithString:@"http://"]
						stringByAppendingString:server]
						stringByAppendingString:@"/1.0/get.php?resource=artist&document=similar&format=xml&artist="]
						stringByAppendingString:[artist stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] retain];
    
	increaserElementName = @"artist";
	mainElementName = @"similarartists";
    
    LOG(@"searching similar artist");
    LOG(lastSearch);
    
    owner = [anOwner retain];
    searchHandle = [[CURLHandle alloc] initWithURL:[NSURL URLWithString:lastSearch]
                        cached:FALSE];
    [searchHandle setFailsOnError:YES];
    [searchHandle setFollowsRedirects:YES];
    [searchHandle setUserAgent:userAgent];
	[searchHandle addClient:self];
    [searchHandle loadInBackground];
}


- (NSString *)getMainResultText
{
	if (mainResultEntry != nil && [[mainResultEntry objectForKey:@"streamable"] isEqualToString:@"1"]) {
		return [mainResultEntry objectForKey:@"artist"];
	} else {
		return nil;
	}
}


- (NSString *)getSearchResultWithIndex:(int)index
{
	if (result != nil && [[[result objectAtIndex:index] objectForKey:@"streamable"] isEqualToString:@"1"]) {
		return [[result objectAtIndex:index] objectForKey:@"name"];
	} else {
		return nil;
	}
}


- (NSURL *)getImageUrl
{
	if (mainResultEntry != nil) {
		return [NSURL URLWithString:[mainResultEntry objectForKey:@"picture"]];
	} else {
		return nil;
	}
}


- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn
    row:(int)rowIndex
{
	if (result != nil) {
		return [[result objectAtIndex:rowIndex] objectForKey:@"name"];
	} else {
		return nil;
	}
}


- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [result count];
}

- (void)URLHandleResourceDidFinishLoading:(NSURLHandle *)sender
{
    NSString *data = [[[NSString alloc]
    	initWithData:[sender resourceData]
            encoding:NSUTF8StringEncoding] autorelease];
    LOG(@"search finished");
    NSXMLParser *addressParser = [[NSXMLParser alloc] initWithData:
                                [data dataUsingEncoding:NSUTF8StringEncoding]];
    [addressParser setDelegate:self];
    [addressParser setShouldResolveExternalEntities:YES];
	
	BOOL success = [addressParser parse];
    if (!success) {
        ERROR([[NSString stringWithString: @"search: could not parse xml file: "]
                        stringByAppendingString:
            [[addressParser parserError] localizedDescription]]);
    }
	
	// this special call is necessary to make sure the searchFinished method
	// is called in the main thread (for drawing reasons)
	[owner performSelectorOnMainThread:@selector(searchFinished:)
                            withObject:self waitUntilDone:YES];
    
    if (sender == searchHandle) {
        searchHandle = nil;
    }
    
    [sender release];
}


- (void)URLHandleResourceDidBeginLoading:(NSURLHandle *)sender
{}


- (void)URLHandleResourceDidCancelLoading:(NSURLHandle *)sender
{
    ERROR(@"search: could not load result");
}


- (void)URLHandle:(NSURLHandle *)sender resourceDataDidBecomeAvailable:(NSData *)newBytes
{}


- (void)URLHandle:(NSURLHandle *)sender resourceDidFailLoadingWithReason:(NSString *)reason
{
    ERROR(@"search: an error occured during loading process");
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
		if ([[temp objectForKey:@"streamable"] isEqualToString:@"1"]) {
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
		tempValue = [tempValue stringByAppendingString:string];
	}
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
}

@end
