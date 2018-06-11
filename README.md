# react-native-sf-push

# 基于友盟推送

# 安装
> npm i react-native-sf-umpush

# 用法
1. 低级用法  
* 将GitHub上SFPUSh文件下载并拽入IOS工程 在appdelegate中添加下列示例代码 
* 引入的库:
  CoreTelephony.framework 
  libz.tbd 
  libsqlite3.tbd 
  SystemConfiguration.framework 
  UserNotifications.framework
* target中 capabilities中 将background modes中的 remote notications点上对号 push notification 点开
* 下载友盟的push框架导入工程
* 去配置P12证书 (添加APP ID 与你工程的bundle必须一样, 创建生产或开发证书推送证书,并导入钥匙串颁发机构证书, 添加测试设备(测试用), 生成p12描述文件 玩去吧~)
* 测试模式推送(上线之后忽略)
* 在JS文件中添加监听 信息会传入JS 详细见下面JS代码 

2.高级用法
* 在 React-native工程中添加 alias或者tag等 详细见下面Reactnative代码

# IOS 例子
```
/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "AppDelegate.h"

#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import <UMPush/UMessage.h>
#import <UMCommon/UMCommon.h>
#import "SFUmPush.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  NSURL *jsCodeLocation;
  jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
  RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                      moduleName:@"RNPush"
                                               initialProperties:nil
                                                   launchOptions:launchOptions];
  rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];

  
  
  //友盟注册
  [UMConfigure initWithAppkey:@"5b1892c0b27b0a334700008e" channel:@"App Store"];
  //推送配置
  [[SFUmPush share] setPushConfig:launchOptions];
  
  return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
  NSString *deviceTokenString = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""]
                          stringByReplacingOccurrencesOfString:@">"withString:@""]stringByReplacingOccurrencesOfString:@" "withString:@""];
  NSLog(@"本地存储deviceToken = %@", deviceTokenString);
}


//iOS10以下使用这两个方法接收通知
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
  [[SFUmPush share] userNoficationApplication:application didReceiveRemoteNotification:userInfo];
  completionHandler(UIBackgroundFetchResultNewData);
}

//iOS10新增：处理前台收到通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center
      willPresentNotification:(UNNotification *)notification
        withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
  [[SFUmPush share] userNotificationOfForeGround:center didNotificationResponse:notification];
  completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert);
}
//iOS10新增：处理后台点击通知的代理方法
- (void) userNotificationCenter:(UNUserNotificationCenter *)center
 didReceiveNotificationResponse:(UNNotificationResponse *)response
          withCompletionHandler:(void (^)(void))completionHandler{
  [[SFUmPush share] userNotificationOfBackGround:center didNotificationResponse:response];
}
@end
```

# JS 例子
```
/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, {Component} from 'react';
import {
    Text,
    View,
    NativeModules,
    NativeEventEmitter,
} from 'react-native';

var nativeBridge = NativeModules.SFUmPush;
const NativeModule = new NativeEventEmitter(nativeBridge);
import SFPush from './react-native-sf-umpush/src/SFPush'

type Props = {};
export default class App extends Component<Props> {
    render() {
        return (
            <View style={styles.container}>
                <Text style={styles.welcome}>
                    Welcome to React Native!
                </Text>
            </View>
        );
    }


    componentWillMount() {
        SFPush.addTag('热血');
    }

    componentDidMount() {
        this.subscription = NativeModule.addListener('userNotification', (data) => {
            console.log(data)
        });
    }


    componentWillUnmount() {
        this.subscription.remove()
    }
}


```

