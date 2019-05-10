//
//  ViewController.m
//  QLSocketDemo
//
//  Created by qiu on 2019/5/9.
//  Copyright © 2019 qiu. All rights reserved.
//

#import "ViewController.h"

//原生
#import "QLSocketManager.h"
//基于socket原生的封装
#import "QLCASSocketManager.h"
//基于websocket的封装
#import "QLWebSocketManager.h"
//基于mqtt的MQTTKit
#import "QLMQTTKitManager.h"
//基于mqtt的MQTTClient
#import "QLMQTTClientManager.h"
//基于mqtt的MQTTClient2
#import "QLMQTTClientManager2.h"

@interface ViewController ()

@property (nonatomic, strong) UITextField *textField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(10, 100, 300, 300)];
    bgView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:bgView];
    
    UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(50, 100, 200, 44)];
    textField.backgroundColor = [UIColor whiteColor];
    textField.placeholder = @"请输入信息";
    textField.text = @"我是你大爷";
    [bgView addSubview:textField];
    self.textField = textField;
    
    UIButton *sendBtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 200, 100, 44)];
    sendBtn.backgroundColor = [UIColor whiteColor];
    [sendBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    sendBtn.tag = 10010;
    [bgView addSubview:sendBtn];
    
    
    UIButton *onBtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 480, 100, 44)];
    onBtn.backgroundColor = [UIColor greenColor];
    [onBtn setTitle:@"连接" forState:UIControlStateNormal];
    [onBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [onBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    onBtn.tag = 10000;
    [self.view addSubview:onBtn];
    
    UIButton *offBtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 550, 100, 44)];
    offBtn.backgroundColor = [UIColor redColor];
    [offBtn setTitle:@"断开" forState:UIControlStateNormal];
    [offBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [offBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    offBtn.tag = 10001;
    [self.view addSubview:offBtn];
    
    
    UIButton *on2Btn = [[UIButton alloc]initWithFrame:CGRectMake(100, 620, 100, 44)];
    on2Btn.backgroundColor = [UIColor greenColor];
    [on2Btn setTitle:@"专用于MQTT2连接" forState:UIControlStateNormal];
    [on2Btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [on2Btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    on2Btn.tag = 66666;
    [self.view addSubview:on2Btn];
}

- (void)clickBtn:(UIButton *)sender{
    if (sender.tag == 10000) {
        //链接
//        [[QLSocketManager Instance]connect];
        
//        [[QLCASSocketManager Instance]connect];
        
//        [[QLWebSocketManager Instance]connect];
        
//        [[QLMQTTKitManager Instance]connect];
        
//        [[QLMQTTClientManager Instance]bindWithUserName:@"1212" password:@"12222" epoch:1];
        
        [[QLMQTTClientManager2 Instance]subscribeTopic:@"user1"];
    }else if (sender.tag == 10001){
        //断开
//        [[QLSocketManager Instance]disConnect];
        
//        [[QLCASSocketManager Instance]disConnect];
        
//        [[QLWebSocketManager Instance]disConnect];
        
//        [[QLMQTTKitManager Instance]disConnect];
        
//        [[QLMQTTClientManager Instance]disconnect];
        
        [[QLMQTTClientManager2 Instance]disconnect];
    }else if(sender.tag == 10010){
        //发送信息
//        [[QLSocketManager Instance]sendMsg:self.textField.text];
        
//        [[QLSocketManager Instance]sendMsg:self.textField.text];
        
//        [[QLWebSocketManager Instance]sendMsg:self.textField.text];
        
//        [[QLMQTTKitManager Instance]sendMsg:self.textField.text];
        
//        [[QLMQTTClientManager Instance]switchWithDevice];
        
        [[QLMQTTClientManager2 Instance]sendDataToTopic:@"user1" msg:self.textField.text];
    }else if(sender.tag == 66666){
        //转用于测试QLMQTTClientManager2
        [[QLMQTTClientManager2 Instance]subscribeTopic:@"user2"];
    }
}

@end
