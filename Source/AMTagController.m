//
//  AMTagController.m
//  Amua
//
//  Created by Mathis & Simon Hofer on 04.02.06.
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

#import "AMTagController.h"

@implementation AMTagController

- (IBAction)showWindow:(id)sender
{
    if (!isSaving) {
        [self changeRadioButton:[radioButtons selectedCell]];
        [spinner setDisplayedWhenStopped:NO];
    }
    
	[NSApp activateIgnoringOtherApps:YES];
	[tagWindow makeKeyAndOrderFront:nil];
}


- (void)hideWindow
{
	[tagWindow orderOut:self];
}


/*- (void)setWebservice:(LastfmWebService *)service
{
    webservice = [service retain];
    isSaving = NO;
    [artistButton setEnabled:YES];
    [albumButton setEnabled:YES];
    [trackButton setEnabled:YES];
}*/


- (void)releaseWebservice
{
    if (artist != nil) {
        [artist release];
        artist = nil;
    }
    
    if (album != nil) {
        [album release];
        album = nil;
    }
    
    if (track != nil) {
        [track release];
        track = nil;
    }
    
   /* if (webservice != nil) {
        [webservice release];
        webservice = nil;
    }*/
    
    if (userTags != nil) {
        [userTags release];
        userTags = nil;
    }
    
    if (userArtistTags != nil) {
        [userArtistTags release];
        userArtistTags = nil;
    }
    
    if (userAlbumTags != nil) {
        [userAlbumTags release];
        userAlbumTags = nil;
    }
    
    if (userTrackTags != nil) {
        [userTrackTags release];
        userTrackTags = nil;
    }
    
    if (currentTags != nil) {
        [currentTags release];
        currentTags = nil;
    }
}


- (void)searchTags
{
	/*SearchService *searchService = [[SearchService alloc]
						initWithWebServiceServer:[preferences stringForKey:@"webServiceServer"]
                                     asUserAgent:[preferences stringForKey:@"userAgent"]];
    [searchService setDelegate:self];
	[searchService searchUserTags:[preferences stringForKey:@"username"]];*/
}

/*
- (void)searchFinished:(SearchService *)service
{
    int i;
    NSArray *searchResult = [service getSearchResult];
    NSMutableArray *result = [[[NSMutableArray alloc] init] autorelease];
    for (i = 0; i < [searchResult count]; i++) {
        [result addObject:[[searchResult objectAtIndex:i] objectForKey:@"name"]];
    }
    
    switch ([service getType]) {
        case USER_TAGS_SEARCH:
            userTags = [result retain];
            break;
        case USER_TAGS_ARTIST_SEARCH:
            [artistButton setEnabled:YES];
            if (userArtistTags != nil) {
                [userArtistTags release];
            }
            userArtistTags = [result retain];
            break;
        case USER_TAGS_ALBUM_SEARCH:
            [albumButton setEnabled:YES];
            if (userAlbumTags != nil) {
                [userAlbumTags release];
            }
            userAlbumTags = [result retain];
            break;
        case USER_TAGS_TRACK_SEARCH:
            [trackButton setEnabled:YES];
            if (userTrackTags != nil) {
                [userTrackTags release];
            }
            userTrackTags = [result retain];
            break;
    }
    
    [service release];
    
    [self changeRadioButton:[radioButtons selectedCell]];
    [spinner stopAnimation:self];
}*/

/*
- (void)searchFailed:(SearchService *)service
{
    [self changeRadioButton:nil];
    [spinner stopAnimation:self];
    [errorField setStringValue: @"Could not retrieve all the data."];
}*/


- (void)setNewTrack:(NSString *)inTrack fromAlbum:(NSString *)inAlbum andArtist:(NSString *)inArtist
{
    track = [inTrack copy];
    album = [inAlbum copy];
    artist = [inArtist copy];
    [saveButton setEnabled:NO];
    [errorField setStringValue:@""];
    if (userArtistTags != nil) {
        [userArtistTags release];
        userArtistTags = nil;
    }
    
    if (userAlbumTags != nil) {
        [userAlbumTags release];
        userAlbumTags = nil;
    }
    
    if (userTrackTags != nil) {
        [userTrackTags release];
        userTrackTags = nil;
    }
    
    if (currentTags != nil) {
        [currentTags release];
    }
    
    if (!isSaving && artist != nil && ![artist isEqualToString:@""]) {
        [artistLabel setStringValue:artist];
        if (album != nil && ![album isEqualToString:@""]) {
            [albumLabel setStringValue:album];
        } else {
            [albumLabel setStringValue:@""];
        }
        if (track != nil && ![track isEqualToString:@""]) {
            [trackLabel setStringValue:track];
        } else {
            [trackLabel setStringValue:@""];
        }
    } else if (!isSaving) {
        [artistLabel setStringValue:@""];
    }
    
    if ([tagWindow isVisible]) {
        [self changeRadioButton:[radioButtons selectedCell]];
    }
}


- (void)refreshTags
{
    if ([radioButtons selectedCell] == artistButton) {
        if (artist != nil && ![artist isEqualToString:@""] && userArtistTags == nil) {
            /*SearchService *searchService = [[SearchService alloc]
						initWithWebServiceServer:[preferences stringForKey:@"webServiceServer"]
                                     asUserAgent:[preferences stringForKey:@"userAgent"]];
            [searchService setDelegate:self];
            [searchService searchUserTags:[preferences stringForKey:@"username"] forArtist:artist];*/
            [spinner startAnimation:self];
        }
    } else if ([radioButtons selectedCell] == albumButton) {
        if (artist != nil && ![artist isEqualToString:@""] &&
            album != nil && ![album isEqualToString:@""] && userAlbumTags == nil) {
            /*SearchService *searchService = [[SearchService alloc]
						initWithWebServiceServer:[preferences stringForKey:@"webServiceServer"]
                                     asUserAgent:[preferences stringForKey:@"userAgent"]];
            [searchService setDelegate:self];
            [searchService searchUserTags:[preferences stringForKey:@"username"] forArtist:artist andAlbum:album];*/
            [spinner startAnimation:self];
        }
    } else if ([radioButtons selectedCell] == trackButton) {
        if (artist != nil && ![artist isEqualToString:@""] &&
            track != nil && ![track isEqualToString:@""] && userTrackTags == nil) {
            /*SearchService *searchService = [[SearchService alloc]
						initWithWebServiceServer:[preferences stringForKey:@"webServiceServer"]
                                     asUserAgent:[preferences stringForKey:@"userAgent"]];
            [searchService setDelegate:self];
            [searchService searchUserTags:[preferences stringForKey:@"username"] forArtist:artist andTrack:track];*/
            [spinner startAnimation:self];
        }
    }
}


- (IBAction)addTag:(id)sender
{
    int i;
    NSArray *tags = [[tagField stringValue] componentsSeparatedByString:@","];
    for (i = 0; i < [tags count]; i++) {
        [currentTags addObject:[[tags objectAtIndex:i] stringByTrimmingCharactersInSet:
                                      [NSCharacterSet whitespaceCharacterSet]]];
    }
    [tagField setStringValue:@""];
    [tagsTable reloadData];
}


- (IBAction)removeTag:(id)sender
{
    if (currentTags != nil && [tagsTable selectedRow] < [currentTags count] && [tagsTable selectedRow] >= 0) {
        [currentTags removeObjectAtIndex:[tagsTable selectedRow]];
        [tagsTable reloadData];
    }
}


- (IBAction)saveTags:(id)sender
{
    NSMutableDictionary *data = [[[NSMutableDictionary alloc] init] autorelease];
    if ([radioButtons selectedCell] == artistButton) {
        [data setObject:[artist stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] 
                 forKey:@"artist"];
    } else if ([radioButtons selectedCell] == albumButton) {
        [data setObject:[album stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] 
                 forKey:@"album"];
        [data setObject:[artist stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] 
                 forKey:@"artist"];
    } else if ([radioButtons selectedCell] == trackButton) {
        [data setObject:[track stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] 
                 forKey:@"track"];
        [data setObject:[artist stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] 
                 forKey:@"artist"];
    }
    
    isSaving = YES;
    [spinner startAnimation:self];
    [saveButton setEnabled:NO];
    [artistButton setEnabled:NO];
    [albumButton setEnabled:NO];
    [trackButton setEnabled:NO];
    [tagsTable setEnabled:NO];
    [tagField setEnabled:NO];
    [addButton setEnabled:NO];
    [removeButton setEnabled:NO];
    [errorField setStringValue:@""];
    AmuaLog(LOG_MSG, [self convertArrayToString:currentTags]);
    //[webservice setTags:[self convertArrayToString:currentTags] forData:data];
}


- (void)tagSaved:(id)sender
{
    [spinner stopAnimation:self];
    [self hideWindow];
    [artistButton setEnabled:YES];
    [albumButton setEnabled:YES];
    [trackButton setEnabled:YES];
    [errorField setStringValue:@""];
    isSaving = NO;
    [self setNewTrack:track fromAlbum:album andArtist:artist];
}


- (void)tagError:(id)sender
{
    [spinner stopAnimation:self];
    
    [artistButton setEnabled:YES];
    [albumButton setEnabled:YES];
    [trackButton setEnabled:YES];
    [errorField setStringValue:@"An error occured while saving the tags"];
    isSaving = NO;
    [self setNewTrack:track fromAlbum:album andArtist:artist];
}


- (IBAction)changeRadioButton:(id)sender
{
    NSButtonCell *selected = [radioButtons selectedCell];
    BOOL enableGUI = YES;
    if (selected == artistButton) {
        if (userArtistTags != nil) {
            currentTags = [userArtistTags retain];
        } else {
            enableGUI = NO;
        }
    } else if (selected == albumButton) {
        if (userAlbumTags != nil) {
            currentTags = [userAlbumTags retain];
        } else {
            enableGUI = NO;
        }
    } else if (selected == trackButton) {
        if (userTrackTags != nil) {
            currentTags = [userTrackTags retain];
        } else {
            enableGUI = NO;
        }
    }
    
    if (enableGUI) {
        [saveButton setEnabled:YES];
        [addButton setEnabled:YES];
        [removeButton setEnabled:YES];
        [tagsTable setEnabled:YES];
        [tagsTable reloadData];
        [tagField setEnabled:YES];
        [spinner stopAnimation:self];
    } else {
        [saveButton setEnabled:NO];
        [addButton setEnabled:NO];
        [removeButton setEnabled:NO];
        [tagsTable setEnabled:NO];
        [tagField setEnabled:NO];
        if (sender != nil) {
            [self refreshTags];
        }
    }
}


- (void)setPreferences:(NSUserDefaults *)prefs
{
	preferences = [prefs retain];
}


- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(int)rowIndex
{
    return [currentTags objectAtIndex:rowIndex];
}


- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    if (currentTags == nil || [currentTags count] == 0) {
        [removeButton setEnabled:NO];
        return 0;
    } else {
        [removeButton setEnabled:[tagsTable isEnabled]];
        return [currentTags count];
    }
}


- (NSString *)convertArrayToString:(NSArray *)array
{
    int i;
    NSMutableString *result = [[[NSMutableString alloc] init] autorelease];
    for (i = 0; array != nil && i < [array count]; i++) {
        [result appendString:(NSString *)[array objectAtIndex:i]];
        if (i + 1 < [array count]) {
            [result appendString:@","];
        }
    }
         
    return result;
}


@end
