//
//  Notification.h
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

#import <Cocoa/Cocoa.h>

/**
 * The value for the primary button click.
 */
#define YES_BUTTON_CLICKED 1

/**
 * The value for the secondary button click.
 */
#define NO_BUTTON_CLICKED 2

/**
 * The value if no button has been clicked yet.
 */
#define NOT_YET_CLICKED 0

@interface Notification : NSWindowController
{
	/**
     * The notification's title.
     */
    IBOutlet NSTextField *title;
    
    /**
     * The textfield with the notification text.
     */
    IBOutlet NSTextField *description;
    
    /**
     * The dismiss checkbox.
     */
    IBOutlet NSButton *dismiss;
    
    /**
     * The yes button.
     */
    IBOutlet NSButton *yes;
    
    /**
     * The no button.
     */
    IBOutlet NSButton *no;
    
    /**
     * The content of the title field.
     */
    NSString *titleText;
    
    /**
     * The content of the description field.
     */
    NSString *descriptionText;
    
    /**
     * The text of the dismiss checkbox.
     */
    NSString *dismissText;
    
    /**
     * The state of the dismiss checkbox.
     * 
     * TRUE is checked, FALSE, unchecked.
     */
    BOOL dismissState;
    
    /**
     * The label of the yes button.
     */
    NSString *yesButtonText;
    
    /**
     * The label of the no button.
     */
    NSString *noButtonText;
    
    /**
     * The action that fired by the buttons.
     */
    SEL action;
    
    /**
     * The target object that contains the action that is fired by the buttons.
     */
    id targetObject;
    
    /**
     * The clicked state (see defines).
     */
    int clicked;
}

/**
 * Initialize the Notification object with its values. The button labels are
 * per default set as "Yes" respectively "No".
 *
 * @param aTitleText The title of the notification
 * @param aDescriptionText The description of the notification
 * @param aDissmissText The label for the checkbox
 * @param anAction The action that should be called when a button is clicked
 * @param aTargetObject The object where anAction should be called on
 * @return An instance of the Notification object
 */
- (id)initWithTitle:(NSString *)aTitleText withDescription:(NSString *)aDescriptionText
                                       withDismissText:(NSString *)aDismissText
                                       dismissState:(BOOL)aDismissState
                                       action:(SEL)anAction
                                       target:(id)aTargetObject;

/**
 * Initialize the Notification object with its values.
 *
 * @param aTitleText The title of the notification
 * @param aDescriptionText The description of the notification
 * @param aDissmissText The label for the checkbox
 * @param aYesButtonText The label for the main button
 * @param aNoButtonText The label for the secondary button
 * @param anAction The action that should be called when a button is clicked
 * @param aTargetObject The object where anAction should be called on
 * @return An instance of the Notification object
 */
- (id)initWithTitle:(NSString *)aTitleText withDescription:(NSString *)aDescriptionText
                                   withDismissText:(NSString *)aDismissText
                                   dismissState:(BOOL)aDismissState
                                   yesButtonText:(NSString *)aYesButtonText
                                   noButtonText:(NSString *)aNoButtonText
                                   action:(SEL)anAction
                                   target:(id)aTargetObject;

/**
 * Display the notification panel.
 */
- (void)display;

/**
 * Actions after the window did load.
 */
- (void)windowDidLoad;

/**
 * Handle the button clicks.
 */
- (IBAction)performClick:(id)sender;

/**
 * Get the state of the checkbox.
 * @return The dismiss state
 */
- (BOOL)dismissState;

/**
 * Get the button that was clicked. Possible return values are:
 * YES_BUTTON_CLICKED, NO_BUTTON_CLICKED, NOT_YET_CLICKED
 * @return The clicked button
 */
- (int)clickedButton;

/**
 * Deconstructor.
 */
- (void)dealloc;

@end
