//
//  AMPlainTextParser.m
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

#import "AMPlainTextParser.h"


@implementation AMPlainTextParser

- (NSObject *)parseData:(NSData *)data
{
    NSString *result = [[[NSString alloc] initWithData:data
                                              encoding:NSUTF8StringEncoding] autorelease];    
	
	// Parse keys and values and put them into a NSDictionary
	NSArray *values = [result componentsSeparatedByString:@"\n"];
    NSMutableDictionary *parsedData = [[[NSMutableDictionary alloc] init] autorelease];
	int i;
	for (i=0; i< [values count]; i++) {
		NSRange equalPosition = [[values objectAtIndex:i] rangeOfString:@"="];
		if (equalPosition.length > 0) {
			[parsedData setObject:[[values objectAtIndex:i]
            	                         substringFromIndex:equalPosition.location+equalPosition.length]
                           forKey:[[values objectAtIndex:i] substringToIndex:equalPosition.location]];
		}
	}
    
    return parsedData;
}

@end
