//
//  Dot.m
//  JKPainter
//
//  Created by Jack Huang on 15/5/8.
//  Copyright (c) 2015年 Jack's app for practice. All rights reserved.
//

#import "Dot.h"

#define DOT_COLOR_CODING_KEY @"DOT_COLOR_CODING_KEY"
#define DOT_SIZE_CODING_KEY @"DOT_SIZE_CODING_KEY"

@implementation Dot

@synthesize color = _color;
@synthesize size = _size;

- (instancetype)initWithColor:(UIColor *)color
                         size:(CGFloat)size
                     location:(CGPoint)location
{
    self = [super initWithLocation: location];
    if (self) {
        _color = [color retain];
        _size = size;
    }
    return self;
}

- (void)drawWithContext:(CGContextRef)context
{
    CGPoint location = self.location;
    CGFloat size = self.size;
    CGRect rect = CGRectMake(location.x-size/2.0, location.y-size/2.0, size, size);
    CGContextSetFillColorWithColor(context, self.color.CGColor);
    CGContextFillEllipseInRect(context, rect);
}

#pragma mark - copy

- (id)copyWithZone:(NSZone *)zone
{
    Dot *copyedDot = [[Dot allocWithZone: zone] initWithColor: self.color
                                                         size: self.size
                                                     location: self.location];
    return copyedDot;
}

#pragma mark - coding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder: aCoder];
    [aCoder encodeObject: self.color forKey: DOT_COLOR_CODING_KEY];
    [aCoder encodeObject: @(self.size) forKey: DOT_SIZE_CODING_KEY];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    if (self) {
        _color = [[aDecoder decodeObjectForKey: DOT_COLOR_CODING_KEY] retain];
        _size = (CGFloat)[[aDecoder decodeObjectForKey: DOT_SIZE_CODING_KEY] floatValue];
    }
    return self;
}

- (void)dealloc
{
    [_color release];
    [super dealloc];
}

@end
