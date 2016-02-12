//
//  HomeViewController.m
//  iOSCustomeCamera
//
//  Created by Amir Khan on 11/02/16.
//  Copyright © 2016 anupam. All rights reserved.
//

#import "HomeViewController.h"
#import "CustomeCameraViewController.h"
@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cameraButtonClicked:(id)sender
{
    CustomeCameraViewController *vc = [[CustomeCameraViewController alloc] initWithNibName:@"CustomeCameraView" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
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
