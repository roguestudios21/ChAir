//
//  ContentView.swift
//  ChAir
//

import SwiftUI
import MultipeerConnectivity

struct AlertItem: Identifiable {
    let id = UUID()
    let message: String
}

struct ContentView: View {
    @StateObject private var multipeer = MultipeerManager()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        ZStack {
            NavigationView {
                ZStack {
                    Image("bgImage")
                        .resizable()
                        .ignoresSafeArea()
                    
                    List {
                        Section(header: Text("Chatrooms").foregroundColor(.white)) {
                            NavigationLink("Chat Room 1") {
                                ChatRoomView(multipeer: multipeer, roomName: "Chat Room 1")
                            }
                            NavigationLink("Chat Room 2") {
                                ChatRoomView(multipeer: multipeer, roomName: "Chat Room 2")
                            }
                        }
                        
                        Section(header: Text("Available Users").foregroundColor(.white)) {
                            if multipeer.nearbyPeers.isEmpty {
                                Text("No users available")
                                    .foregroundColor(.secondary)
                            } else {
                                ForEach(multipeer.nearbyPeers, id: \.self) { peer in
                                    NavigationLink(destination: PrivateChatView(multipeer: multipeer, peer: peer)) {
                                        HStack {
                                            Text(peer.displayName)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .simultaneousGesture(TapGesture().onEnded {
                                        multipeer.invite(peer)
                                    })
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .listStyle(InsetGroupedListStyle())
                }
                .navigationTitle("\(UsernameManager.shared.username)")
                .navigationBarTitleDisplayMode(.inline)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .blur(radius: hasSeenOnboarding ? 0 : 8) // Apply blur conditionally

            if !hasSeenOnboarding {
                OnBoardingView(showOnboarding: Binding(
                    get: { !hasSeenOnboarding },
                    set: { newValue in
                        hasSeenOnboarding = !newValue
                    }
                ))
                .transition(.opacity)
            }
        }
        .alert(item: $multipeer.alertItem) { alertItem in
            Alert(
                title: Text("Oops!"),
                message: Text(alertItem.message),
                dismissButton: .default(Text("OK")) {
                    multipeer.alertItem = nil
                }
            )
        }
    }
}

#Preview {
    ContentView()
}
