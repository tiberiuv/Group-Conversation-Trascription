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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
<<<<<<< HEAD
        self.audio_engine.stop()
        self.recognitionTask?.cancel()
        self.request.endAudio()
=======
        self.audio_engine.stop();
        self.recognitionTask?.cancel();
        self.request.endAudio();
>>>>>>> 47ef41a332b45300ae210a40d7218ad8060926ef
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
            print("Speech recognition is not currently available please try again later.")
            return
        }
        self.recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: {(result, error) in
            guard let result = result else {
                print("An error occured while trying to transcribe the file")
                return;
            }
            self.updateUITranscript(result.bestTranscription)
        })
    }
    @IBAction func start_recording(_ sender: Any) {
        self.recognize();
    }

    fileprivate func updateUIFullTranscript(_ transcription: String) {
        DispatchQueue.main.async {
            [unowned self] in
<<<<<<< HEAD
            self.transcript_label.text = transcription
            UIView.animate(withDuration: 0.5, animations: {
                self.activityIndicator.isHidden = true
                self.transcript_label.isHidden = false
                
            }, completion: { _ in
                self.activityIndicator.stopAnimating()
                //self.transcripeButton.isEnabled = true
=======
            self.transcript_label.text = transcription;
            UIView.animate(withDuration: 0.5, animations: {
                self.activityIndicator.isHidden = true;
                self.transcript_label.isHidden = false;
                
            }, completion: { _ in
                self.activityIndicator.stopAnimating();
                //self.transcripeButton.isEnabled = true;
>>>>>>> 47ef41a332b45300ae210a40d7218ad8060926ef
            })
        }
    }
    fileprivate func updateUITranscript(_ transcription: SFTranscription) {
        self.transcript_label.text = transcription.formattedString;
//        DispatchQueue.main.async {
//            [unowned self] in
//            self.activityIndicator.startAnimating()
//            UIView.animate(withDuration: 0.5) {
//                self.activityIndicator.isHidden = false;
//            }
//        }
    }
}

