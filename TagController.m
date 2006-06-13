//
//  TagController.m
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

#import "TagController.h"

@implementation TagController

- (IBAction)showWindow:(id)sender
{
    [self changeRadioButton:[tagCombo selectedCell]];
    [spinner setDisplayedWhenStopped:NO];
    
	[NSApp activateIgnoringOtherApps:YES];
	[tagWindow makeKeyAndOrderFront:nil];
}


- (void)hideWindow
{
	[tagWindow orderOut:self];
}


- (void)setWebservice:(LastfmWebService *)service
{
    webservice = [service retain];
    isSaving = NO;
    [artistButton setEnabled:YES];
    [albumButton setEnabled:YES];
    [trackButton setEnabled:YES];
}


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
    
    if (webservice != nil) {
        [webservice release];
        webservice = nil;
    }
    
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
}


- (void)searchTags
{
	SearchService *searchService = [[SearchService alloc]
						initWithWebServiceServer:[preferences stringForKey:@"webServiceServer"]
                                     asUserAgent:[preferences stringForKey:@"userAgent"]];
    [searchService setDelegate:self];
	[searchService searchUserTags:[preferences stringForKey:@"username"]];
}


- (void)searchFinished:(SearchService *)service
{
    NSArray *result = [service getSearchResult];
    NSMutableString *string = [[[NSMutableString alloc] init] autorelease];
    
    int i;
    for (i=0; i<[result count]; i++) {
        [string appendString:[[result objectAtIndex:i] objectForKey:@"name"]];
        if (i+1 < [result count]) {
            [string appendString:@","];
        }
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
            userArtistTags = [string retain];
            break;
        case USER_TAGS_ALBUM_SEARCH:
            [albumButton setEnabled:YES];
            if (userAlbumTags != nil) {
                [userAlbumTags release];
            }
            userAlbumTags = [string retain];
            break;
        case USER_TAGS_TRACK_SEARCH:
            [trackButton setEnabled:YES];
            if (userTrackTags != nil) {
                [userTrackTags release];
            }
            userTrackTags = [string retain];
            break;
    }
    
    [service release];
    
    [self changeRadioButton:[radioButtons selectedCell]];
    [spinner stopAnimation:self];
}


- (void)setNewTrack:(NSString *)inTrack fromAlbum:(NSString *)inAlbum andArtist:(NSString *)inArtist
{
    track = [inTrack retain];
    album = [inAlbum retain];
    artist = [inArtist retain];
    [saveButton setEnabled:NO];
    [tagCombo setEnabled:NO];
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
        [self changeRadioButton:[tagCombo selectedCell]];
    }
}


- (void)refreshTags
{
    if ([radioButtons selectedCell] == artistButton) {
        if (artist != nil && ![artist isEqualToString:@""] && userArtistTags == nil) {
            SearchService *searchService = [[SearchService alloc]
						initWithWebServiceServer:[preferences stringForKey:@"webServiceServer"]
                                     asUserAgent:[preferences stringForKey:@"userAgent"]];
            [searchService setDelegate:self];
            [searchService searchUserTags:[preferences stringForKey:@"username"] forArtist:artist];
            [spinner startAnimation:self];
        }
    } else if ([radioButtons selectedCell] == albumButton) {
        if (artist != nil && ![artist isEqualToString:@""] &&
            album != nil && ![album isEqualToString:@""] && userAlbumTags == nil) {
            SearchService *searchService = [[SearchService alloc]
						initWithWebServiceServer:[preferences stringForKey:@"webServiceServer"]
                                     asUserAgent:[preferences stringForKey:@"userAgent"]];
            [searchService setDelegate:self];
            [searchService searchUserTags:[preferences stringForKey:@"username"] forArtist:artist andAlbum:album];
            [spinner startAnimation:self];
        }
    } else if ([radioButtons selectedCell] == trackButton) {
        if (artist != nil && ![artist isEqualToString:@""] &&
            track != nil && ![track isEqualToString:@""] && userTrackTags == nil) {
            SearchService *searchService = [[SearchService alloc]
						initWithWebServiceServer:[preferences stringForKey:@"webServiceServer"]
                                     asUserAgent:[preferences stringForKey:@"userAgent"]];
            [searchService setDelegate:self];
            [searchService searchUserTags:[preferences stringForKey:@"username"] forArtist:artist andTrack:track];
            [spinner startAnimation:self];
        }
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
    [tagCombo setEnabled:NO];
    [webservice setTags:[tagCombo stringValue] forData:data];
}


- (void)tagSaved:(id)sender
{
    [spinner stopAnimation:self];
    [self hideWindow];
    [artistButton setEnabled:YES];
    [albumButton setEnabled:YES];
    [trackButton setEnabled:YES];
    isSaving = NO;
    [self setNewTrack:track fromAlbum:album andArtist:artist];
}


- (IBAction)changeRadioButton:(id)sender
{
    NSButtonCell *selected = [radioButtons selectedCell];
    if (selected == artistButton) {
        if (userArtistTags != nil) {
            [tagCombo setStringValue:userArtistTags];
            [saveButton setEnabled:YES];
            [tagCombo setEnabled:YES];
            [spinner stopAnimation:self];
        } else {
            [saveButton setEnabled:NO];
            [tagCombo setEnabled:NO];
            [tagCombo setStringValue:@""];
            [self refreshTags];
        }
    } else if (selected == albumButton) {
        if (userAlbumTags != nil) {
            [tagCombo setStringValue:userAlbumTags];
            [saveButton setEnabled:YES];
            [tagCombo setEnabled:YES];
            [spinner stopAnimation:self];
        } else {
            [saveButton setEnabled:NO];
            [tagCombo setEnabled:NO];
            [tagCombo setStringValue:@""];
            [self refreshTags];
        }
    } else if (selected == trackButton) {
        if (userTrackTags != nil) {
            [tagCombo setStringValue:userTrackTags];
            [saveButton setEnabled:YES];
            [tagCombo setEnabled:YES];
            [spinner stopAnimation:self];
        } else {
            [saveButton setEnabled:NO];
            [tagCombo setEnabled:NO];
            [tagCombo setStringValue:@""];
            [self refreshTags];
        }
    }
}


- (void)setPreferences:(NSUserDefaults *)prefs
{
	preferences = [prefs retain];
}


- (int)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    if (userTags != nil) {
        return [userTags count];
    } else {
        return 0;
    }
}


- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(int)index
{
    return [[userTags objectAtIndex:index] objectForKey:@"name"];
}


- (NSString *)comboBox:(NSComboBox *)aComboBox completedString:(NSString *)uncompletedString
{
    int index = [uncompletedString length];
    bool commaFound = false;
    while (index > 0 && !commaFound) {
        index--;
        commaFound = [uncompletedString characterAtIndex:index] == ',';
    }
    
    if (commaFound) {
        index++;
    }
    
    NSString *completion = [uncompletedString substringFromIndex:index];
    if ([completion length] > 0) {
        int i;
        int count = [userTags count];
        for (i=0; i<count; i++) {
            NSString *item = [[userTags objectAtIndex:i] objectForKey:@"name"];
            if ([item hasPrefix:completion]) {
                completion = item;
            }
        }
    }
    
    return [[uncompletedString substringToIndex:index] stringByAppendingString:completion];
}


@end
