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
//  PlotBoard_iPhone.m
//  Demo
//
//  Created by hao on 13-8-12.
//  Copyright (c) 2013年 hao. All rights reserved.
//

#import "PlotBoard_iPhone.h"


#pragma mark -

@interface PlotBoard_iPhone()
{
	//<#@private var#>
}
@end

@implementation PlotBoard_iPhone
{
    NSMutableArray * dataArray;
}

@synthesize dataArray = _dataArray;

SUPPORT_AUTOMATIC_LAYOUT( YES )
SUPPORT_RESOURCE_LOADING( YES )

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
        //初始化数组，并放入十个 0 － 20 间的随机数
        dataArray = [[NSMutableArray alloc] init];
        for(int i=0; i< 10; i++){
            [dataArray addObject:[NSNumber numberWithInt:rand()%20]];
        }
                
        //图形要放在一个 CPTGraphHostingView 中，CPTGraphHostingView 继承自 UIView
        CPTGraphHostingView *hostView = [[CPTGraphHostingView alloc] initWithFrame:self.bounds];
        
        //把 CPTGraphHostingView 加到你自己的 View 中
        [self.view addSubview:hostView];
        hostView.backgroundColor = [UIColor whiteColor];
        
        CPTTheme * theme = [CPTTheme themeNamed:kCPTStocksTheme];
        CPTXYGraph * graph = [[CPTXYGraph alloc] initWithFrame:hostView.frame];
        [graph applyTheme:theme];
        graph.paddingLeft = 40.0;
        graph.paddingBottom = 20.0;
        graph.paddingRight = 20.0;
        graph.paddingTop = 20;
        hostView.hostedGraph = graph;
        
        CPTScatterPlot *scatterPlot = [[CPTScatterPlot alloc] initWithFrame:graph.bounds];
        [graph addPlot:scatterPlot];
        scatterPlot.dataSource = self; //设定数据源，需应用 CPTPlotDataSource 协议
        
        //设置 PlotSpace，这里的 xRange 和 yRange 要理解好，它决定了点是否落在图形的可见区域
        //location 值表示坐标起始值，一般可以设置元素中的最小值
        //length 值表示从起始值上浮多少，一般可以用最大值减去最小值的结果
        //其实我倒觉得，CPTPlotRange:(NSRange) range 好理解些，可以表示值从 0 到 20
        CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) scatterPlot.plotSpace;
        plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0)
                                                        length:CPTDecimalFromFloat([dataArray count]-1)];
        plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0)
                                                        length:CPTDecimalFromFloat(20)];
        
        //下面省去了坐标与线型及其他图形风格的代码
        
        [plotSpace release];
        [graph release];
        [hostView release];
    }
    else if ( [signal is:BeeUIBoard.DELETE_VIEWS] )
    {
        [dataArray release];
    }
    else if ( [signal is:BeeUIBoard.LAYOUT_VIEWS] )
    {
    }
    else if ( [signal is:BeeUIBoard.LOAD_DATAS] )
    {
    }
    else if ( [signal is:BeeUIBoard.FREE_DATAS] )
    {
    }
    else if ( [signal is:BeeUIBoard.WILL_APPEAR] )
    {
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
	}
	else if ( [signal is:BeeUINavigationBar.RIGHT_TOUCHED] )
	{
	}
}

#pragma mark -
//询问有多少个数据，在 CPTPlotDataSource 中声明的
- (NSUInteger) numberOfRecordsForPlot:(CPTPlot *)plot {
    return [dataArray count];
}

//询问一个个数据值，在 CPTPlotDataSource 中声明的
- (NSNumber *) numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    if(fieldEnum == CPTScatterPlotFieldY){    //询问 Y 值时
        return [dataArray objectAtIndex:index];
    }else{                                    //询问 X 值时
        return [NSNumber numberWithInt:index];
    }
}

@end
