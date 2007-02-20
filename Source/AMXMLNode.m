//
//  AMXMLNode.m
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

#import "AMXMLNode.h"


@implementation AMXMLNode

- (id)initWithName:(NSString *)name
{
    self = [super init];
    elementName = [name copy];
    childs = [[NSMutableArray alloc] init];
    return self;
}


- (void)setAttributes:(NSDictionary *)dictionary
{
    if (attributes != nil) {
        [attributes release];
    }
    attributes = [dictionary retain];
}


- (void)setContent:(NSString *)string
{
    if (content != nil) {
        [content release];
    }
    content = [string retain];
}

- (void)addChild:(AMXMLNode *)xmlElement
{
    [childs addObject:xmlElement];
}


- (NSString *)attributeForName:(NSString *)name
{
    return [attributes objectForKey:name];
}


- (AMXMLNode *)childElementAtIndex:(int)index
{
    return [childs objectAtIndex:index];
}


- (int)childElementsCount
{
    return [childs count];
}


- (NSString *)content
{
    return content;
}


- (void)dealloc
{
    if (content != nil) {
        [content release];
    }
    if (childs != nil) {
        [childs release];
    }
    if (attributes != nil) {
        [attributes release];
    }
    
    [super dealloc];
}

@end
