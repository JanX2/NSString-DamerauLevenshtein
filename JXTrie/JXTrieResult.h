//
//  JXTrieResult.h
//  Damerau-Levenshtein
//
//  Created by Jan on 15.01.11.
//  Copyright 2011-2015 geheimwerk.de. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JXTrieResult : NSObject <NSCopying>

@property (nonatomic, readonly) NSString *word;
@property (nonatomic, readonly) NSUInteger distance;
@property (nonatomic, readonly) NSUInteger searchStringLength;

@property (nonatomic, readonly) float normalizedDistance;
@property (nonatomic, readonly) float similarity;

+ (instancetype)resultWithWord:(NSString *)word distance:(NSUInteger)distance searchStringLength:(NSUInteger)searchStringLength;
- (instancetype)initWithWord:(NSString *)word distance:(NSUInteger)distance searchStringLength:(NSUInteger)searchStringLength NS_DESIGNATED_INITIALIZER;

@end

