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

#import <Foundation/Foundation.h>
#import <AWSS3/AWSS3.h>
#import <AWSSecurityTokenService/AWSSecurityTokenService.h>
#import "Constants.h"


@class AmazonClientManager;

@protocol AmazonClientManagerDelegate

@required
-(void)AmazonClientManagerDidLoginSuccessfully:(AmazonClientManager*)manager ;
-(void)AmazonClientManagerDidNotLogin:(AmazonClientManager*)manager withError:(NSString*)message;

@end

@interface AmazonClientManager:NSObject {}

//@property (retain, nonatomic) UIViewController *viewController;

@property (retain, nonatomic) FBSession *session;
@property (nonatomic, retain) id<AmazonClientManagerDelegate> delegate;
@property (nonatomic, strong, readonly) NSString* userName;
@property (nonatomic, strong, readonly) NSString* profileID;

-(void)reloadFBSession;
-(void)FBLogin;


+(AmazonClientManager *)sharedInstance;

-(AmazonS3Client *)s3;

-(bool)isLoggedIn;
-(bool)hasCredentials;
-(void)wipeAllCredentials;

@end
