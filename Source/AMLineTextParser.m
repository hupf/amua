//
//  AMLineTextParser.m
//  Amua
//
//  Created by Simon Hofer on 04.10.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "AMLineTextParser.h"


@implementation AMLineTextParser

- (NSObject *)parseData:(NSData *)data
{
    NSString *result = [[[NSString alloc] initWithData:data
                                              encoding:NSUTF8StringEncoding] autorelease];    
	return [result componentsSeparatedByString:@"\n"];
}


@end
