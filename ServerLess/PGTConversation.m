//
//  PGTConversation.m
//  ServerLess
//
//  Created by Gilot, Pierre on 7/23/13.
//  Copyright (c) 2013 Gilot, Pierre. All rights reserved.
//

#import "PGTConversation.h"
#import "PGTJSONCoding.h"
#import <AWSS3/AWSS3.h>

#define METADATA_FILENAME @"metadata.json"
#define MESSAGES_FILENAME @"messages.json"

@interface PGTConversation ()
@property (nonatomic, strong) NSFileWrapper * fileWrapper;
@property (nonatomic, strong) NSMutableArray* messages;
@end

@implementation PGTConversation

#pragma mark - UIDocument methods
- (void)encodeObject:(id<PGTJSONCoding>)object toWrappers:(NSMutableDictionary *)wrappers preferredFilename:(NSString *)preferredFilename {
    @autoreleasepool {
//        NSMutableData * data = [NSMutableData data];
//        NSKeyedArchiver * archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
//        [archiver encodeObject:object forKey:@"data"];
//        [archiver finishEncoding];
//data = [object json
        //data = [object jsonRepresentation];
        NSFileWrapper * wrapper = [[NSFileWrapper alloc] initRegularFileWithContents:[object jsonRepresentation]];
        [wrappers setObject:wrapper forKey:preferredFilename];
    }
}

- (id)contentsForType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    
    if (self.metadata == nil /*|| self.messages == nil*/) {
        return nil;
    }
    
    NSMutableDictionary * wrappers = [NSMutableDictionary dictionary];
    [self encodeObject:self.metadata toWrappers:wrappers preferredFilename:METADATA_FILENAME];
    //[self encodeObject:self.messages toWrappers:wrappers preferredFilename:MESSAGES_FILENAME];
    NSFileWrapper * fileWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:wrappers];
    
    return fileWrapper;
    
}

- (id)decodeObjectFromWrapperWithPreferredFilename:(NSString *)preferredFilename {
    
    NSFileWrapper * fileWrapper = [self.fileWrapper.fileWrappers objectForKey:preferredFilename];
    if (!fileWrapper) {
        AMZLogDebug(@"Unexpected error: Couldn't find %@ in file wrapper!", preferredFilename);
        return nil;
    }
    
    NSData * data = [fileWrapper regularFileContents];
    //NSKeyedUnarchiver * unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    
    return data;
    //return [unarchiver decodeObjectForKey:@"data"];
    
}

- (PGTConversationMetadata *)metadata {
    if (_metadata == nil) {
        if (self.fileWrapper != nil) {
            AMZLogDebug(@"Loading metadata for %@...", self.fileURL);
            self.metadata = [[PGTConversationMetadata alloc] initWithJSON:[self decodeObjectFromWrapperWithPreferredFilename:METADATA_FILENAME]];
        } else {
            self.metadata = [[PGTConversationMetadata alloc] init];
        }
    }
    return _metadata;
}

//- (PTKData *)data {
//    if (_data == nil) {
//        if (self.fileWrapper != nil) {
//            //NSLog(@"Loading photo for %@...", self.fileURL);
//            self.data = [self decodeObjectFromWrapperWithPreferredFilename:DATA_FILENAME];
//        } else {
//            self.data = [[PTKData alloc] init];
//        }
//    }
//    return _data;
//}

- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    
    self.fileWrapper = (NSFileWrapper *) contents;
    
    // The rest will be lazy loaded...
    //self.data = nil;
    self.metadata = nil;
    
    return YES;
    
}
@end
