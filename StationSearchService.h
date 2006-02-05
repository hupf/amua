//
//  StationSearchService.h
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

/**
 * Communication class for performing station search queries.
 */
@interface StationSearchService : NSObject {

	/**
     * The webservice server's hostname.
     */
	NSString *server;
    
    /**
     * User agent name that is sent with the HTML header.
     */
	NSString *userAgent;
	
    /**
     * The last search query.
     */
	NSString *lastSearch;
	
    /**
     * An array that will contain the result.
     */
	NSMutableArray *result;
    
    /**
     * The XML element name for the rest of the result entries.
     */
	NSString *increaserElementName;
    
    /**
     * The XML element name of the main result entry.
     */
	NSString *mainElementName;
    
    /**
     * The data for the current parsing result entry.
     */
	NSMutableDictionary *temp;
    
    /**
     * The exact matching result.
     */
	NSDictionary *mainResultEntry;
    
    /**
     * The data that has been parsed so far for the current tag.
     */
	NSString *tempValue;
    
    /**
     * True if the NSXMLParser is parsing data.
     */
	BOOL parsingData;
	
}

/**
 * Constructor.
 * 
 * @param webServiceServer The host to connect to.
 * @param userAgentIdentifier The user agent string.
 */
- (id)initWithWebServiceServer:(NSString *)webServiceServer
			       asUserAgent:(NSString *)userAgentIdentifier;
                   
/**
 * Perform a similar artist radio station search.
 * 
 * @param artist The artist search query.
 * @param owner The sending object.
 */
- (void)searchSimilarArtist:(NSString *)artist withSender:(NSObject *)owner;

/**
 * Get the description of the main result.
 */
- (NSString *)getMainResultText;

/**
 * Get the URL of the image for the main result.
 */
- (NSURL *)getImageUrl;

/**
 * Get the result entry for a specific index.
 *
 * @param index The index of the entry.
 * @return The description of the search result at index.
 */
- (NSString *)getSearchResultWithIndex:(int)index;

/**
 * Delegate of NSTableView.
 */
- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn
    row:(int)rowIndex;

/**
 * Delegate of NSTableView.
 */
- (int)numberOfRowsInTableView:(NSTableView *)aTableView;

/**
 * Delegate of NSXMLParser.
 */
- (void)parserDidStartDocument:(NSXMLParser *)parser;

/**
 * Delegate of NSXMLParser.
 */
- (void)parserDidEndDocument:(NSXMLParser *)parser;

/**
 * Delegate of NSXMLParser.
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
                                    namespaceURI:(NSString *)namespaceURI
                                    qualifiedName:(NSString *)qualifiedName
                                    attributes:(NSDictionary *)attributeDict;

/**
 * Delegate of NSXMLParser.
 */
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
                                    namespaceURI:(NSString *)namespaceURI
                                    qualifiedName:(NSString *)qName;

/**
 * Delegate of NSXMLParser.
 */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;

@end
