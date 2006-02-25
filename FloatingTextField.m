//
//  FloatingTextField.m
//  Amua
//
//  Created by Mathis & Simon Hofer on 24.02.06.
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

#import "FloatingTextField.h"

@implementation FloatingTextField

- (NSString *)stringValue
{
    return [textField stringValue];
}


- (void)setStringValue:(NSString *)string
{
    if (textField == nil) {
        textField = [[[NSTextField alloc] initWithFrame:[self bounds]] retain];
        [textField setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
        [textField setEditable:NO];
        [textField setSelectable:NO];
        [textField setDrawsBackground:NO];
        [textField setBordered:NO];
        [self addSubview:textField];
    }
    [textField setStringValue:string];
    [textField sizeToFit];
}


- (int)maxSize
{
    return maxSizeValue;
}


- (void)setMaxSize:(int)size
{
    maxSizeValue = size;
}


- (void)sizeToFit
{
    NSRect rect = [self frame];
    if (maxSizeValue < [textField frame].size.width) {
        rect.size.width = maxSizeValue;
    } else {
        rect.size.width = [textField frame].size.width;
    }
    
    [self setFrame:rect];
}


- (void)startFloating
{
    if (timer != nil) {
        [timer invalidate];
        [timer release];
        timer = nil;
    }
    
    if (maxSizeValue < [textField frame].size.width) {
        timer = [[NSTimer scheduledTimerWithTimeInterval:(0.04) target:self
                                                selector:@selector(reposition:) userInfo:nil repeats:YES] retain];
        NSRect rect = [textField frame];
        rect.origin.x = [self bounds].origin.x;
        [textField setFrame:rect];
        positionIncreasing = NO;
    }
}


- (void)stopFloating
{
    if (timer != nil) {
        [timer invalidate];
        [timer release];
        timer = nil;
    }
}


- (void)reposition:(id)sender
{
    NSRect rect = [textField frame];
    
    if (positionIncreasing && rect.origin.x < [self bounds].origin.x) {
        positionIncreasing = YES;
    } else if (rect.origin.x+rect.size.width > 
               [self bounds].origin.x+[self bounds].size.width) {
        positionIncreasing = NO;
    } else {
        positionIncreasing = YES;
    }
    
    if (positionIncreasing) {
        rect.origin.x+=0.3;
    } else {
        rect.origin.x-=0.3;
    }
    [textField setFrame:rect];
    [textField display];
}

@end
