//
//  MLPackWrapper.h
//  asr_project
//
//  Created by Tiberiu Simion Voicu on 27/02/2018.
//  Copyright © 2018 Tiberiu Simion Voicu. All rights reserved.
//

#ifndef MLPackWrapper_h
#define MLPackWrapper_h

#import <Foundation/Foundation.h>

@interface MLPackWrapper : NSObject

- (void)build_classifier:(double*) features and_size:(uint32_t) size;

@end

#endif /* MLPackWrapper_h */
