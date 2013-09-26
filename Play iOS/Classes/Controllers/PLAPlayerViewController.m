//
//  PLViewController.m
//  Play
//
//  Created by Jon Maddox on 2/9/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "PLAPlayerViewController.h"
#import "PLAIOSAppDelegate.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageDownloader.h"
#import "PLAController.h"
#import "PLALogInViewControllerViewController.h"
#import "PLAChannelsViewController.h"
#import "PLANavigationController.h"
#import <QuartzCore/QuartzCore.h>

@implementation PLAPlayerViewController
@synthesize songLabel, artistLabel, albumArtImageView, playButton, channelsButton, starButton, volumeDownLabel, volumeUpLabel, volumeView, airplayView;

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
  [self destroyStreamer];

  [songLabel release];
  [artistLabel release];
  [albumArtImageView release];
  [playButton release];
  [channelsButton release];
  [starButton release];
  [volumeDownLabel release];
  [volumeUpLabel release];
  [volumeView release];
  [airplayView release];
  [super dealloc];
}


#pragma mark - View lifecycle

- (void)viewDidLoad{
  [super viewDidLoad];
  
  [self.volumeDownLabel setFont:[UIFont fontWithName:@"FontAwesome" size:16.0]];
  [self.volumeUpLabel setFont:[UIFont fontWithName:@"FontAwesome" size:16.0]];

  [self.starButton.titleLabel setFont:[UIFont fontWithName:@"FontAwesome" size:22.0]];
  
  [self.volumeView setShowsRouteButton:NO];
  [self.volumeView setVolumeThumbImage:[UIImage imageNamed:@"volume-knob.png"] forState:UIControlStateNormal];

  [self.airplayView setShowsVolumeSlider:NO];
  [self.airplayView setRouteButtonImage:[UIImage imageNamed:@"airplay-off.png"] forState:UIControlStateNormal];
  [self.airplayView setRouteButtonImage:[UIImage imageNamed:@"airplay-on.png"] forState:UIControlStateSelected];
  
  [self adjustStarButton:NO];

  CGRect artistLabelRect = self.artistLabel.frame;
  self.artistLabel.fadeLength = 10.0f;
  self.artistLabel.marqueeType = MLContinuous;
  self.artistLabel.animationCurve = UIViewAnimationOptionCurveLinear;
  self.artistLabel.continuousMarqueeExtraBuffer = 50.0f;
  self.artistLabel.textAlignment = NSTextAlignmentCenter;
  
  self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self.channelsButton] autorelease];
  
  [self.artistLabel setText:@""];
  [self.songLabel setText:@""];
  
  albumArtImageView.layer.masksToBounds = YES;
    
  [playButton.titleLabel setFont:[UIFont fontWithName:@"FontAwesome" size:24.0]];
  [playButton setTitle:@"\uf04b" forState:UIControlStateNormal];

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViewsWithTrackInformation) name:PLANowPlayingUpdated object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTunedChannel) name:PLAChannelTuned object:nil];
  

  [[PLAController sharedController] logInWithBlock:^(BOOL succeeded) {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
      if (succeeded) {
        [[PLAController sharedController] updateNowPlaying];
      }else{
        [self presentLogIn];
      }
      
    });
  }];
  
  [self toggleViews:YES];
}

- (void)viewDidUnload{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [self setSongLabel:nil];
  [self setArtistLabel:nil];
  [self setAlbumArtImageView:nil];
  [self setPlayButton:nil];
  [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated{
  [super viewDidAppear:animated];
  
  UIApplication *application = [UIApplication sharedApplication];
  [application beginReceivingRemoteControlEvents];
	[self becomeFirstResponder]; // this enables listening for events
	[[NSNotificationCenter defaultCenter] postNotificationName:ASStatusChangedNotification object:self];
}

- (NSUInteger)supportedInterfaceOrientations {
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    return UIInterfaceOrientationMaskPortrait;
  } else {
    return UIInterfaceOrientationMaskAll;
  }
}

- (BOOL) shouldAutorotate {
  return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
  NSLog(@"SHOULD AUTOROTATE");
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
  } else {
    return YES;
  }
}

#pragma mark - Data methods

- (PLATrack *)currentTrack{
  return [[PLAController sharedController] currentlyPlayingTrack];
}

#pragma mark - Actionable methods

- (void)likeSong{
  [self adjustStarButton:YES];
  [self.starButton setUserInteractionEnabled:NO];

  [[self currentTrack] starWithCompletionBlock:^(BOOL success, NSError *err) {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
      [self.starButton setUserInteractionEnabled:YES];
      [self adjustStarButton:[[self currentTrack] liked]];
    });
  }];
}

- (void)unlikeSong{
  [self adjustStarButton:NO];
  [self.starButton setUserInteractionEnabled:NO];

  [[self currentTrack] unstarWithCompletionBlock:^(BOOL success, NSError *err) {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
      [self adjustStarButton:[[self currentTrack] liked]];
      [self.starButton setUserInteractionEnabled:YES];
    });
  }];
}

- (IBAction)presentLogIn{
  PLALogInViewControllerViewController *controller = [[PLALogInViewControllerViewController alloc] initWithNibName:@"PLALogInViewControllerViewController" bundle:nil];
  
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    controller.modalPresentationStyle = UIModalPresentationFullScreen;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
  } else {
    controller.modalPresentationStyle = UIModalPresentationFormSheet;
    controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
  }
  
  [self presentViewController:controller animated:YES completion:^{
    [controller release];
  }];
}

- (IBAction)presentChannels{
  PLAChannelsViewController *controller = [[PLAChannelsViewController alloc] initWithStyle:UITableViewStylePlain];
  PLANavigationController *nc = [[PLANavigationController alloc] initWithRootViewController:controller];
  
  [self presentViewController:nc animated:YES completion:^{
    [controller release];
    [nc release];
  }];
}


#pragma mark - View State methods

- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (void)handleTunedChannel{
  BOOL isPlaying = [streamer isPlaying];
  
  if (isPlaying){
    [self destroyStreamer];
    [self createStreamer];
    [streamer start];
  }
}

- (void)updateViewsWithTrackInformation{
  PLATrack *currentlyPlayingTrack = [[PLAController sharedController] currentlyPlayingTrack];
  
  // start downloading the album art first
  // we'll update the view metadata once we have the actual art to prevent
  // a flash and have everything just be cleaner
  [SDWebImageDownloader downloaderWithURL:[currentlyPlayingTrack albumArtURL] delegate:self];
}

- (void)updateMetaData{

  self.title = [[[PLAController sharedController] tunedChannel] name];
  
  PLATrack *currentlyPlayingTrack = [[PLAController sharedController] currentlyPlayingTrack];
    
  if (currentlyPlayingTrack) {
    self.songLabel.text = [currentlyPlayingTrack name];
    self.artistLabel.text = [NSString stringWithFormat:@"%@ • %@", [currentlyPlayingTrack artist], [currentlyPlayingTrack album]];
    [self adjustStarButton:[currentlyPlayingTrack liked]];

    [self toggleViews:NO];
    
    MPMediaItemArtwork *mediaItemArtwork = [[MPMediaItemArtwork alloc] initWithImage:albumArtImageView.image];

    NSDictionary *nowPlayingMetaDict = [NSDictionary dictionaryWithObjectsAndKeys:[currentlyPlayingTrack name], MPMediaItemPropertyTitle, [currentlyPlayingTrack album], MPMediaItemPropertyAlbumTitle, [currentlyPlayingTrack artist], MPMediaItemPropertyArtist, mediaItemArtwork, MPMediaItemPropertyArtwork, nil];
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nowPlayingMetaDict];
    
    [mediaItemArtwork release];
  }else{
    self.songLabel.text = @"";
    self.artistLabel.text = @"";
    [self hideNowPlaying:NO];
    [self adjustStarButton:NO];
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
  }
}

- (void)adjustStarButton:(BOOL)isLiked{
  [self.starButton removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];

  if (isLiked) {
    [self.starButton setTitle:@"\uf005" forState:UIControlStateNormal];
    [self.starButton setTitle:@"\uf005" forState:UIControlStateSelected];
    [self.starButton setTitle:@"\uf005" forState:UIControlStateHighlighted];
    [self.starButton addTarget:self action:@selector(unlikeSong) forControlEvents:UIControlEventTouchDown];
  }else{
    [self.starButton setTitle:@"\uf006" forState:UIControlStateNormal];
    [self.starButton setTitle:@"\uf006" forState:UIControlStateSelected];
    [self.starButton setTitle:@"\uf006" forState:UIControlStateHighlighted];
    [self.starButton addTarget:self action:@selector(likeSong) forControlEvents:UIControlEventTouchDown];
  }
}

- (void)toggleViews:(BOOL)hidden{
  for (id view in [self.view subviews]) {
    [view setHidden:hidden];
  }
}

#pragma mark - Play Methods

- (IBAction)togglePlayState:(id)sender{
  if ([streamer isPlaying]) {
		[self destroyStreamer];
    [playButton setTitle:@"\uf04b" forState:UIControlStateNormal];
  }else{
    [self createStreamer];
    [streamer start];
  }
}

- (void)createStreamer{
	if (streamer){
		return;
	}
  
  NSString *streamUrl = [[PLAController sharedController] streamUrl];
  
	[self destroyStreamer];
  
  NSURL *url = [NSURL URLWithString:streamUrl];
	streamer = [[AudioStreamer alloc] initWithURL:url];
	 
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateChanged:) name:ASStatusChangedNotification object:streamer];
	[[NSNotificationCenter defaultCenter] addObserver:[PLAController sharedController] selector:@selector(updateNowPlaying) name:ASUpdateMetadataNotification object:streamer];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentStreamerAlert:) name:ASPresentAlertWithTitleNotification object:streamer];
}

- (void)destroyStreamer{
	if (streamer){
    [streamer stop];
    [playButton setTitle:@"\uf04b" forState:UIControlStateNormal];

		[[NSNotificationCenter defaultCenter] removeObserver:self name:ASStatusChangedNotification object:streamer];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:ASPresentAlertWithTitleNotification object:streamer];
		[[NSNotificationCenter defaultCenter] removeObserver:[PLAController sharedController] name:ASUpdateMetadataNotification object:streamer];
		  
		[streamer release];
		streamer = nil;
	}
}

#pragma mark - Audio player callbacks

- (void)playbackStateChanged:(NSNotification *)aNotification{
  NSLog(@"streamer isWaiting: %d", [streamer isWaiting]);
  NSLog(@"streamer isPlaying: %d", [streamer isPlaying]);
  NSLog(@"streamer isPaused: %d", [streamer isPaused]);
  NSLog(@"streamer isIdle: %d", [streamer isIdle]);
  
	if ([streamer isWaiting]){
    [playButton setTitle:@"\uf04d" forState:UIControlStateNormal];
	}else if ([streamer isPlaying]){
    [playButton setTitle:@"\uf04d" forState:UIControlStateNormal];
	}else if ([streamer isPaused]){
    [playButton setTitle:@"\uf04b" forState:UIControlStateNormal];
	}else if ([streamer isIdle]){
    [playButton setTitle:@"\uf04b" forState:UIControlStateNormal];
	}else{
    [playButton setTitle:@"\uf04b" forState:UIControlStateNormal];
	}
}

- (void)presentStreamerAlert:(NSNotification *)aNotification{  
  [self destroyStreamer];
  [playButton setTitle:@"\uf04b" forState:UIControlStateNormal];
  
  NSDictionary *userInfo = [aNotification userInfo];
  
  dispatch_async(dispatch_get_main_queue(), ^(void) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Stream Error" message:[userInfo objectForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
    [alert release];
  });

  
}

#pragma mark - SDWebImageDownloader Callback

- (void)imageDownloader:(SDWebImageDownloader *)imageDownloader didFinishWithImage:(UIImage *)image{
  if (image) {
    [albumArtImageView setImage:image];
  }else{
    [albumArtImageView setImage:[UIImage imageNamed:@"default_album.png"]];
  }
  [self updateMetaData];
}

#pragma mark - Remote Control Events

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
	switch (event.subtype) {
		case UIEventSubtypeRemoteControlTogglePlayPause:
      if (streamer && [streamer isPlaying]) {
        [streamer pause];
      }else{
        [streamer start];
        [self updateMetaData];
      }
			break;
		case UIEventSubtypeRemoteControlPlay:
      [self createStreamer];
      [streamer start];
			break;
		case UIEventSubtypeRemoteControlPause:
      [self destroyStreamer];
			break;
		case UIEventSubtypeRemoteControlStop:
      [self destroyStreamer];
			break;
		default:
			break;
	}
  
  [self updateMetaData];
}

@end
