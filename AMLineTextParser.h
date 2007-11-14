//
//  AMLineTextParser.h
//  Amua
//
//  Created by Simon Hofer on 04.10.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMWebserviceRequest.h"

@protocol AMWebserviceRequestParser;

@interface AMLineTextParser : NSObject<AMWebserviceRequestParser>  {

}

- (NSObject *)parseData:(NSData *)data;

@end
