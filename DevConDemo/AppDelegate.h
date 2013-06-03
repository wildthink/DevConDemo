//
//  AppDelegate.h
//  DevConDemo
//
//  Created by Jason Jobe on 6/1/13.
//  Copyright (c) 2013 Jason Jobe. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSOutlineView *sourceView;
@property (assign) IBOutlet NSTextView *textView;

@end
