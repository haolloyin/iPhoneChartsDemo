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
//  ProductDetailBoard_iPhone.m
//  Demo
//
//  Created by hao on 13-8-11.
//  Copyright (c) 2013年 hao. All rights reserved.
//

#import "ProductDetailBoard_iPhone.h"
#import "ProductDetailBoardCell_iPhone.h"
#import "ProductDetailTitleCell.h"
#import "ProductDetailDataCell.h"
#import "BarPlotBoard_iPhone.h"
#import "PiePlotBoard_iPhone.h"
#import "ScatterPlotBoard_iPhone.h"
#import "ServerAPI.h"

#pragma mark -

@interface ProductDetailBoard_iPhone()
{
	//<#@private var#>
}
@end

@implementation ProductDetailBoard_iPhone
{
    BeeUIScrollView * _scroll;
    NSArray * details;
    NSMutableArray * sectionIndex;     // 所有 section 的下标 index
    NSMutableArray * dataRows;
    NSDictionary * productInfo;         // product/ next_id/ is_folder
}

@synthesize details = _details;
@synthesize sectionIndex = _sectionIndex;
@synthesize dataRows = _dataRows;
@synthesize productInfo = _productInfo;

SUPPORT_AUTOMATIC_LAYOUT( YES );
SUPPORT_RESOURCE_LOADING( YES );

- (void)load
{
	[super load];
}

- (void)unload
{
	[super unload];
}

#pragma mark Signal

ON_SIGNAL2( BeeUIBoard, signal )
{
    [super handleUISignal:signal];

    if ( [signal is:BeeUIBoard.CREATE_VIEWS] )
    {
        self.view.backgroundColor = SHORT_RGB( 0x333 );
		
		[self showNavigationBarAnimated:NO];
		[self showBarButton:BeeUINavigationBar.LEFT image:[UIImage imageNamed:@"navigation-back.png"]];
		        
		_scroll = [BeeUIScrollView new];
		_scroll.dataSource = self;
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
        _scroll.frame = self.view.bounds;
    }
    else if ( [signal is:BeeUIBoard.LOAD_DATAS] )
    {
    }
    else if ( [signal is:BeeUIBoard.FREE_DATAS] )
    {
    }
    else if ( [signal is:BeeUIBoard.WILL_APPEAR] )
    {
        [_scroll asyncReloadData];
    }
    else if ( [signal is:BeeUIBoard.DID_APPEAR] )
    {
    }
    else if ( [signal is:BeeUIBoard.WILL_DISAPPEAR] )
    {
    }
    else if ( [signal is:BeeUIBoard.DID_DISAPPEAR] )
    {
    }
}

ON_SIGNAL2( BeeUINavigationBar, signal )
{
	[super handleUISignal:signal];
	
	if ( [signal is:BeeUINavigationBar.LEFT_TOUCHED] )
	{
        [self.stack popBoardAnimated:YES];
	}
	else if ( [signal is:BeeUINavigationBar.RIGHT_TOUCHED] )
	{
	}
}

ON_SIGNAL3( ProductDetailDataCell, data_btn, signal)
{
    if ( [signal.sourceCell.data[@"is_folder"] isEqualToString:@"true"] ) {
        // 如果是二级目录，点击进入新的列表页面
        ProductDetailBoard_iPhone * board = [ProductDetailBoard_iPhone board];
        NSDictionary * infoDict = @{
            @"productName": self.productInfo[@"productName"],
            @"next_id": signal.sourceCell.data[@"next_id"],
            @"is_menu": @"true"
        };
        [board setProductInfo:infoDict];
        [board setTitleString:[NSString stringWithFormat:@"%@", signal.sourceCell.data[@"sub_title"]]];

        // 访问 server
        board.MSG( ServerAPI.GET_MENU_DETAIL ).INPUT( @"subMenuInfo", infoDict );
        [self.stack pushBoard:board animated:YES];
    }
    else {
        NSString * chartClassName = [NSString stringWithFormat:@"%@PlotBoard_iPhone", signal.sourceCell.data[@"chart_type"]];
        BeeUIBoard * board = [NSClassFromString(chartClassName) board]; // 赋值给父类实例
        [board setTitleString:[NSString stringWithFormat:@"%@", signal.sourceCell.data[@"sub_title"]]];

        NSDictionary * infoDict = @{
            @"productName": self.productInfo[@"productName"],
            @"next_id": signal.sourceCell.data[@"next_id"]
        };

        // 访问 server
        if ([signal.sourceCell.data[@"chart_type"] isEqualToString:@"Scatter"]) {
            ((ScatterPlotBoard_iPhone *)board).MSG( ServerAPI.GET_PAGE_DETAIL ).INPUT( @"pageInfo", infoDict );
        } 
        else if ([signal.sourceCell.data[@"chart_type"] isEqualToString:@"Bar"]) {
            ((BarPlotBoard_iPhone *)board).MSG( ServerAPI.GET_PAGE_DETAIL ).INPUT( @"pageInfo", infoDict );
        }
        else if ([signal.sourceCell.data[@"chart_type"] isEqualToString:@"Pie"]) {
            ((PiePlotBoard_iPhone *)board).MSG( ServerAPI.GET_PAGE_DETAIL ).INPUT( @"pageInfo", infoDict );
        }

        [self.stack pushBoard:board animated:YES];
    }
}

#pragma mark - 下拉/触底刷新

ON_SIGNAL2( BeeUIScrollView, signal )
{
    [super handleUISignal:signal];
    
    if ( [signal is:BeeUIScrollView.HEADER_REFRESH] )
    {
        if ([self.productInfo[@"is_menu"] isEqualToString:@"true"]) {
            self.MSG( ServerAPI.GET_MENU_DETAIL ).INPUT( @"subMenuInfo", self.productInfo );
        }
        else {
            self.MSG( ServerAPI.GET_PRODUCT_DETAIL ).INPUT( @"productName", self.productInfo[@"productName"] );
        }
    }
    else if ( [signal is:BeeUIScrollView.REACH_BOTTOM] )
    {
    }
}

#pragma mark - 处理 Controller 消息

- (void)handleMessage:(BeeMessage *)msg
{
    [super handleMessage:msg];
    if ( [msg is:ServerAPI.GET_PRODUCT_DETAIL] || [msg is:ServerAPI.GET_MENU_DETAIL]) {
        if ( msg.succeed ) {
            NSArray * resp = msg.GET_OUTPUT( @"response" );
            self.details = resp;
            
            self.rowCount = 0;
            NSMutableArray *indexs = [NSMutableArray arrayWithCapacity:[resp count]];
            NSMutableArray *rows = [NSMutableArray arrayWithCapacity:100];
            
            [indexs addObject:[NSNumber numberWithInt:0]];
            
            for (NSDictionary *section in resp) {
                self.rowCount += [section[@"data_rows"] count] + 1;
                [indexs addObject:[NSNumber numberWithInt:self.rowCount]];
                [rows addObject:section[@"section_title"]];         // trick：直接把标题行也当作数据行，便于下面 cell data 的计算
                [rows addObjectsFromArray:section[@"data_rows"]];
            }
            
            self.sectionIndex = [NSArray arrayWithArray:indexs];
            self.dataRows = [NSArray arrayWithArray:rows];
            
            [_scroll asyncReloadData];
            [_scroll setHeaderLoading:NO];
        }
    }
}

#pragma mark -

- (NSInteger)numberOfViewsInScrollView:(BeeUIScrollView *)scrollView
{
    return [self.dataRows count];
}

- (UIView *)scrollView:(BeeUIScrollView *)scrollView viewForIndex:(NSInteger)index scale:(CGFloat)scale
{
//	ProductDetailBoardCell_iPhone * cell = [scrollView dequeueWithContentClass:[ProductDetailBoardCell_iPhone class]];
//	cell.data = [self.details safeObjectAtIndex:index];
//	return cell;
    
    BeeUICell *cell = nil;
    
    for (int i = 0; i < [self.sectionIndex count] - 1; ++i) {
        NSNumber *num = self.sectionIndex[i];
        if (index == [num integerValue]) {
            cell = [scrollView dequeueWithContentClass:[ProductDetailTitleCell class]];
            cell.data = self.dataRows[index];
            return cell;
        }
    }
    
    cell = [scrollView dequeueWithContentClass:[ProductDetailDataCell class]];
    cell.data = [self.dataRows safeObjectAtIndex:index];
    
    return cell;
}

- (CGSize)scrollView:(BeeUIScrollView *)scrollView sizeForIndex:(NSInteger)index
{
//	return [ProductDetailBoardCell_iPhone estimateUISizeByWidth:scrollView.width -2.0f
//                                                        forData:[self.details safeObjectAtIndex:index]];
    
    for (int i = 0; i < [self.sectionIndex count] - 1; ++i) {
        NSNumber *num = self.sectionIndex[i];
        if (index == [num integerValue]) {
            return [ProductDetailTitleCell estimateUISizeByWidth:scrollView.width - 2.0f
                                                         forData:[self.dataRows safeObjectAtIndex:index]];
        }
    }
    
    return [ProductDetailDataCell estimateUISizeByWidth:scrollView.width - 2.0f
                                                forData:[self.dataRows safeObjectAtIndex:index]];
}

@end
