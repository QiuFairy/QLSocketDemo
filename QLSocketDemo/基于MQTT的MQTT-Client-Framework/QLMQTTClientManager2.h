//
//  QLMQTTClientManager2.h
//  QLSocketDemo
//
//  Created by qiu on 2019/5/9.
//  Copyright © 2019 qiu. All rights reserved.
//

/*!
 先连接
 再订阅
 在发送消息
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QLMQTTClientManager2 : NSObject
+ (instancetype)Instance;

#pragma mark - 连接
- (void)bindSessionManager;

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
- (void)sendDataToTopic:(NSString *)topic msg:(NSString *)msg;
@end

NS_ASSUME_NONNULL_END
