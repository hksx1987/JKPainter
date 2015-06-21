//
//  GalleryCollectionViewController.h
//  JKPainter
//
//  Created by Jack Huang on 15/5/17.
//  Copyright (c) 2015年 Jack's app for practice. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GalleryCollectionViewController : UICollectionViewController

@property (copy, nonatomic) NSString *selectedArtworkName;

- (void)switchEditingMode;

@end
