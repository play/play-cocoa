//
//  PLAChannelsWindowController.m
//  Play Cocoa
//
//  Created by Jon Maddox on 9/24/13.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import "PLAChannelsWindowController.h"
#import "PLAItemAppDelegate.h"
#import "PLAController.h"

@interface PLAChannelsWindowController ()

@property (retain) NSArray *channels;

- (void)updateChannels;
- (IBAction)showQueue:(id)sender;

@end

@implementation PLAChannelsWindowController

- (id)init
{
	self = [super initWithWindowNibName:@"PLAChannelsWindowController"];
	if (self == nil)
		return nil;
	  
	return self;
}

- (void)windowDidLoad
{
  [super windowDidLoad];
	[self.window setOpaque:NO];
	[self.window setLevel:NSFloatingWindowLevel];
  
  [self updateChannels];
}

- (void)updateChannels
{
  [[PLAController sharedController] updateChannelsWithCompletionBlock:^{
    self.channels = [[PLAController sharedController] channels];
  }];
}

- (IBAction)showQueue:(id)sender
{
	[[NSApp delegate] flipWindowToQueue];
}

#pragma mark -
#pragma mark TableView Delegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification{
  NSInteger index = [notification.object selectedRow];
  
  if (index >= 0){
    PLAChannel *channel = [[[PLAController sharedController] channels] objectAtIndex:index];
    [[PLAController sharedController] tuneChannel:channel];
    
    [notification.object deselectAll:nil];
    [self showQueue:nil];
  }
}

@end
