//
//  PGTConversationMetadata.m
//  ServerLess
//
//  Created by Gilot, Pierre on 7/23/13.
//  Copyright (c) 2013 Gilot, Pierre. All rights reserved.
//

#import "PGTConversationMetadata.h"
#import "NSData+Base64.h"

@interface PGTConversationMetadata ()
@property (nonatomic, strong) NSString* id;
@end

@implementation PGTConversationMetadata


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

-(NSData*)jsonRepresentation
{
    
    NSString* thumb64 = [UIImagePNGRepresentation(self.thumb) base64EncodedString];
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:1], @"version",
                          _id, @"ID",
                          _description, @"description",
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
    }
    return self;
}
@end
