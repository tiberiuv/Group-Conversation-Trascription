//
//  Process_helper.swift
//  asr_project
//
//  Created by Tiberiu Simion Voicu on 20/11/2017.
//  Copyright © 2017 Tiberiu Simion Voicu. All rights reserved.
//

import Foundation
import AVFoundation

class Process_helper {
    
    
    /*  Zero crossing rate
     Number of time-domain zero
     crossing rates in a frame
     * Higher value of ZCR for silence or background noise
     */
    func calculate_zcr(audio_frame:[Float]) -> Double{
        var sum: Double = 0
        for i in 2...audio_frame.count-1{
            sum += Double(abs(sign(audio_frame[i]) - sign(audio_frame[i-1])))
        }
        return (sum / 2)
    }
    
    /*  Root Mean Square Represents the energy of a frame
     Equation: sum of squares of each sample in a frame
     * Higher RMS for voice segment
     */
    func calculate_rms(audio_frame:[Float]) -> Double{
        var sum: Double = 0.0
        for sample in audio_frame{
            sum += Double(sample * sample)
        }
        
        return sqrt(sum / Double(audio_frame.count))
    }
    
    /*  Calculate Low energy frame rate of a segment
     as number of frames which have an rms value less than
     half of the average of the segment
     * Higher LEFR for voiced segment
     */
    func low_energy_framte_rate(segment:[[Float]]) -> Int{
        var frame_rms:[Double] = []
        var total_rms = 0.0;
        for frame in segment{
            frame_rms.append(calculate_rms(audio_frame: frame))
            total_rms += calculate_rms(audio_frame: frame)
        }
        let avg_rms = total_rms / Double(frame_rms.count)
        var count_rms = 0
        for rms in frame_rms{
            rms <= (avg_rms / 2) ? count_rms += 1 : nil
        }
        return count_rms
    }
    
    func is_voiced(sound_samples:[Float], vol_threshold:Float) -> Bool{
        var volume: Float = 0
        
        for sample in sound_samples{
            volume += abs(sample)
        }
        if (volume > vol_threshold) {
            return true
        } else {
            return false
        }
    }
    
}
