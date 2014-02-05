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
//  ProductDetailBoardCell_iPhone.m
//  Demo
//
//  Created by hao on 13-8-11.
//  Copyright (c) 2013年 hao. All rights reserved.
//

#import "ProductDetailBoardCell_iPhone.h"

#pragma mark -

@interface ProductDetailBoardCell_iPhone()
{
	//<#@private var#>
}
@end

@implementation ProductDetailBoardCell_iPhone

SUPPORT_AUTOMATIC_LAYOUT( YES )
SUPPORT_RESOURCE_LOADING( YES )

- (void)load
{
}

- (void)unload
{
}

- (void)dataDidChanged
{
    NSDictionary * indexs = self.data;
    if ( indexs ) {
        $(@"#realtime_online_desc").DATA( [indexs objectForKey:@"realtime_online_desc"] );
        $(@"#act_user_desc").DATA( [indexs objectForKey:@"act_user_desc"] );
        $(@"#new_user_desc").DATA( [indexs objectForKey:@"new_user_desc"] );
        $(@"#income_desc").DATA( [indexs objectForKey:@"income_desc"] );
    }
}

@end
