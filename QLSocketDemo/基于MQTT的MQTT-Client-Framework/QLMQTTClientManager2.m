//
//  QLMQTTClientManager2.m
//  QLSocketDemo
//
//  Created by qiu on 2019/5/9.
//  Copyright © 2019 qiu. All rights reserved.
//

#import "QLMQTTClientManager2.h"
#import "Header.h"

#import <MQTTClient.h>
@interface QLMQTTClientManager2()<MQTTSessionManagerDelegate>

@property (nonatomic,strong) MQTTSessionManager *mySessionManager;

@property (nonatomic,copy) NSString *username;
@property (nonatomic,copy) NSString *password;
@property (nonatomic,copy) NSString *cliendId;

//订阅的topic
@property (nonatomic,strong) NSMutableDictionary *subedDict;

@property (nonatomic,assign) BOOL isSSL;
@property (nonatomic, assign) BOOL isDiscontent;
@end

@implementation QLMQTTClientManager2

+ (instancetype)Instance{
    static dispatch_once_t onceToken;
    static QLMQTTClientManager2 *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
        [instance bindSessionManager];
    });
    return instance;
}

#pragma mark - 绑定
- (void)bindSessionManager{
    //第三方的host:broker.mqttdashboard.com -- port:1883(可以登录网址查看)
    /*!
     ClientId:理论上应该是一个客户端一个id
     */
    
    [self.mySessionManager connectTo:@"broker.mqttdashboard.com"
                                port:1883
                                 tls:NO
                           keepalive:60
                               clean:YES
                                auth:false
                                user:nil
                                pass:nil
                                will:YES
                           willTopic:@"MQTTChat"
                             willMsg:nil
                             willQos:MQTTQosLevelExactlyOnce
                      willRetainFlag:NO
                        withClientId:nil
                      securityPolicy:nil
                        certificates:nil
                       protocolLevel:4
                      connectHandler:nil];
    
    self.isDiscontent = NO;
}


- (void)reConnect {
    if (self.mySessionManager.state != MQTTSessionManagerStateConnected && self.mySessionManager.state != MQTTSessionManagerStateConnecting) {
        [self sessionReConnect];
    }
    else {
        NSLog(@"已经连接，不需要重连");
    }
}


#pragma mark - 订阅topic
- (void)subscribeTopic:(NSString *)topic{
    
    NSLog(@"当前需要订阅-------- topic = %@",topic);
    
    if (![self.subedDict.allKeys containsObject:topic]) {
        [self.subedDict setObject:[NSNumber numberWithLong:MQTTQosLevelAtLeastOnce] forKey:[NSString stringWithFormat:@"%@/#", topic]];
        NSLog(@"订阅字典 ----------- = %@",self.subedDict);
        self.mySessionManager.subscriptions =  self.subedDict;
    }
    else {
        NSLog(@"已经存在，不用订阅");
    }
    
}

#pragma mark - 取消订阅
- (void)unsubscribeTopic:(NSString *)topic {
    
    NSLog(@"当前需要取消订阅-------- topic = %@",topic);
    
    if ([self.subedDict.allKeys containsObject:topic]) {
        [self.subedDict removeObjectForKey:topic];
        NSLog(@"更新之后的订阅字典 ----------- = %@",self.subedDict);
        self.mySessionManager.subscriptions =  self.subedDict;
    }
    else {
        NSLog(@"不存在，无需取消");
    }
    
}

#pragma mark - 发布消息
- (void)sendDataToTopic:(NSString *)topic msg:(NSString *)msg{
    
    NSLog(@"发送命令 topic = %@  msg = %@",topic,msg);
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    [self.mySessionManager sendData:data topic:topic qos:MQTTQosLevelAtLeastOnce retain:NO];
}

#pragma mark ---- 状态
- (void)sessionManager:(MQTTSessionManager *)sessionManager didChangeState:(MQTTSessionManagerState)newState {
    switch (newState) {
        case MQTTSessionManagerStateConnected:
            NSLog(@"eventCode -- 连接成功");
            break;
        case MQTTSessionManagerStateConnecting:
            NSLog(@"eventCode -- 连接中");
            
            break;
        case MQTTSessionManagerStateClosed:
            NSLog(@"eventCode -- 连接被关闭");
            break;
        case MQTTSessionManagerStateError:
            NSLog(@"eventCode -- 连接错误");
            break;
        case MQTTSessionManagerStateClosing:
            NSLog(@"eventCode -- 关闭中");
            
            break;
        case MQTTSessionManagerStateStarting:
            NSLog(@"eventCode -- 连接开始");
            
            break;
            
        default:
            break;
    }
}

#pragma mark MQTTSessionManagerDelegate
- (void)handleMessage:(NSData *)data onTopic:(NSString *)topic retained:(BOOL)retained {
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"接到信息>>>dataString=%@>>>>topic=%@>>>",dataString,topic);
    
}


- (void)disconnect {
    
    self.isDiscontent = YES;
    //    self.isContented = NO;
    [self.mySessionManager disconnectWithDisconnectHandler:^(NSError *error) {
        NSLog(@"断开连接  error = %@",[error description]);
    }];
    [self.mySessionManager setDelegate:nil];
    self.mySessionManager = nil;
    [self.subedDict removeAllObjects];
    self.subedDict = nil;
}


- (void)sessionReConnect {
    
    if (self.mySessionManager && self.mySessionManager.port) {
        self.mySessionManager.delegate = self;
        self.isDiscontent = NO;
        [self.mySessionManager connectToLast:^(NSError *error) {
            NSLog(@"重新连接  error = %@",[error description]);
        }];
        self.mySessionManager.subscriptions = self.subedDict;
        
    }
    else {
        [self bindSessionManager];
    }
}


- (MQTTSSLSecurityPolicy *)customSecurityPolicy{
    
    MQTTSSLSecurityPolicy *securityPolicy = [MQTTSSLSecurityPolicy policyWithPinningMode:MQTTSSLPinningModeNone];
    
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesCertificateChain = YES;
    securityPolicy.validatesDomainName = NO;
    return securityPolicy;
}

#pragma mark - 懒加载
- (MQTTSessionManager *)mySessionManager {
    if (!_mySessionManager) {
        _mySessionManager = [[MQTTSessionManager alloc]init];
        _mySessionManager.delegate = self;
    }
    return _mySessionManager;
}

- (NSMutableDictionary *)subedDict {
    if (!_subedDict) {
        _subedDict = [NSMutableDictionary dictionary];
    }
    return _subedDict;
}
@end
