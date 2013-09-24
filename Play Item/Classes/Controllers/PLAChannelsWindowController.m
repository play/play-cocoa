//
//  PLAChannelsWindowController.m
//  Play Cocoa
//
//  Created by Jon Maddox on 9/24/13.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import "PLAChannelsWindowController.h"

@interface PLAChannelsWindowController ()

@property (nonatomic, retain) IBOutlet NSTableView *tableView;

@end

@implementation PLAChannelsWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
