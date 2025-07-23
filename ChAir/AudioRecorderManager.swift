//
//  AudioRecorderManager.swift
//  ChAir
//
//  Created by Atharv on 21/07/25.
//

import Foundation
import AVFoundation
import Combine

class AudioRecorderManager: NSObject, AVAudioRecorderDelegate, ObservableObject {
    @Published var isRecording = false
    @Published var recordingTimeLeft = 15

    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    var onFinish: ((Data?) -> Void)?

    func startRecording() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
            return
        }

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".m4a")

        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record(forDuration: 15)
            isRecording = true
            recordingTimeLeft = 15

            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.recordingTimeLeft -= 1
                if self.recordingTimeLeft <= 0 {
                    self.stopRecording()
                }
            }

        } catch {
            print("Failed to start recording: \(error)")
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        timer?.invalidate()
        timer = nil
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        isRecording = false
        timer?.invalidate()
        timer = nil

        let url = recorder.url
        if let data = try? Data(contentsOf: url) {
            onFinish?(data)
        } else {
            onFinish?(nil)
        }
    }
}
