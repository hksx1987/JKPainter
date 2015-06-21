//
//  Vertex.m
//  JKPainter
//
//  Created by Jack Huang on 15/5/8.
//  Copyright (c) 2015年 Jack's app for practice. All rights reserved.
//

#import "Vertex.h"
#import <UIKit/UIGeometry.h>

#define VERTEX_LOCATION_CODING_KEY @"VERTEX_LOCATION_CODING_KEY"

@implementation Vertex

- (instancetype)initWithLocation:(CGPoint)location
{
    self = [super init];
    if (self) {
        _location = location;
    }
    return self;
}

@synthesize location = _location;

- (void)drawWithContext:(CGContextRef)context
{
    CGContextAddLineToPoint(context, self.location.x, self.location.y);
}

#pragma mark - copy

- (id)copyWithZone:(NSZone *)zone
{
    Vertex *copyedVertex = [[Vertex allocWithZone: zone] initWithLocation: self.location];
    return copyedVertex;
}

#pragma mark - coding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeCGPoint: self.location forKey: VERTEX_LOCATION_CODING_KEY];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _location = [aDecoder decodeCGPointForKey: VERTEX_LOCATION_CODING_KEY];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end
