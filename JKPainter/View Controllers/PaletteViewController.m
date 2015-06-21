//
//  PaletteViewController.m
//  JKPainter
//
//  Created by Jack Huang on 15/5/8.
//  Copyright (c) 2015年 Jack's app for practice. All rights reserved.
//

#import "PaletteViewController.h"
#import "ColorGenerator.h"
#import "PainterKeys.h"
#import "StrokePreview.h"

@interface PaletteViewController () 
@end

@implementation PaletteViewController

- (ColorGenerator *)colorGenerator
{
    if (!_colorGenerator) {
        _colorGenerator = [ColorGenerator defaultGenerator];
    }
    return _colorGenerator;
}

- (CGFloat)dotSize
{
    return [self dotSizeFromSliderValue: self.strokeValueSlider.value];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setupValuesForDisplay
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *storedRed = [defaults objectForKey: RED_COMPONENT_STORE_KEY];
    NSNumber *storedGreen = [defaults objectForKey: GREEN_COMPONENT_STORE_KEY];
    NSNumber *storedBlue = [defaults objectForKey: BLUE_COMPONENT_STORE_KEY];
    
    self.colorGenerator.redComponent = storedRed ? (CGFloat)[storedRed floatValue] : 0.5;
    self.colorGenerator.greenComponent = storedGreen ? (CGFloat)[storedGreen floatValue] : 0.5;
    self.colorGenerator.blueComponent = storedBlue ? (CGFloat)[storedBlue floatValue] : 0.5;
    
    self.redValueSlider.value = self.colorGenerator.redComponent;
    self.greenValueSlider.value = self.colorGenerator.greenComponent;
    self.blueValueSlider.value = self.colorGenerator.blueComponent;
    
    NSNumber *storedDotSize = [defaults objectForKey: STROKE_WIDTH_STRORE_KEY];
    float dotSize = storedDotSize ? (CGFloat)[storedDotSize floatValue] : 5.0;
    float sliderValue = [self sliderValueFromDotSize: dotSize];
    self.strokeValueSlider.value = sliderValue;
    self.strokePreview.dotSize = dotSize;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [self setupValuesForDisplay];
    [self updatePreviews];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: @(self.colorGenerator.redComponent) forKey: RED_COMPONENT_STORE_KEY];
    [defaults setObject: @(self.colorGenerator.greenComponent) forKey: GREEN_COMPONENT_STORE_KEY];
    [defaults setObject: @(self.colorGenerator.blueComponent) forKey: BLUE_COMPONENT_STORE_KEY];
    
    CGFloat dotSize = [self dotSizeFromSliderValue: self.strokeValueSlider.value];
    [defaults setObject: @(dotSize) forKey: STROKE_WIDTH_STRORE_KEY];
    
    [defaults synchronize];
}

- (void)updatePreviews
{
    self.colorPreview.backgroundColor = self.colorGenerator.generatedColor;
    self.strokePreview.dotColor = self.colorGenerator.generatedColor;
    [self.colorPreview setNeedsDisplay];
    [self.strokePreview setNeedsDisplay];
}

- (IBAction)dragSlider:(UISlider *)sender
{
    if (sender == self.redValueSlider) {
        self.colorGenerator.redComponent = sender.value;
    } else if (sender == self.greenValueSlider) {
        self.colorGenerator.greenComponent = sender.value;
    } else if (sender == self.blueValueSlider) {
        self.colorGenerator.blueComponent = sender.value;
    }
    [self updatePreviews];
}

- (IBAction)drawStrokeSlider:(UISlider *)sender
{
    CGFloat dotSize = [self dotSizeFromSliderValue: sender.value];
    self.strokePreview.dotSize = dotSize;
    [self.strokePreview setNeedsDisplay];
}

- (CGFloat)dotSizeFromSliderValue:(float)sliderValue
{
    return sliderValue * 10.0 + 1.0;
}

- (float)sliderValueFromDotSize:(CGFloat)dotSize
{
    return (dotSize - 1.0) / 10.0;
}

- (void)dealloc
{
    [_redValueSlider release];
    [_greenValueSlider release];
    [_blueValueSlider release];
    [_colorPreview release];
    [_strokeValueSlider release];
    [_strokePreview release];
    [super dealloc];
}
@end
