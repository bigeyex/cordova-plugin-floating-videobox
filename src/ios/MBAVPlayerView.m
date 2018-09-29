//
//  MBAVPlayerView.m
//  FloatingVideoboxTest
//
//  Created by Gavin Li on 2018/9/24.
//  Copyright © 2018 Gavin Li. All rights reserved.
//

#import "MBAVPlayerView.h"

@implementation MBAVPlayerView

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self layoutFrame];
    }
    return self;
}

- (void)layoutFrame {

    self.avPlayer = [[AVPlayer alloc] init];
    self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    AVPlayerLayer *videoLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    videoLayer.frame = self.bounds;
    videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [(AVPlayerLayer *)self.layer setPlayer:self.avPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.avPlayer currentItem]];
    
    NSError *error = [[NSError alloc] init];
    AVAudioSession *aSession = [AVAudioSession sharedInstance];
    [aSession setCategory:AVAudioSessionCategoryPlayback
              withOptions:AVAudioSessionCategoryOptionAllowBluetooth
                    error:&error];
    [aSession setMode:AVAudioSessionModeDefault error:&error];
    [aSession setActive: YES error: &error];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAudioSessionInterruption:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:aSession];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resumePlayWhenReenterForeground)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
}


- (void)itemDidFinishPlaying:(NSNotification *)notification {
    AVPlayerItem *player = [notification object];
    [player seekToTime:kCMTimeZero];
}

- (void)playVideoWithURL: (NSURL*)url {
    if(url) {
        [self.avPlayer replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:url]];
        [self.avPlayer play];
    }
    
}

- (void)resumePlayWhenReenterForeground {
    [self.avPlayer play];
}

- (void)handleAudioSessionInterruption:(NSNotification*)notification {
    
    NSNumber *interruptionType = [[notification userInfo] objectForKey:AVAudioSessionInterruptionTypeKey];
    NSNumber *interruptionOption = [[notification userInfo] objectForKey:AVAudioSessionInterruptionOptionKey];
    
    switch (interruptionType.unsignedIntegerValue) {
        case AVAudioSessionInterruptionTypeBegan:{
            // • Audio has stopped, already inactive
            // • Change state of UI, etc., to reflect non-playing state
        } break;
        case AVAudioSessionInterruptionTypeEnded:{
            // • Make session active
            // • Update user interface
            // • AVAudioSessionInterruptionOptionShouldResume option
            if (interruptionOption.unsignedIntegerValue == AVAudioSessionInterruptionOptionShouldResume) {
                // Here you should continue playback.
                [self.avPlayer play];
            }
        } break;
        default:
            break;
    }
}


@end
