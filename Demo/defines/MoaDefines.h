//
//  MoaDefines.h
//  Demo
//
//  Created by hao on 13-10-1.
//  Copyright (c) 2013年 hao. All rights reserved.
//

#ifndef Demo_MoaDefines_h
#define Demo_MoaDefines_h

#define MOA_APPKEY          @"my_appkey"        // MOA 分配的 AppKey
#define NEED_SIGNIN         YES                 // DEBUG 时用于模拟是否需要进行 OA 登录

typedef void(^LoginCallBackBlock)(id viewController, BOOL shouldSignIn);

#endif
