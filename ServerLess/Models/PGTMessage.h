//
//  PGTMessage.h
//  ServerLess
//
//  Created by Gilot, Pierre on 7/9/13.
//  Copyright (c) 2013 Gilot, Pierre. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kMessageTypeText @"TXT"

@interface PGTMessage : NSObject <NSCoding>

@property (nonatomic, strong) NSNumber* id;
@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) NSString* text;
@property (nonatomic, strong) NSString* from;
@property (nonatomic, strong) NSString* to;

@property (nonatomic, strong, readonly) NSData* jsonRepresentation;


-(void)send;
@end
