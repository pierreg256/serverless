//
//  PGTMessage.m
//  ServerLess
//
//  Created by Gilot, Pierre on 7/9/13.
//  Copyright (c) 2013 Gilot, Pierre. All rights reserved.
//

#import "PGTMessage.h"
#import "AmazonClientManager.h"
#import "AmazonKeyChainWrapper.h"
#import <AWSS3/AWSS3.h>

#define kVersionKey @"com.pgt.ServerLess.message.version"
#define kIDKey @"com.pgt.ServerLess.message.ID"
#define kTypeKey @"com.pgt.ServerLess.message.type"
#define kTextKey @"com.pgt.ServerLess.message.text"

@implementation PGTMessage

-(void)send
{
    @try {
        NSString *keyName = [NSString stringWithFormat:@"%@/inbox/%@-%@", _to, _id, _from];
        
        S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:keyName inBucket:BUCKET_NAME] ;
        por.data = [self jsonRepresentation];
        por.storageClass = @"REDUCED_REDUNDANCY";
        por.contentType = @"application/json; charset=utf-8";
        
        [[[AmazonClientManager sharedInstance] s3] putObject:por];
    }
    @catch (AmazonClientException *exception)
    {
        NSLog(@"Exception = %@", exception);
        [[Constants errorAlert:[NSString stringWithFormat:@"Error adding object: %@", exception.message]] show];
    }
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:[NSNumber numberWithInt:1] forKey:kVersionKey];
    [aCoder encodeObject:_id forKey:kIDKey];
    [aCoder encodeObject:_type forKey:kTypeKey];
    [aCoder encodeObject:_text forKey:kTextKey];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super init]) {
        self.id = [aDecoder decodeObjectForKey:kIDKey];
        
        self.text = [aDecoder decodeObjectForKey:kTextKey];
        self.type = [aDecoder decodeObjectForKey:kTypeKey];
    }
    
    return self;
}

-(NSData*) jsonRepresentation
{
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:1], @"version",
                          _id, @"ID",
                          _type, @"type",
                          _text, @"text",
                          _from, @"from",
                          _to, @"to",
                          nil];
    NSError* error;
    return [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    //return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
