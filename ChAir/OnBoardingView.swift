//
//  OnBoardingView.swift
//  ChAir
//
//  Created by Atharv on 15/07/25.
//

import SwiftUI

struct OnBoardingView: View {
    @Binding var showOnboarding: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()

                OnboardingPage(imageName: "welcomePage", showOnboarding: $showOnboarding)
                
            
            .frame(width: 350, height: 600)
            .cornerRadius(30)
            .shadow(radius: 20)
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .transition(.opacity)
    }
}

#Preview {
    OnBoardingView(showOnboarding: .constant(true))
}

struct OnboardingPage: View {
    var imageName: String
    @Binding var showOnboarding: Bool
    var description: String?

    var body: some View {
        ZStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 350, height: 600)
                .clipped()

            VStack {
                HStack {
                    Spacer()
                    CloseButton {
                        showOnboarding = false
                    }
                }
                Spacer()
            }
            .padding(15)
        }
        .frame(width: 350, height: 600)
    }
}

struct CloseButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .padding(10)
        }
//        .buttonStyle(.glassProminent)
        .buttonStyle(.bordered)
    }
}


