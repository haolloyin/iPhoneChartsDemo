//
//  TXMobileAuthenticationProtocol.h
//
//  MOA移动认证客户端，提供基础身份及设备认证服务
//  【宿主程序】调用MOA认证服务客户端的程序
//  Created by none on 9/1/12.
//  Copyright 2012 Tencent Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXMobileAuthenticationMessage.h"

@protocol TXMobileAuthenticationDelegate<NSObject>

@required

/*
 * 认证客户端本地没有保存会话Key，或者Key已经失效，需要通过Token重新登录认证
 */
- (void)clientShouldSignIn;
/*
 * 登录及认证通过
 */
- (void)clientDidFinishAuthentication;
/*
 * 设备被禁用，原因是报失或者其他安全问题。认证客户端宿主必须做数据清理和禁止访问
 */
- (void)clientDeviceAccessDenied:(TXMobileAuthenticationMessage *)message;
/*
 * Token检查失败，此方法由认证客户端宿主主动发起Token检查来触发，非登录结果
 */
- (void)clientCheckTokenDidFailWithError:(TXMobileAuthenticationMessage *)message;
/*
 * 客户端登录认证失败
 */
- (void)clientAuthenticationDidFailWithError:(TXMobileAuthenticationMessage *)message;
/*
 * Token检查通过
 */
- (void)clientCheckTokenDidSuccess;
/*
 * 认证客户端发出请求失败，一般为请求异常或者服务异常
 */
- (void)clientRequestFailed:(TXMobileAuthenticationMessage *)message;

@end
