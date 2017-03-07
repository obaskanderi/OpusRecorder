//
//  OpusRecorder.swift
//  OpusRecorder
//
//  Created by Omair Baskanderi on 2017-03-06.
//
//

import Foundation
import AVFoundation

public class OpusRecorder {
    
    private var microphoneSession: Session?
    private var audioFile: FileHandle?
    private let audioSession = AVAudioSession.sharedInstance()
    private let domain = "org.opus-codec.org"
    
    public init() { }
    
    public func start(_ url: URL, failure: ((Error) -> Void)? = nil) {
        do {
            try self.audioFile = FileHandle(forWritingTo: url)
        } catch {
            let failureReason = "Failed to get handle to url. error = \(error)"
            let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
            let error = NSError(domain: self.domain, code: 0, userInfo: userInfo)
            failure?(error)
            return
        }
        
        // make sure the AVAudioSession shared instance is properly configured
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: [.defaultToSpeaker, .mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            let failureReason = "Failed to setup the AVAudioSession sharedInstance properly."
            let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
            let error = NSError(domain: self.domain, code: 0, userInfo: userInfo)
            failure?(error)
            return
        }
        
        let session = Session()
        session.onError = failure
        session.onMicrophoneData = onMicrophoneData
        session.startMicrophone()
        
        microphoneSession = session
    }
    
    public func stop() {
        microphoneSession?.stopMicrophone()
    }
    
    private func onMicrophoneData(data: Data) {
        audioFile?.write(data)
    }
}
