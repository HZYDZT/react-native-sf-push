//
//  SFUmPush.h
//  RNPush
//
//  Created by SmartFun on 2018/6/7.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

#import <React/RCTEventEmitter.h>
#import <UserNotifications/UserNotifications.h>
@interface SFUmPush : RCTEventEmitter<RCTBridgeModule>

+ (SFUmPush *)share;

- (void)userNotificationOfBackGround:(UNUserNotificationCenter *)center
             didNotificationResponse:(UNNotificationResponse *)response;

- (void)userNotificationOfForeGround:(UNUserNotificationCenter *)center
             didNotificationResponse:(UNNotification *)response
                            msgBlock:(void (^)(UNNotificationPresentationOptions))block;

- (void)userNoficationApplication:(UIApplication *)application
     didReceiveRemoteNotification:(NSDictionary *)userInfo;

- (void)setPushConfig:(NSDictionary *)launchOptions;

@end
