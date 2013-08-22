//
//  PGTConversationMetadata.m
//  ServerLess
//
//  Created by Gilot, Pierre on 7/23/13.
//  Copyright (c) 2013 Gilot, Pierre. All rights reserved.
//

#import "PGTConversationMetadata.h"
#import "NSData+Base64.h"
#import "AmazonClientManager.h"

@interface PGTConversationMetadata ()
@property (nonatomic, strong) NSString* id;
@property (nonatomic, strong) NSMutableArray* friends;
@end

@implementation PGTConversationMetadata

-(NSMutableArray*)friends
{
    if (_friends == nil)
        _friends = [NSMutableArray arrayWithCapacity:5];
    
    return _friends;
}

-(NSString*)id
{
    if (_id == nil)
    {
        NSUUID  *UUID = [NSUUID UUID];
        self.id = [UUID UUIDString];
    }
    
    return _id;
}

-(UIImage*)thumb
{
    if (!_thumb)
    {
        self.thumb = [UIImage imageNamed:@"conversation"];
    }
    
    return _thumb;
}

-(NSUInteger)friendsCount
{
    return self.friends.count;
}

-(BOOL)hasFriendWithID:(NSString*)id
{
    for (FBGraphObject* friend in self.friends)
    {
        if ([[friend objectForKey:@"id"] isEqual: id])
            return YES;
    }
    return NO;
}

-(void)addFriend:(FBGraphObject*)friend
{
    if (![self hasFriendWithID:[friend objectForKey:@"id"]])
        [self.friends addObject:friend];
}

-(FBGraphObject*)friendAtIndex:(NSUInteger)index
{
    return [self.friends objectAtIndex:index];
}

-(NSData*)jsonRepresentation
{
    
    NSString* thumb64 = [UIImagePNGRepresentation(self.thumb) base64EncodedString];
    NSMutableArray* localFriends = [NSMutableArray arrayWithCapacity:5];
    for (FBGraphObject* obj in self.friends) {
        [localFriends addObject:[obj objectForKey:@"id"]];
    }
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:1], @"version",
                          self.id, @"ID",
                          self.description, @"description",
                          localFriends, @"friends",
                          thumb64, @"thumb",
                          nil];
    NSError* error;
    return [NSJSONSerialization dataWithJSONObject:dict
                                           options:NSJSONWritingPrettyPrinted error:&error];
}

-(id) initWithJSON:(NSData *)jsonObject
{
    NSError* error;
    NSDictionary* obj = [NSJSONSerialization JSONObjectWithData:jsonObject options:NSJSONReadingAllowFragments error:&error];
    if (self = [super init]){
        self.id = [obj objectForKey:@"ID"];
        self.description = [obj objectForKey:@"description"];
        
        NSArray* localFriends = [obj objectForKey:@"friends"];
        for (NSString* ID in localFriends) {
            FBRequest* friend = [FBRequest requestForGraphPath:[NSString stringWithFormat:@"/%@",ID]];
            friend.session = [AmazonClientManager sharedInstance].session;
            [ friend startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                FBGraphObject<FBGraphUser> *data = result; // objectForKey:@"data"];
                [self.friends addObject:data];
                }];
        }
    }
    return self;
}
@end
