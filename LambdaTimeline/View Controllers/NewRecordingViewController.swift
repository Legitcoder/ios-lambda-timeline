//
//  NewRecordingViewController.swift
//  LambdaTimeline
//
//  Created by Moin Uddin on 11/6/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation
class NewRecordingViewController: UIViewController, AVAudioRecorderDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        requestMicrophonePermission()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func record(_ sender: Any) {
        defer { updateButtons() }
        guard !isRecording else {
            recorder?.stop()
            return
        }
        
        do {
            let format = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2)!
            recorder = try AVAudioRecorder(url: newRecordingURL(), format: format)
            recorder?.delegate = self
            recorder?.record()
        } catch {
            NSLog("Unable to start recording: \(error)")
        }
    }
    
    func requestMicrophonePermission() {
        let session = AVAudioSession.sharedInstance()
        
        session.requestRecordPermission { (granted) in
            guard granted else {
                NSLog("Please give the application permission to record in Settings.")
                return
            }
            
            do {
                try session.setCategory(.playAndRecord, mode: .default, options: [])
                try session.setActive(true, options: [])
            } catch {
                NSLog("Error setting up AVAudiosSession: \(error)")
            }
        }
    }
    
    @IBAction func save(_ sender: Any) {
        guard var post = post else { return }
        postController?.addComment( audioURL: recordingURL!, to: &post)
        dismiss(animated: true, completion: nil)
    }
    
    private func updateButtons() {
        isRecording ? recordButton.setTitle("Stop", for: .normal) : recordButton.setTitle("Record", for: .normal)
    }
    
    private func newRecordingURL() -> URL {
        let documentsDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return documentsDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("caf")
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        recordingURL = recorder.url
        self.recorder = nil
        updateButtons()
    }
    
    private var recordingURL: URL?
    private var recorder: AVAudioRecorder?
    private var isRecording: Bool {
        return recorder?.isRecording ?? false
    }
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var postController: PostController?
    var post: Post?
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
