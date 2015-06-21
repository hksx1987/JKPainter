//
//  CanvasView.h
//  JKPainter
//
//  Created by Jack Huang on 15/5/9.
//  Copyright (c) 2015年 Jack's app for practice. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (char, CanvasViewSwipeDirection) {
    CanvasViewSwipeDirectionUp = 1,
    CanvasViewSwipeDirectionDown,
    CanvasViewSwipeDirectionLeft,
    CanvasViewSwipeDirectionRight,
};


@protocol Mark;
@protocol CanvasViewTouchDetectionDelegate;
@protocol CanvasViewTouchDetectionDataSource;


@interface CanvasView : UIView {
    id <CanvasViewTouchDetectionDelegate> delegate;
    id <CanvasViewTouchDetectionDataSource> dataSource;
}
@property (nonatomic, assign) id <CanvasViewTouchDetectionDelegate> delegate;
@property (nonatomic, assign) id <CanvasViewTouchDetectionDataSource> dataSource;
- (void)drawMark:(id <Mark>)newMark;
@end



@protocol CanvasViewTouchDetectionDataSource <NSObject>
@optional
/// \brief This method for setting number of required swipe touches, default is 2.
/// \param canvasView The view object for user interaction.
- (NSUInteger)numberOfMultipleSwipeTouchesRequiredInCanvasView:(CanvasView *)canvasView;
@end



@protocol CanvasViewTouchDetectionDelegate <NSObject>
@optional
/// \brief This method gets called when user put one finger onto the canvas view, and it will not get called when multi-touches get detected.
/// \param canvasView The view object for user interaction.
/// \param location The location for user's finger.
- (void)canvasView:(CanvasView *)canvasView didDetectSingleTouchDownAtLocation:(CGPoint)location;

/// \brief This method gets called when user lifted one finger after single-touch interaction and only if the touch end location is not same as touch start location, otherwise system will call canvasView:didDetectSingleTapFinishedAtLocation: instead. It will not get called by the end of multi-touches interaction. (如果用户单指触屏操作结束时的触屏坐标与刚触屏的坐标不一致时才会调用该方法，若一致则会调用canvasView:didDetectSingleTapFinishedAtLocation:)
/// \param canvasView The view object for user interaction.
/// \param location The location for user's finger.
- (void)canvasView:(CanvasView *)canvasView didDetectSingleTouchLiftAtLocation:(CGPoint)location;

/// \brief This method gets called when user presses screen with 2-fingers after amount of short period time.
/// \param canvasView The view object for user interaction.
- (void)canvasViewDidDetectTwoFingerLongPress:(CanvasView *)canvasView;

/// \brief This method gets called when user start multi-touches interaction.
/// \param canvasView The view object for user interaction.
/// \param touchCount The number of touches.
- (void)canvasView:(CanvasView *)canvasView didDetectMultipleTouchesDownWithTouchCount:(NSUInteger)touchCount;

/// \brief This method gets called at the end of multi-touches interaction, which means when user lifted all touches, and it's happened earlier than any other multi-gesture is detected at canvas view. However, if any gesture is recognized by the ancestor of this canvas view in the view hierarchy, then it will not call this method when that gesture is finished. In that case, it will call canvasViewDidCancelTouchDetection: instead. (如果canvas视图的上级视图能够处理某个手势的话，那么当那个手势结束时，即使用户的所有手指抬起后也不会调用这个方法，反而会调用canvasViewDidCancelTouchDetection:)
/// \param canvasView The view object for user interaction.
- (void)canvasViewDidDetectMultipleTouchesAllLifted:(CanvasView *)canvasView;

/// \brief This method gets called when single tap gesture was detected at canvas view.
/// \param canvasView The view object for user interaction.
/// \param location The location for user's finger.
- (void)canvasView:(CanvasView *)canvasView didDetectSingleTapFinishedAtLocation:(CGPoint)location;

/// \brief This method gets called when single pan gesture was detected at canvas view.
/// \param canvasView The view object for user interaction.
/// \param location The location for user's finger.
- (void)canvasView:(CanvasView *)canvasView didDetectSingleDragMovingAtLocation:(CGPoint)location;

/// \brief This method gets called when multi-figner-swipe gesture was detected at canvas view.
/// \param canvasView The view object for user interaction.
/// \param swipeDirection The enum parameter represents the direction of the swipe
- (void)canvasView:(CanvasView *)canvasView didDetectMultipleFingerSwipeFinishedWithDirection:(CanvasViewSwipeDirection)swipeDirection;

/// \brief This method gets called when gesture is cancelled at canvas view. It also get called for gesture which will be handled by its ancestor view.
/// \param canvasView The view object for user interaction.
- (void)canvasViewDidCancelTouchDetection:(CanvasView *)canvasView;

@end