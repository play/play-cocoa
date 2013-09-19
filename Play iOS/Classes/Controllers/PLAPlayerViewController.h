//
//  PLViewController.h
//  Play
//
//  Created by Jon Maddox on 2/9/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioStreamer.h"
#import "PLATrack.h"
#import "SDWebImageDownloader.h"

@interface PLAPlayerViewController : UIViewController <SDWebImageDownloaderDelegate>{
  UILabel *songLabel;
  UILabel *artistLabel;
  UIImageView *albumArtImageView;
  UIButton *playButton;
  UIView *nowPlayingView;
  UIView *sliderView;
  UILabel *statusLabel;
  PLATrack *currentTrack;
	AudioStreamer *streamer;
}

@property (retain, nonatomic) IBOutlet UILabel *songLabel;
@property (retain, nonatomic) IBOutlet UILabel *artistLabel;
@property (retain, nonatomic) IBOutlet UIImageView *albumArtImageView;
@property (retain, nonatomic) IBOutlet UIButton *playButton;
@property (retain, nonatomic) IBOutlet UILabel *statusLabel;
@property (retain, nonatomic) PLATrack *currentTrack;

- (void)setUpForStreaming;
- (void)presentLogIn;
- (void)updateMetaData;
- (void)updateViewsWithTrackInformation;
- (void)hideNowPlaying:(BOOL)animated;
- (void)showNowPlaying:(BOOL)animated;
- (void)adjustLabels;
- (IBAction)togglePlayState:(id)sender;
- (void)createStreamer;
- (void)destroyStreamer;
- (void)playbackStateChanged:(NSNotification *)aNotification;
- (void)presentStreamerAlert:(NSNotification *)aNotification;
- (void)presentChannels;

@end
