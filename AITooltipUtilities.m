/*-------------------------------------------------------------------------------------------------------*\
| Adium, Copyright (C) 2001-2004, Adam Iser  (adamiser@mac.com | http://www.adiumx.com)                   |
\---------------------------------------------------------------------------------------------------------/
 | This program is free software; you can redistribute it and/or modify it under the terms of the GNU
 | General Public License as published by the Free Software Foundation; either version 2 of the License,
 | or (at your option) any later version.
 |
 | This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
 | the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
 | Public License for more details.
 |
 | You should have received a copy of the GNU General Public License along with this program; if not,
 | write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 \------------------------------------------------------------------------------------------------------ */

#import "AITooltipUtilities.h"

#define TOOLTIP_MAX_WIDTH           300
#define TOOLTIP_INSET               4.0
#define TOOLTIP_TITLE_BODY_MARGIN   10.0
#define IMAGE_DIMENSION             50.0

@interface AITooltipUtilities (PRIVATE)
+ (void)_createTooltip;
+ (void)_closeTooltip;
+ (void)_sizeTooltip;
+ (void)_drawImage;
+ (NSPoint)_tooltipFrameOriginForSize:(NSSize)tooltipSize;
@end

@implementation AITooltipUtilities

static	NSPanel                 *tooltipWindow;
static	NSTextView				*textView_tooltipTitle = nil;
static	NSTextView				*textView_tooltipBody = nil;
static  NSImageView				*view_tooltipImage = nil;
static  NSWindow				*onWindow = nil;
static	NSAttributedString      *tooltipBody;
static	NSAttributedString      *tooltipTitle;
static  NSImage                 *tooltipImage;
static  NSSize                  imageSize;
static  BOOL                    imageOnRight;
static	NSPoint					tooltipPoint;
static	AITooltipOrientation	tooltipOrientation;

//Tooltips
+ (void)showTooltipWithString:(NSString *)inString onWindow:(NSWindow *)inWindow atPoint:(NSPoint)inPoint orientation:(AITooltipOrientation)inOrientation
{
    [self showTooltipWithAttributedString:[[[NSAttributedString alloc] initWithString:inString] autorelease] 
								 onWindow:inWindow 
								  atPoint:inPoint 
							  orientation:inOrientation];
}

+ (void)showTooltipWithAttributedString:(NSAttributedString *)inString onWindow:(NSWindow *)inWindow atPoint:(NSPoint)inPoint orientation:(AITooltipOrientation)inOrientation
{
    [self showTooltipWithTitle:nil 
						  body:inString
						 image:nil
				  imageOnRight:YES
					  onWindow:inWindow
					   atPoint:inPoint 
				   orientation:inOrientation];
}

+ (void)showTooltipWithTitle:(NSAttributedString *)inTitle body:(NSAttributedString *)inBody image:(NSImage *)inImage onWindow:(NSWindow *)inWindow atPoint:(NSPoint)inPoint orientation:(AITooltipOrientation)inOrientation
{
    [self showTooltipWithTitle:inTitle 
						  body:inBody 
						 image:inImage
				  imageOnRight:YES
					  onWindow:inWindow
					   atPoint:inPoint 
				   orientation:inOrientation];    
}

+ (void)showTooltipWithTitle:(NSAttributedString *)inTitle body:(NSAttributedString *)inBody image:(NSImage *)inImage imageOnRight:(BOOL)inImageOnRight onWindow:(NSWindow *)inWindow atPoint:(NSPoint)inPoint orientation:(AITooltipOrientation)inOrientation
{    
   if((inTitle && [inTitle length]) || (inBody && [inBody length]) || inImage){ //If passed something to display
       BOOL		newLocation = (!NSEqualPoints(inPoint,tooltipPoint) || tooltipOrientation != inOrientation);
       BOOL     needToCreateTooltip = (!tooltipTitle && !tooltipBody && !tooltipImage);
       
        //Update point and orientation
        tooltipPoint = inPoint;
        tooltipOrientation = inOrientation;
        onWindow = inWindow;
		
        if(needToCreateTooltip){
            [self _createTooltip]; //make the window
        }
        
        if (needToCreateTooltip ||
			![inBody isEqualToAttributedString:tooltipBody] ||
			![inTitle isEqualToAttributedString:tooltipTitle] || 
			!(inImage==tooltipImage)) { //we don't exist or something changed
            
			[tooltipTitle release]; tooltipTitle = [inTitle retain];
            
			if (inTitle) {
                [[textView_tooltipTitle textStorage] replaceCharactersInRange:NSMakeRange(0,[[textView_tooltipTitle textStorage] length])
														 withAttributedString:tooltipTitle];
            } else {
                [[textView_tooltipTitle textStorage] deleteCharactersInRange:NSMakeRange(0,[[textView_tooltipTitle textStorage] length])];            
            }
            
            [tooltipBody release]; tooltipBody = [inBody retain];
            if (inBody) {
                [[textView_tooltipBody textStorage] replaceCharactersInRange:NSMakeRange(0,[[textView_tooltipBody textStorage] length])
														withAttributedString:tooltipBody];
            } else {
                [[textView_tooltipBody textStorage] deleteCharactersInRange:NSMakeRange(0,[[textView_tooltipBody textStorage] length])];
            }
            
            [tooltipImage release]; tooltipImage = [inImage retain];
				
            imageOnRight = inImageOnRight;
            [view_tooltipImage setImage:tooltipImage];

			imageSize = (tooltipImage ? NSMakeSize(IMAGE_DIMENSION,IMAGE_DIMENSION) : NSMakeSize(0,0));
            
            [self _sizeTooltip];
				
        } else if(newLocation){
                [tooltipWindow setFrameOrigin:[self _tooltipFrameOriginForSize:[[tooltipWindow contentView] frame].size]];
        }
    }else{ //If passed a nil string, hide any existing tooltip
        if(tooltipBody){
            [self _closeTooltip];
        }

    }
}

//Create the tooltip
+ (void)_createTooltip
{
	NSTextStorage   *textStorage;
	NSLayoutManager *layoutManager;
	NSTextContainer *container;
	
    //Create the window
    tooltipWindow = [[NSPanel alloc] initWithContentRect:NSMakeRect(0,0,0,0) 
											   styleMask:NSBorderlessWindowMask
												 backing:NSBackingStoreBuffered
												   defer:NO];
    [tooltipWindow setHidesOnDeactivate:NO];
    [tooltipWindow setIgnoresMouseEvents:YES];
	[tooltipWindow setBackgroundColor:[NSColor colorWithCalibratedRed:1.000 green:1.000 blue:1.000 alpha:1.0]];
    [tooltipWindow setAlphaValue:0.9];
    [tooltipWindow setHasShadow:YES];
	
	//Just using the floating panel level is insufficient because the contact list can float, too
    [tooltipWindow setLevel:NSStatusWindowLevel];
    
    //Add the title text view
    textStorage = [[NSTextStorage alloc] init];
    
    layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    [layoutManager release];
    
    container = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(TOOLTIP_MAX_WIDTH,10000000.0)];
    [container setLineFragmentPadding:1.0]; //so widths will caclulate properly
    [layoutManager addTextContainer:container];
    [container release];
    
    textView_tooltipTitle = [[NSTextView alloc] initWithFrame:NSMakeRect(0,0,0,0) textContainer:container];
    [textView_tooltipTitle setSelectable:NO];
    [textView_tooltipTitle setRichText:YES];
    [textView_tooltipTitle setDrawsBackground:NO];
    [[tooltipWindow contentView] addSubview:textView_tooltipTitle];
        
    //Add the body text view
    textStorage = [[NSTextStorage alloc] init];
    
    layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    [layoutManager release];
    
    container = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(TOOLTIP_MAX_WIDTH,10000000.0)];
    [container setLineFragmentPadding:0.0]; //so widths will caclulate properly
    [layoutManager addTextContainer:container];
    [container release];
    
    textView_tooltipBody = [[NSTextView alloc] initWithFrame:NSMakeRect(0,0,0,0) textContainer:container];
    [textView_tooltipBody setSelectable:NO];
    [textView_tooltipBody setRichText:YES];
    [textView_tooltipBody setDrawsBackground:NO];

    [[tooltipWindow contentView] addSubview:textView_tooltipBody];
    
    view_tooltipImage = [[NSImageView alloc] initWithFrame:NSMakeRect(0,0,0,0)];
    [[tooltipWindow contentView] addSubview:view_tooltipImage];    
}

+ (void)_closeTooltip
{
    [tooltipWindow orderOut:nil];
    [textView_tooltipBody release]; textView_tooltipBody = nil;
    [textView_tooltipTitle release]; textView_tooltipTitle = nil;
    [view_tooltipImage release]; view_tooltipImage = nil;
    [tooltipWindow release]; tooltipWindow = nil;
    [tooltipBody release]; tooltipBody = nil;
    [tooltipTitle release]; tooltipTitle = nil;
    [tooltipImage release]; tooltipImage = nil;
    tooltipPoint = NSMakePoint(0,0);
}

+ (void)_sizeTooltip
{
    NSRect  tooltipTitleRect;
    NSRect  tooltipBodyRect;
    NSRect  tooltipWindowRect;
    
    BOOL hasTitle = tooltipTitle && [tooltipTitle length];
    BOOL hasBody = tooltipBody && [tooltipBody length];
    if (hasTitle) {
        //Make sure we're not wrapping by default
        //Set up the tooltip's bounds
        [[textView_tooltipTitle layoutManager] glyphRangeForTextContainer:[textView_tooltipTitle textContainer]]; //void - need to force it to lay out the glyphs for an accurate measurement
        tooltipTitleRect = [[textView_tooltipTitle layoutManager] usedRectForTextContainer:[textView_tooltipTitle textContainer]];
    } else {
        tooltipTitleRect = NSMakeRect(0,0,0,0);
    }
    
    if (hasBody) {
        //Make sure we're not wrapping by default
        //Set up the tooltip's bounds
        [[textView_tooltipBody layoutManager] glyphRangeForTextContainer:[textView_tooltipBody textContainer]]; //void - need to force it to lay out the glyphs for an accurate measurement
        tooltipBodyRect = [[textView_tooltipBody layoutManager] usedRectForTextContainer:[textView_tooltipBody textContainer]];
    } else {
        tooltipBodyRect = NSMakeRect(0,0,0,0);   
    }
    
    float titleAndBodyMargin = (hasTitle && hasBody) ? TOOLTIP_TITLE_BODY_MARGIN : 0;
    //width is the greater of the body and title widths
    float windowWidth = TOOLTIP_INSET*2 + ((tooltipBodyRect.size.width > tooltipTitleRect.size.width) ? tooltipBodyRect.size.width : tooltipTitleRect.size.width);
    float windowHeight = titleAndBodyMargin + TOOLTIP_INSET*2 + (tooltipTitleRect.size.height + tooltipBodyRect.size.height);
    
    //Set the textView's origin 
//  tooltipTitleRect.origin =  NSMakePoint(windowWidth/2 - tooltipTitleRect.size.width/2,TOOLTIP_INSET + tooltipBodyRect.size.height); //center the title
    tooltipTitleRect.origin =  NSMakePoint(TOOLTIP_INSET,titleAndBodyMargin + TOOLTIP_INSET + tooltipBodyRect.size.height); //left
    tooltipBodyRect.origin =  NSMakePoint(TOOLTIP_INSET, TOOLTIP_INSET);
    
    if (tooltipImage) {
        //if the image isn't going to fit without overlapping the title, expand the window's width
        float neededWidth = imageSize.width + tooltipTitleRect.size.width + (TOOLTIP_INSET*3);
        if (neededWidth > windowWidth) {
            windowWidth = neededWidth;   
        }
        //The image should not overlap the body of the tooltip, so increase the window height (the body has an origin at the bottom-left so will move with the window)
        if (IMAGE_DIMENSION > tooltipTitleRect.size.height) {
            windowHeight = titleAndBodyMargin + imageSize.height + tooltipBodyRect.size.height + TOOLTIP_INSET*2;
        }
        
        if(imageOnRight) {
            //recenter the title to be between the left of the window and the left of the image
            //tooltipTitleRect.origin = NSMakePoint(((windowWidth - imageSize.width - tooltipTitleRect.size.width)/2 - TOOLTIP_INSET),tooltipBodyRect.size.height + TOOLTIP_INSET + (imageSize.height)/2 - tooltipTitleRect.size.height/2);
            tooltipTitleRect.origin = NSMakePoint(TOOLTIP_INSET,windowHeight - (imageSize.height)/2 - tooltipTitleRect.size.height/2);
            [view_tooltipImage setFrameOrigin:NSMakePoint(windowWidth - imageSize.width - TOOLTIP_INSET,windowHeight - imageSize.height - TOOLTIP_INSET)];
        } else {
            //recenter the title to be between the right of the image and the right of the window
            //tooltipTitleRect.origin = NSMakePoint(((windowWidth + imageSize.width - tooltipTitleRect.size.width)/2 + TOOLTIP_INSET),tooltipBodyRect.size.height + TOOLTIP_INSET + (imageSize.height)/2 - tooltipTitleRect.size.height/2);
//            tooltipTitleRect.origin = NSMakePoint((imageSize.width + TOOLTIP_INSET * 2),tooltipBodyRect.size.height + TOOLTIP_INSET*2 + (imageSize.height)/2 - tooltipTitleRect.size.height/2);
            tooltipTitleRect.origin = NSMakePoint((imageSize.width + TOOLTIP_INSET * 2),windowHeight - (imageSize.height)/2 - tooltipTitleRect.size.height/2);
            [view_tooltipImage setFrameOrigin:NSMakePoint(TOOLTIP_INSET,windowHeight - imageSize.height - TOOLTIP_INSET)];
        }
    }

    [view_tooltipImage setFrameSize:imageSize];
    
    //Apply the new frames for the text views
    [textView_tooltipTitle  setFrame:tooltipTitleRect];
    [textView_tooltipBody   setFrame:tooltipBodyRect];
    
    [textView_tooltipTitle  setNeedsDisplay:YES];
    [textView_tooltipBody   setNeedsDisplay:YES];
    [view_tooltipImage      setNeedsDisplay:YES];
    [[tooltipWindow contentView] setNeedsDisplay:YES];
    
    //Set the window origin and give it a border
    tooltipWindowRect.size = NSMakeSize(windowWidth,windowHeight);
    tooltipWindowRect.origin =  [self _tooltipFrameOriginForSize:tooltipWindowRect.size];
    
    //Apply the frame change
    [tooltipWindow setFrame:tooltipWindowRect display:YES];
    
    //Draw the dividing line
    if (titleAndBodyMargin) {
        [[tooltipWindow contentView] lockFocus];
        [[[NSColor grayColor] colorWithAlphaComponent:.7] set];
        [NSBezierPath setDefaultLineWidth:0.5];
        [NSBezierPath strokeLineFromPoint:NSMakePoint(TOOLTIP_INSET,titleAndBodyMargin/2 + tooltipBodyRect.size.height + 4)
                                  toPoint:NSMakePoint(windowWidth - TOOLTIP_INSET,titleAndBodyMargin/2 + tooltipBodyRect.size.height + 4)];
        [[tooltipWindow contentView] unlockFocus];
    }
    
    //Ensure the tip is visible
    if(![tooltipWindow isVisible]){
        [tooltipWindow makeKeyAndOrderFront:nil];
    }
}

+ (NSPoint)_tooltipFrameOriginForSize:(NSSize)tooltipSize;
{
	NSRect screenRect;
	if (onWindow) {
		screenRect = [[onWindow screen] visibleFrame];
	} else {
		screenRect = [[NSScreen mainScreen] visibleFrame];
	}
	
    NSPoint      tooltipOrigin;
    
    //Adjust the tooltip so it fits completely on the screen
    if(tooltipOrientation == TooltipAbove){
        if(tooltipPoint.x > (screenRect.origin.x + screenRect.size.width - tooltipSize.width)){
           tooltipOrigin.x = tooltipPoint.x - 2 - tooltipSize.width;
        }else{
          tooltipOrigin.x = tooltipPoint.x;
        }

        if(tooltipPoint.y > (screenRect.origin.y + screenRect.size.height - tooltipSize.height)){
            tooltipOrigin.y = screenRect.origin.y + screenRect.size.height - tooltipSize.height;
        }else{
            tooltipOrigin.y = tooltipPoint.y + 2;
        }
        
        if (tooltipOrigin.y < 0)
            tooltipOrigin.y = 0;
        
    }else{
        if(tooltipPoint.x > (screenRect.origin.x + screenRect.size.width - tooltipSize.width)){
            tooltipOrigin.x = tooltipPoint.x - 2 - tooltipSize.width;
        }else{
            tooltipOrigin.x = tooltipPoint.x + 10;
        }

        if(tooltipPoint.y < (screenRect.origin.y + tooltipSize.height)){
            tooltipOrigin.y = tooltipPoint.y + 2;
        }else{
            tooltipOrigin.y = tooltipPoint.y - 2 - tooltipSize.height;
        }
        
        if (tooltipOrigin.y + tooltipSize.height > (screenRect.origin.y + screenRect.size.height))
            tooltipOrigin.y = (screenRect.origin.y + screenRect.size.height) - tooltipSize.height;
    }
    
    return(tooltipOrigin);
}

@end
