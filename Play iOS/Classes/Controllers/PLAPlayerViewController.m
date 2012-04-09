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
	NSNotification *notification = [NSNotification notificationWithName:ASStatusChangedNotification object:self];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
  return interfaceOrientation == UIInterfaceOrientationPortrait;
    // Return YES for supported orientations
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
      return (interfaceOrientation == UIInterfaceOrientationPortrait);
  } else {
      return YES;
  }
}

#pragma mark - View State methods

- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (void)hideNowPlaying:(BOOL)animated{
  float duration = 0.0;
  if (animated) {
    duration = 0.3;
  }

  [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
    [sliderView setFrame:CGRectMake(sliderView.frame.origin.x, 170.0, sliderView.frame.size.width, sliderView.frame.size.height)];
  } completion:^(BOOL finished) {
  }];

}

- (void)showNowPlaying:(BOOL)animated{
  float duration = 0.0;
  if (animated) {
    duration = 0.3;
  }
  
  [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{
    [sliderView setFrame:CGRectMake(sliderView.frame.origin.x, 290.0, sliderView.frame.size.width, sliderView.frame.size.height)];
  } completion:^(BOOL finished) {
  }];
}

- (void)adjustLabels{
  CGRect songLabelFrame = songLabel.frame;
  CGRect artistLabelFrame = artistLabel.frame;
  
  songLabelFrame.origin.x = 10.0;
  songLabelFrame.origin.y = 10.0;
  songLabelFrame.size.width = 192.0;
  
  CGSize maximumSongLabelSize = CGSizeMake(songLabelFrame.size.width,9999);
  CGSize expectedSongLabelSize = [[songLabel text] sizeWithFont:[songLabel font] constrainedToSize:maximumSongLabelSize lineBreakMode:[songLabel lineBreakMode]]; 
  
  songLabelFrame.size = expectedSongLabelSize;
  

  artistLabelFrame.origin.x = songLabelFrame.origin.x;
  artistLabelFrame.origin.y = songLabelFrame.origin.y + songLabelFrame.size.height + 2.0;
  artistLabelFrame.size.width = 192.0;
  
  CGSize maximumArtistLabelSize = CGSizeMake(artistLabelFrame.size.width,9999);
  CGSize expectedArtistLabelSize = [[artistLabel text] sizeWithFont:[artistLabel font] constrainedToSize:maximumArtistLabelSize lineBreakMode:[artistLabel lineBreakMode]]; 
  
  artistLabelFrame.size = expectedArtistLabelSize;
  
  
  self.songLabel.frame = songLabelFrame;
  self.artistLabel.frame = artistLabelFrame;
}

#pragma mark - Play Methods

- (void)createStreamer{
	if (streamer){
		return;
	}
  
	[self destroyStreamer];
  
  NSURL *url = [NSURL URLWithString:@"http://play.githubapp.com:8000/listen"];
	streamer = [[AudioStreamer alloc] initWithURL:url];
	  
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateChanged:) name:ASStatusChangedNotification object:streamer];
#ifdef SHOUTCAST_METADATA
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(metadataChanged:) name:ASUpdateMetadataNotification object:streamer];
#endif
}

- (void)destroyStreamer{
	if (streamer){
		[[NSNotificationCenter defaultCenter] removeObserver:self name:ASStatusChangedNotification object:streamer];
		
    self.currentTrack = nil;
    
		[streamer stop];
		[streamer release];
		streamer = nil;
	}
}


- (IBAction)togglePlayState:(id)sender{
  if ([streamer isPlaying]) {
		[self destroyStreamer];
    [playButton setImage:[UIImage imageNamed:@"button-play.png"] forState:UIControlStateNormal];
    [self hideNowPlaying:YES];
    [statusLabel setHidden:YES];
  }else{
		[self createStreamer];
    [statusLabel setHidden:NO];
    [streamer start];
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

#ifdef SHOUTCAST_METADATA
- (void)metadataChanged:(NSNotification *)aNotification{
  [PLATrack currentTrackWithBlock:^(PLATrack *track) {
    self.currentTrack = track;
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
      [albumArtImageView setImage:[UIImage imageNamed:@"default_album.png"]];
      [self updateMetaData];
      [SDWebImageDownloader downloaderWithURL:[NSURL URLWithString:[currentTrack albumArtUrl]] delegate:self];
    });
    
  }];
}
#endif

- (void)imageDownloader:(SDWebImageDownloader *)imageDownloader didFinishWithImage:(UIImage *)image{
  [albumArtImageView setImage:image];
  [self updateMetaData];  
}

- (void)updateMetaData{
  if (currentTrack) {
    self.songLabel.text = [currentTrack name];
    self.artistLabel.text = [currentTrack artist];
    
    [self adjustLabels];
    [self showNowPlaying:YES];

    MPMediaItemArtwork *mediaItemArtwork = [[MPMediaItemArtwork alloc] initWithImage:albumArtImageView.image];

    NSDictionary *nowPlayingMetaDict = [NSDictionary dictionaryWithObjectsAndKeys:[currentTrack name], MPMediaItemPropertyTitle, [currentTrack album], MPMediaItemPropertyAlbumTitle, [currentTrack artist], MPMediaItemPropertyArtist, mediaItemArtwork, MPMediaItemPropertyArtwork, nil];
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nowPlayingMetaDict];
    
    [mediaItemArtwork release];
  }else{
    self.songLabel.text = @"";
    self.artistLabel.text = @"";
    [self hideNowPlaying:NO];

    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
  }
}



#pragma mark Remote Control Events
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

- (void)didReceiveMemoryWarning{
  [super didReceiveMemoryWarning];
}

@end
