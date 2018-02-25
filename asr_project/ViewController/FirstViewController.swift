//
//  FirstViewController.swift
//  asr_project
//
//  Created by Tiberiu Simion Voicu on 20/11/2017.
//  Copyright © 2017 Tiberiu Simion Voicu. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    @IBOutlet weak var file_select_lable: UILabel!
    @IBOutlet weak var file_path_text_box: UITextField!
    
    @IBOutlet weak var turns_button: UIButton!
    @IBOutlet weak var turns_lable: UILabel!
    
    @IBOutlet weak var get_trascript_button: UIButton!
    @IBOutlet weak var get_transcript_lable: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
}

