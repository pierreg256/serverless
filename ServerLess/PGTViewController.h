//
//  PGTViewController.h
//  ServerLess
//
//  Created by Gilot, Pierre on 6/28/13.
//  Copyright (c) 2013 Gilot, Pierre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AmazonClientManager.h"

@interface PGTViewController : UIViewController <AmazonClientManagerDelegate>

-(IBAction)doLogin:(id)sender;
-(IBAction)doLogout:(id)sender;

@end
