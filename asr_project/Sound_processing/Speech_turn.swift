//
//  Speech_turn.swift
//  asr_project
//
//  Created by Tiberiu Simion Voicu on 22/11/2017.
//  Copyright © 2017 Tiberiu Simion Voicu. All rights reserved.
//

import Foundation
class Speech_turn {
    var segments: [Audio_segment] = [];
    var speaker_id: Int = 0
    init(){
        
    }
    init(segments: [Audio_segment], speaker_id: Int!){
        self.segments = segments;
        self.speaker_id = speaker_id
    }
    
    func set_speaker_id(speaker_id: Int){
        self.speaker_id = speaker_id;
    }
    
}
