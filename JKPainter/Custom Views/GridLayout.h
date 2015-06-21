//
//  GridLayout.h
//  JKPainter
//
//  Created by Jack Huang on 15/5/18.
//  Copyright (c) 2015年 Jack's app for practice. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GridLayout : UICollectionViewFlowLayout

@property (nonatomic) CGFloat pinchScale;
@property (nonatomic) CGPoint pinchCenter;
@property (nonatomic, retain) NSIndexPath *pinchIndexPath;

- (void)applyBackToOriginalAttributesAfterPinch;

@end
