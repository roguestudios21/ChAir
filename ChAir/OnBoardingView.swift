//
//  OnBoardingView.swift
//  ChAir
//
//  Created by Atharv  on 15/07/25.
//

import SwiftUI

struct OnBoardingView: View {
    @Binding var showOnboarding: Bool
    
    var body: some View {
        TabView{
            WelcomePage(showOnboarding: $showOnboarding)
                        FirstPage(showOnboarding: $showOnboarding)
                        SecondPage(showOnboarding: $showOnboarding)
                        ThirdPage(showOnboarding: $showOnboarding)
        }.tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .ignoresSafeArea()
    }
}

#Preview {
    OnBoardingView(showOnboarding: .constant(true))
}

struct WelcomePage: View {
    @Binding var showOnboarding: Bool
    var body: some View {
        ZStack {
            Image("welcomePage")
                .resizable()
                .scaledToFill()
        }
        .overlay(
            Button(action: { showOnboarding = false }) {
                Image(systemName: "xmark")
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .clipShape(Circle())
            }
              
            .padding(.top, 75) // move lower
            .padding(.leading),
            alignment: .topLeading
        )
    }
}


struct FirstPage: View {
    @Binding var showOnboarding: Bool
    var body: some View {
        ZStack {
            Image("firstPage")
                .resizable()
                .scaledToFill()
            
            VStack {
                Spacer()
                
                ZStack {
                    Rectangle()
                        .fill(Color.accentColor)
                        .frame(height: 300)
                    
                    Text("""
                        When you start the app, you are randomly assigned a username.
                        
                        You can choose to join a chatroom or have a one-on-one chat with another user in the network.
                        """)
                        .foregroundColor(.white)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(6)
                        .padding(.bottom, 75)
                        .padding()
                }
               
            }
            
        }.overlay(
            Button(action: { showOnboarding = false }) {
                Image(systemName: "xmark")
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .clipShape(Circle())
            }
               
                .padding(.top, 75)
                .padding(),
            alignment: .topLeading
        )
    }
}

struct SecondPage: View {
    @Binding var showOnboarding: Bool
    var body: some View{
        ZStack{
            Image("secondPage")
                .resizable()
                .scaledToFill()
            VStack {
                Spacer()
                
                ZStack {
                    Rectangle()
                        .fill(Color.accentColor)
                        .frame(height: 300)
                    
                    Text("""
                        Two secure chat rooms are always open join any time.
                        
                        Chats auto-delete when you leave.
                        
                        """)
                        .foregroundColor(.white)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(6)
                        .padding(.bottom, 75)
                        .padding()
                }
                
            }
        }.overlay(
            Button(action: { showOnboarding = false }) {
                Image(systemName: "xmark")
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .clipShape(Circle())
            }
               
                .padding(.top, 75)
                .padding(),
            alignment: .topLeading
        )
    }
}

struct ThirdPage: View {
    @Binding var showOnboarding: Bool
    var body: some View{
        ZStack{
            Image("thirdPage")
                .resizable()
                .scaledToFill()
            VStack {
                Spacer()
                
                ZStack {
                    Rectangle()
                        .fill(Color.accentColor)
                        .frame(height: 300)
                    
                    Text("""
                        Chat with anyone on the same network.
                        
                        Chats auto-delete when you or the other user leaves.
                        """)
                        .foregroundColor(.white)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(6)
                        .padding(.bottom, 75)
                        .padding()
                }
                
            }
        }.overlay(
            Button(action: { showOnboarding = false }) {
                Image(systemName: "xmark")
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .clipShape(Circle())
            }
                .padding(.top, 75)
                .padding(),
            alignment: .topLeading
        )
    }
}
