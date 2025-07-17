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
                List {
                    Section(header: Text("Chatrooms")) {
                        NavigationLink("General") {
                            ChatRoomView(multipeer: multipeer, roomName: "General")
                        }
                        NavigationLink("Fun") {
                            ChatRoomView(multipeer: multipeer, roomName: "Fun")
                        }
                    }
                    
                    Section(header: Text("Nearby Users")) {
                        if multipeer.nearbyPeers.isEmpty {
                            Text("No user nearby")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(multipeer.nearbyPeers, id: \.self) { peer in
                                NavigationLink(destination: PrivateChatView(multipeer: multipeer)) {
                                    HStack {
                                        Text(peer.displayName)
                                        Spacer()
                                        Button(action: {
                                            multipeer.invite(peer)
                                        }) {
                                            Image(systemName: "person.badge.plus")
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("Connected Users")) {
                        if multipeer.connectedPeers.isEmpty {
                            Text("No user connected yet")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(multipeer.connectedPeers, id: \.self) { peer in
                                NavigationLink(destination: PrivateChatView(multipeer: multipeer)) {
                                    Text(peer.displayName)
                                }
                            }
                        }
                    }
                }
                
                .navigationTitle("\(UsernameManager.shared.username)")
            }
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
