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

+ (id)resultWithWord:(NSString *)aWord andDistance:(NSUInteger)aDistance;
- (id)initWithWord:(NSString *)aWord andDistance:(NSUInteger)aDistance;

@end

