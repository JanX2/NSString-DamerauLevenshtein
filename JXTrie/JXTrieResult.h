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

#ifdef JXTRIE_WANT_VALUE_STORAGE
@property (nonatomic, readonly) id value;
#endif

@property (nonatomic, readonly) float normalizedDistance;
@property (nonatomic, readonly) float similarity;

#ifndef JXTRIE_WANT_VALUE_STORAGE
+ (instancetype)resultWithWord:(NSString *)word distance:(NSUInteger)distance searchStringLength:(NSUInteger)searchStringLength;
- (instancetype)initWithWord:(NSString *)word distance:(NSUInteger)distance searchStringLength:(NSUInteger)searchStringLength NS_DESIGNATED_INITIALIZER;
#else
+ (instancetype)resultWithWord:(NSString *)word distance:(NSUInteger)distance searchStringLength:(NSUInteger)searchStringLength value:(id)value;
- (instancetype)initWithWord:(NSString *)word distance:(NSUInteger)distance searchStringLength:(NSUInteger)searchStringLength value:(id)value NS_DESIGNATED_INITIALIZER;
#endif

@end

