/*
 * Copyright (C) 2017 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

/**
 This header is private to the Twitter Kit SDK and not exposed for public SDK consumption
 */

#import <Foundation/Foundation.h>
#import <TwitterKit/TWTRAuthConfig.h>
#import <TwitterKit/TWTRLoginURLParser.h>
#import <TwitterKit/TWTRTwitter.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^TWTRMobileSSOCompletion)(BOOL twitterAppInstalled);

@interface TWTRMobileSSO : NSObject

@property (nonatomic) TWTRLoginURLParser *loginURLParser;
@property (nonatomic, copy) TWTRLogInCompletion completion;

- (instancetype)initWithSessionStore:(id<TWTRSessionStore>)store;

/*
 *  Attempt to authenticate with the Twitter iOS app if installed
 */
- (void)attemptAppLoginWithCompletion:(TWTRLogInCompletion)completion;

/*
 *  Save authentication details received from the Twitter iOS App
 *
 *  Returns YES if a valid Mobile SSO redirect URL, NO if not.
 */
- (BOOL)processRedirectURL:(NSURL *)url;

/**
 *  Determines if the source application sent from the calling applciation is valid.
 *
 *  Returns YES if the source application is Twitter sanctioned, NO otherwise.
 */
- (BOOL)isSSOWithSourceApplication:(NSString *)sourceApplication;

/**
 *  Determines if the source application sent from web is valid.
 *
 *  Returns YES if the source application is Twitter sanctioned, NO otherwise.
 */
- (BOOL)isWebWithSourceApplication:(NSString *)sourceApplication;

/**
 *  Determines if the url sent from the calling applciation is valid.
 */
- (BOOL)isSSOWithURL:(NSURL *)url;

/**
 *  Determines if the url sent from web is valid.
 */
- (BOOL)isWebWithURL:(NSURL *)url;

/**
 *  Triggers an error completion when invalid source is detected
 */
- (void)triggerInvalidSourceError;

/**
 *  Verifies if the token embedded in the url is the same one received by oauth/request_token.
 *
 *  Returns YES if the token passed in the url parameter matches the token received by oauth/request_token.
 */
- (BOOL)verifyOauthTokenResponsefromURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
