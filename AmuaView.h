//
//  AmuaView.h
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

#import <Cocoa/Cocoa.h>

/**
 * Handles the Amua statusbar icon, "is-a" NSView.
 */
@interface AmuaView : NSView {
	
    /**
	 * The Amua statusbar item.
	 */
	NSStatusItem *statusItem;
    
    /**
	 * The Amua menu.
	 */
	NSMenu *menu;
    
    /**
	 * A flag for wheter the menu is visible or not.
     * 
     * The flag is used to invert the color of the Amua status bar icon, if the
     * menu is visible (active).
	 */
	bool menuIsVisible;
    
    /**
	 * The rectangle used to track the mouse.
	 */
	NSTrackingRectTag mouseEventTag;
    
    /**
     * Whether the application had an error.
     */
    bool hasError;

}

/**
 * Constructor.
 * 
 * @param frame Initializes the view with frame as its frame rectangle.
 * @param status A reference to the statusbar item.
 * @param myMenu A reference to the Amua menu.
 */
- (id)initWithFrame:(NSRect)frame statusItem:(NSStatusItem *)status menu:(NSMenu *)myMenu;

/**
 * Displays the statusbar icon and the rectangle in the back.
 * 
 * @param rect A rectangle for the statusbar.
 */
- (void)drawRect:(NSRect)rect;

/**
 * Install a listener for mouse over events.
 */
- (void)addMouseOverListener;

/**
 * Remove the listener fr mouse over events.
 */
- (void)removeMouseOverListener;

/**
 * Actions if the mouse button is pressed over the Amua statusbar icon.
 * 
 * Pops up the menu, inverts the icon color, etc.
 */
- (void)mouseDown:(NSEvent *)theEvent;

/**
 * Actions if the mouse enters the Amua statusbar icon.
 */
- (void)mouseEntered:(NSEvent *)theEvent;

/**
 * Actions if the mouse exists the Amua statusbar icon.
 */
- (void)mouseExited:(NSEvent *)theEvent;

/**
 * Check if the is visible or not.
 * 
 * @return YES if the menu is visible, NO otherwise.
 */
- (bool)menuIsVisible;

/**
 * Set the error state of the application.
 *
 * @param error Set to true if the application is in error state.
 */
- (void)setError:(BOOL)error;

/**
 * Deconstructor.
 */
- (void)dealloc;

@end
