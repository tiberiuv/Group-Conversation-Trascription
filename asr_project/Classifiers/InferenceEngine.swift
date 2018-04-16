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
    private var OAOTraingSets: [[DataSet]]
    private var inputCount: Int
    private var outputCount: Int
    private var speakersCount: Int
    private var speakerModels: [SVMModel]
    private var gammaParamteres: [Double]
    private var mean: Double
    private var stdDev: Double
    
    init(speakerFeatMatrix: [[Double]], outputCount: Int) {
        self.inputCount = speakerFeatMatrix[0].count
        self.outputCount = outputCount
        self.trainingData = [DataSet]()
        self.speakerModels = [SVMModel]()
        self.speakersCount = 1
        self.OAATraingSets = [DataSet]()
        self.OAOTraingSets = [[DataSet]]()
        self.gammaParamteres = [Double]()
        self.mean = 0
        self.stdDev = 0
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
        self.OAOTraingSets = [[DataSet]]()
        self.gammaParamteres = [Double]()
        self.mean = 0
        self.stdDev = 0
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
        self.OAOTraingSets = [[DataSet]]()
        self.gammaParamteres = [Double]()
        self.mean = 0
        self.stdDev = 0
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
    // Create One Against All training sets N training sets
    private func buildOAATrainingSets() {
        do {
            for i in 0..<trainingData.count {
                let speaker = DataSet(dataType: dataType, inputDimension: self.inputCount, outputDimension: self.outputCount)
                let entries = Array(0..<trainingData[i].size)
                try speaker.includeEntries(fromDataSet: trainingData[i], withEntries: entries)
                for j in 0..<trainingData.count {
                    if j != i {
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
    // Create One Against One traing sets N * (N-1) / 2
    private func buildOAOTrainingSets() {
        do {
            for i in 0..<trainingData.count {
                let speaker = DataSet(dataType: dataType, inputDimension: self.inputCount, outputDimension: self.outputCount)
                
                let entries = Array(0..<trainingData[i].size)
                let dataSet = trainingData[i]
                for k in 0..<dataSet.size {
                    try dataSet.setClass(k, newClass: i)
                }
                try speaker.includeEntries(fromDataSet: dataSet, withEntries: entries)
                for j in 0..<trainingData.count {
                    if i != j {
                        let entries = Array(0..<trainingData[j].size)
                        let dataSet = DataSet(fromDataSet: trainingData[j])
                        for k in 0..<dataSet.size {
                            try dataSet.setClass(k, newClass: j)
                        }
                        try speaker.includeEntries(fromDataSet: dataSet, withEntries: entries)
                    }
                }
            }
        } catch { print("error in building OO traing sets", error) }
    }
    public func classify(_ vector: [Double]) -> Int {
        let vector = normalizeTestData(vector)
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
//    private func crossValidation(_ dataSet :DataSet, model: SVMModel) {
//        let validation = Validation(type: dataType)
//        validation.
//    }
    private func findParamGamma() {
        let gammas = [0.1,0.01,0.001,0.0001,0.00001]
        let validation = Validation(type: dataType)
        for i in 0..<OAATraingSets.count {
            for gamma in gammas {
                let model = SVMModel(problemType: .c_SVM_Classification, kernelSettings: KernelParameters(type: .radialBasisFunction, degree: 0 , gamma: gamma, coef0: 0))
                do {
                    try validation.addModel(model)
                } catch { print("Failed adding classifier in findParamGamma funtion", error) }
            }
            var bestIndex = 0
            do {
                bestIndex = try validation.NFoldCrossValidation(OAATraingSets[i], numberOfFolds: 10)
            } catch { print("Error in find best model through cross validation") }
            gammaParamteres.append(gammas[bestIndex])
            print("Index of classifier : \(i), best gamma: \(gammaParamteres[i])")
            
        }
        for i in 0..<gammaParamteres.count {
            print("Index of classifier : \(i), best gamma: \(gammaParamteres[i])")
        }
    }
    
    // MARK: - Modifies traing data
    private func normalizeTraingingData() {
        var mean = 0.0
        var stdDev = 0.0
        var totalFeats = 0
        do {
            for dataset in trainingData {
                for i in 0..<dataset.size {
                    let featVector = try dataset.getInput(i)
                    for feature in featVector {
                        mean += feature
                    }
                }
                totalFeats += dataset.size * dataset.inputDimension
            }
            mean /= Double(totalFeats)
            for dataset in trainingData {
                for i in 0..<dataset.size {
                    let featVector = try dataset.getInput(i)
                    for feature in featVector {
                        stdDev += pow(feature - mean, 2);
                    }
                }
            }
            stdDev /= Double(totalFeats)
            
            for dataset in trainingData {
                for i in 0..<dataset.size {
                    var featVector = try dataset.getInput(i)
                    for k in 0..<featVector.count {
                        featVector[k] = ( featVector[k] - mean ) / stdDev
                    }
                    try dataset.setOutput(i, newOutput: featVector)
                }
            }
        } catch {print("Failed normalizing traing data", error)}
        self.stdDev = stdDev
        self.mean = mean
    }
    private func normalizeTestData(_ vector: [Double]) -> [Double] {
        var normVector = vector
        for i in 0..<normVector.count {
            normVector[i] = (normVector[i] - mean) / stdDev
        }
        return normVector
    }
    public func buildClassifiers() {
        normalizeTraingingData()
        buildOAATrainingSets()
        findParamGamma()

        for i in 0..<OAATraingSets.count {
            let svmKernel = KernelParameters(type: .radialBasisFunction, degree: 0 , gamma: gammaParamteres[i], coef0: 0)
            let svm = SVMModel(problemType: .c_SVM_Classification, kernelSettings: svmKernel)
            do {
                try svm.trainClassifier(OAATraingSets[i])
            } catch { print("Error in training classifier ", error)}
            speakerModels.append(svm)
        }
    }
    
}
