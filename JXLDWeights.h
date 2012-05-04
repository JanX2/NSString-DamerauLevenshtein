//
//  JXLDWeights.h
//  Damerau-Levenshtein
//
//  Created by Jan on 04.05.12.
//  Copyright (c) 2012 geheimwerk.de. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
	float phrase_to_word;
	float min;
	float max;
	float length;
} JXLDWeights;

NS_INLINE JXLDWeights JXLDWeightsNormalize(JXLDWeights weights) {
	// Normalize weights so that the resulting distances/similarities will be normalized to the 0.0 … 1.0 range.
	float weight_sum = weights.min + weights.max + weights.length;
	
	weights.min /= weight_sum;
	weights.max /= weight_sum;
	weights.length /= weight_sum;
	
	return weights;
}

NS_INLINE JXLDWeights JXLDWeightsDefault() {
	JXLDWeights weights = (JXLDWeights){
		.phrase_to_word = 1.0f/3.0f,
		.min = 10.0f,
		.max = 1.0f,
		.length = -0.3f,
	};
	return JXLDWeightsNormalize(weights);
}

