//
//  CanvasView.m
//  JKPainter
//
//  Created by Jack Huang on 15/5/9.
//  Copyright (c) 2015年 Jack's app for practice. All rights reserved.
//

#import "CanvasView.h"
#import "Mark.h"
#import "Stroke.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

#define kTwoFingerLongPressDuration 0.6
#define kLongPressValidMovement 5.0
#define kLongPressTimerUserInfoKey @"kLongPressTimerUserInfoKey"

@interface CanvasView() {
    id <Mark> mark;
    BOOL isMultipleTouches;
    CGPoint startLocation;
    CFMutableDictionaryRef startLocations;
    NSUInteger requiredSwipeTouches;
}
@end

CanvasViewSwipeDirection calculateSwipeDirection(CGFloat dx, CGFloat dy);

@implementation CanvasView
@synthesize delegate;
@synthesize dataSource;

#pragma mark - setup & dealloc

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.multipleTouchEnabled = YES;
        self.exclusiveTouch = NO;
        delegate = nil;
        isMultipleTouches = NO;
        requiredSwipeTouches = 2;
        startLocations = CFDictionaryCreateMutable(kCFAllocatorDefault, 2, NULL, NULL);
        
        // long press gesture
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget: self action: @selector(handleTwoFingerLongPress:)];
        longPress.numberOfTouchesRequired = 2;
        [self addGestureRecognizer: longPress];
        [longPress release];
    }
    return self;
}

- (void)dealloc
{
    CFRelease(startLocations);
    [super dealloc];
}

- (void)setDataSource:(id)theDataSource
{
    dataSource = theDataSource;
    [self setupRequiredSwipeTouches];
}

#pragma mark - drawing

- (void)drawMark:(id <Mark>)newMark
{
    mark = newMark;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    mark ? [mark drawWithContext: context] : [self drawGreetingInRect: rect];
}

- (void)drawGreetingInRect:(CGRect)rect
{
    NSString *greeting = [NSString stringWithFormat: @"Hello Painter!"];
    NSDictionary *attrs = @{
                            NSFontAttributeName : [UIFont fontWithName: @"Menlo" size: 32.0],
                            NSForegroundColorAttributeName : [UIColor lightGrayColor]
                            };
    
    NSAttributedString *attrGreeting = [[[NSAttributedString alloc] initWithString: greeting attributes: attrs] autorelease];
    
    CGRect computedRect = [attrGreeting boundingRectWithSize: rect.size options: NSStringDrawingTruncatesLastVisibleLine context: nil];
    CGPoint computedCenter = CGPointMake(computedRect.origin.x+computedRect.size.width/2.0, computedRect.origin.y+computedRect.size.height/2.0);
    
    CGFloat deltaX = self.center.x - computedCenter.x;
    CGFloat deltaY = self.center.y - computedCenter.y;
    
    CGRect finalRect = CGRectMake(computedRect.origin.x+deltaX, computedRect.origin.y+deltaY, computedRect.size.width, computedRect.size.height);
    [attrGreeting drawInRect: finalRect];
}

#pragma mark - responder

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event touchesForView: self];
    
    if (allTouches.count == 1) {
        isMultipleTouches = NO;
        
        // single touch down
        startLocation = [[touches anyObject] locationInView: self];
        [self handleSingleTouchDownWithLocation: startLocation];
        
    } else {
        isMultipleTouches = YES;
        
        // multi touch down
        if (requiredSwipeTouches == allTouches.count) {
            
            for (UITouch *touch in allTouches) {
                // store location
                CGPoint *startLocPtr = (CGPoint *)CFDictionaryGetValue(startLocations, touch);
                if (startLocPtr == NULL) {
                    startLocPtr = (CGPoint *)malloc(sizeof(CGPoint));
                    CFDictionarySetValue(startLocations, touch, startLocPtr);
                }
                *startLocPtr = [touch locationInView: self];
            }
        }
        
        [self handleMultipleTouchesDownWithTouchCount: allTouches.count];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([event touchesForView: self].count == 1) {
        UITouch *touch = [[event touchesForView: self] anyObject];
        CGPoint location = [touch locationInView: self];
        [self handleSingleDragAtLocation: location];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *multiTouches = [event touchesForView: self];
    NSUInteger totalFingerCount = multiTouches.count;
    BOOL allFingerLifted = (touches.count == totalFingerCount);
    
    // 该操作为单指操作，且单指离开屏幕时
    if (!isMultipleTouches && allFingerLifted) {
        
        // 使用previousLocationInView进行大致判断：手指按下和抬起前后点是否一致
        CGPoint endLocation = [[touches anyObject] previousLocationInView: self];
        if (CGPointEqualToPoint(startLocation, endLocation)) {
            [self handleSingleTapWithLocation: endLocation];
        } else {
            // 使用locationInView进行精确定位：手指抬起时的位置
            endLocation = [[touches anyObject] locationInView: self];
            [self handleSingleTouchLiftWithLocation: endLocation];
        }
    }
    
    // 该操作为多指操作
    else if (isMultipleTouches) {
        
        if (allFingerLifted) {
            [self handleMultipleTouchesAllLifted];
        }
        
        // handle multi-finger swipe
        [self handleMultipleFingerSwipeWithTouches: multiTouches allFingerLifted: allFingerLifted];
    }
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self handleTouchCancel];
}

- (void)handleSingleTouchDownWithLocation:(CGPoint)location
{
    if ([delegate respondsToSelector: @selector(canvasView:didDetectSingleTouchDownAtLocation:)]) {
        [delegate canvasView: self didDetectSingleTouchDownAtLocation: location];
    }
}

- (void)handleSingleTouchLiftWithLocation:(CGPoint)location
{
    if ([delegate respondsToSelector: @selector(canvasView:didDetectSingleTouchLiftAtLocation:)]) {
        [delegate canvasView: self didDetectSingleTouchLiftAtLocation: location];
    }
}

- (void)handleMultipleTouchesDownWithTouchCount:(NSUInteger)touchCount
{
    if ([delegate respondsToSelector: @selector(canvasView:didDetectMultipleTouchesDownWithTouchCount:)]) {
        [delegate canvasView: self didDetectMultipleTouchesDownWithTouchCount: touchCount];
    }
}

- (void)handleMultipleTouchesAllLifted
{
    if ([delegate respondsToSelector: @selector(canvasViewDidDetectMultipleTouchesAllLifted:)]) {
        [delegate canvasViewDidDetectMultipleTouchesAllLifted: self];
    }
}

- (void)handleSingleDragAtLocation:(CGPoint)location
{
    if ([delegate respondsToSelector: @selector(canvasView:didDetectSingleDragMovingAtLocation:)]) {
        [delegate canvasView: self didDetectSingleDragMovingAtLocation: location];
    }
}

- (void)handleSingleTapWithLocation:(CGPoint)location
{
    if ([delegate respondsToSelector: @selector(canvasView:didDetectSingleTapFinishedAtLocation:)]) {
        [delegate canvasView: self didDetectSingleTapFinishedAtLocation: location];
    }
}

- (void)handleMultipleFingerSwipeWithTouches:(NSSet *)multiTouches allFingerLifted:(BOOL)allFingerLifted
{
    NSUInteger totalFingerCount = (NSUInteger)CFDictionaryGetCount(startLocations);
    NSMutableSet *allDirections = [NSMutableSet set];
    BOOL isSwipe = YES;
    CanvasViewSwipeDirection direction = 0;
    
    for (UITouch *touch in multiTouches) {
        CGPoint *startLocPtr = (CGPoint *)CFDictionaryGetValue(startLocations, touch);
        if (startLocPtr) {
            
            CGPoint startLoc = *startLocPtr;
            CGPoint endLoc = [touch locationInView: touch.window];
            
            if (!CGPointEqualToPoint(startLoc, endLoc)) {
                
                CGFloat dx = endLoc.x - startLoc.x;
                CGFloat dy = endLoc.y - startLoc.y;
                
                // check direction
                direction = calculateSwipeDirection(dx, dy);
                if (direction) {
                    [allDirections addObject: @(direction)];
                }
            } else {
                isSwipe = NO;
                NSLog(@"swipe fail - figner not moving");
            }
        } else {
            NSLog(@"swipe fail - no start location data");
        }
    }
    
    if (allFingerLifted) {
        
        if (allDirections.count != 1) {
            isSwipe = NO;
            direction = 0;
            NSLog(@"swipe fail - total %d directions", (int)allDirections.count);
        } else {
            direction = [[allDirections anyObject] charValue];
        }
        
        if (totalFingerCount != requiredSwipeTouches) {
            isSwipe = NO;
            NSLog(@"swipe fail - not correct finger count: %d", (int)totalFingerCount);
        }
        
        if (isSwipe) {
            if ([delegate respondsToSelector: @selector(canvasView:didDetectMultipleFingerSwipeFinishedWithDirection:)]) {
                [delegate canvasView: self didDetectMultipleFingerSwipeFinishedWithDirection: direction];
            }
        }
        
        [(NSDictionary *)startLocations enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop){
            free((void *)obj);
        }];
        CFDictionaryRemoveAllValues(startLocations);
    }
}

- (void)handleTouchCancel
{
    if ([delegate respondsToSelector: @selector(canvasViewDidCancelTouchDetection:)]) {
        [delegate canvasViewDidCancelTouchDetection: self];
    }
}

- (void)handleTwoFingerLongPress:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        gesture.state = UIGestureRecognizerStateEnded;
        if ([delegate respondsToSelector: @selector(canvasViewDidDetectTwoFingerLongPress:)]) {
            [delegate canvasViewDidDetectTwoFingerLongPress: self];
        }
    }
}

- (void)setupRequiredSwipeTouches
{
    if ([dataSource respondsToSelector: @selector(numberOfMultipleSwipeTouchesRequiredInCanvasView:)]) {
        NSUInteger requiredTouchCount = [dataSource numberOfMultipleSwipeTouchesRequiredInCanvasView: self];
        if (requiredTouchCount > 2) {
            requiredSwipeTouches = requiredTouchCount;
        }
    }
}

@end


CanvasViewSwipeDirection calculateSwipeDirection(CGFloat dx, CGFloat dy) {
    if (fabsf(dx) < fabsf(dy)) {
        if (dy < 0) return CanvasViewSwipeDirectionUp;
        else if (dy > 0) return CanvasViewSwipeDirectionDown;
    } else if (fabsf(dx) > fabsf(dy)) {
        if (dx < 0) return CanvasViewSwipeDirectionLeft;
        else if (dx > 0) return CanvasViewSwipeDirectionRight;
    }
    return 0;
}































