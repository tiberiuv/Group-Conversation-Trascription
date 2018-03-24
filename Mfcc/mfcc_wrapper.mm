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
#import <WebRTC/WebRTC.h>



@implementation mfcc_wrapper
- (double*)get_mfccs:(float*) samples and_size:(uint32_t) size{
    int numCepstra = 12;
    int numFilters = 40;
    int samplingRate = 16000; // change
    int winLength = 25;
    int frameShift = 10;
    int lowFreq = 50;
    int highFreq = samplingRate / 2;
    bool appendDeltas = true;
    
    // Initialise MFCC class instance
    MFCC mfccComputer (samplingRate, numCepstra, winLength, frameShift, numFilters, lowFreq, highFreq, appendDeltas);
    auto mfccs = mfccComputer.process_floats(samples, size);
    std::vector<double> flat_mfccs;
    flat_mfccs.push_back(mfccs.size());
    for(const auto &v : mfccs) {
        flat_mfccs.insert(flat_mfccs.end(), v.begin()+1, v.end()); // begin()+1 to get rid of first cepestrum(energy)
    }
    
    return flat_mfccs.data();
}

@end
