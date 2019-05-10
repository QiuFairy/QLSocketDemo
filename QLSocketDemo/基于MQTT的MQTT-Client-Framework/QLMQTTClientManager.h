//
//  QLMQTTClientManager.h
//  QLSocketDemo
//
//  Created by qiu on 2019/5/9.
//  Copyright © 2019 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QLMQTTClientManager : NSObject
+ (instancetype)Instance;

#pragma mark - 登录 解绑
- (void)bindWithUserName:(NSString *)username password:(NSString *)password epoch:(long long)epoch;

- (void)disconnect;

- (void)reConnect;

#pragma mark - 订阅命令
/**
 订阅设备inf、res、sys三种topic
 */
- (void)subscribeTopic:(NSString *)topic;

#pragma mark - 取消订阅
/**
 取消订阅设备inf、res、sys三种topic
 */
- (void)unsubscribeTopic:(NSString *)topic;

#pragma mark - 发送消息
- (void)switchWithDevice;
@end

NS_ASSUME_NONNULL_END
