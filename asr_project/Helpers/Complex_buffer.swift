//
//  Complex_buffer.swift
//  asr_project
//
//  Created by Tiberiu Simion Voicu on 27/01/2018.
//  Copyright © 2018 Tiberiu Simion Voicu. All rights reserved.
//

struct Buffer {
    var elements: [Float]
    var realElements: [Float]?
    var imagElements: [Float]?
    
    var count: Int {
        return elements.count
    }
    
    // MARK: - Initialization
    init(elements: [Float], realElements: [Float]? = nil, imagElements: [Float]? = nil) {
        self.elements = elements
        self.realElements = realElements
        self.imagElements = imagElements
    }
}
