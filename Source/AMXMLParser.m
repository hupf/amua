//
//  AMXMLParser.m
//  Amua
//
//  Created by Mathis & Simon Hofer on 18.12.06.
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

#import "AMXMLParser.h"

@implementation AMXMLParser

- (NSObject *)parseData:(NSData *)data
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:YES];
    
    BOOL success = [parser parse];
    if (!success) {
        AmuaLogf(LOG_ERROR, @"search: could not parse xml file: %@",
                 [[parser parserError] localizedDescription]);
    }
    
    return rootElement;
}


- (void)dealloc
{
    if (tempElement != nil) {
        [tempElement release];
    } 
    if (rootElement != nil) {
        [rootElement release];
    }
    if (temp != nil) {
        [temp release];
    }
    if (elements != nil) {
        [elements release];
    }
    
    [super dealloc];
}


// NSXMLParser delegate implementation


- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    if (elements != nil) {
        [elements release];
    }
    elements = [[NSMutableArray alloc] init];
    if (tempElement != nil) {
        [tempElement release];
        tempElement = nil;
    }
    if (temp != nil) {
        [temp release];
        temp = nil;
    }
    if (rootElement != nil) {
        [rootElement release];
        rootElement = nil;
    }
}


- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    if (elements != nil) {
        [elements release];
        elements = nil;
    }
    if (tempElement != nil) {
        [tempElement release];
        tempElement = nil;
    }
    if (temp != nil) {
        [temp release];
        temp = nil;
    }
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
                                     namespaceURI:(NSString *)namespaceURI
                                     qualifiedName:(NSString *)qualifiedName
                                     attributes:(NSDictionary *)attributeDict
{
    AMXMLNode *element = [[[AMXMLNode alloc] initWithName:elementName] autorelease];
    [element setAttributes:attributeDict];
    if (tempElement != nil) {
        [tempElement addChild:element];
        [elements addObject:tempElement];
        [tempElement release];
    } else {
        rootElement = [element retain];
    }

    tempElement = [element retain];
    if (temp != nil) {
        [temp release];
    }
    temp = [[NSMutableString alloc] init];
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
                                     namespaceURI:(NSString *)namespaceURI
                                     qualifiedName:(NSString *)qName
{
    [tempElement setContent:temp];
    [temp release];
    temp = nil;
    [tempElement release];
    tempElement = nil;
    if ([elements count] > 0) {
        tempElement = [[elements lastObject] retain];
        [elements removeLastObject];
    }
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (temp != nil) {
        [temp appendString:string];
    }
}

@end
