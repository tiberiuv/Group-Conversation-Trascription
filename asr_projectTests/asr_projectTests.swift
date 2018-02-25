//
//  asr_projectTests.swift
//  asr_projectTests
//
//  Created by Tiberiu Simion Voicu on 20/11/2017.
//  Copyright © 2017 Tiberiu Simion Voicu. All rights reserved.
//

import XCTest
import AIToolbox
@testable import asr_project
class asr_projectTests: XCTestCase {
    var file: Audio_file!
    var file_bily_train: Audio_file!
    var file_rachel_train: Audio_file!
    var file_paul_train: Audio_file!
    var file_joey_train: Audio_file!
    var file_rachel_test: Audio_file!
    
    var billy_train: [Float]!
    var joey_train: [Float]!
    var paul_train: [Float]!
    var rachel_train: [Float]!
    var rachel_test: [Float]!
    var mean: Double = 0;
    var std_dev: Double = 0;
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        file = Audio_file(url :Bundle.main.url(forResource: "7127-75946-0002", withExtension: "flac")!)
        
        file_bily_train = Audio_file(url: Bundle.main.url(forResource: "friends_s01e01_billy_train", withExtension: "wav")!)
        file_joey_train = Audio_file(url: Bundle.main.url(forResource: "friends_s01e01_joey_train", withExtension: "wav")!)
        file_paul_train = Audio_file(url: Bundle.main.url(forResource: "friends_s01e01_paul_train", withExtension: "wav")!)
        file_rachel_train = Audio_file(url: Bundle.main.url(forResource: "friends_s01e01_rachel_train", withExtension: "wav")!)
        file_rachel_test = Audio_file(url: Bundle.main.url(forResource: "friends_s01e01_rachel_test", withExtension: "wav")!)
        print(file_bily_train.format.description)
        let buffer = AVAudioPCMBuffer(pcmFormat: file_bily_train.format, frameCapacity: UInt32(file_bily_train.file.length))
        let buffer1 = AVAudioPCMBuffer(pcmFormat: file_joey_train.format, frameCapacity: UInt32(file_joey_train.file.length))
        let buffer2 = AVAudioPCMBuffer(pcmFormat: file_paul_train.format, frameCapacity: UInt32(file_paul_train.file.length))
        let buffer3 = AVAudioPCMBuffer(pcmFormat: file_rachel_train.format, frameCapacity: UInt32(file_rachel_train.file.length))
        let buffer4 = AVAudioPCMBuffer(pcmFormat: file_rachel_test.format, frameCapacity: UInt32(file_rachel_test.file.length))
        do {
            try file_bily_train.file.read(into: buffer!)
            billy_train = Process_helper.buffer_to_float(buffer: buffer!)
            try file_joey_train.file.read(into: buffer1!)
            joey_train = Process_helper.buffer_to_float(buffer: buffer1!)
            try file_paul_train.file.read(into: buffer2!)
            paul_train = Process_helper.buffer_to_float(buffer: buffer2!)
            try file_rachel_train.file.read(into: buffer3!)
            rachel_train = Process_helper.buffer_to_float(buffer: buffer3!)
            try file_rachel_test.file.read(into: buffer4!)
            rachel_test = Process_helper.buffer_to_float(buffer: buffer4!)
        } catch {print(error)}
//        8k_8PCM_eng 7127-75946-0002
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    func test_fft() {
        let buffer = AVAudioPCMBuffer(pcmFormat: file.format, frameCapacity: AVAudioFrameCount(file.file.length))
        do {
            try file.file.read(into: buffer!, frameCount: 512);
            let fft = Fft_transformer();
            let fft_buffer = try fft.transform(samples: Process_helper.buffer_to_float(buffer: buffer!));
            fft_buffer.elements.forEach({element in print(element)});
            for i in 0...fft_buffer.count - 1  {
                print("Freq \(Double(i) * (buffer?.format.sampleRate)! / Double(fft_buffer.count))")
            }
            let index = Double(try fft.domin_freq(fft_buffer: fft_buffer))
            print("Dominant freq : \(index * (buffer?.format.sampleRate)! / Double(fft_buffer.count))")
        } catch {print(error)}
        
    }
    func test_floatToBuffer() throws {
        let buffer = AVAudioPCMBuffer(pcmFormat: file.format, frameCapacity: 512)
        do {
            try file.file.read(into: buffer!, frameCount: 512);
            let buffer_to_float = Process_helper.buffer_to_float(buffer: buffer!)
            let buffer2 = Process_helper.float_to_buffer(samples: buffer_to_float, audio_format: file.format)
            let samples = Process_helper.buffer_to_float(buffer: buffer2)
            
            for i in 0...buffer!.frameLength - 1  {
                print("Buffer to float : \(buffer_to_float[Int(i)])")
                print("Float to buffer : \(samples[Int(i)])")
            }
        } catch {}
        
    }
    func test_vad() {
        let buffer = AVAudioPCMBuffer(pcmFormat: file.format, frameCapacity: AVAudioFrameCount(file.file.length))
        do {
            try file.file.read(into: buffer!)
        } catch {print(error)}
        let mfcc = mfcc_wrapper();
        let detector = VAD(buffer: buffer!);
        let samples = Process_helper.buffer_to_float(buffer: buffer!);
        var times = [Double]();
        detector.detect(speech: {(speech_time: Double) -> Void in
            times.append(speech_time);
            if(times.count > 1) {
                let index1 = Int(times[0] * file.format.sampleRate / 10);
                let index2 = Int(times[1] * file.format.sampleRate / 10);
                let s_samples = [Float](samples[index1..<index2])
                let s_pointer = UnsafeMutablePointer(mutating: s_samples)
                mfcc.get_mfccs(s_pointer, and_size: UInt32(s_samples.count));
                print("Index 1: \(index1)");
                print("Index 2: \(index2)");
                times[0] = times.popLast()!;
            }
//            mfcc.get_mfccs(pointer, and_size: Int32(speech_samples.count - 1))
        });
        
    }
    func test_mfcc(samples: [Float]) -> [[Double]]{
//        let buffer = AVAudioPCMBuffer(pcmFormat: file.format, frameCapacity: UInt32(file.file.length))
//        do {
//            try file.file.read(into: buffer!)
//        } catch {print(error)}
//        let samples = Process_helper.buffer_to_float(buffer: buffer!);
        let pointer = UnsafeMutablePointer<Float>(mutating: samples)
        let mfcc_computer =  mfcc_wrapper()
        let mfcc = mfcc_computer.get_mfccs(pointer, and_size: UInt32(samples.count))
        var mfcc_array = [[Double]]()
        var features = [Double]()
        for i in 1...Int(mfcc![0]) {
            
            features.append(mfcc![i])
            if(i % 12 == 0) {
                mfcc_array.append(features)
                features.removeAll()
            }
            
        }
       return mfcc_array
    }

    func test_mfcc_extraction(){
//        let buffer = AVAudioPCMBuffer(pcmFormat: file.format, frameCapacity: UInt32(file.file.length))
//        do {
//            try file.file.read(into: buffer!)
//        } catch {print(error)}
//        let samples = Process_helper.buffer_to_float(buffer: buffer!);
        let pointer = UnsafeMutablePointer<Float>(mutating: billy_train)


        let mfcc_computer = mfcc_wrapper();
        
        let x = mfcc_computer.get_mfccs(pointer, and_size: UInt32(billy_train.count))

    }
    func apply_vad(buffer: AVAudioPCMBuffer) {
        let vad = VAD(buffer: buffer);
    
    }
   // maybe some bug in training processing of mfccs either in mfcc.cc or mfcc.wrapper.mm or  test_mfcss
    func test_classifierknn() {
        var training_samples = [knn_curve_label_pair]();
        let knn = KNNDTW()
//        knn.configure(neighbors: 50, max_warp: 3)
        let numFeatureSets =  60;
        let mfcc_billy = test_mfcc(samples: billy_train)[0...numFeatureSets]
        let mfcc_joey = test_mfcc(samples: joey_train)[0...numFeatureSets]
        let mfcc_paul = test_mfcc(samples: paul_train)[0...numFeatureSets]
        let mfcc_rachel = test_mfcc(samples: rachel_test)[0...numFeatureSets]
        var data_set = [[Double]](mfcc_billy + mfcc_joey + mfcc_paul + mfcc_rachel);
        data_set = normaliseData(data: data_set)
        for i in 0..<data_set.count {
            if(i < 60) {
                training_samples.append(knn_curve_label_pair(curve: data_set[i].map {Float($0) }, label: "billy"))
            }
            else if(i > 60 && i < 120) {
                training_samples.append(knn_curve_label_pair(curve: data_set[i].map {Float($0) }, label: "joey"))
            }
            else if(i > 120 && i < 180) {
                training_samples.append(knn_curve_label_pair(curve: data_set[i].map {Float($0) }, label: "paul"))
            }
            else {
                training_samples.append(knn_curve_label_pair(curve: data_set[i].map {Float($0) }, label: "rachel"))
            }
        }
        
        knn.train(data_sets: training_samples)
        let mfcc_test = test_mfcc(samples: rachel_train)
        var accuracy = 0.0;
        for instance: [Double] in data_set[0..<60] {
            let prediction: knn_certainty_label_pair = knn.predict(curve_to_test: instance.map {Float($0) })
            if(prediction.label == "billy") {
                accuracy += 1;
            }
            print("predicted " + prediction.label, "with ", prediction.probability * 100,"% certainty")
        }
        print("Prediction accuracy per all test data: \(accuracy / Double(mfcc_test.count))");
        

    }
    func test_ClassifierSVM(){
        let train_data = DataSet(dataType: .classification, inputDimension: 12, outputDimension: 1)
        let test_data = DataSet(dataType: .classification, inputDimension: 12, outputDimension: 1)
        let regressor = LogisticRegression(numInputs: 12, solvingMethod: .parameterDelta);
        let numFeatureSets =  60;
        let mfcc_billy = test_mfcc(samples: billy_train)
        let mfcc_joey = test_mfcc(samples: joey_train)
        let mfcc_paul = test_mfcc(samples: paul_train)
        let mfcc_rachel = test_mfcc(samples: rachel_test)
        let mfcc_test = test_mfcc(samples: rachel_train)

        do {
            for i in 0..<numFeatureSets {
                
                try train_data.addDataPoint(input: mfcc_billy[i], dataClass: 0)
                
                try train_data.addDataPoint(input: mfcc_joey[i], dataClass: 1)
                
                try train_data.addDataPoint(input: mfcc_paul[i], dataClass: 2)
                
                try train_data.addDataPoint(input: mfcc_rachel[i], dataClass: 3)
            }
            for i in 0..<mfcc_test.count {
                try test_data.addTestDataPoint(input: mfcc_test[i])
            }
        } catch {print("Error creating testing and training data : \(error)")}
        

        do {
            var accuracy = 0.0;
            try regressor.classify(test_data)
            for i in 0..<test_data.size {
                
                let result = try test_data.getOutput(i);
                print("Test sample \(i) classified as : \(result)");
                if(result[0] == 3) {accuracy += 1}
            }
            print("Accuracy of NN Prediction: \(accuracy / Double(test_data.size) * 100)")
            
        } catch {print("Error classyfing : \(error)")}
        
        
    }
    func normaliseData(data: [[Double]]) -> [[Double]] {
        var norm_data = [[Double]](data)
        var mean: Double = 0.0;
        var std_dev: Double = 0.0;
        for mfcc in data {
            for feature in mfcc {
                mean += feature
            }
        }
        mean /= Double(data.count * data[0].count)
        for mfcc in data {
            for feature in mfcc {
                std_dev += pow(feature - mean, 2);
            }
        }
        std_dev /= Double(data.count * data[0].count)
        
        for i in 0..<data.count {
            for j in 0..<data[0].count {
                norm_data[i][j] = (norm_data[i][j] - mean) / std_dev
            }
        }
        self.mean = mean
        self.std_dev = std_dev
        return norm_data
    }
func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
