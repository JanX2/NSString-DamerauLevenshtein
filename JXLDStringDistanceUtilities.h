//
//  JXLDStringDistanceUtilities.h
//  Damerau-Levenshtein
//
//  Created by Jan on 18.01.11.
//  Copyright 2011 geheimwerk.de. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JXLDStringDistance.h"


// Return the minimum of a, b and c - used by distanceFromString:options:
CF_INLINE CFIndex jxld_smallestCFIndex(CFIndex a, CFIndex b, CFIndex c) {
	CFIndex min = a;
	if ( b < min )
		min = b;
	
	if ( c < min )
		min = c;
	
	return min;
}

void jxld_CFStringPreprocessWithOptions(CFMutableStringRef string, JXLDStringDistanceOptions options);