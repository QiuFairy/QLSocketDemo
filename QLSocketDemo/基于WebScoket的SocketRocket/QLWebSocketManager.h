//
//  QLWebSocketManager.h
//  QLSocketDemo
//
//  Created by qiu on 2019/5/9.
//  Copyright © 2019 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    disConnectByUser = 1000,
    disConnectByServer,
} DisConnectType;


@interface QLWebSocketManager : NSObject
+ (instancetype)Instance;

- (void)connect;
- (void)disConnect;

- (void)sendMsg:(NSString *)msg;

- (void)ping;

@end

NS_ASSUME_NONNULL_END
