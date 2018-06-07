//
//  SFUmPush.m
//  RNPush
//
//  Created by SmartFun on 2018/6/7.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "SFUmPush.h"
#import <UMPush/UMessage.h>

@implementation SFUmPush

+ (SFUmPush *)share{
  static SFUmPush *_obj;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _obj = [SFUmPush new];
  });
  return _obj;
}

+ (id)allocWithZone:(NSZone *)zone {
  static SFUmPush *_obj = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _obj = [super allocWithZone:zone];
    [UMessage setAutoAlert:NO];
  });
  return _obj;
}

RCT_EXPORT_MODULE();

- (void)setPushConfig:(NSDictionary *)launchOptions{
  // Push功能配置
  UMessageRegisterEntity * entity = [[UMessageRegisterEntity alloc] init];
  entity.types = UMessageAuthorizationOptionBadge|UMessageAuthorizationOptionAlert|UMessageAuthorizationOptionSound;
  //如果你期望使用交互式(只有iOS 8.0及以上有)的通知，请参考下面注释部分的初始化代码
  if (([[[UIDevice currentDevice] systemVersion]intValue]>=8)&&([[[UIDevice currentDevice] systemVersion]intValue]<10)) {
    UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc] init];
    action1.identifier = @"action1_identifier";
    action1.title=@"打开应用";
    action1.activationMode = UIUserNotificationActivationModeForeground;//当点击的时候启动程序
    UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];  //第二按钮
    action2.identifier = @"action2_identifier";
    action2.title=@"忽略";
    action2.activationMode = UIUserNotificationActivationModeBackground;//当点击的时候不启动程序，在后台处理
    action2.authenticationRequired = YES;//需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
    action2.destructive = YES;
    UIMutableUserNotificationCategory *actionCategory1 = [[UIMutableUserNotificationCategory alloc] init];
    actionCategory1.identifier = @"category1";//这组动作的唯一标示
    [actionCategory1 setActions:@[action1,action2] forContext:(UIUserNotificationActionContextDefault)];
    NSSet *categories = [NSSet setWithObjects:actionCategory1, nil];
    entity.categories=categories;
  }
  //如果要在iOS10显示交互式的通知，必须注意实现以下代码
  if ([[[UIDevice currentDevice] systemVersion]intValue]>=10) {
    UNNotificationAction *action1_ios10 = [UNNotificationAction actionWithIdentifier:@"action1_identifier" title:@"打开应用" options:UNNotificationActionOptionForeground];
    UNNotificationAction *action2_ios10 = [UNNotificationAction actionWithIdentifier:@"action2_identifier" title:@"忽略" options:UNNotificationActionOptionForeground];
    //UNNotificationCategoryOptionNone
    //UNNotificationCategoryOptionCustomDismissAction  清除通知被触发会走通知的代理方法
    //UNNotificationCategoryOptionAllowInCarPlay       适用于行车模式
    UNNotificationCategory *category1_ios10 = [UNNotificationCategory categoryWithIdentifier:@"category1" actions:@[action1_ios10,action2_ios10]   intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
    NSSet *categories = [NSSet setWithObjects:category1_ios10, nil];
    entity.categories=categories;
  }
  [UNUserNotificationCenter currentNotificationCenter].delegate=self;
  [UMessage registerForRemoteNotificationsWithLaunchOptions:launchOptions Entity:entity completionHandler:^(BOOL granted, NSError * _Nullable error) {
    if (granted) {
    }else{
    }
  }];
}

- (NSArray<NSString *> *)supportedEvents {
  return @[@"userNotification"]; //这里返回的将是你要发送的消息名的数组。
}

- (void)userNoficationApplication:(UIApplication *)application
     didReceiveRemoteNotification:(NSDictionary *)userInfo
{
  if([[[UIDevice currentDevice] systemVersion]intValue] < 10){
    [UMessage didReceiveRemoteNotification:userInfo];
    [self sendEventWithName:@"userNotification"
                       body:userInfo];
  }
}

- (void)userNotificationOfBackGround:(UNUserNotificationCenter *)center
             didNotificationResponse:(UNNotificationResponse *)response
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
  NSDictionary *userInfo = response.notification.request.content.userInfo;
  if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
    //应用处于后台时的远程推送接受
    //必须加这句代码
    [UMessage didReceiveRemoteNotification:userInfo];
    [self sendEventWithName:@"userNotification"
                       body:userInfo];
  }else{
    //应用处于后台时的本地推送接受

  }
#else
    //<8.0
#endif
  
}

- (void)userNotificationOfForeGround:(UNUserNotificationCenter *)center
             didNotificationResponse:(UNNotification *)response
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
  NSDictionary *userInfo = response.request.content.userInfo;
  if([response.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
    [UMessage setAutoAlert:NO];
    //应用处于前台时的远程推送接受
    //必须加这句代码
    [UMessage didReceiveRemoteNotification:userInfo];
    [self sendEventWithName:@"userNotification"
                       body:userInfo];
  }else{
    //应用处于前台时的本地推送接受
  }
#else
  //<10.0
#endif
}


@end
