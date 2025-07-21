//
//  VoiceMessagePlayer.swift
//  ChAir
//
//  Created by Atharv on 21/07/25.
//

import SwiftUI
import AVFoundation

struct VoiceMessagePlayer: View {
    let audioData: Data
    @State private var player: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var animateWave = false

    var body: some View {
        Button(action: {
            if isPlaying {
                stopAudio()
            } else {
                playAudio()
            }
        }) {
            HStack(spacing: 4) {
                if isPlaying {
                    SoundWaveView()
                        .frame(height: 24)
                        .transition(.opacity)
                } else {
                    Image(systemName: "play.circle.fill")
                        .font(.title)
//                        .glassEffect(.clear)
                        .foregroundColor(.white)
                }

                Text(isPlaying ? "Playing" : "Audio")
                    .foregroundColor(.white)
                    .fontWeight(.medium)
            }
            .padding(8)
            .glassEffect(.clear.tint(Color.blue.opacity(0.7)))
//            .background(Color.black.opacity(0.3))
//            .clipShape(RoundedRectangle(cornerRadius: 10))
            

        }
    }

    func playAudio() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session for playback: \(error)")
        }

        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".m4a")

        do {
            try audioData.write(to: tempURL)
            player = try AVAudioPlayer(contentsOf: tempURL)
            player?.prepareToPlay()
            player?.play()
            isPlaying = true
            animateWave = true

            DispatchQueue.main.asyncAfter(deadline: .now() + (player?.duration ?? 0)) {
                stopAudio()
            }
        } catch {
            print("Playback failed: \(error)")
        }
    }

    func stopAudio() {
        player?.stop()
        isPlaying = false
        animateWave = false
    }
    
    
}

#Preview("VoiceMessagePlayer Preview", traits: .sizeThatFitsLayout) {
    if let url = Bundle.main.url(forResource: "testaudio", withExtension: "m4a"),
       let data = try? Data(contentsOf: url) {
        VoiceMessagePlayer(audioData: data)
            .padding()
            .background(Color.gray)
    } else {
        Text("❌ testaudio.m4a not found in bundle")
            .foregroundColor(.red)
            .padding()
    }
}

struct SoundWaveView: View {
    @State private var heights: [CGFloat] = Array(repeating: 10, count: 5)

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            ForEach(0..<heights.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white)
                    .frame(width: 4, height: heights[index])
            }
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 0.2).repeatForever(autoreverses: true)) {
                animateWave()
            }
        }
    }

    func animateWave() {
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            for i in 0..<heights.count {
                heights[i] = CGFloat.random(in: 8...24)
            }
        }
    }
}
