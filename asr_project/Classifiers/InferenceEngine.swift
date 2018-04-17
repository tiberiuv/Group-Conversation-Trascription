//
//  InferenceEngine.swift
//  asr_project
//
//  Created by Tiberiu Simion Voicu on 14/04/2018.
//  Copyright © 2018 Tiberiu Simion Voicu. All rights reserved.
//

import Foundation
import AIToolbox

enum TrainingStrategy {
    case OAA
    case OAO
    case none
}
enum NormalizationType {
    case zscore
    case minmax
    case none
}

public class InferenceEngine {
    //MARK: - Training parameters
    private var dataType = DataSetType.classification
    private var trainingData: [DataSet]
    private var trainingSets: [DataSet]
    private var inputCount: Int
    private var outputCount: Int
    private var speakersCount: Int
    private var speakerModels: [SVMModel]
    //MARK: - Model Creation Parameters
    private var gammaParamteres: [Double]
    private var trainStrategy: TrainingStrategy
    //MARK: - Normalization Parameters
    private var means: [Double]
    private var stdDevs: [Double]
    private var maxVals: [Double]
    private var minVals: [Double]
    private var normType: NormalizationType
    // TODO: - Add data checks
    // MARK: - Initiators
    init(speakerFeatMatrix: [[Double]], outputCount: Int, normalization: NormalizationType, trainStrategy: TrainingStrategy) {
        self.inputCount = speakerFeatMatrix[0].count
        self.outputCount = outputCount
        self.trainingData = [DataSet]()
        self.speakerModels = [SVMModel]()
        self.speakersCount = 1
        self.trainingSets = [DataSet]()
        self.trainingSets = [DataSet]()
        self.gammaParamteres = [Double]()
        self.means = [Double]()
        self.stdDevs = [Double]()
        self.maxVals = [Double]()
        self.minVals = [Double]()
        self.normType = normalization
        self.trainStrategy  = trainStrategy
        _ = addSpeakerTrainingData(featureMatrix: speakerFeatMatrix)
    }
    init(singleTrainingSet: DataSet, normalization: NormalizationType, trainStrategy: TrainingStrategy) {
        self.inputCount = singleTrainingSet.inputDimension
        self.outputCount = singleTrainingSet.outputDimension
        
        self.trainingData = [DataSet]()
        self.trainingData.append(singleTrainingSet)
        
        self.speakerModels = [SVMModel]()
        self.speakersCount = 1
        self.trainingSets = [DataSet]()
        self.trainingSets = [DataSet]()
        self.gammaParamteres = [Double]()
        self.means = [Double]()
        self.stdDevs = [Double]()
        self.maxVals = [Double]()
        self.minVals = [Double]()
        self.normType = normalization
        self.trainStrategy  = trainStrategy
    }
    init(trainingData: [DataSet], normalization: NormalizationType, trainStrategy: TrainingStrategy){
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
        self.trainingSets = [DataSet]()
        self.trainingSets = [DataSet]()
        self.gammaParamteres = [Double]()
        self.means = [Double]()
        self.stdDevs = [Double]()
        self.maxVals = [Double]()
        self.minVals = [Double]()
        self.normType = normalization
        self.trainStrategy  = trainStrategy
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
                trainingSets.append(speaker)
            }
        } catch { print("Error creating OAA traing sets", error) }
    }
    // Create One Against One traing sets N * (N-1) / 2
    private func buildOAOTrainingSets() {
        do {
            for i in 0..<trainingData.count-1 {
                for j in i+1..<trainingData.count {
                    let speaker = DataSet(dataType: dataType, inputDimension: self.inputCount, outputDimension: self.outputCount)
                    let entriesi = Array(0..<trainingData[i].size)
                    let entriesj = Array(0..<trainingData[j].size)
                    let dataSeti = DataSet(fromDataSet: trainingData[i])
                    let dataSetj = DataSet(fromDataSet: trainingData[j])
                    
                    for k in 0..<dataSeti.size {
                        try dataSeti.setClass(k, newClass: i)
                    }
                    for k in 0..<dataSetj.size {
                        try dataSetj.setClass(k, newClass: j)
                    }
                    try speaker.includeEntries(fromDataSet: dataSeti, withEntries: entriesi)
                    try speaker.includeEntries(fromDataSet: dataSetj, withEntries: entriesj)
                    trainingSets.append(speaker)
                    print("Added model for class \(i) and class \(j)")
                }
            }
            print("Total models : \(trainingSets.count)")
        } catch { print("Error in building OO traing sets", error) }
    }
    public func classify(_ vector: [Double]) -> Int {
        var normVector = vector
        var results = [Int]()
        var index = -1
        if normType == .minmax {
            normVector = scaleTestAttributes(vector)
        } else if normType == .zscore {
            normVector = normalizeTestAttributes(vector)
        }
        
        for speakerModel in speakerModels {
            results.append(speakerModel.classifyOne(normVector))
        }
        
        if trainStrategy == .OAA {
            for i in 0..<results.count {
                if(results[i] == 1) {
                    if(index != -1) {
                        return -1
                    } else {
                        index = i
                    }
                }
            }
        }
        else if trainStrategy == .OAO {
            var voteCounts = [Int](repeating: 0, count: speakerModels.count)
            for i in 0..<results.count {
                voteCounts[results[i]] += 1
            }
            index = voteCounts.index(of: voteCounts.max()!)!
        }
        
        return index
    }

    private func findParamGamma() {
        let gammas = [0.1,0.01,0.001,0.0001,0.00001]
        var bestGammas = [Double]()
        let validation = Validation(type: dataType)
        for i in 0..<trainingSets.count {
            for gamma in gammas {
                let model = SVMModel(problemType: .c_SVM_Classification, kernelSettings: KernelParameters(type: .radialBasisFunction, degree: 0 , gamma: gamma, coef0: 0))
                do {
                    try validation.addModel(model)
                } catch { print("Failed adding classifier in findParamGamma funtion", error) }
            }
            var bestIndex = 0
            do {
                bestIndex = try validation.NFoldCrossValidation(trainingSets[i], numberOfFolds: 5)
            } catch { print("Error in find best model through cross validation") }
            bestGammas.append(gammas[bestIndex])
            
        }
        for i in 0..<bestGammas.count {
            print("Index of classifier : \(i), best gamma: \(bestGammas[i])")
        }
        gammaParamteres = bestGammas
    }
    // Provide min/max normalization
    private func scaleTrainAttributes() -> [DataSet] {
        var max = [Double](repeating: 0.0, count: trainingData[0].inputDimension)
        var min = [Double](repeating: 0.0, count: trainingData[0].inputDimension)
        var normTrainSets = [DataSet]()
        do {
            for dataset in trainingData {
                for i in 0..<dataset.size {
                    let featVector = try dataset.getInput(i)
                    for j in 0..<featVector.count {
                        if ( featVector[j] > max[j] ) {
                            max[j] = featVector[j]
                        }
                        if ( featVector[j] < min[j] ) {
                            min[j] = featVector[j]
                        }
                    }
                }
            }
            for dataset in trainingData {
                let normDataSet = DataSet(dataType: dataset.dataType, inputDimension: dataset.inputDimension, outputDimension: dataset.outputDimension)
                for i in 0..<dataset.size {
                    var scaledVector = try dataset.getInput(i)
                    for j in 0..<scaledVector.count {
                        scaledVector[j] = ( scaledVector[j] - min[j] ) / ( max[j] - min[j] )
                    }
                    try normDataSet.addDataPoint(input: scaledVector, dataClass: try dataset.getClass(i))
                }
                normTrainSets.append(normDataSet)
                
            }
        } catch {print("Failed scaling training data", error)}
        
        self.minVals = min
        self.maxVals = max
        
        return normTrainSets
    }
    private func scaleTestAttributes(_ vector: [Double]) -> [Double] {
        var scaledVector = vector
        
        for i in 0..<scaledVector.count {
            scaledVector[i] = ( scaledVector[i] - minVals[i] ) / ( maxVals[i] - minVals[i] )
        }
        
        return scaledVector
    }
    
    // Z-Score (mean = 0, stddev = 1) Normalization on a per attribute basis
    // Keeps track of means and stddevs for use in classifying
    private func normalizeTraingingAttributes() -> [DataSet] {
        var means = [Double](repeating: 0.0, count: trainingData[0].inputDimension)
        var stdDevs = [Double](repeating: 0.0, count: trainingData[0].inputDimension)
        var normTrainSets = [DataSet]()
        
        var totalFeatVectors = 0
        do {
            for dataset in trainingData {
                for i in 0..<dataset.size {
                    let featVector = try dataset.getInput(i)
                    for j in 0..<featVector.count {
                        means[j] += featVector[j]
                    }
                }
                totalFeatVectors += dataset.size
            }
            for i in 0..<means.count {
                means[i] /= Double(totalFeatVectors - 1)
            }
            for dataset in trainingData {
                for i in 0..<dataset.size {
                    let featVector = try dataset.getInput(i)
                    for j in 0..<featVector.count {
                        stdDevs[j] += sqrt(pow(featVector[j] - means[j], 2));
                    }
                }
            }
            for i in 0..<means.count {
                stdDevs[i] /= Double(totalFeatVectors - 1)
            }
            
            for dataset in trainingData {
                let normDataSet =  DataSet(dataType: dataset.dataType, inputDimension: dataset.inputDimension, outputDimension: dataset.outputDimension)
                for i in 0..<dataset.size {
                    var normVector = try dataset.getInput(i)
                    for k in 0..<normVector.count {
                        normVector[k] = ( normVector[k] - means[k] ) / stdDevs[k]
                    }
                    try normDataSet.addDataPoint(input: normVector, dataClass: dataset.getClass(i))
                }
                normTrainSets.append(normDataSet)
            }
        } catch {print("Failed normalizing traing data", error)}
        
        self.stdDevs = stdDevs
        self.means = means
        
        return normTrainSets
    }
    private func normalizeTestAttributes(_ vector: [Double]) -> [Double] {
        var normVector = vector
        for i in 0..<normVector.count {
            normVector[i] = (normVector[i] - means[i]) / stdDevs[i]
        }
        return normVector
    }
    public func buildClassifiers() {
        // MARK: - Modifies traing data
        if normType == .minmax {
            self.trainingData = scaleTrainAttributes()
        } else if normType == .zscore {
            self.trainingData = normalizeTraingingAttributes()
        }
        if trainStrategy == .OAA {
            buildOAATrainingSets()
        } else if trainStrategy == .OAO {
            buildOAOTrainingSets()
        }

        findParamGamma()

        for i in 0..<trainingSets.count {
            let svmKernel = KernelParameters(type: .radialBasisFunction, degree: 0 , gamma: gammaParamteres[i], coef0: 0)
            let svm = SVMModel(problemType: .c_SVM_Classification, kernelSettings: svmKernel)
            do {
                try svm.trainClassifier(trainingSets[i])
            } catch { print("Error in training classifier ", error)}
            speakerModels.append(svm)
        }
    }
    
}
