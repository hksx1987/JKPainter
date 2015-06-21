//
//  CoordinatingViewController.h
//  JKPainter
//
//  Created by Jack Huang on 15/5/18.
//  Copyright (c) 2015年 Jack's app for practice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaletteViewController.h"
#import "GalleryCollectionViewController.h"

@interface CoordinatingViewController : UIViewController {
    
    IBOutlet UIToolbar *toolbar;
}

/* should call super if override */
- (IBAction)showPalette:(UIBarButtonItem *)sender;
- (IBAction)showGallery;

/* for subclass overriding */
- (void)retrieveGalleryStatement:(GalleryCollectionViewController *)galleryVC;
- (void)retrievePaletteSettings:(PaletteViewController *)paletteVC;

@end
