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
- (GCDWebServerResponse*)_responseWithContentsOfDirectory:(NSString*)path;
@end


@implementation CDVFloatingVideobox

- (void) pluginInitialize {
    self.floatingBoxView = [[MBFloatingVideoBoxView alloc] init];
    [ [ [ self viewController ] view ] addSubview:self.floatingBoxView];
    self.floatingBoxView.hidden = YES;
}

- (void)setAttribute : (CDVInvokedUrlCommand*)command {
    NSString* key = [command.arguments objectAtIndex:0];
    NSString* value = [command.arguments objectAtIndex:1];
}
- (void)playVideo : (CDVInvokedUrlCommand*)command {
    
}
- (void)onPrevButton : (CDVInvokedUrlCommand*)command {
    
}
- (void)onNextButton : (CDVInvokedUrlCommand*)command {
    
}

@end
