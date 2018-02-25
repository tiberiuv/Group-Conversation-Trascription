//
//  vad.swift
//  asr_project
//
//  Created by Tiberiu Simion Voicu on 05/12/2017.
//  Copyright © 2017 Tiberiu Simion Voicu. All rights reserved.
//

import Foundation

class vad {
    var energy_threshold = 0
    var f_threshold = 0
    var SFM_threshold = 0
    
    func is_speech(segment: Audio_segment){
        let samples_array = segment.get_frames()
        let samples_pointer: UnsafeMutablePointer<Float> = UnsafeMutablePointer(mutating:samples_array)
        let size = int32(samples_array.count)

    }
}
