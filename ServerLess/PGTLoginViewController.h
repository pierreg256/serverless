//
//  PGTLoginViewController.h
//  ServerLess
//
//  Created by Gilot, Pierre on 7/17/13.
//  Copyright (c) 2013 Gilot, Pierre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AmazonClientManager.h"

@class PGTLoginViewController;

@protocol PGTLoginViewControllerDelegate <NSObject>

@required
-(void)loginControllerDidLoginSuccessfully:(PGTLoginViewController*)controller;
-(void)loginControllerDidNotLogin:(PGTLoginViewController*)controller withError:(NSString*)message;

@end

@interface PGTLoginViewController : UIViewController <AmazonClientManagerDelegate>

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* spinner;
@property (nonatomic, strong) id<PGTLoginViewControllerDelegate> delegate;

-(IBAction)performLogin:(id)sender;

@end
