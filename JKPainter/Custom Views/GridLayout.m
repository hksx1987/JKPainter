//
//  GridLayout.m
//  JKPainter
//
//  Created by Jack Huang on 15/5/18.
//  Copyright (c) 2015年 Jack's app for practice. All rights reserved.
//

#import "GridLayout.h"

#define INNER_SPACE 12.0
#define CELL_COLUMN 4

@implementation GridLayout {
    CGFloat pinchScale;
    CGPoint pinchCenter;
    CGPoint originalCenter;
    NSIndexPath *pinchIndexPath;
    NSInteger zIndexValue;
}

@synthesize pinchScale;
@synthesize pinchCenter;
@synthesize pinchIndexPath;

- (void)dealloc
{
    [pinchIndexPath release];
    [super dealloc];
}

- (void)setPinchScale:(CGFloat)newScale
{
    pinchScale = newScale;
    zIndexValue = 1.0;
    [self invalidateLayout];
}

- (void)setPinchCenter:(CGPoint)newCenter
{
    pinchCenter = newCenter;
    zIndexValue = 1.0;
    [self invalidateLayout];
}

- (void)prepareLayout
{
    [super prepareLayout];
    self.itemSize = [self cellSize];
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.sectionInset = UIEdgeInsetsMake(INNER_SPACE,INNER_SPACE,INNER_SPACE,INNER_SPACE);
    self.minimumInteritemSpacing = INNER_SPACE;
    self.minimumLineSpacing = INNER_SPACE;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *allAttributesInRect = [super layoutAttributesForElementsInRect:rect];
    for (UICollectionViewLayoutAttributes *attributes in allAttributesInRect) {
        [self applyPinchResultToAttributes:attributes];
    }
    return allAttributesInRect;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    [self applyPinchResultToAttributes:attributes];
    return attributes;
}

- (void)applyPinchResultToAttributes:(UICollectionViewLayoutAttributes *)attributes
{
    if (pinchIndexPath) {
        if ([attributes.indexPath isEqual:pinchIndexPath]) {
            originalCenter = attributes.center;
            attributes.center = pinchCenter;
            attributes.transform3D = CATransform3DMakeScale(pinchScale, pinchScale, 1.0);
            attributes.zIndex = zIndexValue;
        }
    }
}

- (void)applyBackToOriginalAttributesAfterPinch
{
    [self.collectionView performBatchUpdates:^{
        zIndexValue = 0.0;
        pinchScale = 1.0;
        pinchCenter = originalCenter;
    } completion:^(BOOL finished){
        pinchIndexPath = nil; // 忽略这里会产生悬挂指针！
    }];
}

#pragma mark - helper

- (CGSize)cellSize
{
    CGSize cellSize;  CGFloat w;
    
    w = ([self viewWidth] - 2 * INNER_SPACE) / [self cellColumn]; //CELL_COLUMN;
    cellSize.width = w - INNER_SPACE;
    cellSize.height = w / [self viewRatio];
    
    return cellSize;
}

- (NSUInteger)cellColumn
{
    return [self viewWidth] < 400 ? 2 : 4;
}

- (CGFloat)viewRatio
{
    return [self viewWidth] / [self viewHeight];
}

- (CGFloat)viewWidth
{
    return self.collectionView.bounds.size.width;
}

- (CGFloat)viewHeight
{
    return self.collectionView.bounds.size.height;
}

@end
