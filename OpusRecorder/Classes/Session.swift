//
//  Session.swift
//  OpusRecorder
//
//  Created by Omair Baskanderi on 2017-03-06.
//
//  This class was extracted from:
//  watson-developer-cloud/swift-sdk SpeechToTextSession.swift
//
//  Minor modifications:
//     - removed web components
//     - removed speech components
//
//  original source:
//  https://github.com/watson-developer-cloud/swift-sdk/blob/master/Source/SpeechToTextV1/SpeechToTextSession.swift
//
//  Copyright IBM Corporation 2016
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


import Foundation

internal class Session {
    
    /// Invoked with microphone audio when a recording audio queue buffer has been filled.
    /// If microphone audio is being compressed, then the audio data is in Opus format.
    /// If uncompressed, then the audio data is in 16-bit mono PCM format at 16 kHZ.
    public var onMicrophoneData: ((Data) -> Void)?
    
    /// Invoked every 0.025s when recording with the average dB power of the microphone.
    public var onPowerData: ((Float32) -> Void)? {
        get { return recorder.onPowerData }
        set { recorder.onPowerData = newValue }
    }
    
    /// Invoked when the session disconnects from the Speech to Text service.
    public var onDisconnect: ((Void) -> Void)?
    
    /// Invoked when an error or warning occurs.
    public var onError: ((Error) -> Void)?
    
    private var recorder: Recorder
    private var encoder: Encoder
    private var compress: Bool = true
    private let domain = "org.opus-codec.org"
    
    public init() {
        recorder = Recorder()
        encoder = try! Encoder(
            format: recorder.format,
            opusRate: Int32(recorder.format.mSampleRate),
            application: .voip
        )
    }
    
    /**
     Start streaming microphone audio data to transcribe.
     
     Knowing when to stop the microphone depends upon the recognition request's continuous setting:
     
     - If `false`, then the service ends the recognition request at the first end-of-speech
     incident (denoted by a half-second of non-speech or when the stream terminates). This
     will coincide with a `final` transcription result. So the `success` callback should
     be configured to stop the microphone when a final transcription result is received.
     
     - If `true`, then you will typically stop the microphone based on user-feedback. For example,
     your application may have a button to start/stop the request, or you may stream the
     microphone for the duration of a long press on a UI element.
     
     By default, microphone audio data is compressed to Opus format to reduce latency and bandwidth.
     To disable Opus compression and send linear PCM data instead, set `compress` to `false`.
     
     If compression is enabled, the recognitions request's `contentType` setting should be set to
     `AudioMediaType.Opus`. If compression is disabled, then the `contentType` settings should be
     set to `AudioMediaType.L16(rate: 16000, channels: 1)`.
     
     This function may cause the system to automatically prompt the user for permission
     to access the microphone. Use `AVAudioSession.requestRecordPermission(_:)` if you
     would rather prefer to ask for the user's permission in advance.
     
     - parameter compress: Should microphone audio be compressed to Opus format?
     (Opus compression reduces latency and bandwidth.)
     */
    public func startMicrophone(_ compress: Bool = true) {
        self.compress = compress
        
        // reset encoder
        encoder = try! Encoder(
            format: recorder.format,
            opusRate: Int32(recorder.format.mSampleRate),
            application: .voip
        )
        
        // request recording permission
        recorder.session.requestRecordPermission { granted in
            guard granted else {
                let failureReason = "Permission was not granted to access the microphone."
                let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
                let error = NSError(domain: self.domain, code: 0, userInfo: userInfo)
                self.onError?(error)
                return
            }
            
            // callback if uncompressed
            let onMicrophoneDataPCM = { (pcm: Data) in
                guard pcm.count > 0 else { return }
                self.onMicrophoneData?(pcm)
            }
            
            // callback if compressed
            let onMicrophoneDataOpus = { (pcm: Data) in
                guard pcm.count > 0 else { return }
                try! self.encoder.encode(pcm: pcm)
                let opus = self.encoder.bitstream(flush: true)
                guard opus.count > 0 else { return }
                self.onMicrophoneData?(opus)
            }
            
            // set callback
            if compress {
                self.recorder.onMicrophoneData = onMicrophoneDataOpus
            } else {
                self.recorder.onMicrophoneData = onMicrophoneDataPCM
            }
            
            // start recording
            do {
                try self.recorder.startRecording()
            } catch {
                let failureReason = "Failed to start recording."
                let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
                let error = NSError(domain: self.domain, code: 0, userInfo: userInfo)
                self.onError?(error)
                return
            }
        }
    }
    
    /**
     Stop streaming microphone audio data to transcribe.
     */
    public func stopMicrophone() {
        do {
            try recorder.stopRecording()
        } catch {
            let failureReason = "Failed to stop recording."
            let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
            let error = NSError(domain: self.domain, code: 0, userInfo: userInfo)
            self.onError?(error)
            return
        }
        
        if compress {
            let opus = try! encoder.endstream()
            guard opus.count > 0 else { return }
            self.onMicrophoneData?(opus)
        }
    }    
}
