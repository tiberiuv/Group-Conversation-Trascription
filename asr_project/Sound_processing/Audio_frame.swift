//
//  Audio_frame.swift
//  asr_project
//
//  Created by Tiberiu Simion Voicu on 20/11/2017.
//  Copyright © 2017 Tiberiu Simion Voicu. All rights reserved.
//

import Foundation

class Audio_frame {
    public var sample_list:[Float];
    var zcr:Float
    var rms:Double
    init(samples:[Float]) {
        self.sample_list = samples;
        self.zcr = Process_helper.calculate_zcr(sample_list)
        self.rms = Process_helper.calculate_rms(sample_list)
    }
    func get_samples()-> [Float]{
        return sample_list
    }
    func print_features(){
        print("ZCR: \(zcr)")
        print("RMS: \(rms)")
    }
    
}
