//
//  QRScanViewController.h
//  GymQ
//
//  Created by Dominic Ong on 7/17/14.
//  Copyright (c) 2014 GymQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class QRScanViewController;

@protocol QRScanViewControllerDelegate <NSObject>

@optional

- (void) scanViewController:(QRScanViewController *) aCtler didTapToFocusOnPoint:(CGPoint) aPoint;
- (void) scanViewController:(QRScanViewController *) aCtler didSuccessfullyScan:(NSString *) aScannedValue;

@end

@interface QRScanViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate, QRScanViewControllerDelegate>

@property (nonatomic, weak) id<QRScanViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;

@property (assign, nonatomic) BOOL touchToFocusEnabled;

- (BOOL) isCameraAvailable;
- (void) startScanning;
- (void) stopScanning;
- (void) setTorch:(BOOL) aStatus;
- (IBAction)dismiss:(id)sender;

@end

