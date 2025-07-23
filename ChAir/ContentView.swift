import SwiftUI
import MultipeerConnectivity

struct AlertItem: Identifiable {
    let id = UUID()
    let message: String
}

enum SidebarItem: Hashable {
    case room(String)
    case peer(MCPeerID)
}

struct ContentView: View {
    @StateObject private var multipeer = MultipeerManager()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var selection: SidebarItem? = nil
    @AppStorage("hasSeenTooltip") private var hasSeenTooltip: Bool = false

    var body: some View {
        ZStack {
            NavigationSplitView {
                List(selection: $selection) {
                    // Tooltip section
                    if !hasSeenTooltip {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top) {
                                Text("""
- Click on the available user to establish connection with them then 

- You can either use one of the available chatrooms to chat with all the people in the network that are using the app.

- Or you can have 1v1 chat with them by clicking on their name after connecting.
""")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                                Spacer()
                                Button(action: {
                                    withAnimation {
                                        hasSeenTooltip = true
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                        .padding(15)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .listRowInsets(EdgeInsets())
                    }
                    // Available peers (not yet connected)
                    Section(header: Text("Available Users")) {
                        let unconnectedPeers = multipeer.nearbyPeers.filter { !multipeer.connectedPeers.contains($0) }
                        if unconnectedPeers.isEmpty {
                            Text("No available users nearby")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(unconnectedPeers, id: \.self) { peer in
                                HStack {
                                    Text(peer.displayName)
                                    Spacer()
                                    Button("Connect") {
                                        multipeer.invite(peer)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .controlSize(.small)
                                }
                            }
                        }
                    }

                    // Chatroom section
                    Section(header: Text("Chatrooms")) {
                        NavigationLink(value: SidebarItem.room("Chat Room 1")) {
                            Text("Chat Room 1")
                        }
                        NavigationLink(value: SidebarItem.room("Chat Room 2")) {
                            Text("Chat Room 2")
                        }
                    }

                   
                    // Connected peers
                    Section(header: Text("Connected Users")) {
                        if multipeer.connectedPeers.isEmpty {
                            Text("No connected users")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(multipeer.connectedPeers, id: \.self) { peer in
                                NavigationLink(value: SidebarItem.peer(peer)) {
                                    Text(peer.displayName)
                                }
                            }
                        }
                    }
                }
                .navigationTitle(UsernameManager.shared.username)
                .listStyle(InsetGroupedListStyle())
                .scrollContentBackground(.hidden)
            } detail: {
                if let selection = selection {
                    switch selection {
                    case .room(let roomName):
                        ChatRoomView(multipeer: multipeer, roomName: roomName)
                    case .peer(let peer):
                        PrivateChatView(multipeer: multipeer, peer: peer)
                    }
                } else {
                    VStack {
                        Spacer()
                        Text("Welcome to ChAir")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
            }
            .blur(radius: hasSeenOnboarding ? 0 : 8)
            .navigationSplitViewStyle(.automatic)
            .navigationDestination(for: SidebarItem.self) { selection in
                switch selection {
                case .room(let name):
                    ChatRoomView(multipeer: multipeer, roomName: name)
                case .peer(let peer):
                    PrivateChatView(multipeer: multipeer, peer: peer)
                }
            }

            // Onboarding overlay
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
        .alert(item: $multipeer.alertItem) { (item: AlertItem) in
            Alert(
                title: Text("Oops!"),
                message: Text(item.message),
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
