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


@implementation mfcc_wrapper
- (double*)get_mfccs:(float*) samples and_size:(uint32_t) size{
    int numCepstra = 12;
    int numFilters = 26;
    int samplingRate = 16000; // change
    int winLength = 25;
    int frameShift = 10;
    int lowFreq = 0;
    int highFreq = samplingRate / 2;
    bool appendDeltas = true;
    
    // Initialise MFCC class instance
    MFCC mfccComputer (samplingRate, numCepstra, winLength, frameShift, numFilters, lowFreq, highFreq, appendDeltas);
    auto mfccs = mfccComputer.process_floats(samples, size);
    std::vector<double> flat_mfccs;
    
    flat_mfccs.reserve(mfccs.size() * mfccs[0].size());
    flat_mfccs.push_back((mfccs.size() * numCepstra * 3));
    flat_mfccs.push_back((mfccs.size() * numCepstra * 3)); // size of flat_mfccs = first element is buggy so using second
    for(const auto &v : mfccs) {
        // begin()+1 to get rid of first cepestrum(energy)
        flat_mfccs.insert(flat_mfccs.end(), v.begin()+1, v.end());
    }
    return flat_mfccs.data();
}

@end
