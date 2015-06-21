//
//  ThumbnailCell.h
//  JKPainter
//
//  Created by Jack Huang on 15/5/18.
//  Copyright (c) 2015年 Jack's app for practice. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ThumbnailCell;

@protocol ThumbnailCellDeletionTrigerDelegate
- (void)deleteCell:(ThumbnailCell *)cell;
@end


@interface ThumbnailCell : UICollectionViewCell

@property (copy, nonatomic) NSString *uniqueName;
@property (assign, nonatomic) id <ThumbnailCellDeletionTrigerDelegate> delegate;

- (void)showDeleteButtonAnimated:(BOOL)animated;
- (void)hideDeleteButtonAnimated:(BOOL)animated;

@end
