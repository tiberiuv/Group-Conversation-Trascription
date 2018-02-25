//
//  audio_file.swift
//  asr_project
//
//  Created by Tiberiu Simion Voicu on 20/11/2017.
//  Copyright © 2017 Tiberiu Simion Voicu. All rights reserved.
//

import Foundation
import AVFoundation
class Audio_file {
    var url:URL;
    var file:AVAudioFile;
    var sampling_rate:Double
    var format: AVAudioFormat;
    
    init(url:URL) {
        self.url = url;
        self.file = try! AVAudioFile(forReading: url)
        self.sampling_rate = file.fileFormat.sampleRate
        
        format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false)!

    }
    func print_description(){
        print("File Url: \(self.url)")
        print("Sampling rate: \(self.sampling_rate)")
    
    }
    
    
    
    
}
