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
//  AppBoard_iPhone.h
//  Demo
//
//  Created by hao on 13-8-10.
//  Copyright (c) 2013年 hao. All rights reserved.
//

#import "Bee.h"

@interface AppBoard_iPhone : BeeUIBoard

AS_SINGLETON( AppBoard_iPhone );

- (void)showMenu;
- (void)hideMenu;

@end
