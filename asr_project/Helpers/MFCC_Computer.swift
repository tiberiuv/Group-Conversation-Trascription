//
//  MFCC_Computer.swift
//  asr_project
//
//  Created by Tiberiu Simion Voicu on 28/01/2018.
//  Copyright © 2018 Tiberiu Simion Voicu. All rights reserved.
//winLengthSamples   = winLength * fs / 1e3;  // winLength in milliseconds
//frameShiftSamples  = frameShift * fs / 1e3; // frameShift in milliseconds
//
//numFFTBins = numFFT/2 + 1;
//powerSpectralCoef.assign (numFFTBins, 0);
//prevsamples.assign (winLengthSamples-frameShiftSamples, 0);
//
//initFilterbank();
//initHamDct();
//compTwiddle();

import Foundation
import Accelerate
import AVFoundation

class MFCC_Computer {

    var sampling_freq = 16000.0;
    var num_cepestra = 12
    var win_length = 25
    var frame_shift = 10
    var num_filters = 40
    var low_freq = 50.0
    var high_freq =  65000.0
    var pre_emph = 0.97
    var num_fft = 512
    var num_fftbins: Int
    
    var frame = [Float]()
    var power_spectrum = [Double]()
    var lmfb_coef = [Double]()
    var prev_samples = [Float]()
    var hamming = [Double]()
    var win_length_samples = 0
    var frame_shift_samples = 0
    var dct = [[Double]]()
    var filter_bank = [[Double]]()
    init() {
        //num_fftbins = self.num_fft / 2 + 1
        num_fftbins = self.num_fft / 2
        win_length_samples = win_length * Int(sampling_freq) / 1000
        frame_shift_samples = frame_shift * Int(sampling_freq) / 1000
        
        init_filter_bank()
        init_ham_dct()
    }
    init(sa_freq: Double?, n_cep: Int?,win_len: Int?, frame_sft: Int?, n_filt: Int?, low_f: Double?, high_f: Double?) {
        self.sampling_freq = sa_freq!
        self.num_cepestra = n_cep!
        self.win_length = win_len!
        self.frame_shift = frame_sft!
        self.num_filters = n_filt!
        self.low_freq = low_f!
        self.high_freq = high_f!

       // num_fftbins = self.num_fft / 2 + 1
        num_fftbins = self.num_fft / 2
        win_length_samples = win_length * Int(sampling_freq) / 1000
        frame_shift_samples = frame_shift * Int(sampling_freq) / 1000
        
        init_filter_bank()
        init_ham_dct()
    }
    
    func process_frame(samples: [Float]) -> [Double]{
        frame = prev_samples;
        
        for i in 0..<samples.count {
            frame.append(samples[i])
        }
        prev_samples = [Float](frame[frame_shift_samples..<frame.count])
        
        preemph_ham()
        comp_power_spectrum()
        apply_lmfb()
        let mfcc = apply_dct()
        
        return mfcc;
    }

    func process(samples: [Float]) -> [[Double]]{
        var mfccs = [[Double]]()
        let buffer_length = win_length_samples - frame_shift_samples;
        prev_samples = [Float](repeating: 0, count: buffer_length)
        
        for i in 0..<buffer_length {
            self.prev_samples[i] = samples[i]
        }
        let buffer_len = frame_shift_samples;
        for i in stride(from: buffer_length, to: samples.count, by: buffer_len) {
            let frame_sample = [Float] (samples[i...i+buffer_len-1])
            let mfcc = process_frame(samples: frame_sample)
            print(mfcc)
            mfccs.append(mfcc)
        }
        
        return mfccs
    }
    // apply pre emphasis filter and hamming window to the frame
    func preemph_ham(){
        var proc_frame = [Float](repeating: 0, count: frame.count);
        for i in 1..<frame.count {
            proc_frame[i] = Float(hamming[i]) * (frame[i] - Float(pre_emph) * frame[i-1])
            var sample = proc_frame[i];
        }
        frame = proc_frame
    }
    func comp_power_spectrum() {
        let fft_computer = Fft_transformer();

        power_spectrum = [Double](repeating: 0, count: num_fftbins)
        do {
            let spectrum = try fft_computer.get_power_spectrum(fft_buffer: fft_computer.transform(samples: frame))
            for i in 0..<num_fftbins {
                power_spectrum[i] = Double(pow(abs(spectrum[i]),2));
            }
        } catch {print(error)}
    }
    // Applying log Mel filterbank (LMFB)
    func apply_lmfb() {
        lmfb_coef = [Double](repeating: 0, count: num_filters)
        for i in 0..<num_filters{
        // Multiply the filterbank matrix
            for j in 0..<filter_bank[i].count {
                lmfb_coef[i] += filter_bank[i][j] * power_spectrum[j];
            }
            // Apply Mel-flooring
            if (lmfb_coef[i] < 1.0) {
                lmfb_coef[i] = 1.0;
            }
        }
        
        // Applying log on amplitude
        for i in 0..<num_filters {
            lmfb_coef[i] = log(lmfb_coef[i]);
        }
    }
    
    // apply direct consine tranform -> return mfcc array
    func apply_dct() -> [Double]{
        var mfcc = [Double](repeating: 0, count: num_cepestra+1);
        for i in 0...num_cepestra {
            for j in 0..<num_filters {
                mfcc[i] += ( dct[i][j] * lmfb_coef[j])
            }
        }
        return mfcc;
    }
    
    // Initiate hamming window values and direct cosine transform matrix
    func init_ham_dct() {
        hamming = [Double](repeating: 0, count: win_length_samples)
        for i in 0..<win_length_samples {
            hamming[i] = 0.54 - 0.46 * cos(2 * Double.pi * Double(i) / Double(win_length_samples-1) )
        }
        var arr1 = [Double](repeating: 0, count: num_cepestra+1)
        var arr2 = [Double](repeating: 0, count: num_filters)
        for i in 0...num_cepestra {
            arr1[i] = (Double(i)) ;
        }
        for i in 0..<num_filters {
            arr2[i] = (Double(i) + 0.5);
        }
        dct = [[Double]]();
        let c: Double = sqrt(2.0 / Double(num_filters))
        for i in 0...num_cepestra {
            var temp = [Double]()
            for j in 0..<num_filters {
                temp.append(c * cos(Double.pi / Double(num_filters) * arr1[i] * arr2[j]))
            }
            dct.append(temp)
        }
    }
    // Initiate mel filter bank
    func init_filter_bank() {
        let low_mel_freq = hz_to_mel(freq: low_freq)
        let high_mel_freq = hz_to_mel(freq: high_freq)
        
        var centre_freq = [Double](repeating: 0, count: num_filters + 2)
        for i in 0..<num_filters + 2 {
            centre_freq[i] = (mel_to_hz(mel: low_mel_freq + (high_mel_freq - low_mel_freq )/Double(num_filters+1)*Double(i)))
            var x = centre_freq[i]
        }
        var fftbin_freq = [Double](repeating: 0, count: num_fftbins)
        for i in 0..<num_fftbins {
            fftbin_freq[i] = (sampling_freq / 2.0 / Double(num_fftbins-1)*Double(i))
            var x = fftbin_freq[i]
        }
        filter_bank = [[Double]]();
        // Populate the fbank matrix
        for filt in 1...num_filters {
            var ftemp = [Double]()
            for bin in 0..<num_fftbins {
                var weight = Double()
                if (fftbin_freq[bin] < centre_freq[filt-1]) {
                    weight = 0;
                }
                else if (fftbin_freq[bin] <= centre_freq[filt]) {
                     weight = (fftbin_freq[bin] - centre_freq[filt-1]) / (centre_freq[filt] - centre_freq[filt-1]);
                }
               
                else if (fftbin_freq[bin] <= centre_freq[filt+1]) {
                     weight = (centre_freq[filt+1] - fftbin_freq[bin]) / (centre_freq[filt+1] - centre_freq[filt]);
                }
                else {
                    weight = 0;
                }
                ftemp.append (weight);
            }
            filter_bank.append(ftemp);
        }
    }
    
//    func hamming(k: Int) -> Double {
//        return 0.54 - 0.46 * cos(2 * M_PI * k / (win_length_samples-1) )
//    }
//Helpers
    func hz_to_mel(freq: Double) -> Double {
        return 2595 * log10(1+freq/700)
    }
    func mel_to_hz(mel: Double) -> Double {
        return 700 * (pow(10,mel/2595) - 1)
    }
    
}
