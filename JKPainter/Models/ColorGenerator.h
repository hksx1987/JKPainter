//
//  ColorGenerator.h
//  JKPainter
//
//  Created by Jack Huang on 15/5/8.
//  Copyright (c) 2015年 Jack's app for practice. All rights reserved.
//

#import <CoreGraphics/CGGeometry.h>
#import <UIKit/UIColor.h>

@interface ColorGenerator : NSObject

@property (nonatomic) CGFloat redComponent; // 0.0 ~ 1.0
@property (nonatomic) CGFloat greenComponent;
@property (nonatomic) CGFloat blueComponent;

@property (nonatomic, readonly) UIColor *generatedColor;

+ (ColorGenerator *)defaultGenerator;

@end
