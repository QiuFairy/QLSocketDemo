//
//  QLSocketManager.h
//  QLScoketDemo
//
//  Created by qiu on 2019/5/9.
//  Copyright © 2019 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QLSocketManager : NSObject
+ (instancetype)Instance;
- (void)connect;
- (void)disConnect;
- (void)sendMsg:(NSString *)msg;
@end

NS_ASSUME_NONNULL_END
