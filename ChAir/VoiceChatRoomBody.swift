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
    @StateObject private var recorderManager = AudioRecorderManager()

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

            VStack(spacing: 4) {
                if recorderManager.isRecording {
                    HStack {
                        SoundWaveView()
                            .animation(.easeInOut, value: recorderManager.isRecording)

                        Text("\(recorderManager.recordingTimeLeft)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .bold()
                    }
                    .frame(height: 60)
                    .frame(maxWidth: 150)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .transition(.opacity)
                    .padding(.horizontal)
                    
                    
                }

                HStack(spacing: 12) {
                    TextField("Type your message...", text: $newMessage)
                        .padding(12)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                    Button(action: {
                        multipeer.send(message: newMessage, toRoom: roomKey)
                        newMessage = ""
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(12)
                            .background(.blue)
                            .clipShape(Capsule())
                    }

                    Button(action: {
                        if recorderManager.isRecording {
                            recorderManager.stopRecording()
                        } else {
                            recorderManager.onFinish = { data in
                                if let data = data {
                                    multipeer.sendVoice(data, toRoom: roomKey)
                                }
                            }
                            recorderManager.startRecording()
                        }
                    }) {
                        Image(systemName: recorderManager.isRecording ? "stop.fill" : "mic.fill")
                            .foregroundColor(.white)
                            .padding(12)
                            .background(recorderManager.isRecording ? Color.red : Color.blue)
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .shadow(radius: 5)
                .padding(.bottom, 8)
            }
        }
    }

    @ViewBuilder
    func messageView(for msg: ChatMessage) -> some View {
        if let text = msg.text {
            Text(text)
                .padding(10)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
        } else if let voice = msg.audioData {
            VoiceMessagePlayer(audioData: voice)
        } else {
            Text("[Unsupported]")
                .foregroundColor(.red)
        }
    }
}
