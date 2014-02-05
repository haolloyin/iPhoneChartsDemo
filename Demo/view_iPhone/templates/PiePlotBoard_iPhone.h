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
//  PiePlotBoard_iPhone.h
//  Demo
//
//  Created by hao on 13-8-13.
//  Copyright (c) 2013年 hao. All rights reserved.
//

#import "Bee.h"
#import "CorePlot-CocoaTouch.h"

#pragma mark -

@interface PiePlotBoard_iPhone : BeeUIBoard < CPTPieChartDataSource, CPTPieChartDelegate >
{
    CPTXYGraph * _graph;
    double _sumOfRecords;
}

@property (nonatomic, strong, readwrite) NSString * title;
@property (nonatomic, strong, readwrite) NSNumber * numberOfPlots;
@property (nonatomic, strong, readwrite) NSNumber * numberOfRecords;
@property (nonatomic, strong, readwrite) NSArray * plotIdentifiers;
@property (nonatomic, strong, readwrite) NSArray * xLabels;
@property (nonatomic, strong, readwrite) NSDictionary * plotDataSource;


- (void)preprocessVars;

- (void)drawGraph;

@end
