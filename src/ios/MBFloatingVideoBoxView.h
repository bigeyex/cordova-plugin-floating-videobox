//
//  MBFloatingVideoBoxView.h
//  FloatingVideoboxTest
//
//  Created by Gavin Li on 2018/9/24.
//  Copyright © 2018 Gavin Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBAVPlayerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MBFloatingVideoBoxView : UIView



@property (nonatomic) MBAVPlayerView *avPlayerView;
@property (nonatomic) UIButton *fullScreenButton;
@property (nonatomic) UIButton *prevButton;
@property (nonatomic) UIButton *nextButton;
@property (nonatomic) UIButton *finishButton;
@property (nonatomic) UILabel *stepTextView;

@property (nonatomic) bool isFullScreen;
@property (nonatomic) bool isVideoOnly;
@property (nonatomic) bool isFinishButtonVisible;
@property (nonatomic) int videoOnlyX;
@property (nonatomic) int videoOnlyY;
@property (nonatomic) int videoOnlyWidth;
@property (nonatomic) int videoOnlyHeight;


- (void)enterFullScreen;
- (void)exitFullScreen;
- (void)setStepText:(NSString*)text;
- (void)playBundleVideo: (NSString*)location;
- (void)pauseVideo;
- (void)resumeVideo;

@end

NS_ASSUME_NONNULL_END
