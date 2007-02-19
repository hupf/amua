//
//  AMGlobalTagsController.m
//  Amua
//
//  Created by Mathis & Simon Hofer on 19.12.06.
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

#import "AMGlobalTagsController.h"

@implementation AMGlobalTagsController

- (void)awakeFromNib
{
    [spinner setHidden:YES];
    [searchResultView setHidden:YES];
    [searchResultView setTarget:self];
    [searchResultView setDoubleAction:@selector(play:)];
    windowHeight = 121;
}


- (void)startWithPlayer:(AMPlayer *)player withSender:(id)sender
{
    [player start:[NSString stringWithFormat:@"lastfm://globaltags/%@", 
        [[searchResult objectAtIndex:[searchResultView selectedRow]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
}


- (void)searchWithSender:(id)sender
{
    if (searchRequest != nil) {
        [searchRequest cancel];
        [searchRequest release];
    }
    NSString *searchTerm = [[searchField stringValue] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://ws.audioscrobbler.com/1.0/tag/%@/search.xml?showtop10=1", searchTerm]];
    NSLog(@"%@", [NSString stringWithFormat:@"http://ws.audioscrobbler.com/1.0/tag/%@/search.xml?showtop10=1", searchTerm]);
    searchRequest = [[AMWebserviceRequest xmlRequestWithDelegate:self] retain];
    [spinner startAnimation:self];
    [spinner setHidden:NO];
    [searchButton setEnabled:NO];
    [playButton setEnabled:NO];
    [searchResultView setEnabled:NO];
    [searchRequest startWithURL:requestURL];
    windowHeight = 320;
}


- (int)windowHeight
{
    return windowHeight;
}


- (void)requestHasFinished:(AMWebserviceRequest *)request withData:(NSObject *)data
{
    if (searchResult != nil) {
        searchResult = nil;
    }
    
    AMXMLResult *xml = (AMXMLResult *)data;
    
    if (xml && [xml childElementsCount] > 0) {
        searchResult = [[NSMutableArray alloc] init];
        int i;
        for (i=0; i<[xml childElementsCount]; i++) {
            [searchResult addObject:[[[xml childElementAtIndex:i] childElementAtIndex:1] content]];
        }
        [playButton setEnabled:YES];
        [searchResultView setEnabled:YES];
    } else {
        [playButton setEnabled:NO];
        [searchResultView setEnabled:NO];
    }
    
    [searchButton setEnabled: YES];
    [spinner stopAnimation:self];
    [spinner setHidden:YES];
    [searchResultView setHidden:NO];
    [searchResultView reloadData];
    
    if (searchRequest != nil) {
        [searchRequest release];
        searchRequest = nil;
    }
}


- (void)requestHasFailed:(AMWebserviceRequest *)request
{
    [spinner stopAnimation:self];
    [spinner setHidden:YES];
    [playButton setEnabled:NO];
    if (searchRequest != nil) {
        [searchRequest release];
        searchRequest = nil;
    }
}


- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    if (searchResult != nil) {
        return [searchResult count] == 0 ? 1 : [searchResult count];
    } else {
        return 1;
    }
}


- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    if (searchResult == nil || [searchResult count] == 0) {
        return @"No Result";
    } else {
        return [searchResult objectAtIndex:rowIndex];
    }
}


- (IBOutlet)play:(id)sender
{
    [playButton performClick:self];
}

@end
