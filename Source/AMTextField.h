//
//  AMTextField.h
//  Amua
//
//  Created by Mathis & Simon Hofer on 24.02.06.
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
 * A TextField which content floats if it doesn't fit in.
 */
@interface AMTextField : NSView
{
    /**
     * The internal textfield which is moved around.
     */
    NSTextField *textField;
    
    /**
     * If true the flow runs in positive x direction.
     */
    bool positionIncreasing;
    
    /**
     * The timer which causes the timed move of the textfield.
     */
    NSTimer *timer;
    
    /**
     * The maximal size of the floating textfield.
     */
    int maxSizeValue;
}

/**
 * Get the string value of the textfield.
 * 
 * @return The string value
 */
- (NSString *)stringValue;

/**
 * Set the string value of the textfield.
 * 
 * @param string The new string value
 */
- (void)setStringValue:(NSString *)string;

/**
 * Get the maximal size of the floating textfield.
 *
 * @return The size
 */
- (int)maxSize;

/**
 * Set the maximal size of the floating textfield.
 *
 * @param size The new size
 */
- (void)setMaxSize:(int)size;

/**
 * Resize the floating textfield to fit
 * (the size will never be bigger than maxSize).
 */
- (void)sizeToFit;

/**
 * Start the floating animation if necessary
 */
- (void)startFloating;

/**
 * Stop the floating animation
 */
- (void)stopFloating;

/**
 * A reposition step (for internal use)
 */
- (void)reposition:(id)sender;

/**
 * Reset the internal textfield position
 */
- (void)resetPosition;

@end
