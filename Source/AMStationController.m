//
//  AMStationController.m
//  Amua
//
//  Created by Mathis & Simon Hofer on 09.12.05.
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

#import "AMStationController.h"

@implementation AMStationController

enum {
    SIMILAR_ARTISTS, GLOBAL_TAGS, USERS, CUSTOM
};

- (id)initWithPlayer:(AMPlayer *)aPlayer
{
    if (self = [super initWithWindowNibName:@"Stations"]) {
        [self setWindowFrameAutosaveName:@"StationsWindow"];
    }
    
    player = [aPlayer retain];
    
    return self;
}


- (void)awakeFromNib
{
    [artistController awakeFromNib];
    [globalTagController awakeFromNib];
    [customController awakeFromNib];
    tabController = artistController;
    [self update];
}


- (void)update
{
    NSRect rect = [[self window] frame];
    int oldheight = rect.size.height;
    if (tabController != nil) {
        rect.size.height = [tabController windowHeight] + 20;
    }

    rect.origin.y -= rect.size.height - oldheight;
       
    [[self window] setFrame:rect display:YES animate:YES];
}


- (void)dealloc
{
    if (player != nil) {
        [player release];
    }
    
    [super dealloc];
}


- (IBAction)play:(id)sender
{   
    if (tabController != nil) {
        [tabController startWithPlayer:player withSender:sender];
    }
    
    [[self window] orderOut:self];
}


- (IBAction)search:(id)sender
{
    if (tabController != nil) {
        [tabController searchWithSender:sender];
        [self update];
    }
}


- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    stationType = [tabView indexOfTabViewItem:tabViewItem];
    switch (stationType) {
        case SIMILAR_ARTISTS:
            tabController = artistController;
            break;
        case GLOBAL_TAGS:
            tabController = globalTagController;
            break;
        case USERS:
            tabController = userController;
            break;
        case CUSTOM:
            tabController = customController;
            break;
    }
    [self update];
}

@end
