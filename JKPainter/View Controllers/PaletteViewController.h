//
//  PaletteViewController.h
//  JKPainter
//
//  Created by Jack Huang on 15/5/8.
//  Copyright (c) 2015年 Jack's app for practice. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ColorGenerator;
@class StrokePreview;

@interface PaletteViewController : UIViewController

@property (retain, nonatomic) IBOutlet UISlider *redValueSlider;
@property (retain, nonatomic) IBOutlet UISlider *greenValueSlider;
@property (retain, nonatomic) IBOutlet UISlider *blueValueSlider;
@property (retain, nonatomic) IBOutlet UIView *colorPreview;

@property (retain, nonatomic) IBOutlet UISlider *strokeValueSlider;
@property (retain, nonatomic) IBOutlet StrokePreview *strokePreview;

@property (nonatomic, assign) ColorGenerator *colorGenerator;
@property (nonatomic) CGFloat dotSize;

@end
