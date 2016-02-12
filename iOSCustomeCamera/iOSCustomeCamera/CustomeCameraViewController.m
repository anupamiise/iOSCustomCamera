//
//  CustomeCameraViewController.m
//  iOSCustomeCamera
//
//  Created by Amir Khan on 09/02/16.
//  Copyright © 2016 anupam. All rights reserved.
//

#import "CustomeCameraViewController.h"
#import "OverLayViewController.h"
#import "CustomIOSAlertView.h"
#import "UIImage+fixOrientation.h"


@interface CustomeCameraViewController ()
@property(nonatomic, strong)UIImagePickerController *picker;
@end

@implementation CustomeCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [notificationCenter addObserver:self
                           selector:@selector(deviceOrientationDidChange)
                               name:UIDeviceOrientationDidChangeNotification object:nil];
    //[self setOrientation:AVCaptureVideoOrientationPortrait];
    // assign action to button
     [self OpenCamera];
   }
- (void)deviceOrientationDidChange{
    
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
    AVCaptureVideoOrientation newOrientation;
    
    if (deviceOrientation == UIDeviceOrientationPortrait){
        NSLog(@"deviceOrientationDidChange - Portrait");
        newOrientation = AVCaptureVideoOrientationPortrait;
    }
    else if (deviceOrientation == UIDeviceOrientationPortraitUpsideDown){
        NSLog(@"deviceOrientationDidChange - UpsideDown");
        newOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
    }
    
    // AVCapture and UIDevice have opposite meanings for landscape left and right (AVCapture orientation is the same as UIInterfaceOrientation)
    else if (deviceOrientation == UIDeviceOrientationLandscapeLeft){
        NSLog(@"deviceOrientationDidChange - LandscapeLeft");
        newOrientation = AVCaptureVideoOrientationLandscapeRight;
    }
    else if (deviceOrientation == UIDeviceOrientationLandscapeRight){
        NSLog(@"deviceOrientationDidChange - LandscapeRight");
        newOrientation = AVCaptureVideoOrientationLandscapeLeft;
    }
    
    else if (deviceOrientation == UIDeviceOrientationUnknown){
        NSLog(@"deviceOrientationDidChange - Unknown ");
        newOrientation = AVCaptureVideoOrientationPortrait;
    }
    
    else{
        NSLog(@"deviceOrientationDidChange - Face Up or Down");
        newOrientation = AVCaptureVideoOrientationPortrait;
    }
    
    [self ChangeOriantation:newOrientation];
}





-(void)ChangeOriantation:(AVCaptureVideoOrientation)interfaceOrientation
{
   // [self OpenCamera];
}

- (void)OpenCamera {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        // alert the user that the camera can't be accessed
        UIAlertView *noCameraAlert = [[UIAlertView alloc] initWithTitle:@"No Camera" message:@"Unable to access the camera!" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        [noCameraAlert show];
        
    } else {
        
        self.picker = [[UIImagePickerController alloc] init];
        self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.picker.modalPresentationStyle = UIModalPresentationCurrentContext;
       
        self.picker.delegate = self;
        self.picker.allowsEditing = NO;
        self.picker.showsCameraControls = NO;
        
        OverLayViewController *vc = [[OverLayViewController alloc] initWithNibName:@"OverLayView" bundle:nil];
        UIView *overlayView =vc.view;
        CGRect overlayRect = CGRectMake(0, 0, self.picker.view.frame.size.width, self.picker.view.frame.size.height);
        overlayView.frame =overlayRect;
        [vc.cancelBarButton setAction:@selector(cancelButtonPressed:)] ;
        [vc.cancelBarButton setTarget:self] ;
        [vc.captureBarButton setAction:@selector(catpureButtonPressed:)] ;
        [vc.captureBarButton setTarget:self] ;

        [vc.flipBarButton setAction:@selector(flipButtonPressed:)] ;
        [vc.flipBarButton setTarget:self] ;

        [vc.flashBarButton setAction:@selector(flashButtonPressed:)] ;
        [vc.flashBarButton setTarget:self] ;
      
        [self.picker setCameraOverlayView:overlayView];
        // display imagePicker
       [self presentViewController:self.picker animated:YES completion:nil];
    }
}

#pragma mark - UIBarButton Selectors

- (void)catpureButtonPressed:(id)sender
{
    [self.picker takePicture];
}

- (void)flipButtonPressed:(id)sender
{
    NSLog(@"flipButtonPressed...");
    // TODO: make this do something
    if (self.picker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
    {
        self.picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
    else
    {
        self.picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
}


- (void)flashButtonPressed:(id)sender
{
    if (self.picker.cameraDevice == UIImagePickerControllerCameraDeviceRear)
    {
    AVCaptureDevice *flashLight = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([flashLight isTorchAvailable] && [flashLight isTorchModeSupported:AVCaptureTorchModeOn])
    {
        BOOL success = [flashLight lockForConfiguration:nil];
        if (success)
        {
            if ([flashLight isTorchActive]) {
                [flashLight setTorchMode:AVCaptureTorchModeOff];
            } else {
                [flashLight setTorchMode:AVCaptureTorchModeOn];
            }
            [flashLight unlockForConfiguration];
        }
    }
    }
}

- (void)cancelButtonPressed:(id)sender {
    NSLog(@"cancelButtonPressed");
    [self.picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIImagePickerController Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)editingInfo {
    
    // determine if the user selected or took a new photo
    UIImage *selectedImage;
    if ([editingInfo objectForKey:UIImagePickerControllerOriginalImage]) selectedImage = (UIImage *)[editingInfo objectForKey:UIImagePickerControllerOriginalImage];
    else if ([editingInfo objectForKey:UIImagePickerControllerEditedImage]) selectedImage = (UIImage *)[editingInfo objectForKey:UIImagePickerControllerEditedImage];
    [selectedImage fixOrientation];
    
    
    if (selectedImage)
    {
    [self SaveFileToDocumentDirectory:selectedImage];
        
    [self CapturedImage:selectedImage];
    }
    // TODO: Do something with selectedImage (put it in a UIImageView
    
    // dismiss the imagePicker
   // [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return [documentsPath stringByAppendingPathComponent:name];
}
-(NSString *)SaveFileToDocumentDirectory:(UIImage *)selectedImage
{
    NSData *pngData = UIImagePNGRepresentation(selectedImage);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *myUniqueName = [NSString stringWithFormat:@"%@-%u", @"anupam", (NSUInteger)([[NSDate date] timeIntervalSince1970]*10.0)];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",myUniqueName]]; //Add the file name
    [pngData writeToFile:filePath atomically:YES]; //Write the file
    NSLog(@"File Path is %@",filePath);
    return filePath;
}

-(UIImage *)CapturedImage:(UIImage *)selectedImage
{
    
   CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 400, 400)];
    [imageView setImage:selectedImage];
    [alertView setContainerView:imageView];
  
    [alertView show];
   return selectedImage;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

