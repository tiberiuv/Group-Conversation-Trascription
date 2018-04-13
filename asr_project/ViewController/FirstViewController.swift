//
//  FirstViewController.swift
//  asr_project
//
//  Created by Tiberiu Simion Voicu on 20/11/2017.
//  Copyright © 2017 Tiberiu Simion Voicu. All rights reserved.
//

import UIKit
import Speech

class FirstViewController: UIViewController {
<<<<<<< HEAD
    var isRecordingPermissionGranted = false
=======
    var isRecordingPermissionGranted = false;
>>>>>>> 47ef41a332b45300ae210a40d7218ad8060926ef
    @IBOutlet weak var file_select_lable: UILabel!
    @IBOutlet weak var file_path_text_box: UITextField!
    
    @IBOutlet weak var turns_button: UIButton!
    @IBOutlet weak var turns_lable: UILabel!
    
    @IBOutlet weak var get_trascript_button: UIButton!
    @IBOutlet weak var get_transcript_lable: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkRecordingPermission()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func on_file_select(_ sender: Any) {
        
    }
    @IBAction func get_turns(_ sender: Any) {
    }
    @IBAction func get_transcript(_ sender: Any) {
        let file = Audio_file(url :Bundle.main.url(forResource: "7127-75946-0002", withExtension: "flac")!)
        let turn = Process_helper.split_audio(audio_file: file)
        let recognizer = S_recognizer(turn:turn)
        recognizer.recognize(controller:self)
    
    }
    func update_transcript(lable: String) {
        get_transcript_lable.text = lable
    }
    func checkRecordingPermission() {
        switch AVAudioSession.sharedInstance().recordPermission() {
        case AVAudioSessionRecordPermission.granted:
<<<<<<< HEAD
            isRecordingPermissionGranted = true
            break
        case AVAudioSessionRecordPermission.denied:
            isRecordingPermissionGranted = false
=======
            isRecordingPermissionGranted = true;
            break
        case AVAudioSessionRecordPermission.denied:
            isRecordingPermissionGranted = false;
>>>>>>> 47ef41a332b45300ae210a40d7218ad8060926ef
        case AVAudioSessionRecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission() {
                [unowned self] allowed in DispatchQueue.main.sync {
                    if allowed {
<<<<<<< HEAD
                        self.isRecordingPermissionGranted = true
                    }
                    else {
                        self.isRecordingPermissionGranted = false
=======
                        self.isRecordingPermissionGranted = true;
                    }
                    else {
                        self.isRecordingPermissionGranted = false;
>>>>>>> 47ef41a332b45300ae210a40d7218ad8060926ef
                    }
                }
            }
            break
        }
    }
    func checkRecognizerPermission() {
        
    }
    
}

