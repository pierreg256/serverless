/*
 * Copyright 2010-2012 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#import "AmazonClientManager.h"
#import <AWSRuntime/AWSRuntime.h>
#import "AmazonKeyChainWrapper.h"
#import <AWSSecurityTokenService/AWSSecurityTokenService.h>

static AmazonS3Client                    *_s3  = nil;
static AmazonWIFCredentialsProvider      *_wif = nil;

@interface AmazonClientManager (    )
@property (nonatomic, strong) NSString* userName;
@property (nonatomic, strong) NSString* profileID;

- (void)populateUserDetails;

@end

@implementation AmazonClientManager



+ (AmazonClientManager *)sharedInstance
{
    static AmazonClientManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AmazonClientManager alloc] init];
    });
    return sharedInstance;
}



-(AmazonS3Client *)s3
{
    return _s3;
}

-(bool)hasCredentials
{
    return TRUE;
}

-(bool)isLoggedIn
{
    return ( [AmazonKeyChainWrapper username] != nil && _wif != nil);
}

-(void)initClients
{
    if (_wif != nil) {
        //[_s3 release];
        _s3  = [[AmazonS3Client alloc] initWithCredentialsProvider:_wif];
    }
}

-(void)wipeAllCredentials
{
    @synchronized(self)
    {
        //[_s3 release];
        _s3  = nil;
    }
}

- (void)populateUserDetails
{
    AMZLogDebug(@"");
    FBRequest* req = [FBRequest requestForMe];
    req.session = self.session;
    
        [req startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary<FBGraphUser> *user,
           NSError *error) {
             
             if (!error) {
                 self.userName = user.name;
                 self.profileID = user.id;
             }
         }];
}

#pragma mark - Facebook

-(void)reloadFBSession
{
    if (!self.session.isOpen) {
        // create a fresh session object
        self.session = [[FBSession alloc] init] ;
        
        // if we don't have a cached token, a call to open here would cause UX for login to
        // occur; we don't want that to happen unless the user clicks the login button, and so
        // we check here to make sure we have a token before calling open
        if (self.session.state == FBSessionStateCreatedTokenLoaded) {
            
            // even though we had a cached token, we need to login to make the session usable
            [self.session openWithCompletionHandler:^(FBSession *session,
                                                      FBSessionState status,
                                                      NSError *error) {
                if (error != nil) {
                    [[Constants errorAlert:[NSString stringWithFormat:@"Error logging in with FB: %@", error.description]] show];
                } else {
                    [self populateUserDetails];
                }
            }];
        }
    }
}


-(void)CompleteFBLogin
{
    AMZLogDebug(@"");
    _wif = [[AmazonWIFCredentialsProvider alloc] initWithRole:FB_ROLE_ARN
                                          andWebIdentityToken:self.session.accessTokenData.accessToken
                                                 fromProvider:@"graph.facebook.com"];
    
    // if we have an id, we are logged in
    if (_wif.subjectFromWIF != nil) {
        NSLog(@"IDP id: %@", _wif.subjectFromWIF);
        [AmazonKeyChainWrapper storeUsername:_wif.subjectFromWIF];
        [self initClients];
        //[self.viewController dismissModalViewControllerAnimated:NO];
        //[self populateUserDetails];
        if (_delegate){
            [_delegate AmazonClientManagerDidLoginSuccessfully:self];
        }
    }
    else {
        //[[Constants errorAlert:@"Unable to assume role, please check logs for error"] show];
        if(_delegate)
            [_delegate AmazonClientManagerDidNotLogin:self withError:@"Unable to assume role, please check logs for error"];
    }
}

-(void)FBLogin
{
    AMZLogDebug(@"");

    // session already open, exit
    if (self.session.isOpen) {
        [self CompleteFBLogin];
        return;
    }
    
    AMZLogDebug(@"");
    if (self.session.state != FBSessionStateCreated) {
        AMZLogDebug(@"");
        // Create a new, logged out session.
        self.session = [[FBSession alloc] init] ;
    }
    
    AMZLogDebug(@"");
    [self.session openWithCompletionHandler:^(FBSession *session,
                                              FBSessionState status,
                                              NSError *error) {
        AMZLogDebug(@"");
        if (error != nil) {
            [[Constants errorAlert:[NSString stringWithFormat:@"Error logging in with FB: %@", error.description]] show];
        }
        else {
            [self CompleteFBLogin];
        }
    }];
    
}




@end
