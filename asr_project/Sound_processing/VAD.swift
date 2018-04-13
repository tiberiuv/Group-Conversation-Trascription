//
//  Voice_detector.swift
//  asr_project
//
//  Created by Tiberiu Simion Voicu on 02/12/2017.
//  Copyright © 2017 Tiberiu Simion Voicu. All rights reserved.
//

import Foundation
//import WebRTC
class VAD {
//    var segment: Audio_segment
    private var framesize:Double = 10 //10 ms
    private var no_frames = 0
    private var num_samples = 0
    // default threshold params
<<<<<<< HEAD
    private let def_e: Double = 40
    private let def_f: Double = 185
    private let def_sfm: Double = 5
    var pcm_buffer: AVAudioPCMBuffer
    var samples: [Float]?
=======
    private let def_e: Double = 40;
    private let def_f: Double = 185;
    private let def_sfm: Double = 5;
    var pcm_buffer: AVAudioPCMBuffer;
    var samples: [Float]?;
>>>>>>> 47ef41a332b45300ae210a40d7218ad8060926ef
    
    init(buffer: AVAudioPCMBuffer) {
        self.pcm_buffer = buffer
        self.num_samples = Int(buffer.format.sampleRate * (framesize / 1000.0))
        self.no_frames = Int(Double(buffer.frameLength) / Double(num_samples))
        
    }
//    init(speech_samples: [Float], sampling_rate: Double) {
//        self.samples = speech_samples;
//        self.num_samples = Int(sampling_rate * (framesize / 1000.0));
//        self.no_frames = speech_samples.count / num_samples;
//    }
    func reinit(buffer: AVAudioPCMBuffer) {
<<<<<<< HEAD
        self.pcm_buffer = buffer
        self.num_samples = Int(buffer.format.sampleRate * (framesize / 1000.0))
        self.no_frames = Int(Double(buffer.frameLength) / Double(num_samples))
=======
        self.pcm_buffer = buffer;
        self.num_samples = Int(buffer.format.sampleRate * (framesize / 1000.0));
        self.no_frames = Int(Double(buffer.frameLength) / Double(num_samples));
>>>>>>> 47ef41a332b45300ae210a40d7218ad8060926ef
    }
    // energy is root mean square(rms) of a frame
    // frequency is the most dominant frequency in the fft bins of a frame
    // sfm is the spectral flatness measure of the power spectrum of a frame
<<<<<<< HEAD
    func detect(speech: (_ index: Int) -> Void){
=======
    func detect(speech: (_ speech_time: Double) -> Void){
>>>>>>> 47ef41a332b45300ae210a40d7218ad8060926ef
        
        print("Duration \(Double(pcm_buffer.frameLength) / (pcm_buffer.format.sampleRate))")
        // thresholds based on float stream
        var thr_energy: Double = 0.0
        var thr_freq: Double = 0.0
        var thr_sfm: Double = 0.0
        var min_e: Double = 1000
        var min_f: Double = 1000
        var min_sfm: Double = 1000
        var samples: [Float]
        let fft = FFTComputer(no_frames)
        var freq = 0.0
        var speech_c = 0
        var silence_c:Double = 0
        var sfm = 0.0
        var flag = false
        for i in 0...no_frames {
            samples = Array(UnsafeBufferPointer(start: pcm_buffer.floatChannelData?[0].advanced(by: i*num_samples), count:num_samples)); // 1 frame worth of
            let energy = Process_helper.calculate_rms(audio_frame: samples); // energy of 1 frame
            do {
<<<<<<< HEAD
                let fft_buffer = try fft.transform(input: samples)
                freq = try Double(fft.domin_freq(fft_buffer)) * ((pcm_buffer.format.sampleRate)/2) / Double(fft_buffer.count)
                sfm = fft.getSpectralFlatness(fft_buffer)
            } catch {print("error in calcualting fft: \(error)")}
            if (i < 30) {
                if( energy < min_e ) { min_e = energy}
                if (freq  < min_f) {min_f = freq}
                if (sfm < min_sfm) {min_sfm = sfm}
            }
            else {
                thr_energy = def_e * log(min_e)
                thr_freq = def_f
                thr_sfm = def_sfm;
                
                var counter = 0
                if(energy - min_e >= thr_energy) { counter += 1 }
                if(freq - min_f >= thr_freq) { counter += 1 }
                if(sfm - min_sfm >= thr_sfm) { counter += 1 }
                
                if counter > 1 { speech_c += 1; silence_c = 0}
                else {
                    speech_c = 0
                    silence_c += 1
                    min_e = ((silence_c * min_e) + energy) / (silence_c + 1)
                }
<<<<<<< HEAD
                thr_energy = def_e * log(min_e)
                var indexSpeech = 0
                var speech_time = 0.0
                // speech happening
                if(speech_c >= 5) {
                    indexSpeech = i * num_samples
                    speech_time = ( Double(i*num_samples) / pcm_buffer.format.sampleRate)
                    print("SPEECH !!! at : \(speech_time)")
                    speech(indexSpeech)
                }
                
                // no speech happening
                if(silence_c >= 10) {
                    print("NO SPEECH !!! at : \( Double(i*num_samples) / pcm_buffer.format.sampleRate)")
                    if(speech_time != 0.0) {
                        speech_time = ( Double(i*num_samples) / (pcm_buffer.format.sampleRate))
                    }
                }
            }
        }
    }
}
