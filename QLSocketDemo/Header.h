//
//  Header.h
//  QLSocketDemo
//
//  Created by qiu on 2019/5/9.
//  Copyright © 2019 qiu. All rights reserved.
//

#ifndef Header_h
#define Header_h

#define serverIP  @"127.0.0.1"
#define serverPort  @"6969"

static NSString *const AddressOfMQTTServer      = @"127.0.0.1";  // MQTT服务器地址
static UInt16   const PortOfMQTTServer          = 6969;  // MQTT服务器端口
static UInt16   const PortOfMQTTServerWithSSL          = 6969;  // MQTT服务器端口

#pragma mark - 项目相关主题
//topic
static NSString *const HeadTopic           = @"nidaye";

#endif /* Header_h */
