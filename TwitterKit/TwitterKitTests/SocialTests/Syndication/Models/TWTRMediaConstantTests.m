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

#import <XCTest/XCTest.h>
#import <TwitterKit/TWTRNotificationConstants.h>
#import <TwitterKit/TWTRVideoMediaType.h>

@interface TWTRMediaConstantTests : XCTestCase

@end

@implementation TWTRMediaConstantTests

- (void)testType_GIF
{
    NSString *expected = @"TWTRVideoTypeGIF";
    NSString *actual = TWTRMediaConstantFromMediaType(TWTRMediaTypeGIF);

    XCTAssertEqualObjects(expected, actual);
}

- (void)testType_Standard
{
    NSString *expected = @"TWTRVideoTypeStandard";
    NSString *actual = TWTRMediaConstantFromMediaType(TWTRMediaTypeVideo);

    XCTAssertEqualObjects(expected, actual);
}

- (void)testType_Vine
{
    NSString *expected = @"TWTRVideoTypeVine";
    NSString *actual = TWTRMediaConstantFromMediaType(TWTRMediaTypeVine);

    XCTAssertEqualObjects(expected, actual);
}

@end
