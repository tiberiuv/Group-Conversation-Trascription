//
//  SecondViewController.swift
//  asr_project
//
//  Created by Tiberiu Simion Voicu on 20/11/2017.
//  Copyright © 2017 Tiberiu Simion Voicu. All rights reserved.
//

import UIKit
import Speech
class SecondViewController: UIViewController {

    @IBOutlet weak var transcript_label: UILabel!
    @IBOutlet weak var start_rec_button: UIButton!
    @IBOutlet weak var stop_rec_button: UIButton!
    
    let audio_engine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "en-UK"))
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func stop_recording(_ sender: Any) {
        self.recognitionTask?.finish();
        self.recognitionTask = nil;
        self.audio_engine.reset();
        self.request.endAudio();
    }
    func recognize() {
        let node = audio_engine.inputNode
        let recording_format = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recording_format) {
            buffer, _ in self.request.append(buffer)
        }
        
        audio_engine.prepare()
        do {
            try audio_engine.start();
        } catch {
            return print(error)
        }
        
        guard let my_recog = SFSpeechRecognizer() else { return }
        
        if !my_recog.isAvailable {
            return
        }
        self.recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: {(result, error) in
            
            if result != nil {
                let result = (result?.bestTranscription.formattedString)!
                print(result)
                self.transcript_label.text = result;
            }
                
            else if let error = error {
                print("Errrrorrrrr \(error)")
            }
        })
    }
    @IBAction func start_recording(_ sender: Any) {
        self.recognize();
    }
    
}

