# QLSocketDemo

>主要是用来研究socket通信的几种搭建方式

**运行时，请`pod install`**

## 一、主要包含以下几种请求方式

基于条件 | 第三方框架 | 协议 
:------ | :---: | :---: 
Socket | 也可不使用框架 | 传输协议 
Socket | CocoaAsyncSocket | 传输协议 
WebSocket | SocketRocket | 传输通讯协议 
MQTT | MQTTKit / MQTTClient | 聊天协议 
XMPP | XMPPFramework | 聊天协议

## 二、基础库的地址

- [基于原生Socket的CocoaAsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket)

- [基于WebSocket的SocketRocket](https://github.com/facebook/SocketRocket)

- [基于MQTT的MQTTKit](https://github.com/mobile-web-messaging/MQTTKit)

- [基于MQTT的MQTT-Client-Framework](https://github.com/novastone-media/MQTT-Client-Framework)
	- [MQTTClient官方推荐Demo](https://github.com/ckrey/MQTTChat
)

## 三、增加了部分本地服务器的搭建

#### 详情请参考 **`scoket服务器搭建`** 文件夹

- socketServer: 对应socket方式
	- 运行方式：`node socketServer`
	
- WSServer: 对应webSocket方式
	- 运行方式：需安装`ws`模块:npm install ws
	- `node WSServer `
	
- MQTTServer: 对应MQTTKit方式
	- 需安装`mosca`模块:npm install mosca
	- `node MQTTServer `
	- 其中MQTTClient方式可以使用.m中的第三方网址来进行测试

## Note

> 仅用来研究socket，仅供参考。
> 
> 本文也是参考第三方文档写就。




----
# BY -- QiuFairy