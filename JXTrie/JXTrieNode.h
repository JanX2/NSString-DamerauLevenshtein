//
//  JXTrieNode.h
//  Damerau-Levenshtein
//
//  Created by Jan on 15.01.11.
//  Copyright 2011 geheimwerk.de. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JXTrieNode : NSObject {
	NSString *word;
	NSMutableDictionary *children;
}

@property (nonatomic, copy) NSString *word;
@property (nonatomic, retain) NSMutableDictionary *children;

- (NSUInteger)insertWord:(NSString *)newWord;

@end
