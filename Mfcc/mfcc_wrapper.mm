//
//  mfcc_wrapper.mm
//  asr_project
//
//  Created by Tiberiu Simion Voicu on 07/12/2017.
//  Copyright © 2017 Tiberiu Simion Voicu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "mfcc_wrapper.h"
#import "mfcc.cc"
//#import <WebKit/WebKit.h>
#import <WebRTC/WebRTC.h>
//#import "src-master-common_audio-vad/webrtc_vad.c"


@implementation mfcc_wrapper
- (double*)get_mfccs:(float*) samples and_size:(uint32_t) size{
    int numCepstra = 12;
    int numFilters = 40;
    int samplingRate = 16000; // change
    int winLength = 25;
    int frameShift = 10;
    int lowFreq = 50;
    int highFreq = samplingRate / 2;
    
    // Initialise MFCC class instance
    MFCC mfccComputer (samplingRate, numCepstra, winLength, frameShift, numFilters, lowFreq, highFreq);
    auto mfccs = mfccComputer.process_floats(samples, size);

    double* vector_mfcc = new double[mfccs.size()*12];
    vector_mfcc[0] = mfccs.size();
    for (int i=1; i<mfccs.size(); i++) {
        for(int k=0; k<mfccs[0].size(); k++)
            vector_mfcc[i] = mfccs[i][k];
        
    }
    return vector_mfcc;
    
}

@end
