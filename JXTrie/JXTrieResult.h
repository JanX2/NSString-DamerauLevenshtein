//
//  JXTrieResult.h
//  Damerau-Levenshtein
//
//  Created by Jan on 15.01.11.
//  Copyright 2011-2012 geheimwerk.de. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JXTrieResult : NSObject <NSCopying> {
	NSString *word;
	NSUInteger distance;
}

@property (nonatomic, copy) NSString *word;
@property (nonatomic, assign) NSUInteger distance;

+ (instancetype)resultWithWord:(NSString *)aWord andDistance:(NSUInteger)aDistance;
- (instancetype)initWithWord:(NSString *)aWord andDistance:(NSUInteger)aDistance NS_DESIGNATED_INITIALIZER;

@end

