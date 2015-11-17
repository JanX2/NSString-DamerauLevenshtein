//
//  NSString+JXCodePointEnumeration.m
//  JXNumberStringProcessing
//
//  Created by Jan on 07.06.14.
//  Copyright (c) 2014 Jan Weiß. All rights reserved.
//

#import "NSString+JXCodePointEnumeration.h"

#if 0
NS_INLINE NSRange NSMakeRangeFromCFRange(CFRange cfr) {
	return NSMakeRange(cfr.location == kCFNotFound ? NSNotFound : cfr.location, cfr.length);
}
#endif

NS_INLINE CFRange CFRangeMakeFromNSRange(NSRange range) {
	return CFRangeMake((range.location == NSNotFound ? kCFNotFound : range.location), range.length);
}

@implementation NSString (JXCodePointEnumeration)

- (void)enumerateCodePointsWithOptionsJX:(JXCodePointEnumerationOptions)opts
							  usingBlock:(void (^)(UTF32Char codePoint, NSRange range, BOOL *stop))block;
{
	NSRange fullRange = NSMakeRange(0, self.length);
	[self enumerateCodePointsInRange:fullRange
						   optionsJX:opts
						  usingBlock:block];
}

- (void)enumerateCodePointsInRange:(NSRange)range
						 optionsJX:(JXCodePointEnumerationOptions)opts
						usingBlock:(void (^)(UTF32Char codePoint, NSRange range, BOOL *stop))block;
{
	if (range.length == 0)  return;
	if (self.length == 0)  return;
	
	CFStringRef string = (__bridge CFStringRef)(self);
	
	const CFRange subRange = CFRangeMakeFromNSRange(range);
	
	const bool wantRange = !(opts & JXCodePointEnumerationOptionsRangeNotRequired);
	const NSRange dummyRange = NSMakeRange(NSNotFound, 0);
	
	const bool forwardEnumeration = !(opts & JXCodePointEnumerationReverse);
	
	CFStringInlineBuffer stringInlineBuffer;
	CFStringInitInlineBuffer(string, &stringInlineBuffer, subRange);
	
	CFIndex i; // Index relative to subRange.
	NSRange currentRange = dummyRange;
	
	if (forwardEnumeration) {
		for (i = 0;
			 i < subRange.length;
			 i++) {
			BOOL stop = NO;
			
			const UniChar char1 = CFStringGetCharacterFromInlineBuffer(&stringInlineBuffer, i);
			UniChar char2 = 0;
			
			const Boolean isPair = CFStringIsSurrogateHighCharacter(char1);
			
			if (isPair) {
				const CFIndex char2Index = i + 1;
				
				NSAssert(char2Index < subRange.length, @"The range must neither start nor end withing a surrogate pair.");
				
				char2 = CFStringGetCharacterFromInlineBuffer(&stringInlineBuffer, char2Index);
				
				NSAssert(CFStringIsSurrogateLowCharacter(char2), @"The string must be valid Unicode.");
				
				const UTF32Char codePoint = CFStringGetLongCharacterForSurrogatePair(char1, char2);
				
				if (wantRange) {
					currentRange.location = subRange.location + i;
					currentRange.length = 2;
				}
				
				block(codePoint, currentRange, &stop);
				
				i++; // Continue, stepping an additional time, so we don’t process the UTF-16 low character again on the next loop.
			}
			else {
				if (wantRange) {
					currentRange.location = subRange.location + i;
					currentRange.length = 1;
				}
				
				block((UTF32Char)char1, currentRange, &stop);
			}
			
			if (stop)  break;
		}
	}
	else {
		CFIndex last = subRange.length - 1;
		for (i = last;
			 YES;
			 --i) {
			BOOL stop = NO;
			
			UniChar char0 = 0;
			const UniChar char1 = CFStringGetCharacterFromInlineBuffer(&stringInlineBuffer, i);
			
			const Boolean isPair = CFStringIsSurrogateLowCharacter(char1);
			
			if (isPair) {
				i -= 1; // The current range actually starts one code unit earlier.
				const CFIndex char0Index = i;
				
				NSAssert(char0Index >= 0, @"The range must neither start nor end withing a surrogate pair.");
				
				char0 = CFStringGetCharacterFromInlineBuffer(&stringInlineBuffer, char0Index);
				
				NSAssert(CFStringIsSurrogateHighCharacter(char0), @"The string must be valid Unicode.");
				
				const UTF32Char codePoint = CFStringGetLongCharacterForSurrogatePair(char0, char1);
				
				if (wantRange) {
					currentRange.location = subRange.location + i;
					currentRange.length = 2;
				}
				
				block(codePoint, currentRange, &stop);
			}
			else {
				if (wantRange) {
					currentRange.location = subRange.location + i;
					currentRange.length = 1;
				}
				
				block((UTF32Char)char1, currentRange, &stop);
			}
			
			if ((i == 0) || stop)  break;
		}
	}
}

- (NSUInteger)countOccurancesOfCharactersInSetJX:(NSCharacterSet *)characterSet;
{
	if (self.length == 0)  return 0;
	
	CFCharacterSetRef characterSetCF = (__bridge CFCharacterSetRef)characterSet;
	
	__block NSUInteger count = 0;
	
	[self enumerateCodePointsWithOptionsJX:JXCodePointEnumerationOptionsRangeNotRequired
								usingBlock:
	 ^(UTF32Char codePoint, NSRange range, BOOL *stop) {
		 if (CFCharacterSetIsLongCharacterMember(characterSetCF, codePoint)) {
			 count++;
		 }
	 }];
	
	return count;
}

- (NSUInteger)countOccurancesOfDecimalDigitsJX;
{
	return [self countOccurancesOfCharactersInSetJX:[NSCharacterSet decimalDigitCharacterSet]];
}

@end
