//
//  VoiceChatRoomBody.swift
//  ChAir
//
//  Created by Atharv on 21/07/25.
//

import SwiftUI
import AVFoundation
import PhotosUI
import UniformTypeIdentifiers
import QuickLook

struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct VoiceChatRoomBody: View {
    @ObservedObject var multipeer: MultipeerManager
    let roomKey: String
    let showSenderName: Bool
    let isPrivate: Bool

    @State private var newMessage = ""
    @StateObject private var recorderManager = AudioRecorderManager()
    @State private var showImagePicker = false
    @State private var selectedImages: [UIImage] = []
    @State private var showFilePicker = false
    @State private var selectedFile: URL?
    @State private var previewedFile: PreviewFile?
    @State private var pendingFiles: [URL] = []
    @State private var showPendingFilePreview = false
    @State private var fullScreenImage: IdentifiableImage? = nil
    
    

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
                AnimatedVoiceRecordingBar(isRecording: recorderManager.isRecording,
                                          timeLeft: recorderManager.recordingTimeLeft)

                HStack(spacing: 12) {
                    TextField("Message", text: $newMessage)
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .frame(minHeight: 44)

                    Button(action: {
                        multipeer.send(message: newMessage, toRoom: roomKey)
                        newMessage = ""
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }

                    Menu {
                        Button {
                            showImagePicker = true
                        } label: {
                            Label("Send Photo", systemImage: "photo.on.rectangle")
                        }

                        Button {
                            showFilePicker = true
                        } label: {
                            Label("Send File", systemImage: "doc.fill")
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }

                    Image(systemName: "mic.fill")
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(recorderManager.isRecording ? Color.red : Color.blue)
                        .clipShape(Circle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    if !recorderManager.isRecording {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            recorderManager.onFinish = { data in
                                                if let data = data {
                                                    multipeer.sendVoice(data, toRoom: roomKey)
                                                }
                                            }
                                            recorderManager.startRecording()
                                        }
                                    }
                                }
                                .onEnded { _ in
                                    if recorderManager.isRecording {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            recorderManager.stopRecording()
                                        }
                                    }
                                }
                        )
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
//                .background(.ultraThinMaterial)
//                .clipShape(RoundedRectangle(cornerRadius: 16))
//                .shadow(radius: 3)
                .padding(.bottom, 8)
            }

        }
        .sheet(isPresented: $showImagePicker) {
            NavigationStack {
                VStack {
                    ScrollView {
                        ForEach(selectedImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                    }
                    Button("Send Images") {
                        for image in selectedImages {
                            multipeer.sendImage(image, toRoom: roomKey)
                        }
                        selectedImages.removeAll()
                        showImagePicker = false
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()
                }
                .navigationTitle("Selected Images")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            selectedImages.removeAll()
                            showImagePicker = false
                        }
                    }
                }
            }
        }

        .sheet(isPresented: $showFilePicker) {
            FilePicker { urls in
                pendingFiles = urls
                if !urls.isEmpty {
                    showPendingFilePreview = true
                }
            }
        }

        .sheet(isPresented: $showPendingFilePreview) {
            NavigationStack {
                VStack {
                    List {
                        ForEach(pendingFiles, id: \.self) { url in
                            HStack {
                                Image(systemName: "doc.text")
                                Text(url.lastPathComponent)
                                    .lineLimit(1)
                            }
                        }
                    }

                    Button("Send All") {
                        for url in pendingFiles {
                            if let data = try? Data(contentsOf: url) {
                                multipeer.sendFile(data, fileName: url.lastPathComponent, toRoom: roomKey)
                            }
                        }
                        pendingFiles.removeAll()
                        showPendingFilePreview = false
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()
                }
                .navigationTitle("Send Files")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            pendingFiles.removeAll()
                            showPendingFilePreview = false
                        }
                    }
                }
            }
        }

        .sheet(item: $previewedFile) { preview in
            NavigationStack {
                QuickLookPreview(fileURL: preview.url)
                    .navigationTitle(preview.url.lastPathComponent)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done") {
                                previewedFile = nil
                            }.foregroundColor(.white)
                        }
                    }
            }
        }

        .fullScreenCover(item: $fullScreenImage) { wrapped in
            ZoomableImageView(image: wrapped.image)
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
        } else if let imageData = msg.imageData, let uiImage = UIImage(data: imageData) {
            Button(action: {
                fullScreenImage = IdentifiableImage(image: uiImage)
            }) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 200)
                    .cornerRadius(10)
            }
        } else if let fileData = msg.fileData, let fileName = msg.fileName {
            Button(action: {
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
                try? fileData.write(to: tempURL)
                previewedFile = PreviewFile(url: tempURL)
            }) {
                HStack {
                    Image(systemName: "doc.text")
                    Text(fileName)
                }
                .padding(10)
                .background(Color.orange)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        } else {
            Text("[Unsupported]")
                .foregroundColor(.red)
        }
    }
}

struct PreviewFile: Identifiable {
    let id = UUID()
    let url: URL
}

struct ZoomableImageView: View {
    let image: UIImage

    @Environment(\.dismiss) var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero

    var body: some View {
        NavigationStack {
            Color.black.ignoresSafeArea()
                .overlay(
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in scale = value }
                                .onEnded { _ in if scale < 1 { scale = 1 } }
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in offset = gesture.translation }
                                .onEnded { _ in withAnimation { offset = .zero } }
                        )
                )
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") {
                            dismiss()
                        }.foregroundColor(.white)
                    }
                }
        }
    }
}

struct AnimatedVoiceRecordingBar: View {
    let isRecording: Bool
    let timeLeft: Int

    var body: some View {
        VStack {
            if isRecording {
                HStack {
                    SoundWaveView()
                        .transition(.scale.combined(with: .opacity))

                    Text("\(timeLeft)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .bold()
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.blue)
                .clipShape(Capsule())
                .shadow(radius: 3)
                .padding(.top, 4)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isRecording)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
