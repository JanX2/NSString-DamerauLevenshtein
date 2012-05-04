//
//  JXLDStringTokenUtilities.m
//  Damerau-Levenshtein
//
//  Created by Jan on 04.05.12.
//  Copyright (c) 2012 geheimwerk.de. All rights reserved.
//

#import "JXLDStringTokenUtilities.h"

int jxst_CFStringPrepareTokenRangesArray(CFStringRef string, CFRange tokenizerRange, CFOptionFlags tokenizerOptions, CFRange **ranges) {
	// This function contains a very crude pseudo-dynamic array implementation as it is a pain to work with CFRange structs and CFArray objects
	// Don’t forget to free the ranges array when you are done with it!
	int token_ranges_capacity = 4;
	CFRange * token_ranges = malloc(token_ranges_capacity * sizeof(CFRange));
	
	CFStringTokenizerRef tokenizer = CFStringTokenizerCreate(kCFAllocatorDefault, string, tokenizerRange, tokenizerOptions, NULL);
	
	// Set tokenizer to the start of the string. 
	CFStringTokenizerTokenType mask = CFStringTokenizerGoToTokenAtIndex(tokenizer, 0);
	
	CFRange tokenRange;
	int token_index = 0;
	while (mask != kCFStringTokenizerTokenNone) {
		tokenRange = CFStringTokenizerGetCurrentTokenRange(tokenizer);
		
		if (token_ranges_capacity == token_index+1) {
			token_ranges_capacity *= 2;
			token_ranges = realloc(token_ranges, (token_ranges_capacity * sizeof(CFRange)));
		}
		
		token_ranges[token_index] = tokenRange;
		
		token_index++;
		
		mask = CFStringTokenizerAdvanceToNextToken(tokenizer);
	}
	
	CFRelease(tokenizer);
	
	*ranges = token_ranges;
	
	return token_index;
}

