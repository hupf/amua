//
//  AMStatusBarView.m
//  Amua
//
//  Created by Mathis and Simon Hofer on 21.02.05.
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

#import "AMStatusBarView.h"


@implementation AMStatusBarView

- (id)initWithMenu:(NSMenu *)myMenu
{
    statusItem = [[[NSStatusBar systemStatusBar]
					    statusItemWithLength:NSSquareStatusItemLength] retain];
    self = [super initWithFrame:[[statusItem view] frame]];
    
	if (self) {
		menu = [myMenu retain];
        [statusItem setView:self];
		menuVisibility = NO;
        errorState = NO;
        mouseOverState = NO;
	}
    
    return self;
}


- (void)drawRect:(NSRect)rect
{
	// invert icon if necessary
	NSColor *color;
	if (!menuVisibility) {
        if (errorState) {
            color = [[[NSColor redColor] retain] autorelease];
        } else {
            color = [[[NSColor blackColor] retain] autorelease];
        }
	} else {
		color = [[[NSColor whiteColor] retain] autorelease];
	}
	
	// draw item with status as background
	[statusItem drawStatusBarBackgroundInRect:[self frame] withHighlight:menuVisibility];
	[[NSString stringWithFormat:@"%C",0x266A] drawAtPoint:NSMakePoint(8,3) withAttributes:[NSDictionary
													dictionaryWithObjectsAndKeys:
													[NSFont systemFontOfSize:14], NSFontAttributeName,
													color, NSForegroundColorAttributeName, nil]];
}


- (void)addMouseOverListener
{
	mouseEventTag = [self addTrackingRect:[self frame] owner:self userData:nil assumeInside:NO];
}


- (void)removeMouseOverListener
{
	if (mouseEventTag) {
		[self removeTrackingRect:mouseEventTag];
	}
}


- (void)mouseDown:(NSEvent *) theEvent
{
    if (([theEvent modifierFlags] & NSAlternateKeyMask) != 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AmuaStatusItemAltMouseDown" object:self];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AmuaStatusItemMouseDown" object:self];
        menuVisibility = YES;
        [self setNeedsDisplay:YES];
        [statusItem popUpStatusItemMenu:menu];
        menuVisibility = NO;
        [self setNeedsDisplay:YES];
    }
}	


- (void)mouseEntered:(NSEvent *)theEvent
{
    mouseOverState = YES;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AmuaStatusItemMouseEntered" object:self];
}


- (void)mouseExited:(NSEvent *)theEvent
{
    mouseOverState = NO;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AmuaStatusItemMouseExited" object:self];
}


- (bool)isMenuVisible
{
	return menuVisibility;
}


- (bool)isMouseOver
{
    return mouseOverState;
}


- (void)displayError:(BOOL)error
{
    errorState = error;
    [self setNeedsDisplay:YES];
}


- (void)dealloc
{
	[self removeMouseOverListener];
	[menu release];
	[statusItem release];
	[super dealloc];
}

@end
