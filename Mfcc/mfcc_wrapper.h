//
//  mfcc_wrapper.h
//  asr_project
//
//  Created by Tiberiu Simion Voicu on 07/12/2017.
//  Copyright © 2017 Tiberiu Simion Voicu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface mfcc_wrapper : NSObject
- (double*)get_mfccs:(float*) samples and_size:(uint32_t) size;

@end
