//
//  PGTConversationCell.h
//  ServerLess
//
//  Created by Gilot, Pierre on 7/23/13.
//  Copyright (c) 2013 Gilot, Pierre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "PGTConversationMetadata.h"

@interface PGTConversationCell : UITableViewCell

@property (nonatomic, strong) IBOutlet FBProfilePictureView* thumb;

-(void)setConversation:(PGTConversationMetadata*)conversation;
@end
