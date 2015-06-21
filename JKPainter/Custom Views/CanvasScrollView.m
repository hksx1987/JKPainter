//
//  CanvasScrollView.m
//  JKPainter
//
//  Created by Jack Huang on 15/5/26.
//  Copyright (c) 2015年 Jack's app for practice. All rights reserved.
//

#import "CanvasScrollView.h"

@implementation CanvasScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self) {
        self.scrollEnabled = NO;
        self.minimumZoomScale = 1.0;
        self.maximumZoomScale = CANVAS_MAX_ZOOM_SCALE;
        self.canPerformPinch = NO;
    }
    return self;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    return self.canPerformPinch;
}

@end
