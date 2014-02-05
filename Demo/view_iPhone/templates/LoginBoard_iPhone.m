//
//	 ______    ______    ______    
//	/\  __ \  /\  ___\  /\  ___\   
//	\ \  __<  \ \  __\_ \ \  __\_ 
//	 \ \_____\ \ \_____\ \ \_____\ 
//	  \/_____/  \/_____/  \/_____/ 
//
//	Powered by BeeFramework
//
//
//  LoginBoard_iPhone.m
//  Demo
//
//  Created by hao on 13-9-25.
//  Copyright (c) 2013年 hao. All rights reserved.
//

#import "LoginBoard_iPhone.h"
#import "AppBoard_iPhone.h"
#import "TXMobileAuthenticationClient.h"
#import "Helper.h"

#pragma mark -

@interface LoginBoard_iPhone()
{
	//<#@private var#>
}
@end

@implementation LoginBoard_iPhone

SUPPORT_AUTOMATIC_LAYOUT( YES );
SUPPORT_RESOURCE_LOADING( YES );

- (void)load
{
	[super load];
}

- (void)unload
{
	[super unload];
}

#pragma mark Signal

ON_SIGNAL2( BeeUIBoard, signal )
{
    [super handleUISignal:signal];

    if ( [signal is:BeeUIBoard.CREATE_VIEWS] )
    {
        [self showNavigationBarAnimated:NO];
		[self showBarButton:BeeUINavigationBar.LEFT image:[UIImage imageNamed:@"menu-button.png"]];
		[self setTitleString:@"OA登录"];
        
        $(@"#rtx").DATA( @"admin" );
        $(@"#token").DATA( @"1234567token" );
        
    }
    else if ( [signal is:BeeUIBoard.DELETE_VIEWS] )
    {
    }
    else if ( [signal is:BeeUIBoard.LAYOUT_VIEWS] )
    {
    }
    else if ( [signal is:BeeUIBoard.LOAD_DATAS] )
    {
    }
    else if ( [signal is:BeeUIBoard.FREE_DATAS] )
    {
    }
    else if ( [signal is:BeeUIBoard.WILL_APPEAR] )
    {
    }
    else if ( [signal is:BeeUIBoard.DID_APPEAR] )
    {
    }
    else if ( [signal is:BeeUIBoard.WILL_DISAPPEAR] )
    {
    }
    else if ( [signal is:BeeUIBoard.DID_DISAPPEAR] )
    {
    }
}

ON_SIGNAL2( BeeUINavigationBar, signal )
{
	[super handleUISignal:signal];
	
	if ( [signal is:BeeUINavigationBar.LEFT_TOUCHED] )
	{
        [[AppBoard_iPhone sharedInstance] showMenu];
	}
	else if ( [signal is:BeeUINavigationBar.RIGHT_TOUCHED] )
	{
	}
}

#pragma mark - 点击登录按钮

ON_SIGNAL3( LoginBoard_iPhone, login_btn, signal )
{
	// 点击登录按钮：判断输入框内容有效性
    NSString *username = $(@"#rtx").val;
    NSString *password = $(@"#token").val;
    
    if ([username length] < 1) {
        [Helper showAlertWithTitle:@"登录提示:)" message:@"请填写用户名" cancelTitle:nil otherTitle:@"重试"];
        return;
    }
    else if([password length] != 12) {
        [Helper showAlertWithTitle:@"登录提示:)" message:@"Token输入错误" cancelTitle:nil otherTitle:@"重试"];
        return;
    }
    
    [[TXMobileAuthenticationClient sharedInstance] signInWithUserName:username token:password];
}

#pragma mark - OA login delegate

/*
 * 认证客户端本地没有保存会话Key，或者Key已经失效，需要通过Token重新登录认证
 */
- (void)clientShouldSignIn
{
    [USER_DEFAULTS setBool:NO forKey:@"IS_USER_Authenticated"]; // 设置为已登录验证通过
    [USER_DEFAULTS synchronize];
    self.loginCallBackBlock(self, YES);
}

/*
 * 登录及认证通过
 */
- (void)clientDidFinishAuthentication
{
    [USER_DEFAULTS setBool:YES forKey:@"IS_USER_Authenticated"]; // 设置为已登录验证通过
    [USER_DEFAULTS setObject:(NSString *)$(@"#rtx").val forKey:@"username"]; // 设置用户名
    [USER_DEFAULTS synchronize];
    
    // 登录及认证通过，进入 Home 目录
    self.loginCallBackBlock(self, NO);
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
 * 设备被禁用，原因是报失或者其他安全问题。认证客户端宿主必须做数据清理和禁止访问
 */
- (void)clientDeviceAccessDenied:(TXMobileAuthenticationMessage *)message
{
    
}

/*
 * Token检查失败，此方法由认证客户端宿主主动发起Token检查来触发，非登录结果
 */
- (void)clientCheckTokenDidFailWithError:(TXMobileAuthenticationMessage *)message
{
}

/*
 * 客户端登录认证失败
 */
- (void)clientAuthenticationDidFailWithError:(TXMobileAuthenticationMessage *)message
{
    ERROR(@"hao: TXMobileAuthenticationDelegate clientCheckTokenDidFailWithError[%d]:%@", message.code, message.text);
    
    [Helper showAlertWithTitle:@"登录提示" message:message.text cancelTitle:nil otherTitle:@"重试"];
}

/*
 * Token检查通过
 */
- (void)clientCheckTokenDidSuccess
{
    
}

/*
 * 认证客户端发出请求失败，一般为请求异常或者服务异常
 */
- (void)clientRequestFailed:(TXMobileAuthenticationMessage *)message
{
    
}

@end
