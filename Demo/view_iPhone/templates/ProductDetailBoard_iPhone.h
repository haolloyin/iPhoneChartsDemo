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
//  ProductDetailBoard_iPhone.h
//  Demo
//
//  Created by hao on 13-8-11.
//  Copyright (c) 2013年 hao. All rights reserved.
//

#import "Bee.h"

#pragma mark -

@interface ProductDetailBoard_iPhone : BeeUIBoard

@property (nonatomic, retain) NSArray * details;
@property (nonatomic, retain) NSMutableArray * sectionIndex;
@property (nonatomic, retain) NSMutableArray * dataRows;
@property (nonatomic, readwrite) int rowCount;
@property (nonatomic, retain) NSDictionary * productInfo;

@end
