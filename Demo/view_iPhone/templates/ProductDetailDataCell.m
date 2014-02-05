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
//  ProductDetailDataCell.m
//  Demo
//
//  Created by hao on 13-10-3.
//  Copyright (c) 2013年 hao. All rights reserved.
//

#import "ProductDetailDataCell.h"

#pragma mark -

@implementation ProductDetailDataCell

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
    NSDictionary * data = self.data;
    if ( data ) {
        NSString * title = nil;
        if ( [data[@"is_folder"] isEqualToString:@"true"] ) {
            title = [NSString stringWithFormat:@"%@", data[@"sub_title"]];
        }
        else {
            title = [NSString stringWithFormat:@"%@ (%@)", data[@"sub_title"], data[@"chart_type"]];
        }
        
        $(@"#data_title").DATA( title );
        $(@"#content_desc").DATA( data[@"content_desc"] );
    }
}

@end
