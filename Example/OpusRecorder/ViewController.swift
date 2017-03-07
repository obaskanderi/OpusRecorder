//
//  ViewController.swift
//  OpusRecorder
//
//  Created by obaskanderi on 03/06/2017.
//  Copyright (c) 2017 obaskanderi. All rights reserved.
//

import UIKit
import OpusRecorder

class ViewController: UIViewController {

    fileprivate var recorderStartTime: TimeInterval!
    fileprivate var recorderTimer: Timer!
    fileprivate var recorder: OpusRecorder!
    fileprivate var audioURL: URL!
    
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var startRecordingButton: UIButton!
    @IBOutlet var stopRecordingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            //clean up previously recorded files
            let files = FileManager.default.enumerator(atPath: dir.path)
            while let file = files?.nextObject() as? String {
                if file.hasSuffix("ogg") {
                    do {
                        try FileManager.default.removeItem(at: dir.appendingPathComponent(file))
                        print("successfully removed item: \(dir.appendingPathComponent(file))")
                    } catch {
                        print("Failed to remove item: \(dir.appendingPathComponent(file)), error = \(error)")
                    }
                }
            }
        }
        
        self.recorder = OpusRecorder()
        
        stopRecordingButton.isEnabled = false
    }

    @IBAction func startPressed(_ sender: Any) {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let audioFilename = ProcessInfo.processInfo.globallyUniqueString + ".ogg"
            self.audioURL = dir.appendingPathComponent(audioFilename)
            FileManager.default.createFile(atPath: audioURL.path, contents: nil, attributes: nil)
        }
        
        recorder.start(audioURL) { (error: Error) in
            print("recorder encountered, error = \(error)")
        }
        
        durationLabel.text = "00:00"
        self.recorderStartTime = Date.timeIntervalSinceReferenceDate
        self.recorderTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateRecordingTimer), userInfo: nil, repeats: true)
        
        startRecordingButton.isEnabled = false
        stopRecordingButton.isEnabled = true
    }
    
    @IBAction func stopButton(_ sender: Any) {
        if let timer = self.recorderTimer {
            timer.invalidate()
        }
        recorderTimer = nil
        recorder.stop()
        
        startRecordingButton.isEnabled = true
        stopRecordingButton.isEnabled = false
    }
    
    
    func updateRecordingTimer() {
        let currentTime = Date.timeIntervalSinceReferenceDate
        let elapsedTime: TimeInterval = currentTime - recorderStartTime
        self.durationLabel.text = String.stringFromTimeInterval(elapsedTime)
        self.durationLabel.sizeToFit()
    }
}

extension String {
    
    static func stringFromTimeInterval(_ interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
