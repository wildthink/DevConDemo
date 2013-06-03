//
//  logs.c
//  DevConDemo
//
//  Created by Jason Jobe on 6/1/13.
//  Copyright (c) 2013 Jason Jobe. All rights reserved.
//

#include <stdio.h>
#include "logs.h"
#import <Foundation/Foundation.h>

void plog (NSString *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    
    NSString *str = [[NSString alloc] initWithFormat:fmt arguments:args];
    
    NSInteger cnt = [str length];
    for (NSInteger ndx = 0; ndx < cnt; ++ndx) {
        unichar ch = [str characterAtIndex:ndx];
        fputc(ch, stdout);
    }
    fputc ('\n', stdout);
    va_end(args);
}

