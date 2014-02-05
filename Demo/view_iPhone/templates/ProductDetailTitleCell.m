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
//  ProductDetailTitleCell.m
//  Demo
//
//  Created by hao on 13-10-3.
//  Copyright (c) 2013年 hao. All rights reserved.
//

#import "ProductDetailTitleCell.h"

#pragma mark -

@implementation ProductDetailTitleCell

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
    // TODO: fill data
    NSString * title = self.data;
    if ( title ) {
        $(@"#section_title").DATA( title );
    }
}

@end
