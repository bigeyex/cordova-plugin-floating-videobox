/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import "CDVFloatingVideobox.h"
#import <Cordova/CDVViewController.h>
#import <Cordova/NSDictionary+CordovaPreferences.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <objc/message.h>
#import <netinet/in.h>


#define LOCAL_FILESYSTEM_PATH   @"local-filesystem"
#define ASSETS_LIBRARY_PATH     @"assets-library"
#define ERROR_PATH              @"error"

@interface CDVFloatingVideobox()
@end


@implementation CDVFloatingVideobox

- (void) pluginInitialize {
    self.floatingBoxView = [[MBFloatingVideoBoxView alloc] init];
    [ [ [ self viewController ] view ] addSubview:self.floatingBoxView];
    self.floatingBoxView.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prevButtonCallback) name:@"MBVideoBoxPrevButtonTapped" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nextButtonCallback) name:@"MBVideoBoxNextButtonTapped" object:nil];
}

- (void)setAttribute : (CDVInvokedUrlCommand*)command {
    NSString* key = [command.arguments objectAtIndex:0];
    NSString* value = [command.arguments objectAtIndex:1];
    
    if([key isEqualToString:@"showPrevButton"]) {
        self.floatingBoxView.prevButton.hidden = ![value boolValue];
    }
    else if([key isEqualToString:@"showNextButton"]) {
        self.floatingBoxView.nextButton.hidden = ![value boolValue];
    }
    else if([key isEqualToString:@"fullscreen"]) {
        if([value boolValue]) {
            [self.floatingBoxView enterFullScreen];
        }
        else {
            [self.floatingBoxView exitFullScreen];
        }
    }
    else if([key isEqualToString:@"x"]) {
        self.floatingBoxView.videoOnlyX = [value intValue];
    }
    else if([key isEqualToString:@"y"]) {
        self.floatingBoxView.videoOnlyY = [value intValue];
    }
    else if([key isEqualToString:@"width"]) {
        self.floatingBoxView.videoOnlyWidth = [value intValue];
    }
    else if([key isEqualToString:@"height"]) {
        self.floatingBoxView.videoOnlyHeight = [value intValue];
    }
    else if([key isEqualToString:@"videoonly"]) {
        self.floatingBoxView.isVideoOnly = [value boolValue];
        [self.floatingBoxView layoutSubviews];
    }
    else if([key isEqualToString:@"showStepText"]) {
        self.floatingBoxView.stepTextView.hidden = ![value boolValue];
    }
    else if([key isEqualToString:@"setStepText"]) {
        [self.floatingBoxView setStepText:value];
    }
}

- (void)show : (CDVInvokedUrlCommand*)command {
    self.floatingBoxView.hidden = NO;
    [self.floatingBoxView resumeVideo];
}

- (void)hide : (CDVInvokedUrlCommand*)command {
    self.floatingBoxView.hidden = YES;
    [self.floatingBoxView pauseVideo];
}

- (void)playBundleVideo : (CDVInvokedUrlCommand*)command {
    [self.floatingBoxView playBundleVideo:[command.arguments objectAtIndex:0]];
}
- (void)onPrevButton : (CDVInvokedUrlCommand*)command {
    self.onPrevJsCallback = command.callbackId;
}

- (void)onNextButton : (CDVInvokedUrlCommand*)command {
    self.onNextJsCallback = command.callbackId;
}

- (void)prevButtonCallback {
    if(self.onPrevJsCallback) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:self.onPrevJsCallback];
    }
}

- (void)nextButtonCallback {
    if(self.onPrevJsCallback) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:self.onNextJsCallback];
    }
}

@end
