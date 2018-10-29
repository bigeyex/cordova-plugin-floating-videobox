//
//  MBFloatingVideoBoxView.m
//  FloatingVideoboxTest
//
//  Created by Gavin Li on 2018/9/24.
//  Copyright © 2018 Gavin Li. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "MBFloatingVideoBoxView.h"
#import "UIView+draggable.h"


@implementation MBFloatingVideoBoxView {
    int _iphoneXSensorInsetLength;
    UIButton * _replayButton;
}

static int defaultVideoWidth = 320;
static int defaultVideoHeight = 240;
static int boxMargin = 4;
static int bottomPaneHeight = 48;
static int buttonSizeS = 50;
static int buttonSizeXS = 30;
static int buttonSizeL = 66;
static int finishButtonWidth = 304;
static int controlMargin = 6;
static int textHeight = 44;
static int textFontSize = 22;
static int fullScreenBottomMargin = 46;
static int fullScreenCornerButtonMargin = 24;

static float fullscreenButtonHeightRatioNormal = 0.125;
static float fullscreenButtonHeightRatioFullScreen = 0.0704;
static float fullscreenButtonMarginHeightRatioNormal = 0.0459;
static float fullscreenButtonMarginHeightRatioFullScreen = 0.0261;

static float replayButtonHeightRatioNormal = 0.275;
static float replayButtonHeightRatioFullScreen = 0.1107;

- (instancetype)init {
    [self updateMetricByDevice];
    self = [super initWithFrame:[self getWindowedFrame]];
    if (self) {
        [self initFrameLayout];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoFinishPlay) name:@"MBVideoPlayFinished" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoStartPlay) name:@"MBVideoPlayStarted" object:nil];
    }
    return self;
}

- (void)initFrameLayout {
    self.layer.cornerRadius = 0;

    self.avPlayerView = [[MBAVPlayerView alloc] init];
    self.avPlayerView.autoReplay = NO;
    [self addSubview:self.avPlayerView];
    
    self.fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.fullScreenButton addTarget:self action:@selector(toggleFullscreen) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.fullScreenButton];
    
    _replayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_replayButton addTarget:self action:@selector(replay) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_replayButton];

    self.layer.masksToBounds = NO;
    self.backgroundColor = [UIColor clearColor];
    
    [self layoutSubviews];
    [self enableDragging];
    
}

- (void)onVideoFinishPlay {
    _replayButton.hidden = NO;
}

- (void)onVideoStartPlay {
    _replayButton.hidden = YES;
}

- (void)clearShadow {
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowColor = [[UIColor clearColor] CGColor];
    self.layer.cornerRadius = 0.0f;
    self.layer.shadowRadius = 0.0f;
    self.layer.shadowOpacity = 0.00f;
}

- (void)makeShadow {
    self.layer.shadowRadius  = 5;
    self.layer.shadowColor   = [UIColor colorWithRed:53/255.0 green:178/255.0 blue:226/255.0 alpha:1].CGColor;
    self.layer.shadowOffset  = CGSizeMake(0.0, 0.0);
    self.layer.shadowOpacity = 0.3;//0.9f;
    
    UIEdgeInsets shadowInsets     = UIEdgeInsetsMake(0, 0, -1.5f, 0);
    UIBezierPath *shadowPath      = [UIBezierPath bezierPathWithRect:UIEdgeInsetsInsetRect(self.bounds, shadowInsets)];
    self.layer.shadowPath    = shadowPath.CGPath;
}

- (void)drawToggleFullScreenButton {
    float buttonSize = 0;
    float buttonMargin = 0;
    if (self.isFullScreen) {
        buttonSize = self.bounds.size.height * fullscreenButtonHeightRatioFullScreen;
        buttonMargin = self.bounds.size.height * fullscreenButtonMarginHeightRatioFullScreen;
        [self.fullScreenButton setImage:[UIImage imageNamed:@"icon-video-big-fullscreen.png"] forState:UIControlStateNormal];
    }
    else {
        buttonSize = self.bounds.size.height * fullscreenButtonHeightRatioNormal;
        buttonMargin = self.bounds.size.height * fullscreenButtonMarginHeightRatioNormal;
        [self.fullScreenButton setImage:[UIImage imageNamed:@"icon-video-small-fullscreen.png"] forState:UIControlStateNormal];
    }
    
    self.fullScreenButton.frame = CGRectMake(self.bounds.size.width - (buttonSize + buttonMargin), buttonMargin, buttonSize, buttonSize);
    self.fullScreenButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)drawReplayButton {
    float replayButtonSize = 0;
    if (self.isFullScreen) {
        replayButtonSize = self.bounds.size.height * replayButtonHeightRatioFullScreen;
    }
    else {
        replayButtonSize = self.bounds.size.height * replayButtonHeightRatioNormal;
    }
    
    [_replayButton setImage:[UIImage imageNamed:@"icon-video-replay.png"] forState:UIControlStateNormal];
    _replayButton.contentMode = UIViewContentModeScaleAspectFit;
    _replayButton.frame = CGRectMake((self.bounds.size.width - replayButtonSize)/2, (self.bounds.size.height - replayButtonSize)/2, replayButtonSize, replayButtonSize);
}

- (void)drawVideoOnly {
    self.frame = CGRectMake(self.videoOnlyX, self.videoOnlyY, self.videoOnlyWidth, self.videoOnlyHeight);
    self.fullScreenButton.frame = CGRectZero;
    _replayButton.frame = CGRectZero;
    self.avPlayerView.frame = self.bounds;
    
    self.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    [self clearShadow];
}

- (void)drawFullScreen {
    self.avPlayerView.frame = self.bounds;
    [self drawToggleFullScreenButton];
    [self drawReplayButton];
    self.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor blackColor];
    [self clearShadow];
}

- (void)drawNormal {
    self.avPlayerView.frame = CGRectMake(boxMargin, boxMargin, self.bounds.size.width-2*boxMargin, self.bounds.size.height-2*boxMargin);
    [self drawToggleFullScreenButton];
    [self drawReplayButton];
    self.layer.masksToBounds = NO;
    self.backgroundColor = [UIColor whiteColor];
    [self makeShadow];
}

- (void)layoutSubviews {
    if(self.isVideoOnly) {
        [self drawVideoOnly];
        self.avPlayerView.autoReplay = YES;
        [self setDraggable:NO];
    }
    else if(self.isFullScreen) {
        self.avPlayerView.autoReplay = NO;
        [self drawFullScreen];
    }
    else {
        self.avPlayerView.autoReplay = NO;
        [self drawNormal];
    }
    
}

- (void)setStepText:(NSString*)text {
    self.stepTextView.text = text;
    [self calculateStepTextDimension];
}

- (void)calculateStepTextDimension {
    [self.stepTextView sizeToFit];
    self.stepTextView.frame = CGRectMake(self.bounds.size.width/2-self.stepTextView.frame.size.width/2, self.bounds.size.height-self.stepTextView.frame.size.height-boxMargin-controlMargin, self.stepTextView.frame.size.width, self.stepTextView.frame.size.height);
}

- (void)enterVideoOnlyMode {
    
}

- (void)enterFullScreen {
    self.isFullScreen = YES;
    self.frame = [[UIApplication sharedApplication].windows.lastObject frame];
    [self layoutSubviews];
    [self setDraggable:NO];
}

- (void)exitFullScreen {
    self.isFullScreen = NO;
    self.frame = [self getWindowedFrame];
    [self layoutSubviews];
    [self setDraggable:YES];
}

- (void)toggleFullscreen {
    if(!self.isFullScreen) {
        [self enterFullScreen];
    }
    else {
        [self exitFullScreen];
    }
}

- (void)replay {
    [self.avPlayerView replayCurrentVideo];
}

- (CGRect)getWindowedFrame {
    CGRect windowFrame = [[UIApplication sharedApplication].windows.lastObject frame];
    int calculatedWidth = defaultVideoWidth + 2 * boxMargin;
//    int calculatedHeight = defaultVideoHeight + boxMargin + bottomPaneHeight;
    int calculatedHeight = defaultVideoHeight + 2 * boxMargin;
    return CGRectMake(windowFrame.size.width-calculatedWidth-_iphoneXSensorInsetLength, 0, calculatedWidth, calculatedHeight);
}

- (bool)isIPhoneX {
    return [[UIScreen mainScreen] bounds].size.height == 375.0; // this is iPhone X height in landscape
}

- (void)updateMetricByDevice {
    if ( UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad )
    {
        defaultVideoWidth = defaultVideoWidth/1.5;
        defaultVideoHeight = defaultVideoHeight/1.5;
        boxMargin = boxMargin/1.5;
        bottomPaneHeight = bottomPaneHeight/1.5;
        buttonSizeS = buttonSizeS/1.5;
        buttonSizeXS = buttonSizeXS/1.5;
        buttonSizeL = buttonSizeL/1.5;
        finishButtonWidth = finishButtonWidth/1.5;
        controlMargin = controlMargin/1.5;
        textHeight = textHeight/1.5;
        textFontSize = textFontSize/1.5;
        fullScreenBottomMargin = fullScreenBottomMargin/1.5;
        fullScreenCornerButtonMargin = fullScreenCornerButtonMargin/1.5;
        _iphoneXSensorInsetLength = [self isIPhoneX] ? 50 : 0;
    }
    
}

- (void)onPrevButtonTapped {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MBVideoBoxPrevButtonTapped" object:nil];
}

- (void)onNextButtonTapped {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MBVideoBoxNextButtonTapped" object:nil];
}

- (void)playBundleVideo: (NSString*)location {
    NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[[NSBundle mainBundle] resourceURL], location]];
    [self.avPlayerView playVideoWithURL:fileURL];
}

- (void)pauseVideo {
    [self.avPlayerView.avPlayer pause];
}

- (void)resumeVideo {
    [self.avPlayerView.avPlayer play];
}


@end
