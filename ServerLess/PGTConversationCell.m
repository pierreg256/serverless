//
//  PGTConversationCell.m
//  ServerLess
//
//  Created by Gilot, Pierre on 7/23/13.
//  Copyright (c) 2013 Gilot, Pierre. All rights reserved.
//

#import "PGTConversationCell.h"

@implementation PGTConversationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setConversation:(PGTConversationMetadata*)conversation
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (conversation.friendsCount == 0) {
            sleep(1);
            NSLog(@"sleeping for: %@", conversation);
        }
        
        //self.thumb.profileID = [[conversation friendAtIndex:0] objectForKey:@"id"];
        self.thumb.profileID = @"100000110502374";
        
    });
}

@end
