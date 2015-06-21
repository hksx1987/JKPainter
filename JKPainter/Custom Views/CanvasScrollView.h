//
//  CanvasScrollView.h
//  JKPainter
//
//  Created by Jack Huang on 15/5/26.
//  Copyright (c) 2015年 Jack's app for practice. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CANVAS_MAX_ZOOM_SCALE 3.0

/* This UIScrollView subclass can not perform scrolling */
@interface CanvasScrollView : UIScrollView
@property (nonatomic) BOOL canPerformPinch;     // default is NO
@end
