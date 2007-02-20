//
//  AMStationController.h
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

#import <Cocoa/Cocoa.h>
#import "AMPlayer.h"
#import "AMWebserviceRequest.h"
#import "AMSimilarArtistsController.h"
#import "AMGlobalTagsController.h"
#import "AMUserController.h"
#import "AMCustomController.h"

@protocol AMStationTabController;

@class AMSimilarArtistsController, AMGlobalTagsController, AMUserController, AMCustomController;


@interface AMStationController : NSWindowController
{
    
    int stationType;
    AMPlayer *player;
    id<AMStationTabController> tabController;
    
    IBOutlet NSTabView *stationTabView;
    IBOutlet AMSimilarArtistsController *artistController;
    IBOutlet AMGlobalTagsController *globalTagController;
    IBOutlet AMUserController *userController;
    IBOutlet AMCustomController *customController;
    
}

- (id)initWithPlayer:(AMPlayer *)player;
- (void)awakeFromNib;
- (void)update;
- (void)dealloc;
- (IBAction)play:(id)sender;
- (IBAction)search:(id)sender;
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem;

@end

@protocol AMStationTabController

- (void)awakeFromNib;
- (void)startWithPlayer:(AMPlayer *)player withSender:(id)sender;
- (void)searchWithSender:(id)sender;
- (int)windowHeight;

@end
