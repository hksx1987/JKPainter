//
//  GalleryCollectionViewController.m
//  JKPainter
//
//  Created by Jack Huang on 15/5/17.
//  Copyright (c) 2015年 Jack's app for practice. All rights reserved.
//

#import "GalleryCollectionViewController.h"
#import "CoordinatingViewController.h"
#import "GridLayout.h"
#import "ThumbnailCell.h"

@interface GalleryCollectionViewController () <ThumbnailCellDeletionTrigerDelegate>
@property (copy, nonatomic) NSMutableArray *contents;
@property (nonatomic) BOOL editMode;
@property (nonatomic) BOOL finishLoading;
@end

@implementation GalleryCollectionViewController

static NSString * const reuseIdentifier = @"Thumbnail Image Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[ThumbnailCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    [self setup];
    
    // set color
    self.collectionView.backgroundColor = [UIColor lightGrayColor];
    
    // set flow layout & pinch gesture
    GridLayout *gridLayout = [[GridLayout alloc] init];
    self.collectionView.collectionViewLayout = gridLayout;
    [gridLayout release];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.collectionView addGestureRecognizer:pinch];
    [pinch release];
    
    // load contents
    [self loadCellContents];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    self.finishLoading = YES;
}

- (void)setup
{
    _contents = nil;
    _selectedArtworkName = nil;
    _editMode = NO;
}

- (void)loadCellContents
{
    NSArray *imageFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: [self snapshotFolderPath] error: NULL];
    _contents = [imageFiles mutableCopy];
    [self.collectionView reloadData];
}

- (NSString *)snapshotFolderPath
{
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    return [documentPath stringByAppendingPathComponent: @"SnapshotFolder"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.contents.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ThumbnailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    cell.uniqueName = self.contents[indexPath.item];
    cell.delegate = self;
    if (!self.finishLoading) {
        self.editMode ? [cell showDeleteButtonAnimated:NO] : [cell hideDeleteButtonAnimated:NO];
    } else {
        self.editMode ? [cell showDeleteButtonAnimated:YES] : [cell hideDeleteButtonAnimated:YES];
    }
    
    return cell;
}

- (CGFloat)collectionViewRatio
{
    return self.collectionView.bounds.size.width / self.collectionView.bounds.size.height;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *imageName = self.contents[indexPath.row];
    self.selectedArtworkName = [imageName substringToIndex: imageName.length-4];
    if ([self.presentingViewController isKindOfClass: [CoordinatingViewController class]]) {
        CoordinatingViewController *coordinatingVC = (CoordinatingViewController *)self.presentingViewController;
        [coordinatingVC retrieveGalleryStatement: self];
        [coordinatingVC dismissViewControllerAnimated: YES completion: nil];
    }
}

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

#pragma mark - gestures

- (void)handlePinch:(UIPinchGestureRecognizer *)gesture
{
    UICollectionView *collectionView = self.collectionView;
    GridLayout *gridLayout = (GridLayout *)self.collectionView.collectionViewLayout;
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            CGPoint location = [gesture locationInView:gesture.view];
            NSIndexPath *indexPath = [collectionView indexPathForItemAtPoint:location];
            gridLayout.pinchIndexPath = indexPath;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            gridLayout.pinchScale = gesture.scale;
            gridLayout.pinchCenter = [gesture locationInView:gesture.view];
            break;
        }
        default:
            [gridLayout applyBackToOriginalAttributesAfterPinch];
            break;
    }
}

#pragma mark <ThumbnailCellDeletionTrigerDelegate>

- (void)deleteCell:(ThumbnailCell *)cell
{
    NSUInteger index = [self.contents indexOfObject: cell.uniqueName];
    if (index < self.contents.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem: (NSInteger)index inSection: 0];
        [self.collectionView performBatchUpdates: ^{
            [self.contents removeObject: cell.uniqueName];
            [self.collectionView deleteItemsAtIndexPaths: @[indexPath]];
        } completion: ^(BOOL finished) {
            [self removeImageNamed: cell.uniqueName];
        }];
    }
}

- (void)removeImageNamed:(NSString *)imageName
{
    NSString *imagePath = [NSString stringWithFormat: @"%@/%@", [self snapshotFolderPath], imageName];
    if (![[NSFileManager defaultManager] removeItemAtPath: imagePath error: NULL]) {
        NSLog(@"remove image failed");
    }
}

#pragma mark - edit mode

- (void)switchEditingMode
{
    self.editMode = !self.editMode;
    [self.collectionView reloadData];
}

#pragma mark - dealloc

- (void)dealloc
{
    [_contents release];
    [_selectedArtworkName release];
    [super dealloc];
}

@end
