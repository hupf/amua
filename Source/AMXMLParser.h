//
//  AMXMLParser.h
//  Amua
//
//  Created by Mathis & Simon Hofer on 18.02.05.
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
#import "AMWebserviceRequest.h"
#import "AMXMLResult.h"
#import "Debug.h"

@protocol AMWebserviceRequestParser;

@interface AMXMLParser : NSObject<AMWebserviceRequestParser> {

    AMXMLResult *rootElement;
    AMXMLResult *tempElement;
    NSMutableString *temp;
    NSMutableArray *elements;
    
}

- (NSObject *)parseData:(NSData *)data;
- (void)dealloc;

- (void)parserDidStartDocument:(NSXMLParser *)parser;
- (void)parserDidEndDocument:(NSXMLParser *)parser;
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
                                     namespaceURI:(NSString *)namespaceURI
                                     qualifiedName:(NSString *)qualifiedName
                                     attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
                                     namespaceURI:(NSString *)namespaceURI
                                     qualifiedName:(NSString *)qName;
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;

@end
