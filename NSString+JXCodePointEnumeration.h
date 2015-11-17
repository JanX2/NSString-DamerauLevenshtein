//
//  NSString+JXCodePointEnumeration.h
//  JXNumberStringProcessing
//
//  Created by Jan on 07.06.14.
//  Copyright (c) 2014 Jan Weiß. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, JXCodePointEnumerationOptions) {
    JXCodePointEnumerationOptionsRangeNotRequired = 1UL << 0,
	JXCodePointEnumerationReverse = 1UL << 1,
};

@interface NSString (JXCodePointEnumeration)

// Enumerates Unicode code points, not composed character sequences!
// The range must neither start nor end withing a surrogate pair.
// The string must be valid Unicode.
// Use -rangeOfComposedCharacterSequencesForRange: if unsure, if the above applies.
- (void)enumerateCodePointsWithOptionsJX:(JXCodePointEnumerationOptions)opts
							  usingBlock:(void (^)(UTF32Char codePoint, NSRange range, BOOL *stop))block;

- (void)enumerateCodePointsInRange:(NSRange)range
						 optionsJX:(JXCodePointEnumerationOptions)opts
						usingBlock:(void (^)(UTF32Char codePoint, NSRange range, BOOL *stop))block;

- (NSUInteger)countOccurancesOfCharactersInSetJX:(NSCharacterSet *)characterSet;

- (NSUInteger)countOccurancesOfDecimalDigitsJX;

@end
