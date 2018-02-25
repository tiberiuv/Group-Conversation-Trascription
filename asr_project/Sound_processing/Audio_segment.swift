//
//  Audio_segment.swift
//  asr_project
//
//  Created by Tiberiu Simion Voicu on 22/11/2017.
//  Copyright © 2017 Tiberiu Simion Voicu. All rights reserved.
//

import Foundation

class Audio_segment {
    var frame_list:[Audio_frame] = []
    var voiced:Bool = false;
    init(){
        
    }
    
    init(frames:[Audio_frame]){
        self.frame_list = frames;
    }
    func set_voiced(){
        if( self.voiced == false) {
            self.voiced = true;
        }
    }
    func append(frame: Audio_frame){
        frame_list.append(frame)
    }
    func print(){
        for frame in frame_list{
            frame.print_features()
        }
    }
    func get_frames() -> [Float]{
        var seg_frames: [Float] = []
        for audio_frame in frame_list{
            seg_frames.append(contentsOf: audio_frame.get_samples())
        }
        return seg_frames
    }
    func deleteAll(){
        if(frame_list.count > 0) { frame_list.removeAll() }
    }
}
