//
//  TXMobileAuthenticationClient.h
//
//  MOA认证服务客户端, 提供基于Token的身份认证服务及设备准入服务
//  【宿主程序】调用MOA认证服务客户端的程序
//  Created by none on 9/1/12.
//  Copyright 2012 Tencent Inc. All rights reserved.
// *************************************************
//
// 2012-11-05  新增 accessKey 方法用于宿主程序后台与MOA后台做校验 by none
// 2012-12-12  新增 userName 方法用于宿主程序获取用户名 by none
//

#import "TXMobileAuthenticationDelegate.h"

@interface TXMobileAuthenticationClient : NSObject

/*
 * 事件委托，宿主程序需要指定并且实现TXMobileAuthenticationDelegate的协议
 */
@property(nonatomic, assign) id<TXMobileAuthenticationDelegate> delegate;
/*
 * MOA 认证接入AppKey，必须传递由MOA分配的合法Key
 */
@property (retain, nonatomic) NSString *appKey;
/*
 * TXMobileAuthenticationClient 单例，推荐宿主程序在调用时候全程使用sharedInstance
 */
+ (TXMobileAuthenticationClient*) sharedInstance;
/*
 * 释放sharedInstance，TXMobileAuthenticationClient 会保存会话身份，建议sharedInstance在宿主程序整个生命周期都存在，不需要手工调用
 */
+ (void) purgeSharedInstance;
/*
 * 启动认证客户端
 * 如果本地保存了会话身份，会自动登录，所有认证结果消息会通知delegate
 */
- (void)start;
/*
 * 通过用户名，token认证
 */
- (void)signInWithUserName:(NSString *)userName token:(NSString *)token;
/*
 * 通过保存的身份登录，一般不需要宿主程序自己调用
 * 使用场景: MOA或者其他MOA认证接入程序之间可以互相通过保存的身份进行登录认证
 */
- (void)signInWithPayload:(NSString *)payload;
/*
 * 注销登录，如果如果没有异常，执行完毕认证客户端的会话信息会被清空
 */
- (void)signOut;
/*
 * Token验证服务，调用此方法只验证Token合法性，不修改会话身份信息
 */
- (void)checkToken:(NSString *)token;
/*
 * 是否保存会话信息，默认保存，如果主动设置关闭，本地将不保存会话信息，但是当前回话还是有效
 */
- (void)rememberMe:(BOOL)remember;
/*
 * 保存的身份信息，仅在与MOA或者其他MOA认证客户端之间传递身份时使用
 */
- (NSString *)payload;
/*
 * 用于获取用户身份的Key，可以用该Key访问MOA后台获取用户的身份信息
 */
-(NSString *)accessKey;
/*
 * 用户获取用户名,只有登录认证完成后才能获取到
 */
-(NSString *)userName;

@end
