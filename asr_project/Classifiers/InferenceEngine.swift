//
//  InferenceEngine.swift
//  asr_project
//
//  Created by Tiberiu Simion Voicu on 14/04/2018.
//  Copyright © 2018 Tiberiu Simion Voicu. All rights reserved.
//

import Foundation
import AIToolbox

public class InferenceEngine {
    private var dataType = DataSetType.classification
    private var trainingData: [DataSet]
    private var OAATraingSets: [DataSet]
    private var inputCount: Int
    private var outputCount: Int
    private var speakersCount: Int
    private var speakerModels: [SVMModel]
    
    init(speakerFeatMatrix: [[Double]], outputCount: Int) {
        self.inputCount = speakerFeatMatrix[0].count
        self.outputCount = outputCount
        self.trainingData = [DataSet]()
        self.speakerModels = [SVMModel]()
        self.speakersCount = 1
        self.OAATraingSets = [DataSet]()
        _ = addSpeakerTrainingData(featureMatrix: speakerFeatMatrix)
        
    }
    init(singleTrainingSet: DataSet) {
        self.inputCount = singleTrainingSet.inputDimension
        self.outputCount = singleTrainingSet.outputDimension
        
        self.trainingData = [DataSet]()
        self.trainingData.append(singleTrainingSet)
        
        self.speakerModels = [SVMModel]()
        self.speakersCount = 1
        self.OAATraingSets = [DataSet]()
    }
    init(trainingData: [DataSet]){
        for dataSet in trainingData {
            if(dataSet.inputDimension != trainingData[0].inputDimension) {
                
            }
            if(dataSet.outputDimension != trainingData[0].outputDimension) {
                
            }
        }
        self.inputCount = trainingData[0].inputDimension
        self.outputCount = trainingData[0].outputDimension
        self.trainingData = trainingData
        self.speakerModels = [SVMModel]()
        self.speakersCount = trainingData.count
        self.OAATraingSets = [DataSet]()
    }
    
    public func addSpeakerTrainingData(featureMatrix: [[Double]]) -> Bool {
        if featureMatrix[0].count != self.inputCount { return false}
        let trainData = DataSet(dataType: dataType, inputDimension: self.inputCount, outputDimension: self.outputCount)
        do {
            for vector in featureMatrix {
                try trainData.addDataPoint(input: vector, dataClass: 1)
            }
        } catch { print("Error in adding speaker Training Data to classifier", error) }
        trainingData.append(trainData)
        speakersCount += 1
        
        return true
    }
    
    private func buildOAATrainingSets() {
        do {
            for i in 0..<trainingData.count {
                let speaker = DataSet(dataType: dataType, inputDimension: self.inputCount, outputDimension: self.outputCount)
                let entries = Array(0..<trainingData[i].size)
                try speaker.includeEntries(fromDataSet: trainingData[i], withEntries: entries)
                for j in 0..<trainingData.count {
                    if i != j {
                        let entries = Array(0..<trainingData[j].size)
                        let dataSet = DataSet(fromDataSet: trainingData[j])
                        for i in 0..<dataSet.size {
                            try dataSet.setClass(i, newClass: 0)
                        }
                        try speaker.includeEntries(fromDataSet: dataSet, withEntries: entries)
                    }
                }
                OAATraingSets.append(speaker)
            }
        } catch { print("Error creating OAA traing sets", error) }
        
    }
    public func classify(_ vector: [Double]) -> Int {
        var results = [Int]()
        var index = -1
        for speakerModel in speakerModels {
            results.append(speakerModel.classifyOne(vector))
        }
        for i in 0..<results.count {
            if(results[i] == 1) {
                if(index != -1) {
                    return -1
                } else {
                  index = i
                }
            }
        }
        return index
    }
    
    public func buildClassifiers() {
        buildOAATrainingSets()
        let svm_kernel = KernelParameters(type: .radialBasisFunction, degree: 0 , gamma: 0.5, coef0: 0);

        for dataSet in OAATraingSets {
            let svm = SVMModel(problemType: .c_SVM_Classification, kernelSettings: svm_kernel)
            do {
                try svm.trainClassifier(dataSet)
            } catch { print("Error in training classifier ", error)}
            speakerModels.append(svm)
        }
    }
    
}
