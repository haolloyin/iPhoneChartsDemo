//
//  DemoDefines.h
//  Demo
//
//  Created by hao on 13-10-1.
//  Copyright (c) 2013年 hao. All rights reserved.
//

#ifndef Demo_DemoDefines_h
#define Demo_DemoDefines_h

//#warning
#define DEMO_DEBUG 						1

#define USER_DEFAULTS                   [NSUserDefaults standardUserDefaults]

#define IS_USER_Authenticated           [USER_DEFAULTS boolForKey:@"IS_USER_Authenticated"]

#if DEMO_DEBUG
	#define SERVER_URL 					@"http://127.0.0.1:8000/mobioss"

#else
	#define SERVER_URL                  @"https://example.com/mobioss"

#endif


#endif
