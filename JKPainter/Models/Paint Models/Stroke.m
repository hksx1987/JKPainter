//
//  Stroke.m
//  JKPainter
//
//  Created by Jack Huang on 15/5/8.
//  Copyright (c) 2015年 Jack's app for practice. All rights reserved.
//

#import "Stroke.h"
#import "Dot.h"

#define STROKE_COLOR_CODING_KEY @"STROKE_COLOR_CODING_KEY"
#define STROKE_SIZE_CODING_KEY @"STROKE_SIZE_CODING_KEY"
#define STROKE_CHILDREN_CODING_KEY @"STROKE_CHILDREN_CODING_KEY"

@interface Stroke()
@property (nonatomic, retain) NSMutableArray *children;
@end

@implementation Stroke

- (instancetype)initWithColor:(UIColor *)color
                         size:(CGFloat)size
{
    self = [super init];
    if (self) {
        _color = [color retain];
        _size = size;
        _shouldStartNewStroke = YES;
    }
    return self;
}

@synthesize color = _color;
@synthesize size = _size;

@dynamic location; // 告知编译器不要生成默认版本的setter和getter

- (CGPoint)location
{
    id <Mark> firstChild = self.children.firstObject;
    return firstChild ? firstChild.location : CGPointZero;
}

- (void)setLocation:(CGPoint)location
{
}

- (NSMutableArray *)children
{
    if (!_children) {
        _children = [[NSMutableArray array] retain];
    }
    return _children;
}

- (id <Mark>)lastChild
{
    return self.children.lastObject; // can be nil
}

- (NSUInteger)count
{
    return self.children.count;
}

- (void)addMark:(id <Mark>)mark
{
    [self.children addObject: mark];
}

- (void)removeMark:(id <Mark>)mark
{
    if ([self.children containsObject: mark]) {
        [self.children removeObject: mark];
    } else {
        [self.children makeObjectsPerformSelector: @selector(removeMark:) withObject: mark];
    }
}

- (void)removeAllMarks
{
    [self.children removeAllObjects];
}

- (id <Mark>)childAtIndex:(NSUInteger)index
{
    return [self.children objectAtIndex: index];
}

- (void)drawWithContext:(CGContextRef)context
{
    for (id <Mark> mark in self.children) {
        if ([mark isKindOfClass: [Dot class]]) {
            [self strokeLineWithContext: context];
            [mark drawWithContext: context];
            self.shouldStartNewStroke = YES;
        } else {
            [self strokeMark: mark withContext: context];
        }
    }
    [self strokeLineWithContext: context];
}

- (void)strokeMark:(id <Mark>)mark withContext:(CGContextRef)context
{
    if (self.shouldStartNewStroke) {
        self.shouldStartNewStroke = NO;
        CGContextMoveToPoint(context, mark.location.x, mark.location.y);
    }
    [mark drawWithContext: context];
}

- (void)strokeLineWithContext:(CGContextRef)context
{
    CGContextSetLineWidth(context, self.size);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetStrokeColorWithColor(context, self.color.CGColor);
    CGContextStrokePath(context);
    self.shouldStartNewStroke = YES; // Must reset to YES at the end!
}

- (void)enumerateMarksOption:(MarkEnumerationOption)option
                  usingBlock:(void(^)(id <Mark> mark, BOOL *stop))block
{
    BOOL stop = NO;
    NSEnumerator *enumerator = [self.children objectEnumerator];
    id <Mark> mark;
    while (mark = [enumerator nextObject]) {
        if (option == MarkEnumerationOptionDirectChildLevel) {
            block(mark, &stop);
            if (stop) break;
        } else if (option == MarkEnumerationOptionLeafLevel) {
            if ([mark isKindOfClass: [Stroke class]]) {
                [mark enumerateMarksOption: option usingBlock: block];
            } else {
                block(mark, &stop);
                if (stop) break;
            }
        }
    }
}

#pragma mark - copy

- (id)copyWithZone:(NSZone *)zone
{
    Stroke *copyedStroke = [[Stroke allocWithZone: zone] initWithColor: self.color
                                                                  size: self.size];
    // 注意：对一个数组进行的copy，结果不会包含每个元素的copy！
    for (id mark in self.children) {
        id copyedMark = [mark copy];
        [copyedStroke addMark: copyedMark];
        [copyedMark release];
    }
    return copyedStroke;
}

#pragma mark - coding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject: self.color forKey: STROKE_COLOR_CODING_KEY];
    [aCoder encodeObject: @(self.size) forKey: STROKE_SIZE_CODING_KEY];
    [aCoder encodeObject: self.children forKey: STROKE_CHILDREN_CODING_KEY];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _color = [[aDecoder decodeObjectForKey: STROKE_COLOR_CODING_KEY] retain];
        _size = (CGFloat)[[aDecoder decodeObjectForKey: STROKE_SIZE_CODING_KEY] floatValue];
        _children = [[aDecoder decodeObjectForKey: STROKE_CHILDREN_CODING_KEY] retain];
        _shouldStartNewStroke = YES;
    }
    return self;
}

- (void)dealloc
{
    [_color release];
    [_children release];
    [super dealloc];
}

@end













