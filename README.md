# OpusRecorder

Record microphone input and encode data with opus codec.

## Example

	// Create a file to store voice recording
	let audioFilename = ProcessInfo.processInfo.globallyUniqueString + ".ogg"
    let audioFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent(audioFilename)
   	let audioURL = URL(fileURLWithPath: audioFilePath, isDirectory: false)

	if !FileManager.default.fileExists(atPath: audioFile.path) {
    	FileManager.default.createFile(atPath: audioFile.path, contents: nil, attributes: nil)
    }

	// Start recording
	let recorder = OpusRecorder()
	recorder.start(audioURL!) { (error: Error) in
		print("Failed to start recording, error: \(error)")
	}

    // Stop recording
    recorder.stop()

## Installation

OpusRecorder is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "OpusRecorder"
```

## Author

obaskanderi, obaskanderi@topologyinc.com

## License

OpusRecorder is available under the Apache 2.0 license. See the LICENSE file for more info.
