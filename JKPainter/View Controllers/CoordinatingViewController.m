//
//  CoordinatingViewController.m
//  JKPainter
//
//  Created by Jack Huang on 15/5/18.
//  Copyright (c) 2015年 Jack's app for practice. All rights reserved.
//

#import "CoordinatingViewController.h"
#import "ColorGenerator.h"

@interface CoordinatingViewController () <UIAdaptivePresentationControllerDelegate, UIPopoverPresentationControllerDelegate>
@property (nonatomic, assign) PaletteViewController *paletteVC;
@property (nonatomic, assign) GalleryCollectionViewController *galleryVC;
@end

@implementation CoordinatingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - adaptable

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationFullScreen;
}

- (UIViewController *)presentationController:(UIPresentationController *)controller viewControllerForAdaptivePresentationStyle:(UIModalPresentationStyle)style
{
    UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController: controller.presentedViewController] autorelease];
    controller.presentedViewController.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone target: self action: @selector(dismiss)] autorelease];
    return nav;
}

- (void)dismiss
{
    if (self.paletteVC) {
        [self retrievePaletteSettings: self.paletteVC];
    } else if (self.galleryVC) {
        [self retrieveGalleryStatement: self.galleryVC];
    }
    [self dismissViewControllerAnimated: YES completion: ^{
        self.paletteVC = nil;
        self.galleryVC = nil;
    }];
}

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    if (self.paletteVC) {
        [self retrievePaletteSettings: self.paletteVC];
        self.paletteVC = nil;
    } else if (self.galleryVC) {
        [self retrieveGalleryStatement: self.galleryVC];
        self.galleryVC = nil;
    }
    return YES;
}

#pragma mark - Modal present

- (IBAction)showPalette:(UIBarButtonItem *)sender
{
    PaletteViewController *paletteVC = [self.storyboard instantiateViewControllerWithIdentifier: @"PaletteStoryboardIdentifier"];
    paletteVC.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *pc = paletteVC.popoverPresentationController;
    pc.barButtonItem = sender;
    pc.permittedArrowDirections = UIPopoverArrowDirectionAny;
    pc.delegate = self;
    [self presentViewController: paletteVC animated: YES completion: ^{
        self.paletteVC = paletteVC;
    }];
}

- (IBAction)showGallery
{
    GalleryCollectionViewController *galleryVC = [self.storyboard instantiateViewControllerWithIdentifier: @"GalleryStoryboardIdentifier"];
    galleryVC.modalPresentationStyle = UIModalPresentationFullScreen;
    UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController: galleryVC] autorelease];
    galleryVC.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone target: self action: @selector(dismiss)] autorelease];
    galleryVC.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemEdit target: galleryVC action: @selector(switchEditingMode)] autorelease];
    [self presentViewController: nav animated: YES completion: ^{
        self.galleryVC = galleryVC;
    }];
}

- (void)retrievePaletteSettings:(PaletteViewController *)paletteVC
{
}

- (void)retrieveGalleryStatement:(GalleryCollectionViewController *)galleryVC
{
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
