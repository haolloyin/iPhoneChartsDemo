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
//  MenuBoard_iPhone.m
//  Demo
//
//  Created by hao on 13-9-24.
//  Copyright (c) 2013年 hao. All rights reserved.
//

#import "AppBoard_iPhone.h"
#import "MenuBoard_iPhone.h"

#pragma mark -

@interface MenuBoard_iPhone()
{
	//<#@private var#>
}
@end

@implementation MenuBoard_iPhone

DEF_SINGLETON( MenuBoard_iPhone );

SUPPORT_AUTOMATIC_LAYOUT( YES );
SUPPORT_RESOURCE_LOADING( YES );

ON_SIGNAL2( BeeUIBoard, signal )
{
	[super handleUISignal:signal];
	
	if ( [signal is:BeeUIBoard.CREATE_VIEWS] )
	{
		self.view.backgroundColor = RGB(15, 15, 15);
		[self hideNavigationBarAnimated:NO];
	}
	else if ( [signal is:BeeUIBoard.DELETE_VIEWS] )
	{
	}
}

- (void)selectItem:(NSString *)item animated:(BOOL)animated
{
	if ( animated )
	{
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.3f];
	}
    
	$(@"item-bg").view.frame = $(item).view.frame;
	
	if ( animated )
	{
		[UIView commitAnimations];
	}
}

- (void)updateLoginButtonTitle:(NSString *)title
{
    $(@"#login_label").DATA(title);
}

@end
