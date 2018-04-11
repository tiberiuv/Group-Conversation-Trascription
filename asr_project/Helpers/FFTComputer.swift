//
//  Fft_transformer.swift
//  asr_project
//
//  Created by Tiberiu Simion Voicu on 27/01/2018.
//  Copyright © 2018 Tiberiu Simion Voicu. All rights reserved.
//

import AVFoundation
import Accelerate

class FFTComputer {
    var fftSetup: FFTSetup?
    var log2n: UInt
    init(_ frameCount: Int) {
        self.log2n = UInt(round(log2(Double(frameCount))))
        fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))
    }
    func transform(input: [Float]) throws -> Buffer {
        var samples = input
        let frameCount = samples.count
        let log2n = UInt(round(log2(Double(frameCount))))
        let bufferSizePOT = Int(1 << log2n)
        let inputCount = bufferSizePOT / 2
        if(log2n > self.log2n){
            self.fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))
        }
        while samples.count < bufferSizePOT {
            samples.append(0.0)
        }
        var realp = [Float](repeating: 0, count: inputCount)
        var imagp = [Float](repeating: 0, count: inputCount)
        var output = DSPSplitComplex(realp: &realp, imagp: &imagp)

        let transferBuffer = [Float](samples)
        let temp = UnsafePointer<Float>(transferBuffer)
        
        temp.withMemoryRebound(to: DSPComplex.self, capacity: transferBuffer.count) { (typeConvertedTransferBuffer) -> Void in
            vDSP_ctoz(typeConvertedTransferBuffer, 2, &output, 1, vDSP_Length(inputCount))
        }
        
        vDSP_fft_zrip(fftSetup!, &output, 1, log2n, FFTDirection(FFT_FORWARD))

        var magnitudes = [Float](repeating: 0.0, count: inputCount)
        vDSP_zvmags(&output, 1, &magnitudes, 1, vDSP_Length(inputCount))
        
        var normalizedMagnitudes = [Float](repeating: 0.0, count: inputCount)
        vDSP_vsmul(sqrtq(magnitudes), 1, [2.0 / Float(inputCount)],
                   &normalizedMagnitudes, 1, vDSP_Length(inputCount))
        
        let buffer = Buffer(elements: normalizedMagnitudes)
        
        //vDSP_destroy_fftsetup(fftSetup)
        
        return buffer
    }
    // Returns bin number of most dominant frequency
    func domin_freq(_ fft_buffer: Buffer) throws -> Int {
        var max: Double = 0.0;
        var index = 0;
        for i in 0...fft_buffer.elements.count-1 {
            if Double(abs(fft_buffer.elements[i])) > max {
                max = Double(fft_buffer.elements[i])
                index = i;
            }
        }
        return index;
    }
    func getPowerSpectrum(_ fft_buffer: Buffer) -> [Float] {
        return fft_buffer.elements.map {value in pow(abs(value),2)};
        
    }
    func getSpectralFlatness(_ fft_buffer: Buffer) -> Double {
        let powerSpectrum = getPowerSpectrum(fft_buffer)
        var gmMean = 0.0
        var arMean = 0.0

        for x in powerSpectrum {
            gmMean += log(Double(x))
            arMean += Double(x)
        }
        gmMean = exp(gmMean / Double(powerSpectrum.count))
        arMean /= Double(powerSpectrum.count);
        
        return gmMean / arMean;
    }
    // MARK: - Helpers
    func destroySetup(){
        vDSP_destroy_fftsetup(self.fftSetup)
    }
    func sqrtq(_ x: [Float]) -> [Float] {
        var results = [Float](repeating: 0.0, count: x.count)
        vvsqrtf(&results, x, [Int32(x.count)])
        
        return results
    }
}
