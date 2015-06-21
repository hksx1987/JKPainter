//
//  ThumbnailCell.m
//  JKPainter
//
//  Created by Jack Huang on 15/5/18.
//  Copyright (c) 2015年 Jack's app for practice. All rights reserved.
//

#import "ThumbnailCell.h"
#import "DeleteControl.h"

@interface ThumbnailCell()
@property (retain, nonatomic) DeleteControl *deleteControl;
@end

@implementation ThumbnailCell

- (void)setUniqueName:(NSString *)uniqueName
{
    if (_uniqueName != uniqueName) {
        if (_uniqueName) [_uniqueName release];
        _uniqueName = [uniqueName copy];
        [self loadImageNamed: uniqueName];
    }
}

- (void)loadImageNamed:(NSString *)imageName
{
    NSString *imagePath = [NSString stringWithFormat: @"%@/%@", [self snapshotFolderPath], imageName];
    NSData *imageData = [NSData dataWithContentsOfFile: imagePath];
    UIImage *image = [UIImage imageWithData: imageData];
    [self loadThumbnailImage: image];
}

- (NSString *)snapshotFolderPath
{
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    return [documentPath stringByAppendingPathComponent: @"SnapshotFolder"];
}

- (void)loadThumbnailImage:(UIImage *)image
{
    if (self.contentView.subviews.count) {
        for (UIView *view in self.contentView.subviews) {
            [view removeFromSuperview];
        }
    }
    UIImageView *imageView = [[UIImageView alloc] initWithFrame: self.contentView.bounds];
    imageView.image = image;
    [self.contentView addSubview: imageView];
    [imageView release];
}

#define kDeleteButtonSize (self.contentView.bounds.size.width/4)
#define kDeleteButtonInsetSpace 5.0

- (DeleteControl *)deleteControl
{
    if (!_deleteControl) {
        CGRect frame = CGRectMake(kDeleteButtonInsetSpace, kDeleteButtonInsetSpace, kDeleteButtonSize, kDeleteButtonSize);
        _deleteControl = [[DeleteControl alloc] initWithFrame: frame];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(deleteAction:)];
        [_deleteControl addGestureRecognizer: tap];
        [_deleteControl setNeedsDisplay];
        [tap release];
    }
    return _deleteControl;
}

- (void)showDeleteButtonAnimated:(BOOL)animated
{
    if (![self.contentView.subviews containsObject: self.deleteControl]) {
        [self.contentView addSubview: self.deleteControl];
        if (animated) {
            self.deleteControl.alpha = 0.0;
            self.deleteControl.transform = CGAffineTransformMakeRotation(45.0*M_PI/180);
            [UIView animateWithDuration: 0.5 animations: ^{
                self.deleteControl.alpha = 1.0;
                self.deleteControl.transform = CGAffineTransformIdentity;
            } completion: nil];
        }
    }
}

- (void)hideDeleteButtonAnimated:(BOOL)animated
{
    if (self.deleteControl) {
        if (animated) {
            self.deleteControl.alpha = 1.0;
            self.deleteControl.transform = CGAffineTransformIdentity;
            [UIView animateWithDuration: 0.5 animations: ^{
                self.deleteControl.alpha = 0.0;
                self.deleteControl.transform = CGAffineTransformMakeRotation(-45.0*M_PI/180);
            } completion: ^(BOOL finished){
                [self.deleteControl removeFromSuperview];
            }];
        } else {
            [self.deleteControl removeFromSuperview];
        }
    }
}

- (void)deleteAction:(UITapGestureRecognizer *)gesture
{
    [self.delegate deleteCell: self];
}

- (void)dealloc
{
    [_deleteControl release];
    [_uniqueName release];
    [super dealloc];
}

@end


//@interface ThumbnailContentView : UIView
//@property (retain, nonatomic) UIImage *thumbnailImage;
//@end
//
//@implementation ThumbnailContentView
//
//- (void)setThumbnailImage:(UIImage *)thumbnailImage
//{
//    if (thumbnailImage != _thumbnailImage) {
//        [_thumbnailImage release];
//        _thumbnailImage = [thumbnailImage retain];
//    }
//    [self setNeedsDisplay];
//}
//
//- (void)drawRect:(CGRect)rect
//{
//    if (self.thumbnailImage) {
//        [self.thumbnailImage drawInRect: rect];
//    }
//}
//
//- (void)dealloc
//{
//    [_thumbnailImage release];
//    [super dealloc];
//}
//
//@end