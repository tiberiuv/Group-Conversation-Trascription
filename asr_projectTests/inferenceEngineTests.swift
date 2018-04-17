//
//  inferenceEngineTests.swift
//  asr_projectTests
//
//  Created by Tiberiu Simion Voicu on 17/04/2018.
//  Copyright © 2018 Tiberiu Simion Voicu. All rights reserved.
//

import Foundation
import XCTest
@testable import asr_project

class inferenceEngineTests: XCTestCase {
    let file_chad_train: Audio_file = Audio_file(url: Bundle.main.url(forResource: "chad_joined", withExtension: "wav", subdirectory: "data_friends")!)
    let file_joey_train = Audio_file(url: Bundle.main.url(forResource: "joey_joined", withExtension: "wav", subdirectory: "data_friends")!)
    let file_monica_train = Audio_file(url: Bundle.main.url(forResource: "monica_joined", withExtension: "wav", subdirectory: "data_friends")!)
    let file_phoebe_train = Audio_file(url: Bundle.main.url(forResource: "phoebe_joined", withExtension: "wav", subdirectory: "data_friends")!)
    let file_rachel_train = Audio_file(url: Bundle.main.url(forResource: "rachel_joined", withExtension: "wav", subdirectory: "data_friends")!)
    let file_ross_train = Audio_file(url: Bundle.main.url(forResource: "ross_joined", withExtension: "wav", subdirectory: "data_friends")!)
    let file_ross_test = Audio_file(url: Bundle.main.url(forResource: "ross_test", withExtension: "wav", subdirectory: "data_friends")!)
    
    var chad_train: [Float]!
    var joey_train: [Float]!
    var monica_train: [Float]!
    var phoebe_train: [Float]!
    var rachel_train: [Float]!
    var ross_train: [Float]!
    var ross_test: [Float]!
    
    var vad_ross: [[Double]]!
    var vad_chad: [[Double]]!
    var vad_rachel: [[Double]]!
    var vad_joey: [[Double]]!
    var vad_phoebe: [[Double]]!
    var vad_monica: [[Double]]!
    var vad_ross_test: [[Double]]!
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        //        file = Audio_file(url :Bundle.main.url(forResource: "7127-75946-0002", withExtension: "flac")!)
        print(file_chad_train.format.description)
        
        let buffer = AVAudioPCMBuffer(pcmFormat: file_chad_train.format, frameCapacity: UInt32(file_chad_train.file.length))
        let buffer1 = AVAudioPCMBuffer(pcmFormat: file_joey_train.format, frameCapacity: UInt32(file_joey_train.file.length))
        let buffer2 = AVAudioPCMBuffer(pcmFormat: file_monica_train.format, frameCapacity: UInt32(file_monica_train.file.length))
        let buffer3 = AVAudioPCMBuffer(pcmFormat: file_phoebe_train.format, frameCapacity: UInt32(file_phoebe_train.file.length))
        let buffer4 = AVAudioPCMBuffer(pcmFormat: file_rachel_train.format, frameCapacity: UInt32(file_rachel_train.file.length))
        let buffer5 = AVAudioPCMBuffer(pcmFormat: file_ross_train.format, frameCapacity: UInt32(file_ross_train.file.length))
        let buffer6 = AVAudioPCMBuffer(pcmFormat: file_ross_test.format, frameCapacity: UInt32(file_ross_test.file.length))
        
        do {
            try file_joey_train.file.read(into: buffer1!)
            joey_train = Process_helper.buffer2float(buffer: buffer1!)
//            vad_joey = test_vad(buffer1!)
            try file_monica_train.file.read(into: buffer2!)
            monica_train = Process_helper.buffer2float(buffer: buffer2!)
//            vad_monica = test_vad(buffer2!);
            try file_phoebe_train.file.read(into: buffer3!)
            phoebe_train = Process_helper.buffer2float(buffer: buffer3!)
//            vad_phoebe = test_vad(buffer3!);
            try file_rachel_train.file.read(into: buffer4!)
            rachel_train = Process_helper.buffer2float(buffer: buffer4!)
//            vad_rachel = test_vad(buffer4!)
            try file_chad_train.file.read(into: buffer!)
            chad_train = Process_helper.buffer2float(buffer: buffer!)
//            vad_chad = test_vad(buffer!);
            try file_ross_train.file.read(into: buffer5!)
            ross_train = Process_helper.buffer2float(buffer: buffer5!)
//            vad_ross = test_vad(buffer5!);
            try file_ross_test.file.read(into: buffer6!)
            ross_test = Process_helper.buffer2float(buffer: buffer6!)
//            vad_ross_test = test_vad(buffer6!);
            
        } catch {print(error)}
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    func testInferenceEngine() {
        let mfccComputer = MFCCComputer()
        //        let chad = vad_chad!
        //        let rachel = vad_rachel!
        //        var ross = vad_ross!
        //        let rossTest = vad_ross_test!
        //        ross.append(contentsOf: rossTest)
        //        let monica = vad_monica!
        //        let phoebe = vad_phoebe!
        //        let joey = vad_joey!
        let chad = mfccComputer.process(samples: chad_train)
        let rachel = mfccComputer.process(samples: rachel_train)
        var ross = mfccComputer.process(samples: ross_train)
        let rossTest = mfccComputer.process(samples: ross_test)
        ross.append(contentsOf: rossTest)
        let monica = mfccComputer.process(samples: monica_train)
        let phoebe = mfccComputer.process(samples: phoebe_train)
        let joey = mfccComputer.process(samples: joey_train)
        
        let infEngine = InferenceEngine(speakerFeatMatrix: chad, outputCount: 1, normalization: .zscore, trainStrategy: .OAO)
        _ = infEngine.addSpeakerTrainingData(featureMatrix: rachel)
        _ = infEngine.addSpeakerTrainingData(featureMatrix: ross)
        _ = infEngine.addSpeakerTrainingData(featureMatrix: monica)
        _ = infEngine.addSpeakerTrainingData(featureMatrix: phoebe)
        _ = infEngine.addSpeakerTrainingData(featureMatrix: joey)
        
        infEngine.buildClassifiers()
        var accuracy = 0.0
        
        let testSet = chad
        for testVector in testSet {
            let speaker = infEngine.classify(testVector)
            print("speaker id = \(speaker)")
            if speaker == 0 {
                accuracy += 1
            }
        }
        print("Accuracy : \(accuracy * 100.0 / Double(testSet.count))% ")
        
        
    }

}

