//
//  PLAChannelsViewController.m
//  Play Cocoa
//
//  Created by Jon Maddox on 9/19/13.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import "PLAChannelsViewController.h"
#import "PLAController.h"
#import "PLAChannel.h"
#import "PLATrack.h"
#import "UIImageView+AFNetworking.h"

@interface PLAChannelsViewController ()

@end

@implementation PLAChannelsViewController

- (void)viewDidLoad{
  [super viewDidLoad];
  self.title = @"Refreshing Channels...";
  
  self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(close)] autorelease];
  
  [[PLAController sharedController] updateChannelsWithCompletionBlock:^{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
      self.title = @"Channels";
      [self.tableView reloadData];
    });
  }];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)close{
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  return [[[PLAController sharedController] channels] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
  }
  
  PLAChannel *channel = [[[PLAController sharedController] channels] objectAtIndex:indexPath.row];
  PLATrack *track = [channel nowPlaying];
  
  cell.textLabel.text = [channel name];
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ by %@", [track name], [track artist]];
  
  [self.tableView beginUpdates];
  [cell.imageView setImageWithURL:[track albumArtURL] placeholderImage:nil];
  [self.tableView endUpdates];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  PLAChannel *channel = [[[PLAController sharedController] channels] objectAtIndex:indexPath.row];
  [[PLAController sharedController] tuneChannel:channel];
  [self close];
}

@end
