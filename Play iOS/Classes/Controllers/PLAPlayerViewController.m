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
#import <MediaPlayer/MediaPlayer.h>
#import "PLAController.h"
#import "PLALogInViewControllerViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation PLAPlayerViewController
@synthesize songLabel, artistLabel, albumArtImageView, playButton, nowPlayingView, sliderView, statusLabel, currentTrack;

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
  [self destroyStreamer];

  [currentTrack release];
  [songLabel release];
  [artistLabel release];
  [albumArtImageView release];
  [playButton release];
  [nowPlayingView release];
  [sliderView release];
  [statusLabel release];
  [super dealloc];
}


#pragma mark - View lifecycle

- (void)viewDidLoad{
  [super viewDidLoad];
  
  [self hideNowPlaying:NO];
  albumArtImageView.layer.masksToBounds = YES;
  
  CGRect nowPlayingViewFrame = nowPlayingView.frame;
  
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    nowPlayingViewFrame.size.height = 126.0;
  }else{
    nowPlayingViewFrame.size.height = 246.0;
  }
  [nowPlayingView setFrame:nowPlayingViewFrame];
  
  [[PLAController sharedController] logInWithBlock:^(BOOL succeeded) {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
      if (succeeded) {
        [self setUpForStreaming];
      }else{
        [self presentLogIn];
      }
      
    });
  }];
}

- (void)viewDidUnload{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [self setSongLabel:nil];
  [self setArtistLabel:nil];
  [self setAlbumArtImageView:nil];
  [self setPlayButton:nil];
  [self setNowPlayingView:nil];
  [self setSliderView:nil];
  [self setStatusLabel:nil];
  [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated{
  [super viewDidAppear:animated];

  UIApplication *application = [UIApplication sharedApplication];
  [application beginReceivingRemoteControlEvents];
	[self becomeFirstResponder]; // this enables listening for events
	[[NSNotificationCenter defaultCenter] postNotificationName:ASStatusChangedNotification object:self];  
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
      return (interfaceOrientation == UIInterfaceOrientationPortrait);
  } else {
      return YES;
  }
}

#pragma mark - Bootstrapping methods

- (void)setUpForStreaming{
  // listen for notifications for updated songs from the CFController and pusher
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViewsWithTrackInformation) name:PLANowPlayingUpdated object:nil];
  
  [PLATrack currentTrackWithBlock:^(PLATrack *track, NSError *error) {
    [[PLAController sharedController] setCurrentlyPlayingTrack:track];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
      [self updateViewsWithTrackInformation];
    });
    
  }];
}

#pragma mark - Actionable methods

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

#pragma mark - View State methods

- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (void)updateViewsWithTrackInformation{
  PLATrack *currentlyPlayingTrack = [[PLAController sharedController] currentlyPlayingTrack];
  
  // start downloading the album art first
  // we'll update the view metadata once we have the actual art to prevent
  // a flash and have everything just be cleaner
  [SDWebImageDownloader downloaderWithURL:[currentlyPlayingTrack albumArtURL] delegate:self];
}

- (void)updateMetaData{
  PLATrack *currentlyPlayingTrack = [[PLAController sharedController] currentlyPlayingTrack];
  
  if (currentlyPlayingTrack) {
    self.songLabel.text = [currentlyPlayingTrack name];
    self.artistLabel.text = [currentlyPlayingTrack artist];
    
    [self adjustLabels];
    [self showNowPlaying:YES];
    
    MPMediaItemArtwork *mediaItemArtwork = [[MPMediaItemArtwork alloc] initWithImage:albumArtImageView.image];
    
    NSDictionary *nowPlayingMetaDict = [NSDictionary dictionaryWithObjectsAndKeys:[currentlyPlayingTrack name], MPMediaItemPropertyTitle, [currentlyPlayingTrack album], MPMediaItemPropertyAlbumTitle, [currentlyPlayingTrack artist], MPMediaItemPropertyArtist, mediaItemArtwork, MPMediaItemPropertyArtwork, nil];
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nowPlayingMetaDict];
    
    [mediaItemArtwork release];
  }else{
    self.songLabel.text = @"";
    self.artistLabel.text = @"";
    [self hideNowPlaying:NO];
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
  }
}

- (void)hideNowPlaying:(BOOL)animated{
  float duration = 0.0;
  if (animated) {
    duration = 0.3;
  }
  
  [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
    sliderView.transform = CGAffineTransformIdentity;
  } completion:^(BOOL finished) {}];
}

- (void)showNowPlaying:(BOOL)animated{
  float duration = 0.0;
  if (animated) {
    duration = 0.3;
  }
  
  float yDistance;
  
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    yDistance = 125.0;
  }else{
    yDistance = 244.0;
  }
  
  [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{
    sliderView.transform = CGAffineTransformMakeTranslation(0, yDistance);
  } completion:^(BOOL finished) {}];
}

- (void)adjustLabels{
  CGRect songLabelFrame = songLabel.frame;
  CGRect artistLabelFrame = artistLabel.frame;
  CGRect albumArtImageViewFrame = albumArtImageView.frame;
  
  CGFloat padding;
  
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    [songLabel setFont:[UIFont systemFontOfSize:17.0]];
    [artistLabel setFont:[UIFont systemFontOfSize:13.0]];
    albumArtImageViewFrame.size = CGSizeMake(100.0, 100.0);
    padding = 10.0;
  }else{
    [songLabel setFont:[UIFont systemFontOfSize:38.0]];
    [artistLabel setFont:[UIFont systemFontOfSize:32.0]];
    albumArtImageViewFrame.size = CGSizeMake(200.0, 200.0);
    padding = 20.0;
  }
    
  albumArtImageViewFrame.origin.y = padding + 3.0;
  albumArtImageViewFrame.origin.x = nowPlayingView.bounds.size.width - albumArtImageViewFrame.size.width - padding;
  
  songLabelFrame.origin.x = padding;
  songLabelFrame.origin.y = padding;
  songLabelFrame.size.width = albumArtImageViewFrame.origin.x - padding - 10.0;
  
  CGSize maximumSongLabelSize = CGSizeMake(songLabelFrame.size.width,9999);
  CGSize expectedSongLabelSize = [[songLabel text] sizeWithFont:[songLabel font] constrainedToSize:maximumSongLabelSize lineBreakMode:[songLabel lineBreakMode]]; 
  
  songLabelFrame.size = expectedSongLabelSize;
  

  artistLabelFrame.origin.x = songLabelFrame.origin.x;
  artistLabelFrame.origin.y = songLabelFrame.origin.y + songLabelFrame.size.height + 2.0;
  artistLabelFrame.size.width = albumArtImageViewFrame.origin.x - padding - 10.0;
  
  CGSize maximumArtistLabelSize = CGSizeMake(artistLabelFrame.size.width,9999);
  CGSize expectedArtistLabelSize = [[artistLabel text] sizeWithFont:[artistLabel font] constrainedToSize:maximumArtistLabelSize lineBreakMode:[artistLabel lineBreakMode]]; 
  
  artistLabelFrame.size = expectedArtistLabelSize;
  
  
  self.songLabel.frame = songLabelFrame;
  self.artistLabel.frame = artistLabelFrame;
  self.albumArtImageView.frame = albumArtImageViewFrame;
}

#pragma mark - Play Methods

- (IBAction)togglePlayState:(id)sender{
  if ([streamer isPlaying]) {
		[self destroyStreamer];
    [playButton setImage:[UIImage imageNamed:@"button-play.png"] forState:UIControlStateNormal];
    [statusLabel setHidden:YES];
  }else{
    [self createStreamer];
    [statusLabel setHidden:NO];
    [streamer start];
  }
}

- (void)createStreamer{
	if (streamer){
		return;
	}
  
  NSString *streamUrl = [[PLAController sharedController] streamUrl];
  
  NSLog(@"opening stream at: %@", streamUrl);

	[self destroyStreamer];
  
  NSURL *url = [NSURL URLWithString:streamUrl];
	streamer = [[AudioStreamer alloc] initWithURL:url];
	  
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateChanged:) name:ASStatusChangedNotification object:streamer];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentStreamerAlert:) name:ASPresentAlertWithTitleNotification object:streamer];
}

- (void)destroyStreamer{
	if (streamer){
		[[NSNotificationCenter defaultCenter] removeObserver:self name:ASStatusChangedNotification object:streamer];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:ASPresentAlertWithTitleNotification object:streamer];
		
    self.currentTrack = nil;
    
		[streamer stop];
		[streamer release];
		streamer = nil;
	}
}

#pragma mark - Audio player callbacks

- (void)playbackStateChanged:(NSNotification *)aNotification{
	if ([streamer isWaiting]){
	}else if ([streamer isPlaying]){
    [statusLabel setHidden:YES];
    [playButton setImage:[UIImage imageNamed:@"button-pause.png"] forState:UIControlStateNormal];
	}else if ([streamer isPaused]){
    [statusLabel setHidden:YES];
    [playButton setImage:[UIImage imageNamed:@"button-play.png"] forState:UIControlStateNormal];
	}else if ([streamer isIdle]){
    [statusLabel setHidden:YES];
    [playButton setImage:[UIImage imageNamed:@"button-play.png"] forState:UIControlStateNormal];
	}
}

- (void)presentStreamerAlert:(NSNotification *)aNotification{  
  [self destroyStreamer];
  [playButton setImage:[UIImage imageNamed:@"button-play.png"] forState:UIControlStateNormal];
  [statusLabel setHidden:YES];
  
  NSDictionary *userInfo = [aNotification userInfo];
  
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Stream Error" message:[userInfo objectForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
  [alert show];
  [alert release];
}

#pragma mark - SDWebImageDownloader Callback

- (void)imageDownloader:(SDWebImageDownloader *)imageDownloader didFinishWithImage:(UIImage *)image{
  [albumArtImageView setImage:image];
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
