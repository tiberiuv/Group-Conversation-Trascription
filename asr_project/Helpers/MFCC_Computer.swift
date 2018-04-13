//
//  MFCC_Computer.swift
//  asr_project
//
//  Created by Tiberiu Simion Voicu on 28/01/2018.
//  Copyright © 2018 Tiberiu Simion Voicu. All rights reserved.

import Foundation
import Accelerate
import AVFoundation

class MFCCComputer {

    var saFreq = 16000.0
    var numCepestra = 12
    var winLength = 25
    var frameShift = 10
    var numFilters = 40
    var lowFreq = 0.0
    var highFreq = 0.0
    var preEmph = 0.97
    var numFFT = 512
    var numFFTBins: Int
    
    var frame = [Float]()
    var powerSpectrum = [Float]()
    var LMFBCoef = [Double]()
    var prevSamples = [Float]()
    var numWinFrames = 0
    var numShiftFrames = 0
    var fftTransformer: FFTComputer
    var dct = [[Double]]()
    var dctSetup: vDSP_DFT_Setup?
    var filterBank = [[Double]]()
    var addDeltas: Bool
    // MARK: - Destroy fft setup after usage destroy
    // TODO: - check
    // FIXME: - Some bug
    init(sa_freq: Double = 16000, n_cep: Int = 12,win_len: Int = 25, frame_sft: Int = 10, n_filt: Int = 40, low_f: Double = 0.0, high_f: Double = 16000/2, compDeltas:Bool = true) {
        saFreq = sa_freq
        numCepestra = n_cep
        winLength = win_len
        frameShift = frame_sft
        numFilters = n_filt
        lowFreq = low_f
        if(high_f <= saFreq / 2){
            highFreq = high_f
        } else {
            highFreq = saFreq / 2
        }
        addDeltas = compDeltas
        
        numFFTBins = self.numFFT / 2 + 1 // TODO: - check if num_fft / 2 + 1 or num_fft / 2
        numWinFrames = winLength * Int(saFreq) / 1000
        numShiftFrames = frameShift * Int(saFreq) / 1000
        self.fftTransformer = FFTComputer(numWinFrames)
        dctSetup = vDSP_DCT_CreateSetup(nil, vDSP_Length(64), vDSP_DCT_Type.II)!
        
        init_filter_bank()
        init_dct()
    }
    
    func process_frame(samples: [Float]) -> [Double]{
        frame = prevSamples;
        
        for i in 0..<samples.count {
            frame.append(samples[i])
        }
        prevSamples = [Float](frame[numShiftFrames..<frame.count])
        
        preemph_ham()
        comp_power_spectrum()
        apply_lmfb()
        let mfcc = apply_dct()
        
        return mfcc;
    }

    func process(samples: [Float]) -> [[Double]]{
        var mfccs = [[Double]]()
        let buffer_length = numWinFrames - numShiftFrames;

        prevSamples = [Float](samples[0..<buffer_length])
        let buffer_len = numShiftFrames;
        for i in stride(from: buffer_length, to: samples.count, by: buffer_len) {
            if(i + buffer_len <= samples.count){
                let frame_samples = [Float] (samples[i..<i+buffer_len])
                let mfcc = process_frame(samples: frame_samples)
                print(mfcc)
                mfccs.append(mfcc)
            }
        }
        return mfccs
    }
    // apply pre emphasis filter and hamming window to the frame
    func preemph_ham(){
        var procFrame = [Float](repeating: 0, count: frame.count)
        
        for i in 1..<frame.count {
<<<<<<< HEAD
            procFrame[i] = (frame[i] - Float(preEmph) * frame[i-1])
        }
        let pointerFrame = UnsafePointer<Float>(procFrame)
        var window = [Float](repeating: 0, count: numWinFrames)
        // 0 means we get a full hamming window(pass VDSP_HALF_WINDOW for half a window)
        vDSP_hamm_window(&window, vDSP_Length(numWinFrames), 0)
        vDSP_vmul(pointerFrame, 1, window,
                  1, &frame, 1, UInt(numWinFrames))

    }
    func comp_power_spectrum() {
        do {
            powerSpectrum = try fftTransformer.getPowerSpectrum(fftTransformer.transform(samples: frame))
        } catch {print(error)}
    }
    // Applying log Mel filterbank (LMFB)
    func apply_lmfb() {
        LMFBCoef = [Double](repeating: 0, count: numFilters)
        for i in 0..<numFilters{
        // Multiply the filterbank matrix
            for j in 0..<filterBank[i].count-1 {
                LMFBCoef[i] += filterBank[i][j] * Double(powerSpectrum[j]);
            }
        }
        // Applying log on filtered coefficients
        for i in 0..<numFilters {
            LMFBCoef[i] = log(LMFBCoef[i]);
        }
    }
    
    // apply direct consine tranform -> return mfcc array
    func apply_dct() -> [Double]{
        var mfcc = [Double](repeating: 0, count: numCepestra+1);
        var floatCoef = LMFBCoef.map{Float($0)}
        while floatCoef.count < 64 {
            floatCoef.append(0.0)
        }
        var pointerMfcc = UnsafeMutablePointer(mutating: Array<Float>())
        vDSP_DCT_Execute(self.dctSetup!, &floatCoef, pointerMfcc)
        var mfcc2 = Array(UnsafeBufferPointer(start: pointerMfcc, count: LMFBCoef.count))
        for i in 0...numCepestra {
            for j in 0..<numFilters {
                 mfcc[i] = dct[i][j] * LMFBCoef[j]
            }
        }
        return mfcc
    }
    
    // Initiate hamming window values and direct cosine transform matrix
    func init_dct() {
        
        var arr1 = [Double](repeating: 0, count: numCepestra+1)
        var arr2 = [Double](repeating: 0, count: numFilters)
        for i in 0...numCepestra {
            arr1[i] = (Double(i)) ;
        }
        for i in 0..<numFilters {
            arr2[i] = (Double(i) + 0.5);
        }

        let c: Double = sqrt(2.0 / Double(numFilters))
        for i in 0...numCepestra {
            var temp = [Double]()
            for j in 0..<numFilters {
                temp.append(c * cos(Double.pi / Double(numFilters) * arr1[i] * arr2[j]))
            }
            dct.append(temp)
        }
    }
    // Initiate mel filter bank
    func init_filter_bank() {
        let lowMel = hzToMel(lowFreq)
        let highMel = hzToMel(highFreq)
        let rangeMel = highMel - lowMel
        var centreFreq = [Double](repeating: 0, count: numFilters + 2)
        for i in 0..<numFilters + 2 {
            centreFreq[i] = (mel_to_hz(lowMel + rangeMel / Double(numFilters+1)*Double(i)))
        }
        
<<<<<<< HEAD
        var binFreq = [Double](repeating: 0, count: numFFTBins)
        for i in 0..<numFFTBins {
            binFreq[i] = saFreq / 2.0 / Double(numFFTBins - 1) * Double(i)
        }

//         Populate the fbank matrix
        for filt in 1...numFilters {
=======
        var centre_freq = [Double](repeating: 0, count: num_filters + 2)
        for i in 0..<num_filters + 2 {
            centre_freq[i] = (mel_to_hz(mel: low_mel_freq + (high_mel_freq - low_mel_freq )/Double(num_filters+1)*Double(i)))
//            var x = centre_freq[i]
        }
        var fftbin_freq = [Double](repeating: 0, count: num_fftbins)
        for i in 0..<num_fftbins {
            fftbin_freq[i] = (sampling_freq / 2.0 / Double(num_fftbins-1)*Double(i))
//            var x = fftbin_freq[i]
        }
        filter_bank = [[Double]]();
        // Populate the fbank matrix
        for filt in 1...num_filters {
>>>>>>> 47ef41a332b45300ae210a40d7218ad8060926ef
            var ftemp = [Double]()
            for bin in 0..<numFFTBins {
                var weight = Double()
                if (binFreq[bin] < centreFreq[filt-1]) {
                    weight = 0;
                } else if (binFreq[bin] <= centreFreq[filt]) {
                     weight = (binFreq[bin] - centreFreq[filt-1]) / (centreFreq[filt] - centreFreq[filt-1]);
                } else if (binFreq[bin] <= centreFreq[filt+1]) {
                     weight = (centreFreq[filt+1] - binFreq[bin]) / (centreFreq[filt+1] - centreFreq[filt]);
                } else {
                    weight = 0;
                }
                ftemp.append (weight);
            }
            filterBank.append(ftemp);
        }
    }
    func computeDeltaN(_ featVector: [Double], _ N: Int = 2) -> [Double]{
        var deltas = [Double](repeating: 0, count: featVector.count)
        var denom = 0.0
        if(N < 1) { return [Double]()}
        for i in 1..<N+1 {
            denom += Double(i*i)
        }
        denom *= 2
        var i1: Int
        var i2: Int

        for i in 0..<deltas.count {
            var delta = 0.0
            for n in 0..<N+1 {
                if(i+n > featVector.count-1) {
                    i1 = featVector.count-1
                } else {
                    i1 = i+n
                }
                if(i-n < 0) {
                    i2 = 0
                } else {
                    i2 = i-n
                }
                delta += featVector[i1] - featVector[i2]
            }
            deltas[i] = delta / denom
        }
        return deltas
    }
//    func hamming(k: Int) -> Double {
//        return 0.54 - 0.46 * cos(2 * M_PI * k / (win_length_samples-1) )
//    }
//Helpers
    func destroySetups() {
        if(self.dctSetup != nil) {
            vDSP_DFT_DestroySetup(self.dctSetup)
        }
        self.fftTransformer.destroySetup()
    }
    func hzToMel(_ hz: Double) -> Double {
        return 2595 * log10(1+hz/700)
    }
    func mel_to_hz(_ mel: Double) -> Double {
        return 700 * (pow(10,mel/2595) - 1)
    }
    
}

