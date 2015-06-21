//
//  CanvasViewController.m
//  JKPainter
//
//  Created by Jack Huang on 15/5/8.
//  Copyright (c) 2015年 Jack's app for practice. All rights reserved.
//

#import "CanvasViewController.h"

#import "CanvasView.h"
#import "Dot.h"
#import "Stroke.h"
#import "Vertex.h"

#import "CanvasScrollView.h"

#import "ColorGenerator.h"
#import "PainterKeys.h"
#import "UIView+Image.h"

CGRect markRect(CGPoint location, CGFloat dotSize);

@interface CanvasViewController () <UIScrollViewDelegate, CanvasViewTouchDetectionDelegate, CanvasViewTouchDetectionDataSource> {
    
    CanvasScrollView *scrollView;
    CanvasView *canvasView;
    
    Stroke *topMark;
    NSMutableArray *redoStack;
    
    BOOL isSetup;
    BOOL isMultiGestureCompleted;   // only YES can allow stroke action
    BOOL isEmptyStrokePossible;     // empty stroke will be possible when single touch began
}

@end

@implementation CanvasViewController

@synthesize colorGenerator;
@synthesize dotSize;
@synthesize dotColor;
@synthesize artworkName;

#pragma mark - setup & dealloc

- (void)setup
{
    if (isSetup) {
        return;
    }
    
    isSetup = YES;
    isMultiGestureCompleted = YES;
    
    CGFloat toolbarHeight = self->toolbar.bounds.size.height;
    CGRect availableRect = self.view.bounds;
    availableRect.size.height -= toolbarHeight;
    
    // setup canvas view and scroll view
    scrollView = [[CanvasScrollView alloc] initWithFrame: availableRect];
    scrollView.delegate = self;
    scrollView.canPerformPinch = NO;
    [self.view addSubview: scrollView];
    [scrollView release];
    
    canvasView = [[CanvasView alloc] initWithFrame: availableRect];
    canvasView.delegate = self;
    canvasView.dataSource = self;
    //        [self.view addSubview: canvasView];
    [scrollView addSubview: canvasView];
    [canvasView release];
    
    topMark = [[Stroke alloc] initWithColor: nil size: 0.0];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *storedRed = [defaults objectForKey: RED_COMPONENT_STORE_KEY];
    NSNumber *storedGreen = [defaults objectForKey: GREEN_COMPONENT_STORE_KEY];
    NSNumber *storedBlue = [defaults objectForKey: BLUE_COMPONENT_STORE_KEY];
    
    colorGenerator = [ColorGenerator defaultGenerator];
    colorGenerator.redComponent = storedRed ? [storedRed floatValue] : 0.5;
    colorGenerator.greenComponent = storedGreen ? [storedGreen floatValue] : 0.5;
    colorGenerator.blueComponent = storedBlue ? [storedBlue floatValue] : 0.5;
    
    /* [UIColor colorWithRed:green:blue:alpha:]创建的是autoreleased对象 */
    /* [UIColor blackColor]创建的对象是唯一的且不会被释放的对象 */
    dotColor = [colorGenerator.generatedColor copy];
    
    NSNumber *storedDotSize = [defaults objectForKey: STROKE_WIDTH_STRORE_KEY];
    dotSize = storedDotSize ? (CGFloat)[storedDotSize floatValue] : 5.0;
    
    redoStack = [[NSMutableArray alloc] init];
    artworkName = [[self uniqueString] copy];
    
    [self setupFolderNamed: SNAPSHOT_FOLDER];
    [self setupFolderNamed: MARKDATA_FOLDER];
}

- (void)dealloc {
    [scrollView release];
    [canvasView release];
    
    [topMark release];
    
    [dotColor release];
    [redoStack release];
    [artworkName release];
    
    [toolbar release];
    [super dealloc];
}

#pragma mark - properties

- (void)setDotSize:(CGFloat)newDotSize
{
    if (newDotSize > 10.0) newDotSize = 10.0;
    if (newDotSize < 1.0) newDotSize = 1.0;
    dotSize = newDotSize;
}

- (void)setArtworkName:(NSString *)newArtworkName
{
    if (artworkName != newArtworkName) {
        [artworkName release];
        artworkName = [newArtworkName copy];
    }
    [self retrieve];
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self cleanUp];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    [canvasView becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear: animated];
    [canvasView resignFirstResponder];
}

#pragma mark - Delegate

#pragma mark <UIScrollViewDelegate>

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return canvasView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)theScrollView withView:(UIView *)view atScale:(CGFloat)scale
{
//    [self turnOffCanvasScaleMode];
}

#pragma mark <CanvasViewTouchDetectionDataSource>

- (NSUInteger)numberOfMultipleSwipeTouchesRequiredInCanvasView:(CanvasView *)canvasView
{
    return 2;
}

#pragma mark <CanvasViewTouchDetectionDelegate>

- (void)canvasView:(CanvasView *)theCanvasView didDetectSingleTouchDownAtLocation:(CGPoint)location
{
    isEmptyStrokePossible = YES;
//    [self turnOffCanvasScaleMode];
    
    Stroke *stroke = [[Stroke alloc] initWithColor: dotColor size: dotSize];
    [topMark addMark: stroke];
    [stroke release];
}

- (void)canvasView:(CanvasView *)theCanvasView didDetectSingleDragMovingAtLocation:(CGPoint)location
{
    // 注意：由于canvasView的superview是scrollView，当检测到swipe手势的时候，由于scrollView本身可以接受并处理swipe，因此就轮不到canvasView来处理swipe
    // 为保证用户可以通过单指swipe进行绘画，之前需要禁止scrollView接受swipe的手势！
    
    if ([topMark.lastChild isKindOfClass: [Stroke class]] && isMultiGestureCompleted) {
        
        // draw a stroke
        Stroke *stroke = topMark.lastChild;
        Vertex *vertex = [[Vertex alloc] initWithLocation: location];
        [stroke addMark: vertex];
        [vertex release];
        [theCanvasView drawMark: topMark];
        
        // clean redo stack
        [self cleanUpRedoStack];
    }
}

- (void)canvasView:(CanvasView *)theCanvasView didDetectSingleTapFinishedAtLocation:(CGPoint)location
{
    // delete empty stroke
    [topMark removeMark: topMark.lastChild];
    isEmptyStrokePossible = NO;
    
    // draw a dot
    Dot *dot = [[Dot alloc] initWithColor: dotColor size: dotSize location: location];
    [topMark addMark: dot];
    [dot release];
    [theCanvasView drawMark: topMark];
    
    // clean redo stack
    [self cleanUpRedoStack];
}

- (void)canvasView:(CanvasView *)theCanvasView didDetectMultipleFingerSwipeFinishedWithDirection:(CanvasViewSwipeDirection)swipeDirection
{
    swipeDirection == CanvasViewSwipeDirectionLeft ? [self performUndo] : [self performRedo];
//    [self turnOnCanvasScaleMode];
}

- (void)canvasView:(CanvasView *)canvasView didDetectMultipleTouchesDownWithTouchCount:(NSUInteger)touchCount
{
    isMultiGestureCompleted = NO;
//    if (touchCount == 3) {
//        [self turnOffCanvasScaleMode];
//    }
}

- (void)canvasViewDidDetectMultipleTouchesAllLifted:(CanvasView *)canvasView
{
    isMultiGestureCompleted = YES;
}

//- (void)canvasViewDidDetectTwoFingerLongPress:(CanvasView *)canvasView
//{
//    [self turnOnCanvasScaleMode];
//}

- (void)canvasViewDidCancelTouchDetection:(CanvasView *)canvasView
{
    // when pinch is recognized
    [self deleteEmptyStroke];
    isMultiGestureCompleted = YES;
//    NSLog(@"touch cancelled");
}

#pragma mark - Actions

- (IBAction)performUndo
{
    [self deleteEmptyStroke];
    id <Mark> lastMark = topMark.lastChild;
    if (lastMark) {
        [redoStack addObject: lastMark];
        [topMark removeMark: lastMark];
        [canvasView drawMark: topMark];
    }
}

- (IBAction)performRedo
{
    id <Mark> retrievedMark = redoStack.lastObject;
    if (retrievedMark) {
        [topMark addMark: retrievedMark];
        [redoStack removeObject: retrievedMark];
        [canvasView drawMark: topMark];
    }
}

- (IBAction)cleanUp
{
    [topMark removeAllMarks];
    [redoStack removeAllObjects];
    [canvasView drawMark: nil];
}

/* 保存当前的状态 */
- (IBAction)save
{
    if (topMark.lastChild) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject: topMark];
        if ([data writeToFile: [self filePath] atomically: YES]) {
            [self takeSnapshot];
        }
    }
}

- (IBAction)retrieve
{
    NSData *data = [NSData dataWithContentsOfFile: [self filePath]];
    if (data) {
        topMark = [[NSKeyedUnarchiver unarchiveObjectWithData: data] retain];
        [canvasView drawMark: topMark];
    } else {
        [NSException raise:NSObjectNotAvailableException format:@"no saved drawing file!"];
    }
}

- (IBAction)startNewCanvas
{
    self.artworkName = [self uniqueString];
    [self save];
    [self cleanUp];
}

#pragma mark - file

- (NSString *)uniqueString
{
    return [NSUUID UUID].UUIDString;
}

- (NSString *)documentPath
{
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
}

- (NSString *)filePath
{
    NSString *filePath = [NSString stringWithFormat: @"/%@/%@.data", MARKDATA_FOLDER, self.artworkName];
    return [[self documentPath] stringByAppendingPathComponent: filePath];
}

- (void)setupFolderNamed:(NSString *)folderName
{
    NSString *folderPath = [NSString stringWithFormat: @"%@/%@", [self documentPath], folderName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath: folderPath]) {
        [fileManager createDirectoryAtPath: folderPath withIntermediateDirectories: YES attributes: nil error: NULL];
    }
}

- (void)takeSnapshot
{
    if ([topMark count]) {
        UIImage *snapImage = canvasView.capturedImage;
        NSData *imageData = UIImagePNGRepresentation(snapImage);
        NSString *imagePath = [NSString stringWithFormat: @"%@/%@.png", SNAPSHOT_FOLDER, self.artworkName];
        NSString *snapPath = [self documentPath];
        snapPath = [snapPath stringByAppendingPathComponent: imagePath];
        if (![imageData writeToFile: snapPath atomically: YES]) {
            NSLog(@"save snap image failed");
        } else {
            //NSLog(@"save snap image in - %@", snapPath);
        }
    }
}

#pragma mark -  override

- (void)retrievePaletteSettings:(PaletteViewController *)paletteVC
{
    self.dotColor = paletteVC.colorGenerator.generatedColor;
    self.dotSize = paletteVC.dotSize;
}

- (void)retrieveGalleryStatement:(GalleryCollectionViewController *)galleryVC
{
    if (galleryVC.selectedArtworkName) {
        self.artworkName = galleryVC.selectedArtworkName;
    }
}

- (void)showGallery
{
    [self save];
    [super showGallery];
}

#pragma mark - helper utility methods

- (void)deleteEmptyStroke
{
    if (isEmptyStrokePossible) {
        NSMutableArray *emptyMarks = [NSMutableArray array];
        [topMark enumerateMarksOption: MarkEnumerationOptionDirectChildLevel
                           usingBlock: ^(id <Mark> mark, BOOL *stop) {
                               if ([mark isKindOfClass: [Stroke class]]) {
                                   if (![mark count]) {
                                       [emptyMarks addObject: mark];
                                   }
                               }
                           }];
        for (int i = 0; i < emptyMarks.count; i++) {
            id <Mark> emptyMark = emptyMarks[i];
            [topMark removeMark: emptyMark];
        }
        isEmptyStrokePossible = NO;
    }
}

- (void)cleanUpRedoStack
{
    if (redoStack.count) {
        [redoStack removeAllObjects];
    }
}

- (void)turnOnCanvasScaleMode
{
    if (!scrollView.canPerformPinch) {
        scrollView.canPerformPinch = YES;
        self->toolbar.backgroundColor = [UIColor darkGrayColor];
    }
}

- (void)turnOffCanvasScaleMode
{
    if (scrollView.canPerformPinch) {
        scrollView.canPerformPinch = NO;
        self->toolbar.backgroundColor = [UIColor clearColor];
    }
}

@end

CGRect markRect(CGPoint location, CGFloat dotSize) {
    return CGRectMake(location.x-dotSize/2.0, location.y-dotSize/2.0, dotSize, dotSize);
}



