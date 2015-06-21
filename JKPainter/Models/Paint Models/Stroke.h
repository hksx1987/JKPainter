//
//  Stroke.h
//  JKPainter
//
//  Created by Jack Huang on 15/5/8.
//  Copyright (c) 2015年 Jack's app for practice. All rights reserved.
//

#import "Mark.h"

@interface Stroke : NSObject <Mark>

@property (nonatomic, retain) UIColor *color;
@property (nonatomic, assign) CGFloat size;
@property (nonatomic, assign) CGPoint location;
@property (nonatomic, readonly) NSUInteger count; // 子节点个数
@property (nonatomic, readonly) id <Mark> lastChild;

@property (nonatomic) BOOL shouldStartNewStroke;

/* designated init */
- (instancetype)initWithColor:(UIColor *)color
                         size:(CGFloat)size;

- (void)addMark:(id <Mark>)child;
- (void)removeMark:(id <Mark>)child;
- (void)removeAllMarks;
- (id <Mark>)childAtIndex:(NSUInteger)index;
/* 使用block枚举时不可以在枚举过程中添加或删除集合元素 */
- (void)enumerateMarksOption:(MarkEnumerationOption)option
                  usingBlock:(void(^)(id <Mark> mark, BOOL *stop))block;


@end
