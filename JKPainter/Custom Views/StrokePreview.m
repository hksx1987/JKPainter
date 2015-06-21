//
//  StrokePreview.m
//  JKPainter
//
//  Created by Jack Huang on 15/5/11.
//  Copyright (c) 2015年 Jack's app for practice. All rights reserved.
//

#import "StrokePreview.h"

@implementation StrokePreview

- (void)setDotSize:(CGFloat)dotSize
{
    if (dotSize < 0) dotSize = 0;
    CGFloat limitSize = MIN(self.bounds.size.width, self.bounds.size.height);
    if (dotSize > limitSize) dotSize = limitSize;
    _dotSize = dotSize;
}

- (void)drawRect:(CGRect)rect {
    if (self.dotSize > 0) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, self.dotColor.CGColor);
        CGRect dotRect = CGRectMake(rect.size.width/2.0-self.dotSize/2.0, rect.size.height/2.0-self.dotSize/2.0, self.dotSize, self.dotSize);
        CGContextFillEllipseInRect(context, dotRect);
    }
}

- (void)dealloc
{
    [_dotColor release];
    [super dealloc];
}

@end
