//
//  AMNotification.m
//  Amua
//
//  Created by Mathis & Simon Hofer on 04.02.06.
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

#import "AMNotification.h"

#define max(a,b) (((a)>(b))?(a):(b))

@implementation AMNotification

- (id)initWithTitle:(NSString *)aTitleText withDescription:(NSString *)aDescriptionText
                                       withDismissText:(NSString *)aDismissText
                                       dismissState:(BOOL)aDismissState
                                       action:(SEL)anAction
                                       target:(id)aTargetObject
{
	return [self initWithTitle:aTitleText withDescription:aDescriptionText
                                      withDismissText:aDismissText
                                      dismissState:aDismissState
                                      yesButtonText:@"Yes"
                                      noButtonText:@"No"
                                      action:anAction
                                      target:aTargetObject];
}


- (id)initWithTitle:(NSString *)aTitleText withDescription:(NSString *)aDescriptionText
                                   withDismissText:(NSString *)aDismissText
                                   dismissState:(BOOL)aDismissState
                                   yesButtonText:(NSString *)aYesButtonText
                                   noButtonText:(NSString *)aNoButtonText
                                   action:(SEL)anAction
                                   target:(id)aTargetObject
                                   
{
	self = [super initWithWindowNibName:@"Notification"];
	
    titleText = [aTitleText copy];
    descriptionText = [aDescriptionText copy];
    dismissText = [aDismissText copy];
    dismissState = aDismissState;
    yesButtonText = [aYesButtonText copy];
    noButtonText = [aNoButtonText copy];
    action = anAction;
    targetObject = [aTargetObject retain];
    
    clicked = NOT_YET_CLICKED;
    
    return self;
}


- (void)display
{
    [NSApp activateIgnoringOtherApps:YES];
	[[self window] makeKeyAndOrderFront:nil];
}


- (void)windowDidLoad
{
	[title setStringValue:titleText];
    [description setStringValue:descriptionText];
    [dismiss setTitle:dismissText];
    if (dismissState) {
	    [dismiss setState:NSOnState];
    } else {
    	[dismiss setState:NSOffState];
    }
    [yes setTitle:yesButtonText];
    [no setTitle:noButtonText];
    
    // Resize buttons
    [yes sizeToFit];
    NSRect yesFrame = [yes frame];
    yesFrame.size.width = max(yesFrame.size.width, 90);
	yesFrame.origin.x -= yesFrame.size.width-90;
    [yes setFrame:yesFrame];
    
    [no sizeToFit];
    NSRect noFrame = [no frame];
    noFrame.size.width = max(noFrame.size.width, 90);
	noFrame.origin.x -= noFrame.size.width-90 + yesFrame.size.width-90;
    [no setFrame:noFrame];
}


- (IBAction)performClick:(id)sender
{
	if (sender == yes) {
    	clicked = YES_BUTTON_CLICKED;
    } else if (sender == no) {
    	clicked = NO_BUTTON_CLICKED;
    } else {
    	clicked = NOT_YET_CLICKED;
    }
    
	[[self window] performClose:nil];
	[targetObject performSelector:action withObject:self];
}


- (BOOL)dismissState
{
	return [dismiss state] == NSOnState;
}


- (int)clickedButton
{
	return clicked;
}


- (void)dealloc
{
	[titleText release];
    [descriptionText release];
    [dismissText release];
    [yesButtonText release];
    [noButtonText release];
    [targetObject release];
    
    [super dealloc];
}

@end
