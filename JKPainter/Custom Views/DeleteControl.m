//
//  DeleteControl.m
//  JKPainter
//
//  Created by Jack Huang on 15/5/18.
//  Copyright (c) 2015年 Jack's app for practice. All rights reserved.
//

#import "DeleteControl.h"

CGFloat radians(CGFloat degrees)
{
    return degrees * M_PI / 180;
}

@implementation DeleteControl

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self) {
        self.contentMode = UIViewContentModeRedraw;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGPoint center = CGPointMake(rect.size.width/2, rect.size.height/2);
    CGFloat radius = MIN(rect.size.width/2, rect.size.height/2);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    CGFloat lineWidthFactor = 0.2;
    CGContextSetLineWidth(context, radius * lineWidthFactor);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    CGContextAddArc(context, center.x, center.y, radius, 0, 2*M_PI, 1);
    
    CGFloat r = radius;
    CGFloat a = (1-0.618/sqrt(2))*r;
    CGFloat b = 2*r-a;
    
    CGContextMoveToPoint(context, a, a);
    CGContextAddLineToPoint(context, b, b);
    CGContextMoveToPoint(context, b, a);
    CGContextAddLineToPoint(context, a, b);
    
    CGContextDrawPath(context, kCGPathFillStroke);
}

@end
