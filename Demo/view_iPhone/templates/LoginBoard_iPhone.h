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
//  LoginBoard_iPhone.h
//  Demo
//
//  Created by hao on 13-9-25.
//  Copyright (c) 2013年 hao. All rights reserved.
//

#import "Bee.h"
#import "TXMobileAuthenticationDelegate.h"
#import "MoaDefines.h"

#pragma mark -

@interface LoginBoard_iPhone : BeeUIBoard <TXMobileAuthenticationDelegate>

@property (nonatomic, copy) LoginCallBackBlock loginCallBackBlock;

@end
