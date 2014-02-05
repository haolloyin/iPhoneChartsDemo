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
//  ProductBoard_iPhone.m
//  Demo
//
//  Created by hao on 13-8-10.
//  Copyright (c) 2013年 hao. All rights reserved.
//

#import "AppBoard_iPhone.h"
#import "ProductBoard_iPhone.h"
#import "ProductBoardCell_iPhone.h"
#import "ProductDetailBoard_iPhone.h"
#import "ServerAPI.h"
#import "Helper.h"

#pragma mark -

@interface ProductBoard_iPhone()
{
	//<#@private var#>
}
@end

@implementation ProductBoard_iPhone
{
	BeeUIScrollView *	_scroll;
    NSArray * products;
}

@synthesize products = _products;

SUPPORT_AUTOMATIC_LAYOUT( YES );
SUPPORT_RESOURCE_LOADING( YES );

- (void)load
{
    
}

- (void)unload
{
    [self.products release];
    self.products = nil;
}

ON_SIGNAL2( BeeUIBoard, signal )
{
	[super handleUISignal:signal];
	
	if ( [signal is:BeeUIBoard.CREATE_VIEWS] )
	{
		self.view.backgroundColor = SHORT_RGB( 0x333 );
        self.view.backgroundImage = [UIImage imageNamed:@"bg1.png"];
		
		[self showNavigationBarAnimated:NO];
		[self showBarButton:BeeUINavigationBar.LEFT image:[UIImage imageNamed:@"menu-button.png"]];
		[self setTitleString:@"产品列表"];
		
		_scroll = [BeeUIScrollView new];
		_scroll.dataSource = self;
        _scroll.lineCount = 4;
		_scroll.vertical = YES;
        [_scroll setBaseInsets:UIEdgeInsetsMake( 0, 0, 44 + 44, 0 )];
		[_scroll showHeaderLoader:YES animated:NO];
		[self.view addSubview:_scroll];

	}
	else if ( [signal is:BeeUIBoard.DELETE_VIEWS] )
	{
		SAFE_RELEASE_SUBVIEW( _scroll );
	}
	else if ( [signal is:BeeUIBoard.LAYOUT_VIEWS] )
	{
		_scroll.frame = self.viewBound;
	}
	else if ( [signal is:BeeUIBoard.WILL_APPEAR] )
	{
        self.MSG( ServerAPI.GET_USER_PRODUCTS );	// 获取用户的产品列表
        [_scroll asyncReloadData];
	}
}

ON_SIGNAL3( BeeUINavigationBar, LEFT_TOUCHED, signal )
{
	[[AppBoard_iPhone sharedInstance] showMenu];
}

#pragma mark - 下拉/触底刷新

ON_SIGNAL2( BeeUIScrollView, signal )
{
	[super handleUISignal:signal];
	
	if ( [signal is:BeeUIScrollView.HEADER_REFRESH] )
	{
		self.MSG( ServerAPI.GET_USER_PRODUCTS );
	}
	else if ( [signal is:BeeUIScrollView.REACH_BOTTOM] )
	{
		// TODO 触底应该是 append 到队尾而不是整个刷新并回到顶部
		//self.MSG( ServerAPI.GET_USER_PRODUCTS );
	}
}

#pragma mark - 处理 Controller 消息

- (void)handleMessage:(BeeMessage *)msg
{
	[super handleMessage:msg];
	if ( [msg is:ServerAPI.GET_USER_PRODUCTS] ) {
		if ( msg.succeed ) {
			NSArray * resp = msg.GET_OUTPUT( @"response" );
			self.products = resp;
            
			[_scroll asyncReloadData];
            
            [_scroll setHeaderLoading:NO];
		}
	}
}

#pragma  mark - 点击各个 Product 的图标，进入到业务详细页面

ON_SIGNAL3( ProductBoardCell_iPhone, mask, signal )
{
	ProductDetailBoard_iPhone * board = [ProductDetailBoard_iPhone board];
	[board setTitleString:[NSString stringWithFormat:@"%@详情", signal.sourceCell.data[@"name_cn"]]];
	[board.navigationController.navigationBar setTitleTextAttributes:[Helper fontDictWithFontSize:12.0f andColor:[UIColor whiteColor]]];
	NSDictionary * infoDict = @{
		@"productName": signal.sourceCell.data[@"product"]
    };
	[board setProductInfo:infoDict];
	
	// 访问 server
	board.MSG( ServerAPI.GET_PRODUCT_DETAIL ).INPUT( @"productName", signal.sourceCell.data[@"product"] );

	[self.stack pushBoard:board animated:YES];
}

#pragma mark - 

- (NSInteger)numberOfViewsInScrollView:(BeeUIScrollView *)scrollView
{
	return [self.products count];
}

- (UIView *)scrollView:(BeeUIScrollView *)scrollView viewForIndex:(NSInteger)index scale:(CGFloat)scale
{
	ProductBoardCell_iPhone * cell = [scrollView dequeueWithContentClass:[ProductBoardCell_iPhone class]];
	cell.data = [self.products safeObjectAtIndex:index];
	return cell;
}

- (CGSize)scrollView:(BeeUIScrollView *)scrollView sizeForIndex:(NSInteger)index
{    
    return [ProductBoardCell_iPhone estimateUISizeByWidth:scrollView.width / 4.0f - 2.0f
                                                  forData:[self.products safeObjectAtIndex:index]];
}

@end
