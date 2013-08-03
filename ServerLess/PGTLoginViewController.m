//
//  PGTLoginViewController.m
//  ServerLess
//
//  Created by Gilot, Pierre on 7/17/13.
//  Copyright (c) 2013 Gilot, Pierre. All rights reserved.
//

#import "PGTLoginViewController.h"

@interface PGTLoginViewController ()

@end

@implementation PGTLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)performLogin:(id)sender
{
    _spinner.hidden = NO;
    [_spinner startAnimating];
    [AmazonClientManager sharedInstance].delegate = self ;
    [[AmazonClientManager sharedInstance] FBLogin];

}

#pragma mark - AmazonClientManager delegate methods
-(void)AmazonClientManagerDidLoginSuccessfully:(AmazonClientManager *)manager
{
    AMZLogDebug(@"Successfully logged in to FB");
    [_spinner stopAnimating];
    [AmazonClientManager sharedInstance].delegate = nil;
    if (_delegate)
        [_delegate loginControllerDidLoginSuccessfully:self];
}

-(void)AmazonClientManagerDidNotLogin:(AmazonClientManager *)manager withError:(NSString *)message
{
    AMZLogDebug(@"Error logging: %@", message);
    [_spinner stopAnimating];
    [AmazonClientManager sharedInstance].delegate = nil;
    [Constants errorAlert:message];
}

@end
