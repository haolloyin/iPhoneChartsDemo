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
//  MenuBoard_iPhone.h
//  Demo
//
//  Created by hao on 13-9-24.
//  Copyright (c) 2013年 hao. All rights reserved.
//

#import "Bee.h"

#pragma mark -

@interface MenuBoard_iPhone : BeeUIBoard

AS_SINGLETON( MenuBoard_iPhone )

- (void)selectItem:(NSString *)item animated:(BOOL)animated;

- (void)updateLoginButtonTitle:(NSString *)title;

@end
