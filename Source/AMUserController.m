//
//  AMUserController.m
//  Amua
//
//  Created by Mathis & Simon Hofer on 14.02.07.
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

#import "AMUserController.h"

@implementation AMUserController

- (void)awakeFromNib
{
    [userField setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"username"]];
}


- (void)startWithPlayer:(AMPlayer *)player withSender:(id)sender
{
    NSString *user = [[userField stringValue] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *url;
    switch ([stationTypePopUp indexOfSelectedItem]) {
        case 0:
            // Neighbour Radio
            url = @"lastfm://user/%@/neighbours";
            break;
        case 1:
            // Personal Radio
            url = @"lastfm://user/%@/personal";
            break;
        case 2:
            // Loved Tracks Radio
            url = @"lastfm://user/%@/loved";
            break;
        case 3:
            // Recommendation Radio
            url = @"lastfm://user/%@/recommended/100";
            break;
    }

    [player start:[NSString stringWithFormat:url, user]];
}


- (void)searchWithSender:(id)sender
{}


- (int)windowHeight
{
    return 200;
}

@end
