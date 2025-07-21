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
            HStack {
                ZStack {
                    Circle()
                        .fill(isPlaying ? Color.green.opacity(0.3) : Color.blue.opacity(0.3))
                        .frame(width: 44, height: 44)
                        .scaleEffect(animateWave ? 1.2 : 1.0)
                        .animation(animateWave ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true) : .default, value: animateWave)

                    Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }

                Text(isPlaying ? "Playing..." : "Play Voice")
                    .foregroundColor(.white)
                    .fontWeight(.medium)
            }
            .padding(8)
            .background(Color.black.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 10))
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
