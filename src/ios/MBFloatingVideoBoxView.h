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
@property (nonatomic) UITextView *stepTextView;

@property (nonatomic) bool isFullScreen;
@property (nonatomic) bool isFinishButtonVisible;

- (void)enterFullScreen;
- (void)exitFullScreen;

@end

NS_ASSUME_NONNULL_END
