//
//  Debug.m
//  Amua
//
//  Created by Mathis & Simon Hofer on 10.02.06.
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

#import "Debug.h"

static int AmuaLogType;

static NSString* const AmuaLogLevelString [] = {
    @"Amua Error: %@",
    @"Amua Warning: %@",
    @"Amua Log: %@"
};


void AmuaSetLogType(int type) {
    AmuaLogType = type;
}


void AmuaLog(LogLevel level, NSString *msg) {
    if (level >= AmuaLogType) {
        return;
    }
    
    NSLog(AmuaLogLevelString[level], msg);
}


void AmuaLogf(LogLevel level, NSString *fmt, ...) {
    NSString *msg;
    va_list  args;
    
    if (level >= AmuaLogType) {
        return;
    }
    
    va_start(args, fmt);
    if (args != nil) {
        msg = [[[NSString alloc] initWithFormat:fmt arguments:args] autorelease];
    } else {
        msg = fmt;
    }
    va_end(args);
    
    NSLog(AmuaLogLevelString[level], msg);
}
