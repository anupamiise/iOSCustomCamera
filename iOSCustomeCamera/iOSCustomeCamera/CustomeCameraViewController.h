//
//  CustomeCameraViewController.h
//  iOSCustomeCamera
//
//  Created by Amir Khan on 09/02/16.
//  Copyright © 2016 anupam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface CustomeCameraViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
- (IBAction)cameraButtonTouchupInSide:(id)sender;

@end
