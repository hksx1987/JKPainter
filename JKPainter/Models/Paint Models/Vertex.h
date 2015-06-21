//
//  Vertex.h
//  JKPainter
//
//  Created by Jack Huang on 15/5/8.
//  Copyright (c) 2015年 Jack's app for practice. All rights reserved.
//

#import "Mark.h"

@interface Vertex : NSObject <Mark>

@property (nonatomic, assign) CGPoint location;

/* designated init */
- (instancetype)initWithLocation:(CGPoint)location;

@end
