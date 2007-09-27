//
//  AMSongInformationPanel.m
//  Amua
//
//  Created by Mathis & Simon Hofer on 11.03.05.
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

#import "AMSongInformationPanel.h"

#define MAX_TEXTFIELD_SIZE 350

@implementation AMSongInformationPanel

- (id)initWithContentRect:(NSRect)contentRect
                styleMask:(unsigned int)styleMask
                  backing:(NSBackingStoreType)backingType
                    defer:(BOOL)flag
{

    self = [super initWithContentRect:contentRect
                            styleMask:NSBorderlessWindowMask
                              backing:NSBackingStoreBuffered
                                defer:NO];
	[self setHidesOnDeactivate:NO];
    [self setIgnoresMouseEvents:NO];
	[self setBackgroundColor:[NSColor colorWithCalibratedRed:1.000 green:1.000 blue:1.000 alpha:1.0]];
    [self setAlphaValue:0.9];
    [self setHasShadow:YES];
	[self setMovableByWindowBackground:YES];
	[self setLevel:NSStatusWindowLevel];
	[self setFrameOrigin:NSMakePoint(0,0)];
	visible = NO;

	return self;

}


- (id)initWithContentRect:(NSRect)contentRect
                styleMask:(unsigned int)styleMask
                  backing:(NSBackingStoreType)backingType
                    defer:(BOOL)flag
                   screen:(NSScreen *)aScreen
{

    self = [super initWithContentRect:contentRect
                            styleMask:NSBorderlessWindowMask
                              backing:NSBackingStoreBuffered
                                defer:NO
                               screen:aScreen];
							   
	[self setHidesOnDeactivate:NO];
    [self setIgnoresMouseEvents:NO];
	[self setBackgroundColor:[NSColor colorWithCalibratedRed:1.000 green:1.000 blue:1.000 alpha:1.0]];
    [self setAlphaValue:0.9];
    [self setHasShadow:YES];
	[self setMovableByWindowBackground:YES];
	[self setLevel:NSStatusWindowLevel];
	[self setFrameOrigin:NSMakePoint(0,0)];
	visible = NO;
	
	return self;

}


- (void)show
{
    [artist startFloating];
    [album startFloating];
    [track startFloating];
    [footer startFloating];
	[self makeKeyAndOrderFront:nil];
    visible = YES;
}


- (void)hide
{
    [self orderOut:nil];
    [artist stopFloating];
    [album stopFloating];
    [track stopFloating];
    [footer stopFloating];
	visible = NO;
}


- (void)updateWithSongInformation:(AMSongInformation *)songInfo;
{
    if (info != nil) {
        [info release];
    }
    info = [songInfo retain];
    
    [artist setStringValue:[info artist]];
    [artist setMaxSize:MAX_TEXTFIELD_SIZE-[artist frame].origin.x];
    [album setStringValue:[info album]];
    [album setMaxSize:MAX_TEXTFIELD_SIZE-[album frame].origin.x];
    [track setStringValue:[info track]];
    [track setMaxSize:MAX_TEXTFIELD_SIZE-[track frame].origin.x];
    
    NSString *footerTitle = @"";
    if (![[info station] isEqualToString:@""]) {
        footerTitle = [info station];
    }
    [footer setStringValue:footerTitle];
    [footer setMaxSize:MAX_TEXTFIELD_SIZE-[footer frame].origin.x];
    
    [image setImage:[info cover]];
    if (timer != nil) {
        [timer invalidate];
        timer = nil;
    }

    [self updateTime:self];
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTime:) 
                 userInfo:nil repeats:YES];
					
    [self resize];
}


- (void)cleanUp
{
    if (timer != nil) {
        [timer invalidate];
        timer = nil;
    }
}


- (void)updateTime:(id)sender
{
    int trackPosition = [info progress];
    int trackDuration = [info length];
	if (trackPosition + 1 >= trackDuration) {
		trackPosition = trackDuration;
		[timer performSelectorOnMainThread:@selector(invalidate) withObject:nil waitUntilDone:YES];
		timer = nil;
	} else {
		trackPosition++;
	}
	
	int progressSecond = trackPosition % 60;
	int progressMinute = (trackPosition - progressSecond) / 60;
	int totalSecond = trackDuration % 60;
	int totalMinute = (trackDuration - totalSecond) / 60;
	NSString *string = @"";
	if (progressMinute < 10) {
		string = [string stringByAppendingString:@"0"];
	}
	string = [string stringByAppendingString:[[NSNumber numberWithInt:progressMinute] stringValue]];
	string = [string stringByAppendingString:@":"];
	if (progressSecond < 10) {
		string = [string stringByAppendingString:@"0"];
	}
	string = [string stringByAppendingString:[[NSNumber numberWithInt:progressSecond] stringValue]];
	string = [string stringByAppendingString:@" / "];
	if (totalMinute < 10) {
		string = [string stringByAppendingString:@"0"];
	}
	string = [string stringByAppendingString:[[NSNumber numberWithInt:totalMinute] stringValue]];
	string = [string stringByAppendingString:@":"];
	if (totalSecond < 10) {
		string = [string stringByAppendingString:@"0"];
	}
	string = [string stringByAppendingString:[[NSNumber numberWithInt:totalSecond] stringValue]];
	
	[time setStringValue:string];
}


- (void)autoPosition
{
	NSPoint point = [NSEvent mouseLocation];
	NSRect displayArea = [[NSScreen mainScreen] visibleFrame];
	point.y = displayArea.origin.y + displayArea.size.height - [self frame].size.height;
	if ((point.x - 10 + [self frame].size.width) > (displayArea.origin.x + displayArea.size.width)) {
		point.x -= [self frame].size.width - 10;
	} else {
		point.x -= 10;
	}
	[self setFrameOrigin:point];
}


- (void)resize
{
	[artist sizeToFit];
	[album sizeToFit];
	[track sizeToFit];
	//[time sizeToFit];
	[footer sizeToFit];
	
	float maxSize = [artist frame].size.width + 107;
	if (maxSize < [album frame].size.width + 107) {
		maxSize = [album frame].size.width + 107;
	}
	if (maxSize < [track frame].size.width + 107) {
		maxSize = [track frame].size.width + 107;
	}
	if (maxSize < [time frame].size.width + 107) {
		maxSize = [time frame].size.width + 107;
	}
	if (maxSize < [footer frame].size.width + 4) {
		maxSize = [footer frame].size.width + 4;
	}
	
	[self setContentSize:NSMakeSize(maxSize, [self frame].size.height)];
	//[artist display];
	//[album display];
	//[track display];
	[time display];
	//[footer display];
	[self display];
	
}


- (BOOL)isVisible
{
	return visible;
}


- (void)dealloc
{
    if (info != nil) {
        [info release];
    }
    if (timer != nil) {
        [timer invalidate];
    }
    
    [super dealloc];
}

@end
