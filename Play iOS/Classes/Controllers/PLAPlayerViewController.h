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
#import <MediaPlayer/MediaPlayer.h>
#import "MarqueeLabel.h"

@interface PLAPlayerViewController : UIViewController <SDWebImageDownloaderDelegate>{
  UILabel *songLabel;
  MarqueeLabel *artistLabel;
  UIImageView *albumArtImageView;
  UIButton *playButton;
  UIButton *channelsButton;
  UIButton *starButton;
  UIView *nowPlayingView;
  UIView *sliderView;
  UILabel *volumeDownLabel;
  UILabel *volumeUpLabel;
	AudioStreamer *streamer;
  MPVolumeView *volumeView;
  MPVolumeView *airplayView;
}

@property (retain, nonatomic) IBOutlet UILabel *songLabel;
@property (retain, nonatomic) IBOutlet MarqueeLabel *artistLabel;
@property (retain, nonatomic) IBOutlet UIImageView *albumArtImageView;
@property (retain, nonatomic) IBOutlet UIButton *playButton;
@property (retain, nonatomic) IBOutlet UIButton *channelsButton;
@property (retain, nonatomic) IBOutlet UIButton *starButton;
@property (retain, nonatomic) IBOutlet UILabel *volumeDownLabel;
@property (retain, nonatomic) IBOutlet UILabel *volumeUpLabel;
@property (retain, nonatomic) IBOutlet MPVolumeView *volumeView;
@property (retain, nonatomic) IBOutlet MPVolumeView *airplayView;

- (void)setUpForStreaming;
- (void)presentLogIn;
- (void)updateMetaData;
- (void)updateViewsWithTrackInformation;
- (void)hideNowPlaying:(BOOL)animated;
- (void)showNowPlaying:(BOOL)animated;
- (void)toggleViews:(BOOL)hidden;
- (IBAction)togglePlayState:(id)sender;
- (void)createStreamer;
- (void)destroyStreamer;
- (void)playbackStateChanged:(NSNotification *)aNotification;
- (void)presentStreamerAlert:(NSNotification *)aNotification;
- (IBAction)presentChannels;
- (void)adjustStarButton:(BOOL)isLiked;
- (PLATrack *)currentTrack;

@end
