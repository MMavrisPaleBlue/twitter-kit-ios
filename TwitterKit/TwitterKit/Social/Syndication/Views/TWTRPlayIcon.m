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

#import <TwitterKit/TWTRPlayIcon.h>
#import <TwitterKit/TWTRImages.h>

const CGFloat TWTRPlayIconWidth = 100.0;

@implementation TWTRPlayIcon

- (instancetype)init
{
    if (self = [super init]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.image = [TWTRImages playIcon];
    }
    return self;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(TWTRPlayIconWidth, TWTRPlayIconWidth);
}

@end
