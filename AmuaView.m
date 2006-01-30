//
//  AmuaView.m
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

#import "AmuaView.h"


@implementation AmuaView

- (id)initWithFrame:(NSRect)frame statusItem:(NSStatusItem*)status menu:(NSMenu*)myMenu
{
    self = [super initWithFrame:frame];
	if (self) {
		menu = [myMenu retain];
		statusItem = [status retain];
		menuIsVisible = NO;
	}
    return self;
}


- (void)drawRect:(NSRect)rect
{
	// invert icon if necessary
	NSColor* color;
	if (!menuIsVisible) {
		color = [[[NSColor blackColor] retain] autorelease];
	} else {
		color = [[[NSColor whiteColor] retain] autorelease];
	}
	
	// draw item with status as background
	[statusItem drawStatusBarBackgroundInRect:[self frame] withHighlight:menuIsVisible];
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


- (void)mouseDown:(NSEvent*) theEvent
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"mouseDown" object:self];
	menuIsVisible = YES;
	[self setNeedsDisplay:YES];
	[statusItem popUpStatusItemMenu:menu];
	menuIsVisible = NO;
	[self setNeedsDisplay:YES];
}	


- (void)mouseEntered:(NSEvent*)theEvent
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"mouseEntered" object:self];
}


- (void)mouseExited:(NSEvent*)theEvent
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"mouseExited" object:self];
}


- (bool)menuIsVisible
{
	return menuIsVisible;
}


- (void)dealloc
{
	[self removeMouseOverListener];
	[menu release];
	[statusItem release];
	[super dealloc];
}

@end
