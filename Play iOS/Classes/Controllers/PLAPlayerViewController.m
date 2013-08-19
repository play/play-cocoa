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
@synthesize songLabel, artistLabel, albumArtImageView, playButton, statusLabel, currentTrack;

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
  [self destroyStreamer];

  [currentTrack release];
  [songLabel release];
  [artistLabel release];
  [albumArtImageView release];
  [playButton release];
  [statusLabel release];
  [super dealloc];
}


#pragma mark - View lifecycle

- (void)viewDidLoad{
  [super viewDidLoad];
  
  [self.artistLabel setText:@""];
  [self.songLabel setText:@""];
  
  albumArtImageView.layer.masksToBounds = YES;
  
  MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 70.0, self.view.bounds.size.height - 35.0, 30.0, 50.0)];
  [volumeView setShowsVolumeSlider:NO];
  [volumeView setShowsRouteButton:YES];
  [volumeView sizeToFit];
  [self.view addSubview:volumeView];
  [volumeView release];
  
  [playButton.titleLabel setFont:[UIFont fontWithName:@"FontAwesome" size:20.0]];
  [playButton setTitle:@"\uf04b" forState:UIControlStateNormal];

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



#pragma mark - Bootstrapping methods

- (void)setUpForStreaming{
  // listen for notifications for updated songs from the CFController and pusher
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViewsWithTrackInformation) name:PLANowPlayingUpdated object:nil];

  [[PLAController sharedController] updateNowPlaying];
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
    self.artistLabel.text = [NSString stringWithFormat:@"%@ • %@", [currentlyPlayingTrack artist], [currentlyPlayingTrack album]];
    
    [self adjustLabels];
    
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

- (void)adjustLabels{
  CGRect songLabelFrame = songLabel.frame;
  CGRect artistLabelFrame = artistLabel.frame;
  CGRect albumArtImageViewFrame = albumArtImageView.frame;
  
  CGFloat padding;
  
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    [songLabel setFont:[UIFont fontWithName:@"OpenSans-Semibold" size:20.0]];
    [artistLabel setFont:[UIFont fontWithName:@"OpenSansLight-Italic" size:17.0]];
    albumArtImageViewFrame.size = CGSizeMake(100.0, 100.0);
    padding = 10.0;
  }else{
    [songLabel setFont:[UIFont fontWithName:@"OpenSans-Semibold" size:38.0]];
    [artistLabel setFont:[UIFont fontWithName:@"OpenSansLight-Italic" size:32.0]];
    albumArtImageViewFrame.size = CGSizeMake(200.0, 200.0);
    padding = 20.0;
  }
    
  albumArtImageViewFrame.origin.y = padding;
  albumArtImageViewFrame.origin.x = padding;
  
  songLabelFrame.origin.x = albumArtImageViewFrame.origin.x + albumArtImageViewFrame.size.width + padding;
  songLabelFrame.origin.y = albumArtImageViewFrame.origin.y;
  songLabelFrame.size.width = self.view.bounds.size.width - songLabelFrame.origin.x - padding;
  
  CGSize maximumSongLabelSize = CGSizeMake(songLabelFrame.size.width,9999);
  CGSize expectedSongLabelSize = [[songLabel text] sizeWithFont:[songLabel font] constrainedToSize:maximumSongLabelSize lineBreakMode:[songLabel lineBreakMode]]; 
  
  songLabelFrame.size.height = expectedSongLabelSize.height;
  

  artistLabelFrame.origin.x = songLabelFrame.origin.x;
  artistLabelFrame.origin.y = songLabelFrame.origin.y + songLabelFrame.size.height + 2.0;
  artistLabelFrame.size.width = songLabelFrame.size.width;
  
  CGSize maximumArtistLabelSize = CGSizeMake(artistLabelFrame.size.width,9999);
  CGSize expectedArtistLabelSize = [[artistLabel text] sizeWithFont:[artistLabel font] constrainedToSize:maximumArtistLabelSize lineBreakMode:[artistLabel lineBreakMode]]; 
  
  artistLabelFrame.size.height = expectedArtistLabelSize.height;
  
  
  self.songLabel.frame = songLabelFrame;
  self.artistLabel.frame = artistLabelFrame;
  self.albumArtImageView.frame = albumArtImageViewFrame;
}

#pragma mark - Play Methods

- (IBAction)togglePlayState:(id)sender{
  if ([streamer isPlaying]) {
		[self destroyStreamer];
    [playButton setTitle:@"\uf04b" forState:UIControlStateNormal];
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
  
	[self destroyStreamer];
  
  NSURL *url = [NSURL URLWithString:streamUrl];
	streamer = [[AudioStreamer alloc] initWithURL:url];
	  
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateChanged:) name:ASStatusChangedNotification object:streamer];
	[[NSNotificationCenter defaultCenter] addObserver:[PLAController sharedController] selector:@selector(updateNowPlaying) name:ASUpdateMetadataNotification object:streamer];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentStreamerAlert:) name:ASPresentAlertWithTitleNotification object:streamer];
}

- (void)destroyStreamer{
	if (streamer){
		[[NSNotificationCenter defaultCenter] removeObserver:self name:ASStatusChangedNotification object:streamer];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:ASPresentAlertWithTitleNotification object:streamer];
		[[NSNotificationCenter defaultCenter] removeObserver:[PLAController sharedController] name:ASUpdateMetadataNotification object:streamer];
		
    self.currentTrack = nil;
    
		[streamer stop];
		[streamer release];
		streamer = nil;
	}
}

#pragma mark - Audio player callbacks

- (void)playbackStateChanged:(NSNotification *)aNotification{
	if ([streamer isWaiting]){
    [statusLabel setHidden:NO];
    [playButton setTitle:@"\uf04d" forState:UIControlStateNormal];
	}else if ([streamer isPlaying]){
    [statusLabel setHidden:YES];
    [playButton setTitle:@"\uf04d" forState:UIControlStateNormal];
	}else if ([streamer isPaused]){
    [statusLabel setHidden:YES];
    [playButton setTitle:@"\uf04b" forState:UIControlStateNormal];
	}else if ([streamer isIdle]){
    [statusLabel setHidden:YES];
    [playButton setTitle:@"\uf04b" forState:UIControlStateNormal];
	}
}

- (void)presentStreamerAlert:(NSNotification *)aNotification{  
  [self destroyStreamer];
  [playButton setTitle:@"\uf04b" forState:UIControlStateNormal];

  [statusLabel setHidden:YES];
  
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
