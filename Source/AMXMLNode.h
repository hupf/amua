//
//  AMXMLNode.h
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

#import <Cocoa/Cocoa.h>

/**
 * AMXMLNode represents an XML data node.
 *
 * Every node can contain multiple childs, attributes, a content string
 * and an element name. An XML document is represented using a reference
 * to the document root node.
 * @ingroup Webservice
 */
@interface AMXMLNode : NSObject {
    
    NSMutableArray *childs;
    NSDictionary *attributes;
    NSString *content;
    NSString *elementName;

}

/**
 * Return an initialized AMXMLNode.
 * @param name The element name of the node.
 */
- (id)initWithName:(NSString *)name;

/**
 * Set the node attributes.
 * @param dictionary A dictionary containing the attributes.
 */
- (void)setAttributes:(NSDictionary *)dictionary;

/**
 * Set the content as string.
 * @param string The content as string.
 */
- (void)setContent:(NSString *)string;

/**
 * Add a child node.
 * @param xmlElement The child node.
 */
- (void)addChild:(AMXMLNode *)xmlElement;

/**
 * Return a specific attribute.
 * @param name The attribute name.
 * @return The attribute for the specified name or nil.
 */
- (NSString *)attributeForName:(NSString *)name;

/**
 * Return a child at a specific index.
 * 
 * If the index is out of the bounds, an NSRangeException is thrown.
 * @param index The position of the child (by document order).
 * @return The child at index
 * @see childElementsCount
 */
- (AMXMLNode *)childElementAtIndex:(int)index;

/**
 * Return a child with a certain name.
 * @param name The name of the element.
 * @return The element or nil if not available.
 */
- (AMXMLNode *)childWithName:(NSString *)name;

/** 
 * Return the number of child nodes.
 * @return The number of child nodes.
 */
- (int)childElementsCount;

/** 
 * Return the node content.
 * @return The node content as string.
 */
- (NSString *)content;

/**
 * Get the name of the xml element.
 * @return The name of the element.
 */
- (NSString *)name;

- (void)dealloc;

@end
