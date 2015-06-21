//
//  UIView+Image.m
//  JKPainter
//
//  Created by Jack Huang on 15/5/17.
//  Copyright (c) 2015年 Jack's app for practice. All rights reserved.
//

#import "UIView+Image.h"

@implementation UIView (Image)

- (UIImage *)capturedImage
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext: context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
