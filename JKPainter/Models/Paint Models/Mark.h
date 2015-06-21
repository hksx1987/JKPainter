//
//  Mark.h
//  JKPainter
//
//  Created by Jack Huang on 15/5/8.
//  Copyright (c) 2015年 Jack's app for practice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIColor.h>

typedef NS_ENUM(char, MarkEnumerationOption) {
    MarkEnumerationOptionDirectChildLevel,
    MarkEnumerationOptionLeafLevel
};

@protocol Mark <NSObject, NSCopying, NSCoding>

@optional
@property (nonatomic, retain) UIColor *color;
@property (nonatomic, assign) CGFloat size;
@property (nonatomic, assign) CGPoint location;
@property (nonatomic, readonly) NSUInteger count; // 子节点个数
@property (nonatomic, readonly) id <Mark> lastChild;

- (void)addMark:(id <Mark>)child;
- (void)removeMark:(id <Mark>)child;
- (void)removeAllMarks;
- (id <Mark>)childAtIndex:(NSUInteger)index;
- (void)enumerateMarksOption:(MarkEnumerationOption)option
                  usingBlock:(void(^)(id <Mark> mark, BOOL *stop))block;

@required
- (void)drawWithContext:(CGContextRef)context;

@end
