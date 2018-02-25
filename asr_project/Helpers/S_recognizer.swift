//
//  s_recognizer.swift
//  asr_project
//
//  Created by Tiberiu Simion Voicu on 23/11/2017.
//  Copyright © 2017 Tiberiu Simion Voicu. All rights reserved.
//

import Foundation
import Speech

class S_recognizer {
    var turns: [Speech_turn] = []
    let speechRecognizer = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognition_task: SFSpeechRecognitionTask?
    
    init(turns: [Speech_turn]){
        self.turns = turns
    }
    
    init(turn: Speech_turn) {
        self.turns.append(turn)
    }
    
    func append(turn: Speech_turn){
        self.turns.append(turn)
    }
    
    func remove_all(){
        self.turns.removeAll()
    }
    func calculate_mfcs(){
        
    }
    func recognize(controller: FirstViewController){
        let audio_format = AVAudioFormat(commonFormat: .pcmFormatFloat32,sampleRate: 160000, channels: 1, interleaved: false)
//        let buffer = AVAudioPCMBuffer(pcmFormat: audio_format!, frameCapacity: AVAudioFrameCount(512))
//
//        var count = 1
        var frames = [Float]();
        for turn in turns {
            for segment in turn.segments {
                for frame in segment.frame_list{
                    //                frame.sample_list.withUnsafeBufferPointer({ (pointer: UnsafeBufferPointer<Float>) -> () in
                    //                    (buffer?.floatChannelData![0].assign(from: pointer.baseAddress!, count: frame.sample_list.count))!
                    //
                    //                })
                    //                count += 1
                    frames.append(contentsOf: frame.get_samples())
                }
            }
        }
        
//        let frame = Array(UnsafeBufferPointer(start: buffer!.floatChannelData?[0], count:Int(512)))
//        for flot in frame{
//            print(flot)
//        }
        let buffer = Process_helper.float_to_buffer(samples: frames, audio_format: audio_format!)
        
        guard let my_recognizer = SFSpeechRecognizer() else { return  }
        if !(my_recognizer.isAvailable) { return }

        self.request.append(buffer)
        self.request.shouldReportPartialResults = true;
        self.recognition_task = speechRecognizer?.recognitionTask(with: request, resultHandler: {(result, error) in
            
            if result != nil {
                let result = (result?.bestTranscription.formattedString)!
                print(result)
                controller.update_transcript(lable: result)
            }
                
            else if let error = error {
                print("Errrrorrrrr \(error)")
            }
        })
    }
}
