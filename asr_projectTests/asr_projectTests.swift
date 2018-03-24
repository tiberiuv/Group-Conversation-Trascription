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
    var file_chad_train: Audio_file!
    var file_joey_train: Audio_file!
    var file_monica_train: Audio_file!
    var file_phoebe_train: Audio_file!
    var file_rachel_train: Audio_file!
    var file_ross_train: Audio_file!
    var file_ross_test: Audio_file!
    
    var chad_train: [Float]!
    var joey_train: [Float]!
    var monica_train: [Float]!
    var phoebe_train: [Float]!
    var rachel_train: [Float]!
    var ross_train: [Float]!
    var ross_test: [Float]!
    
    var vad_ross: [[Double]]!;
    var vad_chad: [[Double]]!;
    var vad_ross_test: [[Double]]!;
    
    var mean: Double = 0;
    var std_dev: Double = 0;
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
//        file = Audio_file(url :Bundle.main.url(forResource: "7127-75946-0002", withExtension: "flac")!)
        
        file_chad_train = Audio_file(url: Bundle.main.url(forResource: "chad_joined", withExtension: "wav", subdirectory: "data_friends")!)
        file_joey_train = Audio_file(url: Bundle.main.url(forResource: "joey_joined", withExtension: "wav", subdirectory: "data_friends")!)
        file_monica_train = Audio_file(url: Bundle.main.url(forResource: "monica_joined", withExtension: "wav", subdirectory: "data_friends")!)
        file_phoebe_train = Audio_file(url: Bundle.main.url(forResource: "phoebe_joined", withExtension: "wav", subdirectory: "data_friends")!)
        file_rachel_train = Audio_file(url: Bundle.main.url(forResource: "rachel_joined", withExtension: "wav", subdirectory: "data_friends")!)
        file_ross_train = Audio_file(url: Bundle.main.url(forResource: "ross_joined", withExtension: "wav", subdirectory: "data_friends")!)
        file_ross_test = Audio_file(url: Bundle.main.url(forResource: "ross_test", withExtension: "wav", subdirectory: "data_friends")!)
        
        print(file_chad_train.format.description);
        
//        vad_chad = test_vad(file: file_chad_train);
//        vad_ross = test_vad(file: file_ross_train);
//        vad_ross_test = test_vad(file: file_ross_test);
        
        let buffer = AVAudioPCMBuffer(pcmFormat: file_chad_train.format, frameCapacity: UInt32(file_chad_train.file.length))
        let buffer1 = AVAudioPCMBuffer(pcmFormat: file_joey_train.format, frameCapacity: UInt32(file_joey_train.file.length))
        let buffer2 = AVAudioPCMBuffer(pcmFormat: file_monica_train.format, frameCapacity: UInt32(file_monica_train.file.length))
        let buffer3 = AVAudioPCMBuffer(pcmFormat: file_phoebe_train.format, frameCapacity: UInt32(file_phoebe_train.file.length))
        let buffer4 = AVAudioPCMBuffer(pcmFormat: file_rachel_train.format, frameCapacity: UInt32(file_rachel_train.file.length))
        let buffer5 = AVAudioPCMBuffer(pcmFormat: file_ross_train.format, frameCapacity: UInt32(file_ross_train.file.length))
        let buffer6 = AVAudioPCMBuffer(pcmFormat: file_ross_test.format, frameCapacity: UInt32(file_ross_test.file.length))
        do {
            try file_chad_train.file.read(into: buffer!)
            chad_train = Process_helper.buffer_to_float(buffer: buffer!)
            try file_joey_train.file.read(into: buffer1!)
            joey_train = Process_helper.buffer_to_float(buffer: buffer1!)
            try file_monica_train.file.read(into: buffer2!)
            monica_train = Process_helper.buffer_to_float(buffer: buffer2!)
            try file_phoebe_train.file.read(into: buffer3!)
            phoebe_train = Process_helper.buffer_to_float(buffer: buffer3!)
            try file_rachel_train.file.read(into: buffer4!)
            rachel_train = Process_helper.buffer_to_float(buffer: buffer4!)
            try file_ross_train.file.read(into: buffer5!)
            ross_train = Process_helper.buffer_to_float(buffer: buffer5!)
            try file_ross_test.file.read(into: buffer6!)
            ross_test = Process_helper.buffer_to_float(buffer: buffer6!)
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
    func test_vad(file: Audio_file ) -> [[Double]] {
        let buffer = AVAudioPCMBuffer(pcmFormat: file.format, frameCapacity: AVAudioFrameCount(file.file.length))
        do {
            try file.file.read(into: buffer!)
        } catch {print(error)}
        let detector = VAD(buffer: buffer!);
        let samples = Process_helper.buffer_to_float(buffer: buffer!);
        var mfccs = [[Double]]();
        var times = [Double]();
        detector.detect(speech: {(speech_time: Double) -> Void in
            times.append(speech_time);
            if(times.count > 1) {
                let index1 = Int(times[0] * file.format.sampleRate / 10);
                let index2 = Int(times[1] * file.format.sampleRate / 10);
                let s_samples = [Float](samples[index1..<index2])
                let s_pointer = UnsafeMutablePointer(mutating: s_samples)
                mfccs.append(contentsOf: extract_mfccs(s_samples));
//                print("Index 1: \(index1)");
//                print("Index 2: \(index2)");
                times[0] = times.popLast()!;
            }
//            mfcc.get_mfccs(pointer, and_size: Int32(speech_samples.count - 1))
        });
        return mfccs
    }
    func extract_mfccs(_ samples: [Float]) -> [[Double]]{
        let pointer = UnsafeMutablePointer<Float>(mutating: samples)
        let mfcc_computer =  mfcc_wrapper()
        let mfcc = mfcc_computer.get_mfccs(pointer, and_size: UInt32(samples.count))
        var mfcc_array = [[Double]]()
        var features = [Double]()
        for i in 1...Int(mfcc![0]) {
            
            features.append(mfcc![i])
            if(i % 36 == 0) {
                mfcc_array.append(features)
                features.removeAll()
            }
        }
       return mfcc_array
    }
    
    func test_mfcc(){
        let samples = joey_train;
        let pointer = UnsafeMutablePointer<Float>(mutating: samples)
        let mfcc_computer =  mfcc_wrapper()
        let mfcc = mfcc_computer.get_mfccs(pointer, and_size: UInt32(samples!.count))
        var mfcc_array = [[Double]]()
        var features = [Double]()
        for i in 1...Int(mfcc![0]) {
            
            features.append(mfcc![i])
            if(i % 36 == 0) {
                mfcc_array.append(features)
                features.removeAll()
            }
        }
    }
//    func test_mfcc_extraction(){
//        let buffer = AVAudioPCMBuffer(pcmFormat: file.format, frameCapacity: UInt32(file.file.length))
//        do {
//            try file.file.read(into: buffer!)
//        } catch {print(error)}
//        let samples = Process_helper.buffer_to_float(buffer: buffer!);
//        let pointer = UnsafeMutablePointer<Float>(mutating: billy_train)
//
//
//        let mfcc_computer = mfcc_wrapper();
//
//        let x = mfcc_computer.get_mfccs(pointer, and_size: UInt32(billy_train.count))
//
//    }
//    func apply_vad(buffer: AVAudioPCMBuffer) {
//        let vad = VAD(buffer: buffer);
//    
//    }
   // maybe some bug in training processing of mfccs either in mfcc.cc or mfcc.wrapper.mm or  test_mfcss
    func test_classifierknn() {
        var training_samples = [knn_curve_label_pair]();
        let knn = KNNDTW()
//        knn.configure(neighbors: 5, max_warp: 3)
        let numFeatureSets =  15;
        let mfcc_chad = extract_mfccs(chad_train)[0..<numFeatureSets]
        let mfcc_joey = extract_mfccs(joey_train)[0..<numFeatureSets]
        let mfcc_monica = extract_mfccs(monica_train)[0..<numFeatureSets]
        let mfcc_phoebe = extract_mfccs(phoebe_train)[0..<numFeatureSets]
        let mfcc_rachel = extract_mfccs(rachel_train)[0..<numFeatureSets]
        let mfcc_ross = extract_mfccs(ross_train)[0..<numFeatureSets]
        let mfcc_ross_test = extract_mfccs(ross_test)
        
        var data_set = [[Double]](mfcc_chad + mfcc_joey + mfcc_monica + mfcc_phoebe + mfcc_rachel + mfcc_ross)
        data_set = normaliseData(data: data_set);
        for i in 0..<data_set.count {
            if(i < 50) {
                training_samples.append(knn_curve_label_pair(curve: data_set[i].map {Float($0) }, label: "chad"))
            }
            else if(i > 50 && i < 100) {
                training_samples.append(knn_curve_label_pair(curve: data_set[i].map {Float($0) }, label: "joey"))
            }
            else if(i > 100 && i < 150) {
                training_samples.append(knn_curve_label_pair(curve: data_set[i].map {Float($0) }, label: "monica"))
            }
            else if(i > 150 && i < 200) {
                training_samples.append(knn_curve_label_pair(curve: data_set[i].map {Float($0) }, label: "phoebe"))
            }
            else if(i > 200 && i < 250) {
                training_samples.append(knn_curve_label_pair(curve: data_set[i].map {Float($0) }, label: "rachel"))
            }
            else  {
                training_samples.append(knn_curve_label_pair(curve: data_set[i].map {Float($0) }, label: "ross"))
            }
        }
        
        knn.train(data_sets: training_samples)

        var accuracy = 0.0;
        for test_instance: [Double] in mfcc_ross_test {
            var normalised_instance = [Double]();
            for mfcc in test_instance {
                normalised_instance.append((mfcc - mean) / std_dev);
            }
//            let prediction: knn_certainty_label_pair = knn.predict(curve_to_test: test_instance.map {Float($0) })
            let prediction: knn_certainty_label_pair = knn.predict(curve_to_test: normalised_instance.map {Float($0) })
            if(prediction.label == "ross") {
                accuracy += 1;
            }
            print("predicted " + prediction.label, "with ", prediction.probability * 100,"% certainty")
        }
        print("Prediction accuracy per all test data: \(accuracy / Double(mfcc_ross_test.count) * 100)%");
        

    }
    func test_ClassifierSVM(){
//        let mfcc_chad = extract_mfccs(chad_train);
//        let mfcc_joey = extract_mfccs(joey_train);
        let mfcc_monica = extract_mfccs(monica_train);
//        let mfcc_phoebe = extract_mfccs(phoebe_train);
        let mfcc_rachel = extract_mfccs(rachel_train);
        let mfcc_ross = extract_mfccs(ross_train);
        let mfcc_ross_test = extract_mfccs(ross_test);

        let train_data = DataSet(dataType: .classification, inputDimension: 36, outputDimension: 1);
        let test_data = DataSet(dataType: .classification, inputDimension: 36, outputDimension: 1);
        
        let svm_kernel = KernelParameters(type: .radialBasisFunction, degree: 0 , gamma: 0.1, coef0: 64);
        let svm_ross = SVMModel(problemType: .c_SVM_Classification, kernelSettings: svm_kernel)
//        let svm_imposter = SVMModel(problemType: .c_SVM_Classification, kernelSettings: svm_kernel)
        let numFeatureSets =  22;
        do {
            for i in 0..<numFeatureSets {
//                try train_data.addDataPoint(input: vad_chad[i], dataClass: 0)
//                try train_data.addDataPoint(input: vad_ross[i], dataClass: 1)
//                try train_data.addDataPoint(input: mfcc_chad[i], dataClass: 0)
//                try train_data.addDataPoint(input: mfcc_joey[i], dataClass: 0)
//                try train_data.addDataPoint(input: mfcc_phoebe[i], dataClass: 0)
                try train_data.addDataPoint(input: mfcc_monica[i], dataClass: 0)
                try train_data.addDataPoint(input: mfcc_rachel[i], dataClass: 0)
                try train_data.addDataPoint(input: mfcc_ross[i], dataClass: 1)
            }
//            for i in 0..<mfcc_ross_test.count {
//                try test_data.addTestDataPoint(input: mfcc_ross_test[i])
//                //try test_data.addDataPoint(input: mfcc_ross_test[i], dataClass: 1)
//            }
        } catch {print("Error creating testing and training data : \(error)")}

        do {
            try svm_ross.trainClassifier(train_data)
            
//            try svm_imposter.trainClassifier(test_data);
        } catch {print("Error in training classifier : \(error)")}
//        do {
//            try svm_ross.classify(test_data);
//        } catch {print("Error in classifing the data")}
        do {
            var accuracy = 0.0;
            var test_mfcc = mfcc_ross_test
            for i in 0..<test_mfcc.count {
                let prediction = try svm_ross.classifyOne(test_mfcc[i]);
                print("Prediction \(prediction)");
                if( prediction == 1) {
                    accuracy += 1;
                }
            }
//            try regressor.predict(test_data)
//            print("Accuracy of \(try regressor.getClassificationPercentage(test_data) * 100) %");
//            for i in 0..<test_data.size {
//
//                let result = try regressor.predictOne(mfcc_rachel[i]);
//
//                if(result[1] > result[0]) {accuracy += 1}
//                for res in result {
//                    print(res);
//                }
//                print("\n");
//                print("Test sample \(i) classified as : \(result)");
//                if(result == 3) {accuracy += 1}
//           }
            print("Accuracy of NN Prediction: \(accuracy / Double(test_mfcc.count) * 100)")

        } catch {print("Error getting the result of classification : \(error)")}


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
    func testmlpack() {
        let mlpack = MLPackWrapper();
//        let ml_pack = wrapper();
        let mfcc_rachel = extract_mfccs(rachel_train)
        let mfcc_rachel_flat =  mfcc_rachel.reduce([], +);
        let pointer = UnsafeMutablePointer<Double>(mutating: mfcc_rachel_flat);
        mlpack.build_classifier(pointer, and_size: UInt32(mfcc_rachel_flat.count));
    }

func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

