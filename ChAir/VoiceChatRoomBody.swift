//
//  VoiceChatRoomBody.swift
//  ChAir
//
//  Created by Atharv on 21/07/25.
//

import SwiftUI
import AVFoundation

struct VoiceChatRoomBody: View {
    @ObservedObject var multipeer: MultipeerManager
    let roomKey: String
    let showSenderName: Bool
    let isPrivate: Bool

    @State private var newMessage = ""
    @State private var isRecording = false
    @State private var audioRecorder: AVAudioRecorder?

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    let messages = multipeer.messagesForRoom(roomKey)

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(messages) { msg in
                            VStack(alignment: msg.sender == "Me" ? .trailing : .leading, spacing: 2) {
                                if showSenderName && msg.sender != "Me" {
                                    Text(msg.sender)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 4)
                                }

                                HStack {
                                    if msg.sender == "Me" {
                                        Spacer()
                                        messageView(for: msg)
                                    } else {
                                        messageView(for: msg)
                                        Spacer()
                                    }
                                }

                                Text(msg.time.formatted(date: .omitted, time: .shortened))
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            .id(msg.id)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .onChange(of: multipeer.messagesForRoom(roomKey).count) { _ in
                    if let last = multipeer.messagesForRoom(roomKey).last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            HStack(spacing: 12) {
                TextField("Type your message...", text: $newMessage)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                Button(action: {
                    multipeer.send(message: newMessage, toRoom: roomKey)
                    newMessage = ""
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(12)
                        .glassEffect(.clear.tint(.blue))
                }

                Button(action: {
                    toggleRecording()
                }) {
                    Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(isRecording ? .red : .white)
                        .glassEffect(.clear.tint(.blue))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .shadow(radius: 5)
            .padding(.bottom, 8)
        }
    }

    @ViewBuilder
    func messageView(for msg: ChatMessage) -> some View {
        if let text = msg.text {
            Text(text)
                .padding(10)
                .glassEffect(.clear.tint(.blue.opacity(0.7)))
                .foregroundColor(.white)
        } else if let voice = msg.audioData {
            VoiceMessagePlayer(audioData: voice)
        } else {
            Text("[Unsupported]")
                .foregroundColor(.red)
        }
    }

    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    func startRecording() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session for recording: \(error)")
        }

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        let fileName = UUID().uuidString + ".m4a"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.record(forDuration: 10)
            isRecording = true
        } catch {
            print("Failed to start recording: \(error)")
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let url = audioRecorder?.url, let data = try? Data(contentsOf: url) {
                print("Audio data size: \(data.count)")
                multipeer.sendVoice(data, toRoom: roomKey)
            } else {
                print("Failed to get audio data from URL")
            }
        }
    }
}
