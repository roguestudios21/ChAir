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

            TabView {
                OnboardingPage(imageName: "welcomePage", showOnboarding: $showOnboarding)
                OnboardingPage(
                    imageName: "firstPage",
                    showOnboarding: $showOnboarding,
                    description: """
                    When you start the app, you are randomly assigned a username.

                    You can choose to join a chatroom or have a one-on-one chat with another user in the network.
                    """
                )
                OnboardingPage(
                    imageName: "secondPage",
                    showOnboarding: $showOnboarding,
                    description: """
                    Two secure chat rooms are always open join any time.

                    Chats auto-delete when you leave.
                    """
                )
                OnboardingPage(
                    imageName: "thirdPage",
                    showOnboarding: $showOnboarding,
                    description: """
                    Chat with anyone on the same network.

                    Chats auto-delete when you or the other user leaves.
                    """
                )
            }
            .frame(width: 350, height: 700)
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
                .frame(width: 350, height: 700)
                .clipped()

            if let description = description {
                VStack {
                    Spacer()
                    InfoCard(text: description)
                }
            }

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
        .frame(width: 350, height: 700)
    }
}

struct CloseButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .padding(10)
        }
        .buttonStyle(.glassProminent)
    }
}

struct InfoCard: View {
    let text: String

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.accentColor)
                .frame(height: 225)
                .cornerRadius(10)

            Text(text)
                .foregroundColor(.white)
                .font(.body)
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)
                .lineSpacing(6)
                .padding()
        }
    }
}
