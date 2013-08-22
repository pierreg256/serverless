//
//  PGTConversationViewController.h
//  ServerLess
//
//  Created by Gilot, Pierre on 7/19/13.
//  Copyright (c) 2013 Gilot, Pierre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGTLoginViewController.h"

@interface PGTConversationViewController : UIViewController <PGTLoginViewControllerDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, FBFriendPickerDelegate>

@property (nonatomic, strong) IBOutlet UITableView* conversationsTable;
@property (nonatomic, strong) IBOutlet UITableView* messagesTable;
@property (nonatomic, strong) IBOutlet UITextField* messageField;
@property (nonatomic, strong) IBOutlet UIButton* okButton;

-(void)refresh;
-(IBAction)sendButtonPressed:(id)sender;
-(IBAction)addFriendButtonPressed:(id)sender;
@end
