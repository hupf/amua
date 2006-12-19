//
//  AMSimilarArtistController.m
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

#import "AMSimilarArtistsController.h"

@implementation AMSimilarArtistsController

- (void)awakeFromNib
{
    [spinner setHidden:YES];
    [playButton setHidden:YES];
    [mainLabel setStringValue:@""];
    [similarLabel setStringValue:@""];
    windowHeight = 121;
}


- (void)dealloc
{
    if (searchRequest != nil) {
        [searchRequest release];
    }
    
    [super dealloc];
}


- (void)startWithPlayer:(AMPlayer *)player withSender:(id)sender
{
    [player start:[NSString stringWithFormat:@"lastfm://artist/%@/similarartists", 
        [[mainLabel stringValue] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
}


- (void)searchWithSender:(id)sender
{
    if (searchRequest != nil) {
        [searchRequest cancel];
        [searchRequest release];
    }
    NSString *searchTerm =  [[searchField stringValue] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://ws.audioscrobbler.com/1.0/artist/%@/similar.xml", searchTerm]];
    NSLog(@"%@", [NSString stringWithFormat:@"http://ws.audioscrobbler.com/1.0/artist/%@/similar.xml", searchTerm]);
    searchRequest = [[AMWebserviceRequest xmlRequestWithDelegate:self] retain];
    [spinner startAnimation:self];
    [spinner setHidden:NO];
    [searchButton setEnabled:NO];
    [searchRequest startWithURL:requestURL];
    windowHeight = 320;
}


- (void)search
{
}


- (int)windowHeight
{
    return windowHeight;
}


- (void)requestHasFinished:(AMWebserviceRequest *)request withData:(NSObject *)data
{
    AMXMLResult *xml = (AMXMLResult *)data;
    
    if (xml) {
        // main result
        [mainLabel setStringValue:[xml attributeForName:@"artist"]];
        
        // image
        NSURL *imageURL = [NSURL URLWithString:[xml attributeForName:@"picture"]];
        NSImage *image = [[[NSImage alloc] initWithContentsOfURL:imageURL] autorelease];
        // resize the image, why the heck doesn't that work automatically?
        float width, height;
        width = [image size].width;
        height = [image size].height;
        float max = width;
        if (max < height)
            max = height;
        NSRect rect = [imageView frame];
        width *= rect.size.width/max;
        height *= rect.size.height/max;
        [image setSize:NSMakeSize(width, height)];
        [image setScalesWhenResized:YES];
            
        [imageView setImage:image];
        NSMutableString *similar = [NSMutableString stringWithString:@"Similar Artists:\n"];
        int i;
        for (i=0; i<7 && i<[xml childElementsCount]; i++) {
            if (i>0) {
                [similar appendString:@", "];
            }
            AMXMLResult *node = [xml childElementAtIndex:i];
            if (node != nil && [node childElementAtIndex:0] != nil) {
                [similar appendString:[[node childElementAtIndex:0] content]];
            }
        }
        [similarLabel setStringValue:similar];
        [spinner stopAnimation:self];
        [spinner setHidden:YES];
        [playButton setHidden:NO];
        [searchButton setEnabled:YES];
        if ([[xml attributeForName:@"streamable"] isEqualToString:@"1"]) {
            [playButton setEnabled:YES];
        } else {
            [playButton setEnabled:NO];
        }
        if (searchRequest != nil) {
            [searchRequest release];
            searchRequest = nil;
        }
    } else {
        [mainLabel setStringValue:@"No Result"];
        [imageView setImage:nil];
        [similarLabel setStringValue:@""];
        [spinner stopAnimation:self];
        [spinner setHidden:YES];
        [searchButton setEnabled:YES];
        [playButton setHidden:YES];
        if (searchRequest != nil) {
            [searchRequest release];
            searchRequest = nil;
        }
    }
}


- (void)requestHasFailed:(AMWebserviceRequest *)request
{
        [imageView setImage:nil];
        [mainLabel setStringValue:@"Connection Error"];
        [similarLabel setStringValue:@""];
        [spinner stopAnimation:self];
        [spinner setHidden:YES];
        [playButton setHidden:YES];
        if (searchRequest != nil) {
            [searchRequest release];
            searchRequest = nil;
        }
}

@end
