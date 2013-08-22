//
//  PGTConversationMetadata.h
//  ServerLess
//
//  Created by Gilot, Pierre on 7/23/13.
//  Copyright (c) 2013 Gilot, Pierre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import "PGTJSONCoding.h"

@interface PGTConversationMetadata : NSObject <PGTJSONCoding>

@property (nonatomic, strong, readonly) NSString* id;
@property (nonatomic, strong) NSString* description;
@property (nonatomic, strong) UIImage* thumb;
@property (nonatomic, readonly) NSUInteger friendsCount;

@property (nonatomic, strong, readonly) NSData* jsonRepresentation;

-(BOOL)hasFriendWithID:(NSString*)id;
-(void)addFriend:(FBGraphObject*)friend;
-(FBGraphObject*)friendAtIndex:(NSUInteger)index;
@end
