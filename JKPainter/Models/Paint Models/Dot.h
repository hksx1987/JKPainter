//
//  Dot.h
//  JKPainter
//
//  Created by Jack Huang on 15/5/8.
//  Copyright (c) 2015年 Jack's app for practice. All rights reserved.
//

#import "Vertex.h"

@interface Dot : Vertex

@property (nonatomic, retain) UIColor *color;
@property (nonatomic, assign) CGFloat size;

/* designated init */
- (instancetype)initWithColor:(UIColor *)color
                         size:(CGFloat)size
                     location:(CGPoint)location;

@end
