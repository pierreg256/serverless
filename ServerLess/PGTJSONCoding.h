//
//  PGTJSONCoding.h
//  ServerLess
//
//  Created by Gilot, Pierre on 7/24/13.
//  Copyright (c) 2013 Gilot, Pierre. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PGTJSONCoding <NSObject>

@required
-(NSData*) jsonRepresentation;
-(id) initWithJSON:(NSData*)jsonObject;
@end
