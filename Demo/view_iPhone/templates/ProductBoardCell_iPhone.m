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
//  ProductBoardCell_iPhone.m
//  Demo
//
//  Created by hao on 13-8-10.
//  Copyright (c) 2013年 hao. All rights reserved.
//

#import "ProductBoardCell_iPhone.h"

#pragma mark -

@implementation ProductBoardCell_iPhone

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
    NSDictionary * productInfo = self.data;
    if ( productInfo ) {
        $(@"#product-name").DATA( [productInfo objectForKey:@"name_cn"] );
        $(@"#product-logo").DATA( [productInfo objectForKey:@"logo"] );
    }
}

@end
