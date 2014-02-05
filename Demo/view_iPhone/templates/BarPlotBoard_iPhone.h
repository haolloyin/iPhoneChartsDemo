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
//  BarPlotBoard_iPhone.h
//  Demo
//
//  Created by hao on 13-8-13.
//  Copyright (c) 2013年 hao. All rights reserved.
//

#import "Bee.h"
#import "CorePlot-CocoaTouch.h"

#pragma mark -

@interface BarPlotBoard_iPhone : BeeUIBoard < CPTPlotDataSource, CPTBarPlotDelegate >
{
    CPTXYGraph * _graph;
    CPTPlotSpaceAnnotation * _plotAnnotation;
    NSArray * _colorArray;

    CGFloat _recordInterval;	// 每个点之间的距离
    CGFloat _barWidth;		// 每个柱状的宽度
}

@property (nonatomic, strong, readwrite) NSString * title;
@property (nonatomic, strong, readwrite) NSNumber * numberOfPlots;
@property (nonatomic, strong, readwrite) NSNumber * numberOfRecords;
@property (nonatomic, strong, readwrite) NSArray * plotIdentifiers;
@property (nonatomic, strong, readwrite) NSArray * xLabels;
@property (nonatomic, strong, readwrite) NSDictionary * plotDataSource;

@property (readwrite, nonatomic) double minForY;
@property (readwrite, nonatomic) double maxForY;

- (void)preprocessVars;

- (void)configGraphAndHostView;

- (void)configPlots;

- (void)configAxes;

@end
