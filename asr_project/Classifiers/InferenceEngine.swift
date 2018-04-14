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
    private var inputCount: Int
    private var outputCount: Int
    private var speakersCount: Int
    
    private var classifiers: [SVMModel]
    init(speakerFeatMatrix: [[Double]], outputCount: Int) {
        self.inputCount = speakerFeatMatrix[0].count
        self.outputCount = outputCount
        self.trainingData = [DataSet]()
        self.classifiers = [SVMModel]()
        self.speakersCount = 1
        
        addSpeakerTrainingData(featureMatrix: speakerFeatMatrix)
        
    }
    init(singleTrainingSet: DataSet) {
        self.inputCount = singleTrainingSet.inputDimension
        self.outputCount = singleTrainingSet.outputDimension
        
        self.trainingData = [DataSet]()
        self.trainingData.append(singleTrainingSet)
        
        self.classifiers = [SVMModel]()
        self.speakersCount = 1
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
        self.classifiers = [SVMModel]()
        self.speakersCount = trainingData.count
    }
    public func addSpeakerTrainingData(featureMatrix: [[Double]]) -> Bool {
        if featureMatrix[0].count != self.inputCount { return false}
        let trainData = DataSet(dataType: dataType, inputDimension: self.inputCount, outputDimension: 1)
        do {
            for vector in featureMatrix {
                try trainData.addDataPoint(input: vector, dataClass: speakersCount)
            }
        } catch { print("Error in adding speaker Training Data to classifier", error) }
        trainingData.append(trainData)
        speakersCount += 1
        
        return true
    }
    public func buildClassifiersOAO() {
        
    }
    
}
