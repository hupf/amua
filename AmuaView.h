//
//  myView.h
//  test
//
//  Created by simon on 21.02.05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AmuaView : NSView {
	
	NSStatusItem *statusItem;
	NSMenu *menu;
	bool menuIsVisible;
	NSTrackingRectTag mouseEventTag;

}

- (id)initWithFrame:(NSRect)frame statusItem:(NSStatusItem *)status menu:(NSMenu *)myMenu;
- (void)drawRect:(NSRect)rect;
- (void)addMouseOverListener;
- (void)mouseDown: (NSEvent *) theEvent;
- (void)mouseEntered:(NSEvent *) theEvent;
- (void)mouseExited:(NSEvent *) theEvent;

@end
