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

#import <TwitterKit/TWTRSearchTimelineDataSource.h>
#import <TwitterKit/TWTRAssertionMacros.h>
#import <TwitterKit/TWTRMultiThreadUtil.h>
#import <TwitterKit/TWTRAPIClient_Private.h>
#import <TwitterKit/TWTRTimelineCursor.h>
#import <TwitterKit/TWTRTimelineDataSource_Constants.h>
#import <TwitterKit/TWTRTimelineFilter.h>
#import <TwitterKit/TWTRTimelineFilterManager.h>
#import <TwitterKit/TWTRTimelineParser.h>

static NSString *const TWTRSearchTimelineResultTypeMixed = @"mixed";
static NSString *const TWTRSearchTimelineResultTypeRecent = @"recent";
static NSString *const TWTRSearchTimelineResultTypePopular = @"popular";

@interface TWTRSearchTimelineDataSource ()
@property (nonatomic) TWTRTimelineFilterManager *timelineFilterManager;
@end

@implementation TWTRSearchTimelineDataSource
@synthesize APIClient = _APIClient;

- (instancetype)initWithSearchQuery:(NSString *)searchQuery APIClient:(TWTRAPIClient *)client
{
    return [self initWithSearchQuery:searchQuery APIClient:client languageCode:nil maxTweetsPerRequest:TWTRTimelineDataSourceDefaultMaxTweetsPerRequest resultType:TWTRSearchTimelineResultTypeMixed];
}

- (instancetype)initWithSearchQuery:(NSString *)searchQuery APIClient:(TWTRAPIClient *)client languageCode:(NSString *)languageCode maxTweetsPerRequest:(NSUInteger)maxTweetsPerRequest resultType:(NSString *)resultType
{
    TWTRParameterAssertOrReturnValue(searchQuery, nil);
    TWTRParameterAssertOrReturnValue(client, nil);
    if (self = [super init]) {
        _searchQuery = [searchQuery copy];
        _languageCode = [languageCode copy];
        _maxTweetsPerRequest = maxTweetsPerRequest;
        _APIClient = client;
        _filterSensitiveTweets = YES;
        _resultType = resultType;
    }
    return self;
}

#pragma mark - Property

- (void)setTimelineFilter:(TWTRTimelineFilter *)timelineFilter
{
    [TWTRMultiThreadUtil assertMainThread];

    if (_timelineFilter != timelineFilter) {
        _timelineFilter = timelineFilter;

        // update associated filter manager
        if (timelineFilter != nil) {
            _timelineFilterManager = [[TWTRTimelineFilterManager alloc] initWithFilters:timelineFilter];
        } else {
            _timelineFilterManager = nil;
        }
    }
}

#pragma mark - TWTRTimelineDataSource Protocol Methods

- (void)loadPreviousTweetsBeforePosition:(NSString *)position completion:(TWTRLoadTimelineCompletion)completion
{
    // We always filter retweets. At some point in the future the search team will give
    // us a new endpoint to call and we can remove this filter.
    NSString *searchQuery = [self.searchQuery stringByAppendingString:@" -filter:retweets"];
    if (self.filterSensitiveTweets) {
        searchQuery = [searchQuery stringByAppendingString:@" filter:safe"];
    }
    NSDictionary *params = [self queryParametersWithMaxPosition:position];

    [self.APIClient loadTweetsForSearchQuery:searchQuery
                                  parameters:params
                       timelineFilterManager:self.timelineFilterManager
                                  completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error) {

                                      BOOL noTweetsFound = [tweets count] == 0;
                                      BOOL noOtherError = error == nil;
                                      if (noTweetsFound && noOtherError) {
                                          NSLog(@"[TwitterKit] No tweets found for query: %@", self.searchQuery);
                                      }

                                      completion(tweets, cursor, error);
                                  }];
}

- (TWTRTimelineType)timelineType
{
    return TWTRTimelineTypeSearch;
}

#pragma mark - Helper Methods

- (NSDictionary *)queryParametersWithMaxPosition:(NSString *)maxPosition
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    NSString *resultType;
    if ([self.resultType isEqualToString:TWTRSearchTimelineResultTypeRecent]) {
        resultType = TWTRSearchTimelineResultTypeRecent;
    } else if ([self.resultType isEqualToString:TWTRSearchTimelineResultTypePopular]) {
        resultType = TWTRSearchTimelineResultTypePopular;
    } else {
        resultType = TWTRSearchTimelineResultTypeMixed;
    }
    params[@"result_type"] = resultType;

    if (self.maxTweetsPerRequest) {
        params[@"count"] = [NSString stringWithFormat:@"%tu", self.maxTweetsPerRequest];
    }

    if (self.languageCode.length > 0) {
        params[@"lang"] = self.languageCode;
    }

    if (self.geocodeSpecifier.length > 0) {
        params[@"geocode"] = self.geocodeSpecifier;
    }

    if (maxPosition) {
        // When fetching a new page of tweets, we need to offset
        // the 'max_id' to ensure that we don't load the last
        // tweet a second time
        NSString *dedupedTweetPosition = decrementTweetPosition(maxPosition);
        if (dedupedTweetPosition) {
            params[@"max_id"] = dedupedTweetPosition;
        }
    }

    return params;
}

@end
