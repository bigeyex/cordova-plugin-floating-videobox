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
    
    // NSString *filepath = [[NSBundle mainBundle] pathForResource:@"testvideo" ofType:@"mp4"];
    // NSURL *fileURL = [NSURL fileURLWithPath:filepath];
    // [self.avPlayer replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:fileURL]];
    // [self.avPlayer play];
}


- (void)itemDidFinishPlaying:(NSNotification *)notification {
    AVPlayerItem *player = [notification object];
    [player seekToTime:kCMTimeZero];
}


@end
