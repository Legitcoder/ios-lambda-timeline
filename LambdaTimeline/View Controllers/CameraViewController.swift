//
//  CameraViewController.swift
//  LambdaTimeline
//
//  Created by Moin Uddin on 11/7/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let captureSession = AVCaptureSession()
        
        let cameraDevice = bestCamera()
        
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: cameraDevice),
            captureSession.canAddInput(videoDeviceInput) else { fatalError() }
        captureSession.addInput(videoDeviceInput)
        
        let fileOutput = AVCaptureMovieFileOutput()
        
        guard captureSession.canAddOutput(fileOutput) else { fatalError() }
        captureSession.addOutput(fileOutput)
        captureSession.sessionPreset = .hd1920x1080
        captureSession.commitConfiguration()
        
        recordingOutput = fileOutput
        self.captureSession = captureSession
        previewView.videoPreviewLayer.session = captureSession
        
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        DispatchQueue.main.async {
            self.updateButton()
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        DispatchQueue.main.async {
            defer { self.updateButton() }
            
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status != .authorized {
                    NSLog("Please give VideoFilters access to your Photo Library in Settings.")
                    return
                }
                
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
                }, completionHandler: { (success, error) in
                    if let error = error {
                        NSLog("Error saving video to Photo Library : \(error)")
                    }
                    NSLog("Success")
                    
                })
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession?.startRunning()
    }
    
    func updateButton() {
        guard isViewLoaded else { return }
        
        let isRecording = recordingOutput.isRecording
        let recordButtonImageTitle = isRecording ? "Stop" : "Record"
        let image = UIImage(named: recordButtonImageTitle)
        recordButton.setImage(image, for: .normal)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession?.stopRunning()
    }
    
    var captureSession: AVCaptureSession!
    var recordingOutput: AVCaptureMovieFileOutput!
    
    @IBAction func record(_ sender: Any) {
        if recordingOutput.isRecording {
            recordingOutput.stopRecording()
        } else {
            recordingOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
    }
    
    private func newRecordingURL() -> URL {
        let fm = FileManager.default
        let documentsDir = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        return documentsDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
    }
    
    
    private func bestCamera() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            return device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        } else {
            fatalError("Missing back camera device")
        }
    }
    
    
    var postController: PostController?
    @IBOutlet weak var previewView: CameraPreviewView!
    @IBOutlet weak var recordButton: UIButton!
    
}

