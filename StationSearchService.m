//
//  StationSearchService.m
//  Amua
//
//  Created by Mathis & Simon Hofer on 20.02.05.
//  Copyright 2005 Mathis & Simon Hofer.
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

- (id)searchSimilarArtist:(NSString *)artist withSender:(NSObject *)owner
{
	if (lastSearch != nil) {
		[lastSearch release];
	}
	lastSearch = [NSString stringWithString:[[[[NSString stringWithString:@"http://"]
						stringByAppendingString:server]
						stringByAppendingString:@"/1.0/get.php?resource=artist&document=similar&format=xml&artist="]
						stringByAppendingString:artist]];
	lastSearch = [[lastSearch stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] retain];;
	increaserElementName = @"artist";
	mainElementName = @"similarartists";
	
	[NSThread detachNewThreadSelector:@selector(doSearch:) toTarget:self withObject:owner];
}

- (id)doSearch:(NSObject *)owner
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	// search and parse
	NSURL* xmlURL = [NSURL URLWithString:lastSearch];
	NSXMLParser *addressParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
    [addressParser setDelegate:self];
    [addressParser setShouldResolveExternalEntities:YES];
	
	BOOL success = [addressParser parse];
	
	// this special call is necessary to make sure the searchFinished method
	// is called in the main thread (for drawing reasons)
	[owner performSelectorOnMainThread:@selector(searchFinished:)
        withObject:self waitUntilDone:YES];
	
	[pool release];
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






- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	//NSLog(@"start document");
	if (result != nil) {
		[result release];
	}
	
	result = [[NSMutableArray alloc] init];
	tempValue = [[NSString alloc] init];
	temp = [[NSMutableDictionary alloc] init];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	//NSLog(@"end document");
	/*int i;
	for (i = 0; i < [result count]; i++) {
		NSLog(@"artist: %@", [[result objectAtIndex:i] objectForKey:@"name"]); 
		NSLog(@"url: %@", [[result objectAtIndex:i] objectForKey:@"url"]);
		NSLog(@"streamable: %@", [[result objectAtIndex:i] objectForKey:@"streamable"]);
		NSLog(@"match: %@", [[result objectAtIndex:i] objectForKey:@"match"]);
		NSLog(@"mbid: %@", [[result objectAtIndex:i] objectForKey:@"mbid"]);
	}*/
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
	                                    namespaceURI:(NSString *)namespaceURI
									   qualifiedName:(NSString *)qualifiedName
									      attributes:(NSDictionary *)attributeDict
{
	if (parsingData == YES) {
		
	}
	
	if ([elementName isEqualToString:increaserElementName]) {
		parsingData = YES;
	}
	
	if ([elementName isEqualToString:mainElementName]) {
		mainResultEntry = [attributeDict copy];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
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
		//NSLog(@"setting '%@' for key '%@'", tempValue, elementName);
		tempValue = [[NSString alloc] init];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (parsingData == YES) {
		tempValue = [tempValue stringByAppendingString:string];
	}
}


@end
