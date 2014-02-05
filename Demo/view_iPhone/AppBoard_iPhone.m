//
//   ______    ______    ______    
//  /\  __ \  /\  ___\  /\  ___\   
//  \ \  __<  \ \  __\_ \ \  __\_ 
//   \ \_____\ \ \_____\ \ \_____\ 
//    \/_____/  \/_____/  \/_____/ 
//
//  Powered by BeeFramework
//
//
//  AppBoard_iPhone.m
//  Demo
//
//  Created by hao on 13-8-10.
//  Copyright (c) 2013年 hao. All rights reserved.
//

#import "AppBoard_iPhone.h"
#import "MenuBoard_iPhone.h"
#import "LoginBoard_iPhone.h"
#import "ProductBoard_iPhone.h"
#import "SplashBoard_iPhone.h"
#import "TXMobileAuthenticationClient.h"
#import "Helper.h"

#pragma mark -

#undef	MENU_BOUNDS
#define	MENU_BOUNDS	(80.0f)

#pragma mark -

@implementation AppBoard_iPhone
{
    BeeUIRouter *_router;
    MenuBoard_iPhone *_menu;
	BeeUIButton *_mask;
	UIWindow *_splash;
	CGRect _origFrame;
}

DEF_SINGLETON( AppBoard_iPhone );

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
		[BeeUITipsCenter setDefaultContainerView:self.view];
		[BeeUITipsCenter setDefaultBubble:[UIImage imageNamed:@"alertBox.png"]];
		[BeeUITipsCenter setDefaultMessageIcon:[UIImage imageNamed:@"index-new-league-icon.png"]];
		[BeeUITipsCenter setDefaultSuccessIcon:[UIImage imageNamed:@"index-new-league-icon.png"]];
		[BeeUITipsCenter setDefaultFailureIcon:[UIImage imageNamed:@"index-new-league-icon.png"]];
		
		[BeeUINavigationBar setBackgroundImage:[UIImage imageNamed:@"navigation-bar.png"]];
		
		self.view.backgroundColor = [UIColor blackColor];
        
        _menu = [MenuBoard_iPhone sharedInstance];
		_menu.parentBoard = self;
		_menu.view.backgroundColor = RGB(15, 15, 15);
		_menu.view.hidden = YES;
		[self.view addSubview:_menu.view];
        
        _splash = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
		_splash.rootViewController = [SplashBoard_iPhone board];
		_splash.windowLevel = UIWindowLevelStatusBar + 1;
		[_splash makeKeyAndVisible];
        
        [self observeNotification:SplashBoard_iPhone.PLAY_DONE];
		[self observeNotification:BeeUIRouter.STACK_WILL_CHANGE];
		[self observeNotification:BeeUIRouter.STACK_DID_CHANGED];
        
        LoginBoard_iPhone *loginBoard = [LoginBoard_iPhone board]; // 登录面板
        
        ERROR(@"hao: 1");
        
        _router = [BeeUIRouter sharedInstance];
		_router.parentBoard = self;
		_router.view.alpha = 0.0f;
        [_router map:@"products" toClass:[ProductBoard_iPhone class]];
        [_router map:@"setting" toClass:nil];
        [_router map:@"about" toClass:nil];
        [_router map:@"login" toBoard:loginBoard];
		[self.view addSubview:_router.view];
        
        ERROR(@"hao: 2");
        
        _mask = [BeeUIButton new];
		_mask.signal = @"mask";
		[self.view addSubview:_mask];
        
        _router.view.frame = self.bounds;
        _router.view.backgroundColor = [UIColor whiteColor];
        _router.view.alpha = 1.0f;
        
        ERROR(@"hao: 3");
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:1.0f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(ready)];
        [UIView commitAnimations];
        
        ERROR(@"hao: 4");
        
        // 调用 MOA API 尝试进行登录，若本地没有保存会话Key，或者Key已经失效，需要通过Token重新登录认证
        loginBoard.loginCallBackBlock = ^(id vc, BOOL shouldSignIn){
            if (shouldSignIn) {
                [_menu updateLoginButtonTitle:@"登录"];
                [_router open:@"login" animated:NO];
                [self hideMenu];
            }
            else {
                [_router open:@"products" animated:NO];
                [_menu selectItem:@"products" animated:YES];
                
                //TODO 用户已经登录验证过，将 login 按钮标题更新为『注销』
                [_menu updateLoginButtonTitle:@"注销"];
            }
        };
        [[TXMobileAuthenticationClient sharedInstance] setDelegate:loginBoard];
        [[TXMobileAuthenticationClient sharedInstance] start];
        
        ERROR(@"hao: 5");
        
	}
	else if ( [signal is:BeeUIBoard.DELETE_VIEWS] )
	{
		_menu = nil;
		_router = nil;
		_mask = nil;
		_splash = nil;
		[self unobserveAllNotifications];
	}
	else if ( [signal is:BeeUIBoard.LAYOUT_VIEWS] )
	{
        _router.view.frame = self.bounds;
	}
	else if ( [signal is:BeeUIBoard.WILL_APPEAR] )
	{
	}
	else if ( [signal is:BeeUIBoard.DID_APPEAR] )
	{
		_router.view.pannable = YES;
	}
	else if ( [signal is:BeeUIBoard.WILL_DISAPPEAR] )
	{
		_router.view.pannable = NO;
	}
	else if ( [signal is:BeeUIBoard.DID_DISAPPEAR] )
	{
	}
}

ON_SIGNAL2( UIView, signal )
{
    if ( [signal is:UIView.PAN_START]  )
    {
        _origFrame = _router.view.frame;
        
        [self syncPanPosition];
    }
    else if ( [signal is:UIView.PAN_CHANGED]  )
    {
        [self syncPanPosition];
    }
    else if ( [signal is:UIView.PAN_STOP] || [signal is:UIView.PAN_CANCELLED] )
    {
        [self syncPanPosition];
        
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.3f];
        
		CGFloat left = _router.view.left;
		CGFloat edge = MENU_BOUNDS;
        
		if ( left <= edge )
		{
			_router.view.left = 0;
			
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(didMenuHidden)];
		}
		else
		{
			_router.view.left = 62.0f;
			
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(didMenuShown)];
		}
		
		[UIView commitAnimations];
    }
}

ON_SIGNAL2( mask, signal )
{
	[self hideMenu];
}

ON_SIGNAL3( BeeUIRouter, WILL_CHANGE, signal )
{
}

ON_SIGNAL3( BeeUIRouter, DID_CHANGED, signal )
{
	[_menu selectItem:_router.currentStack.name animated:YES];
}

ON_SIGNAL3( MenuBoard_iPhone, products, signal )
{
    if (IS_USER_Authenticated) {
        [_router open:@"products" animated:YES];
        [self hideMenu];
    }
    else {
        [Helper showAlertWithTitle:@"温馨提示:)" message:@"请先OA登录" cancelTitle:nil otherTitle:nil];
    }
	
}

ON_SIGNAL3( MenuBoard_iPhone, setting, signal )
{
    if (IS_USER_Authenticated) {
        [_router open:@"setting" animated:YES];
        [self hideMenu];
    }
    else {
        [Helper showAlertWithTitle:@"温馨提示:)" message:@"请先OA登录" cancelTitle:nil otherTitle:nil];
    }
}

ON_SIGNAL3( MenuBoard_iPhone, login, signal )
{
    if ([USER_DEFAULTS boolForKey:@"IS_USER_Authenticated"]) {
        //TODO: 用户注销登录状态
        [USER_DEFAULTS setBool:NO forKey:@"IS_USER_Authenticated"];
        [USER_DEFAULTS synchronize];
        
        [_menu updateLoginButtonTitle:@"登录"];
    }
    
    [_router open:@"login" animated:YES];
    [self hideMenu];
}

ON_SIGNAL3( MenuBoard_iPhone, about, signal )
{
	[_router open:@"about" animated:YES];
	
	[self hideMenu];
}

- (void)didMenuHidden
{
	_mask.hidden = YES;
}

- (void)didMenuShown
{
	_mask.frame = CGRectMake( 60, 0.0, _router.bounds.size.width - 60.0f, _router.bounds.size.height );
	_mask.hidden = NO;
}

- (void)syncPanPosition
{
	_router.view.frame = CGRectOffset( _origFrame, _router.view.panOffset.x, 0 );
}

- (void)showMenu
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(didMenuShown)];
    
	_router.view.left = 62.0f;
	
	[UIView commitAnimations];
}

- (void)hideMenu
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(didMenuHidden)];
    
	_router.view.left = 0.0f;
	
	[UIView commitAnimations];
}

ON_NOTIFICATION3( SplashBoard_iPhone, PLAY_DONE, notification )
{
	[_splash removeFromSuperview];
	[_splash release];
	_splash = nil;
    
	_menu.view.frame = self.bounds;
	_router.view.frame = self.bounds;
    
	_router.view.backgroundColor = [UIColor blackColor];
	_router.view.alpha = 0.0f;
    
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:1.0f];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(ready)];
	
	_router.view.backgroundColor = [UIColor whiteColor];
	_router.view.alpha = 1.0f;
	
	[UIView commitAnimations];
}

- (void)ready
{
    _menu.view.hidden = NO;
    
    [self showMenu];
}

@end