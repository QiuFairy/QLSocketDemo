//
//  QLMQTTClientManager.m
//  QLSocketDemo
//
//  Created by qiu on 2019/5/9.
//  Copyright © 2019 qiu. All rights reserved.
//

#import "QLMQTTClientManager.h"
#import "Header.h"

#import <MQTTClient.h>
@interface QLMQTTClientManager()<MQTTSessionManagerDelegate>

@property (nonatomic,strong) MQTTSessionManager *mySessionManager;

@property (nonatomic,copy) NSString *username;
@property (nonatomic,copy) NSString *password;
@property (nonatomic,copy) NSString *cliendId;

//订阅的topic
@property (nonatomic,strong) NSMutableDictionary *subedDict;

@property (nonatomic,assign) BOOL isSSL;
@property (nonatomic, assign) BOOL isDiscontent;
@end

@implementation QLMQTTClientManager

+ (instancetype)Instance{
    static dispatch_once_t onceToken;
    static QLMQTTClientManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

#pragma mark - 绑定
- (void)bindWithUserName:(NSString *)username password:(NSString *)password epoch:(long long)epoch {
    
    NSString *usernameMQTT = [NSString stringWithFormat:@"a:rinnai:SR:01:SR:%@",username];
    NSString *cliendId = [NSString stringWithFormat:@"a:rinnai:SR:01:SR:%@:%lld",username,epoch];
    
    [self bindWithUserName:usernameMQTT password:password cliendId:cliendId isSSL:YES];
    
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
        [self.subedDict setObject:[NSNumber numberWithLong:MQTTQosLevelAtLeastOnce] forKey:topic];
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

#pragma mark - set命令
//发送数据
- (void)switchWithDevice {
    
    NSDictionary *dict = @{@"ptn":@"J00",
                           @"code":@"1234",
                           @"id": @"1234",
                           @"sum":@"1",
                           @"enl":@[@{@"id":@"power",
                                      @"data":@"31"
                                      }]
                           };
    
    [self sendDataToTopic:[HeadTopic stringByAppendingString:@"/set/"] dict:dict];
    
}

#pragma mark - 发布消息
- (void)sendDataToTopic:(NSString *)topic dict:(NSDictionary *)dict {
    
    NSLog(@"发送命令 topic = %@  dict = %@",topic,dict);
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
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
    
//    NSArray *array = [topic componentsSeparatedByString:@"/"];
//    NSString *str = [[NSString alloc]initWithBytes:&(((UInt8 *)[data bytes])[0]) length:data.length encoding:NSUTF8StringEncoding];
//    NSDictionary *dict = [self dictionaryWithJsonString:str];
//    NSLog(@"str = %@ \n -------- dict:%@ --------- \n",str,dict);
//
//    __weak typeof(self) weakSelf = self;
    //解析
    
}


- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

- (void)disconnect {
    
    self.isDiscontent = YES;
    //    self.isContented = NO;
    [self.mySessionManager disconnectWithDisconnectHandler:^(NSError *error) {
        NSLog(@"断开连接  error = %@",[error description]);
    }];
    [self.mySessionManager setDelegate:nil];
    self.mySessionManager = nil;
    
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
        [self bindWithUserName:self.username password:self.password cliendId:self.cliendId isSSL:self.isSSL];
        
    }
    
}
#pragma mark - 绑定
- (void)bindWithUserName:(NSString *)username password:(NSString *)password cliendId:(NSString *)cliendId isSSL:(BOOL)isSSL{
    
    self.username = username;
    self.password = password;
    self.cliendId = cliendId;
    self.isSSL = isSSL;
    
    [self.mySessionManager connectTo:AddressOfServer
                                port:PortOfServer
                                 tls:self.isSSL
                           keepalive:60
                               clean:YES
                                auth:YES
                                user:self.username
                                pass:self.password
                                will:NO
                           willTopic:nil
                             willMsg:nil
                             willQos:MQTTQosLevelAtLeastOnce
                      willRetainFlag:NO
                        withClientId:self.cliendId
                      securityPolicy:[self customSecurityPolicy]
                        certificates:nil
                       protocolLevel:4
                      connectHandler:nil];
    
    self.isDiscontent = NO;
    self.mySessionManager.subscriptions = self.subedDict;
    
}

- (MQTTSSLSecurityPolicy *)customSecurityPolicy
{
    
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
