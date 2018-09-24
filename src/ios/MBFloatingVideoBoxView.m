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


@implementation MBFloatingVideoBoxView

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

- (instancetype)init {
    [self updateMetricByDevice];
    self = [super initWithFrame:[self getWindowedFrame]];
    if (self) {
        [self initFrameLayout];
    }
    return self;
}

- (void)initFrameLayout {
    self.backgroundColor = [UIColor colorWithRed:53/255.0 green:178/255.0 blue:226/255.0 alpha:1];
    self.layer.cornerRadius = 5;

    self.avPlayerView = [[MBAVPlayerView alloc] init];
    [self addSubview:self.avPlayerView];
    
    self.fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.fullScreenButton addTarget:self action:@selector(toggleFullscreen) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.fullScreenButton];
    self.prevButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.prevButton];
    self.nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.nextButton];
    self.stepTextView = [[UITextView alloc] init];
    self.stepTextView.text = @"2/3";
    self.stepTextView.font = [UIFont systemFontOfSize:textFontSize];
    self.stepTextView.textColor = [UIColor whiteColor];
    self.stepTextView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.stepTextView];

    
    [self layoutSubviews];
    [self enableDragging];
}


- (void)layoutSubviews {
    if(self.isFullScreen) {
        self.layer.masksToBounds = false;
        self.avPlayerView.frame = self.bounds;
        self.avPlayerView.layer.cornerRadius = 0;
        [self.fullScreenButton setImage:[UIImage imageNamed:@"icon-video-big-fullscreen.png"] forState:UIControlStateNormal];
        self.fullScreenButton.frame = CGRectMake(self.bounds.size.width-buttonSizeL-fullScreenCornerButtonMargin, fullScreenCornerButtonMargin, buttonSizeL, buttonSizeL);
        [self.prevButton setImage:[UIImage imageNamed:@"icon-video-big-prev.png"] forState:UIControlStateNormal];
        self.prevButton.frame = CGRectMake(controlMargin*2, self.bounds.size.height/2-buttonSizeL/2, buttonSizeL, buttonSizeL);
        [self.nextButton setImage:[UIImage imageNamed:@"icon-video-big-next.png"] forState:UIControlStateNormal];
        self.nextButton.frame = CGRectMake(self.bounds.size.width-buttonSizeL-controlMargin*2, self.bounds.size.height/2-buttonSizeL/2, buttonSizeL, buttonSizeL);
        
        self.stepTextView.hidden = YES;
    }
    else {
        self.layer.masksToBounds = true;
        self.avPlayerView.frame = CGRectMake(boxMargin, boxMargin, self.bounds.size.width-2*boxMargin, self.bounds.size.height-boxMargin-bottomPaneHeight);
        [self.fullScreenButton setImage:[UIImage imageNamed:@"icon-video-small-fullscreen.png"] forState:UIControlStateNormal];
        self.fullScreenButton.frame = CGRectMake(self.bounds.size.width-buttonSizeS-boxMargin, boxMargin, buttonSizeS, buttonSizeS);
        [self.prevButton setImage:[UIImage imageNamed:@"icon-video-small-prev.png"] forState:UIControlStateNormal];
        self.prevButton.frame = CGRectMake(boxMargin+controlMargin, self.bounds.size.height-boxMargin-controlMargin-buttonSizeXS, buttonSizeXS, buttonSizeXS);
        [self.nextButton setImage:[UIImage imageNamed:@"icon-video-small-next.png"] forState:UIControlStateNormal];
        self.nextButton.frame = CGRectMake(self.bounds.size.width-buttonSizeXS-boxMargin-controlMargin, self.bounds.size.height-boxMargin-controlMargin-buttonSizeXS, buttonSizeXS, buttonSizeXS);

        self.stepTextView.hidden = NO;
        [self.stepTextView sizeToFit];
        self.stepTextView.frame = CGRectMake(self.bounds.size.width/2-self.stepTextView.frame.size.width/2, self.bounds.size.height-textHeight-boxMargin,
                                             self.stepTextView.frame.size.width, self.stepTextView.frame.size.height);
    }
    
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

- (CGRect)getWindowedFrame {
    CGRect windowFrame = [[UIApplication sharedApplication].windows.lastObject frame];
    int calculatedWidth = defaultVideoWidth + 2*boxMargin;
    int calculatedHeight = defaultVideoHeight + boxMargin + bottomPaneHeight;
    return CGRectMake(windowFrame.size.width-calculatedWidth, 0, calculatedWidth, calculatedHeight);
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
    }
    
}

@end
