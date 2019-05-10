//
//  QLWebSocketManager.m
//  QLSocketDemo
//
//  Created by qiu on 2019/5/9.
//  Copyright © 2019 qiu. All rights reserved.
//

#import "QLWebSocketManager.h"
#import "SocketRocket.h"
#import "Header.h"

#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

@interface QLWebSocketManager()<SRWebSocketDelegate>{
    NSTimer *heartBeat;
    NSTimeInterval reConnectTime;
    
}
@property (nonatomic,strong) SRWebSocket *socket;
@end

@implementation QLWebSocketManager

+ (instancetype)Instance{
    static dispatch_once_t onceToken;
    static QLWebSocketManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
        [instance initSocket];
    });
    return instance;
}

//初始化连接
- (void)initSocket{
    if (self.socket) {
        return;
    }
    if(self.socket.readyState == SR_OPEN){
        return;
    }
    self.socket = [[SRWebSocket alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"ws://%@:%d", AddressOfServer, PortOfServer]]];
    
    self.socket.delegate = self;
    
    //设置代理线程queue
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    queue.maxConcurrentOperationCount = 1;
    
    [self.socket setDelegateOperationQueue:queue];
    
    //连接
    [self.socket open];
}

#pragma mark - 对外的一些接口
//建立连接
- (void)connect{
    [self initSocket];
}

//断开连接
- (void)disConnect{
    if (self.socket) {
        [self.socket close];
        self.socket = nil;
        //断开连接时销毁心跳
        [self destoryHeartBeat];
    }
}

//发送消息
- (void)sendMsg:(NSString *)msg{
    [self.socket send:msg];
}
- (void)sendData:(NSDictionary *)paramDic withRequestURI:(NSString *)requestURI{
    //这一块的数据格式由你们跟你们家服务器哥哥商定
    NSDictionary *configDic;
    
    //requestURI = [NSString stringWithFormat:@"/api/%@",requestURI];
    
    //    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //    NSDictionary *configDic = @{
    //                                @"usersign"  :appDelegate.appToken,
    //                                @"command"   :@"response",
    //                                @"requestURI":requestURI,                                @"headers"   :@{@"Version":AboutVersion,
    //                                                @"Token":appDelegate.appToken,
    //                                                @"LoginName":appDelegate.appLoginName},
    //                                @"params"    :paramDic
    //                                };
    NSLog(@"socketSendData--configDic --------------- %@",configDic);
    NSError *error;
    NSString *data;
    //(NSJSONWritingOptions) (paramDic ? NSJSONWritingPrettyPrinted : 0)
    //采用这个格式的json数据会比较好看，但是不是服务器需要的
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:configDic
                                                       options:0
                                                         error:&error];
    
    if (!jsonData) {
        NSLog(@" error: %@", error.localizedDescription);
        return;
    } else {
        data = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        //这是为了取代requestURI里的"\"
        //data = [data stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    }
    __weak typeof(self) weakSelf = self;
    dispatch_queue_t queue =  dispatch_queue_create("zy", NULL);
    
    dispatch_async(queue, ^{
        if (weakSelf.socket != nil) {
            // 只有 SR_OPEN 开启状态才能调 send 方法啊，不然要崩
            if (weakSelf.socket.readyState == SR_OPEN) {
                [weakSelf.socket send:data];    // 发送数据
                
            } else if (weakSelf.socket.readyState == SR_CONNECTING) {
                
                [weakSelf reConnect];
                
            } else if (weakSelf.socket.readyState == SR_CLOSING || weakSelf.socket.readyState == SR_CLOSED) {
                // websocket 断开了，调用 reConnect 方法重连
                NSLog(@"重连");
                
                [weakSelf reConnect];
            }
        } else {
            // 这里要看你的具体业务需求；不过一般情况下，调用发送数据还是希望能把数据发送出去，所以可以再次打开链接；不用担心这里会有多个socketopen；因为如果当前有socket存在，会停止创建哒
            [weakSelf initSocket];
        }
    });
}

//重连机制
- (void)reConnect{
    [self disConnect];
    
    //超过一分钟就不再重连 所以只会重连5次 2^5 = 64
    if (reConnectTime > 64) {
        //您的网络状况不是很好，请检查网络后重试
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(reConnectTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.socket = nil;
        [self initSocket];
        NSLog(@"重连");
    });
    
    //重连时间2的指数级增长
    if (reConnectTime == 0) {
        reConnectTime = 2;
    }else{
        reConnectTime *= 2;
    }
}

#pragma mark - 心跳
//初始化心跳
- (void)initHeartBeat{
    
    dispatch_main_async_safe(^{
        
        [self destoryHeartBeat];
        
        __weak typeof(self) weakSelf = self;
        //心跳设置为3分钟，NAT超时一般为5分钟
        self->heartBeat = [NSTimer scheduledTimerWithTimeInterval:3*60 repeats:YES block:^(NSTimer * _Nonnull timer) {
            NSLog(@"heart");
            //和服务端约定好发送什么作为心跳标识，尽可能的减小心跳包大小
            [weakSelf sendMsg:@"heart"];
        }];
        [[NSRunLoop currentRunLoop]addTimer:self->heartBeat forMode:NSRunLoopCommonModes];
    })
    
}

//取消心跳
- (void)destoryHeartBeat{
    dispatch_main_async_safe(^{
        if (self->heartBeat) {
            if ([self->heartBeat respondsToSelector:@selector(isValid)]){
                if ([self->heartBeat isValid]){
                    [self->heartBeat invalidate];
                    self->heartBeat = nil;
                }
            }
        }
    })
}

//pingPong
- (void)ping{
    if (self.socket.readyState == SR_OPEN) {
        [self.socket sendPing:nil];
    }
}

#pragma mark - SRWebSocketDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    if (webSocket == self.socket) {
       NSLog(@"服务器返回收到消息:%@",message);
    }
}


- (void)webSocketDidOpen:(SRWebSocket *)webSocket{
    NSLog(@"连接成功");
    //每次正常连接的时候清零重连时间
    reConnectTime = 0;
    
    //连接成功了开始发送心跳
    [self initHeartBeat];
    if (self.socket == webSocket) {
        NSLog(@"************************** socket 连接成功************************** ");
    }
}

//open失败的时候调用
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    NSLog(@"连接失败.....\n%@",error);
    
    if (self.socket == webSocket) {
        NSLog(@"************************** socket 连接失败************************** ");
        _socket = nil;
        
        //连接失败就重连
        [self reConnect];
    }
}

//网络连接中断被调用
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    
    NSLog(@"被关闭连接，code:%ld,reason:%@,wasClean:%d",code,reason,wasClean);
    
    //如果是被用户自己中断的那么直接断开连接，否则开始重连
    if (code == disConnectByUser) {
        [self disConnect];
    }else{
        
        [self reConnect];
    }
    //断开连接时销毁心跳
    [self destoryHeartBeat];
    
}

/*该函数是接收服务器发送的pong消息，其中最后一个是接受pong消息的，
 在这里就要提一下心跳包，一般情况下建立长连接都会建立一个心跳包，
 用于每隔一段时间通知一次服务端，客户端还是在线，这个心跳包其实就是一个ping消息，
 我的理解就是建立一个定时器，每隔十秒或者十五秒向服务端发送一个ping消息，这个消息可是是空的
 */
//sendPing的时候，如果网络通的话，则会收到回调，但是必须保证ScoketOpen，否则会crash
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload{
    NSLog(@"收到pong回调");
}


//将收到的消息，是否需要把data转换为NSString，每次收到消息都会被调用，默认YES
//- (BOOL)webSocketShouldConvertTextFrameToString:(SRWebSocket *)webSocket
//{
//    NSLog(@"webSocketShouldConvertTextFrameToString");
//
//    return NO;
//}
@end
