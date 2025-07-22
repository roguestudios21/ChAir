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

    var body: some View {
        ZStack {
            NavigationSplitView {
                List(selection: $selection) {
                    Section(header: Text("Chatrooms")) {
                        NavigationLink(value: SidebarItem.room("Chat Room 1")) {
                            Text("Chat Room 1")
                        }
                        NavigationLink(value: SidebarItem.room("Chat Room 2")) {
                            Text("Chat Room 2")
                        }
                    }

                    Section(header: Text("Available Users")) {
                        if multipeer.nearbyPeers.isEmpty {
                            Text("No users available")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(multipeer.nearbyPeers, id: \.self) { peer in
                                NavigationLink(value: SidebarItem.peer(peer)) {
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
                .navigationTitle(UsernameManager.shared.username)
                .listStyle(InsetGroupedListStyle())
                .scrollContentBackground(.hidden)
//                .background(
//                    Image("bgImage")
//                        .resizable()
//                        .ignoresSafeArea()
//                )
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
            .navigationSplitViewStyle(.automatic) // Optional: for platform-adaptive style
            .navigationDestination(for: SidebarItem.self) { selection in
                switch selection {
                case .room(let name):
                    ChatRoomView(multipeer: multipeer, roomName: name)
                case .peer(let peer):
                    PrivateChatView(multipeer: multipeer, peer: peer)
                }
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
