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
    static func calculate_zcr(audio_frame:[Float]) -> Float{
        var sum: Float = 0
        for i in 2...audio_frame.count-1{
            sum += abs(sign(audio_frame[i]) - sign(audio_frame[i-1]) )
        }
        return (sum / 2 )
    }
    
    /*  Root Mean Square Represents the energy of a frame
     Equation: sum of squares of each sample in a frame
     * Higher RMS for voiced frame
     */
    static func calculate_rms(audio_frame:[Float]) -> Double{
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
    static func low_energy_framte_rate(segment:[[Float]]) -> Int{
        var frame_rms:[Double] = []
        var total_rms = 0.0
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
    
//    static func is_voiced(sound_samples:[Float], vol_threshold:Float) -> Bool{
//        var volume: Float = 0
//
//        for sample in sound_samples{
//            volume += abs(sample)
//        }
//        if (volume > vol_threshold) {
//            return true
//        } else {
//            return false
//        }
//    }
<<<<<<< HEAD
    static func buffer2float(buffer: AVAudioPCMBuffer) -> [Float] {
        return Array(UnsafeBufferPointer(start: buffer.floatChannelData?[0], count:Int(buffer.frameLength)))
=======
    static func buffer_to_float(buffer: AVAudioPCMBuffer) -> [Float] {
        return Array(UnsafeBufferPointer(start: buffer.floatChannelData?[0], count:Int(buffer.frameLength)));
>>>>>>> 47ef41a332b45300ae210a40d7218ad8060926ef
    }
    static func float2buffer(samples :[Float], audio_format: AVAudioFormat) -> AVAudioPCMBuffer{
        let buffer = AVAudioPCMBuffer(pcmFormat: audio_format, frameCapacity: AVAudioFrameCount(samples.count))
        let pointer = UnsafePointer(samples)
        
        buffer?.floatChannelData![0].assign(from: pointer, count: samples.count)
        buffer?.frameLength = AVAudioFrameCount(samples.count)
        return buffer!
    }
    static func split_audio(audio_file :Audio_file) -> Speech_turn{
        let file = audio_file.file
        let buffer = AVAudioPCMBuffer(pcmFormat: file.fileFormat, frameCapacity: AVAudioFrameCount(file.length))
        var segment = Audio_segment()
        let turn = Speech_turn()
        while(file.framePosition < file.length) {
            // read new frame into buffer
            try! file.read(into: buffer!, frameCount: 512)
            
            let frame = Audio_frame(samples: Array(UnsafeBufferPointer(start: buffer?.floatChannelData?[0], count: Int(buffer!.frameLength))))
            segment.append(frame: frame)
            // segment of data 0.5 sec
            if(segment.frame_list.count >= Int(audio_file.sampling_rate / 2 / 512) ){
                turn.segments.append(segment)
                segment = Audio_segment()
            }
        }
        return turn
    }
    static func geometric_mean(samples: [Float]) -> Double {
<<<<<<< HEAD
        var total = 1.0;
        //let total = samples.reduce(1.0) {x,y in Double(x) * Double(y)}
        for i in 0..<samples.count {
            total *= Double(samples[i])
        }
        return abs(pow(total, 1.0/Double(samples.count)))
    }
    static func ar_mean(samples: [Float]) -> Double {
        let total: Double = samples.reduce(0.0) { x,y in Double(x) + Double(y)}
=======
        let total = samples.reduce(1.0) {x,y in Double(x) * Double(y)};
        
        return abs(pow(total, 1.0/Double(samples.count)));
    }
    static func ar_mean(samples: [Float]) -> Double {
        let total: Double = samples.reduce(0.0) { x,y in Double(x) + Double(y)};
>>>>>>> 47ef41a332b45300ae210a40d7218ad8060926ef
        
        return total / Double(samples.count);
    }
}
