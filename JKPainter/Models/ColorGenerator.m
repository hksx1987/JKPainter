//
//  ColorGenerator.m
//  JKPainter
//
//  Created by Jack Huang on 15/5/8.
//  Copyright (c) 2015年 Jack's app for practice. All rights reserved.
//

#import "ColorGenerator.h"

CGFloat modifiedComponent(CGFloat component);

@implementation ColorGenerator

@dynamic generatedColor;

+ (ColorGenerator *)defaultGenerator
{
    static ColorGenerator *defaultGenerator;
    if (!defaultGenerator) {
        defaultGenerator = [[ColorGenerator alloc] init];
    }
    return defaultGenerator;
}

- (void)setRedComponent:(CGFloat)redComponent
{
    _redComponent = modifiedComponent(redComponent);
}

- (void)setGreenComponent:(CGFloat)greenComponent
{
    _greenComponent = modifiedComponent(greenComponent);
}

- (void)setBlueComponent:(CGFloat)blueComponent
{
    _blueComponent = modifiedComponent(blueComponent);
}

- (UIColor *)generatedColor
{
    return [UIColor colorWithRed: self.redComponent
                           green: self.greenComponent
                            blue: self.blueComponent
                           alpha: 1.0];
}

- (void)dealloc
{
    [super dealloc];
}

@end

CGFloat modifiedComponent(CGFloat component)
{
    if (component < 0.0) {
        component = 0.0;
    } else if (component > 1.0) {
        component = 1.0;
    }
    return component;
}
