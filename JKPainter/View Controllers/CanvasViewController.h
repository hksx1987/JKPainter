//
//  CanvasViewController.h
//  JKPainter
//
//  Created by Jack Huang on 15/5/8.
//  Copyright (c) 2015年 Jack's app for practice. All rights reserved.
//

#import "CoordinatingViewController.h"

#define SNAPSHOT_FOLDER @"SnapshotFolder"
#define MARKDATA_FOLDER @"MarkDataFolder"

@class ColorGenerator;

@interface CanvasViewController : CoordinatingViewController {
        
    ColorGenerator *colorGenerator;
    CGFloat dotSize;
    UIColor *dotColor;
    NSString *artworkName;
}

@property (nonatomic, assign) ColorGenerator *colorGenerator;
@property (nonatomic) CGFloat dotSize;
@property (nonatomic, copy) UIColor *dotColor;
@property (nonatomic, copy) NSString *artworkName;

@end
