//
//  JXLDStringTokenUtilities.m
//  Damerau-Levenshtein
//
//  Created by Jan on 04.05.12.
//  Copyright (c) 2012 geheimwerk.de. All rights reserved.
//

#import "JXLDStringTokenUtilities.h"

int jxst_CFStringPrepareTokenRangesArray(CFStringRef string, CFRange tokenizerRange, CFOptionFlags tokenizerOptions, CFRange **ranges) {
	// This function contains a very crude pseudo-dynamic array implementation as it is a pain to work with CFRange structs and CFArray objects.
	// Don’t forget to free the ranges array when you are done with it!
	int token_ranges_capacity = 4;
	CFRange * token_ranges = malloc(token_ranges_capacity * sizeof(CFRange));
	
	CFStringTokenizerRef tokenizer = CFStringTokenizerCreate(kCFAllocatorDefault, string, tokenizerRange, tokenizerOptions, NULL);

	Boolean detectGaps = (tokenizerOptions != kCFStringTokenizerUnitWord);

	// Set tokenizer to the start of the string. 
	CFStringTokenizerTokenType tokenType = CFStringTokenizerGoToTokenAtIndex(tokenizer, 0);
	
	CFRange tokenRange;
	CFIndex prevTokenRangeMax = 0;
	int token_index = 0;
	while (tokenType != kCFStringTokenizerTokenNone) {
		if (token_ranges_capacity == token_index+1) {
			token_ranges_capacity *= 2;
			token_ranges = realloc(token_ranges, (token_ranges_capacity * sizeof(CFRange)));
		}
		
		tokenRange = CFStringTokenizerGetCurrentTokenRange(tokenizer);
		
		if (detectGaps && tokenRange.location > prevTokenRangeMax) {
			// Gaps are expected behaviour when using kCFStringTokenizerUnitWord, 
			// but for some reason, gaps in other tokenizations can appear.
			// One particular example is the tokenizer skipping a line feed ('\n') directly after a string of Chinese characters when using kCFStringTokenizerUnitWordBoundary. 
			CFRange gapRange = CFRangeMake(prevTokenRangeMax, (tokenRange.location - prevTokenRangeMax));
			token_ranges[token_index] = gapRange;
			token_index++;
		}
		
		token_ranges[token_index] = tokenRange;
		token_index++;
		
		tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer);

		prevTokenRangeMax = (tokenRange.location + tokenRange.length);
	}
	
	CFRelease(tokenizer);
	
	*ranges = token_ranges;
	
	return token_index;
}

