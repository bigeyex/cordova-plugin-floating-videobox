//
//  MBAVPlayerView.m
//  FloatingVideoboxTest
//
//  Created by Gavin Li on 2018/9/24.
//  Copyright © 2018 Gavin Li. All rights reserved.
//

#import "MBAVPlayerView.h"

@implementation MBAVPlayerView {
    bool _wasPlayingBeforeEnterBackground;
    bool _wasPlayingBeforeInterrupted;
}

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
    
    self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(savePlayingStateBeforeEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tapRecognizer];

}


- (void)itemDidFinishPlaying:(NSNotification *)notification {
    AVPlayerItem *player = [notification object];
    [player seekToTime:kCMTimeZero];
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        [self.avPlayer play];
    }
}

- (void)playVideoWithURL: (NSURL*)url {
    if(url) {
        [self.avPlayer replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:url]];
        [self.avPlayer play];
    }
    
}

- (void)savePlayingStateBeforeEnterBackground {
    _wasPlayingBeforeEnterBackground = [self isPlayerPlaying];
}

- (void)resumePlayWhenReenterForeground {
    if(_wasPlayingBeforeEnterBackground) {
        [self.avPlayer play];
    }
}

- (void)handleAudioSessionInterruption:(NSNotification*)notification {
    
    NSNumber *interruptionType = [[notification userInfo] objectForKey:AVAudioSessionInterruptionTypeKey];
    NSNumber *interruptionOption = [[notification userInfo] objectForKey:AVAudioSessionInterruptionOptionKey];
    
    switch (interruptionType.unsignedIntegerValue) {
        case AVAudioSessionInterruptionTypeBegan:{
            _wasPlayingBeforeInterrupted = [self isPlayerPlaying];
        } break;
        case AVAudioSessionInterruptionTypeEnded:{
            // • Make session active
            // • Update user interface
            // • AVAudioSessionInterruptionOptionShouldResume option
            [[AVAudioSession sharedInstance] setActive: YES error: nil];
            if (interruptionOption.unsignedIntegerValue == AVAudioSessionInterruptionOptionShouldResume) {
                // Here you should continue playback.
                if(_wasPlayingBeforeInterrupted){
                    [self.avPlayer play];
                }
            }
        } break;
        default:
            break;
    }
}

- (bool)isPlayerPlaying {
    return (self.avPlayer.rate != 0) && (self.avPlayer.error == nil);
}


@end
