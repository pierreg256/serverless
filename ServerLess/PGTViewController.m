//
//  PGTViewController.m
//  ServerLess
//
//  Created by Gilot, Pierre on 6/28/13.
//  Copyright (c) 2013 Gilot, Pierre. All rights reserved.
//

#import "PGTViewController.h"
#import "AmazonClientManager.h"
#import "AmazonKeyChainWrapper.h"
#import "AIMobileLib.h"

@interface PGTViewController ()

@end

@implementation PGTViewController

- (void)viewDidLoad
{
    [AmazonClientManager sharedInstance].delegate = self;
    [[AmazonClientManager sharedInstance] reloadFBSession];

    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    if (![[AmazonClientManager sharedInstance] hasCredentials]) {
        [[Constants credentialsAlert] show];
    }

    if ([[AmazonClientManager sharedInstance] isLoggedIn]) {
        AMZLogDebug(@"logged in!");
        /*
        ObjectListing *objectList = [[ObjectListing alloc] init];
        objectList.bucket = BUCKET_NAME;
        objectList.prefix = [AmazonKeyChainWrapper username];
        
        objectList.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        [self presentModalViewController:objectList animated:YES];
        [objectList release];
         */
        //[AIMobileLib authorizeUserForScopes:[NSArray arrayWithObject:@"profile"] delegate:[AmazonClientManager sharedInstance]];

    } else {
        AMZLogDebug(@"not logged in!");
    }

}

- (void)viewWillAppear:(BOOL)animated {
    //[AmazonClientManager sharedInstance].viewController = self;
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    //[AmazonClientManager sharedInstance].viewController = nil;
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)doLogin:(id)sender
{
    [[AmazonClientManager sharedInstance] FBLogin];
}

-(IBAction)doLogout:(id)sender
{
    [[AmazonClientManager sharedInstance] wipeAllCredentials];
    [AmazonKeyChainWrapper wipeKeyChain];
}

#pragma mark - AmazonClientManager Delegate Methods
-(void)AmazonClientManagerDidNotLogin:(AmazonClientManager *)manager withError:(NSString *)message
{
    [Constants errorAlert:message];
}

-(void)AmazonClientManagerDidLoginSuccessfully:(AmazonClientManager *)manager
{
    AMZLogDebug(@"successfully logged in");
    [self performSegueWithIdentifier: @"detailsSegue" sender: self];
}

#pragma mark - Segue operations
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [AmazonClientManager sharedInstance].delegate = nil;
    
//    if ([[segue identifier] isEqualToString:@"MySegue"])
//    {
//        NewViewController *vc = [segue destinationViewController];
//        vc.dataThatINeedFromTheFirstViewController = self.theDataINeedToPass;
//    }
}
@end
