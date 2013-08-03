//
//  PGTConversationMetadata.h
//  ServerLess
//
//  Created by Gilot, Pierre on 7/23/13.
//  Copyright (c) 2013 Gilot, Pierre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGTJSONCoding.h"

@interface PGTConversationMetadata : NSObject <PGTJSONCoding>

@property (nonatomic, strong, readonly) NSString* id;
@property (nonatomic, strong) NSString* description;
@property (nonatomic, strong) UIImage* thumb;

@property (nonatomic, strong, readonly) NSData* jsonRepresentation;
@end
