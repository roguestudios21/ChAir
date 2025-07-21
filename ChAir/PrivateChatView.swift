import SwiftUI
import MultipeerConnectivity

struct PrivateChatView: View {
    @ObservedObject var multipeer: MultipeerManager
    var peer: MCPeerID
    @State private var newMessage = ""

    private var roomKey: String {
        multipeer.privateRoomKey(for: peer)
    }

    var body: some View {
        ZStack {
            Image("bgImage")
                .resizable()
                .ignoresSafeArea()

            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(multipeer.messagesForRoom(roomKey)) { msg in
                                VStack(alignment: msg.sender == "Me" ? .trailing : .leading, spacing: 2) {
                                    HStack {
                                        if msg.sender == "Me" {
                                            Spacer()
                                            Text(msg.text)
                                                .padding(10)
                                                .glassEffect(.clear.tint(.blue.opacity(0.7)))
                                                .foregroundColor(.white)
                                        } else {
                                            Text(msg.text)
                                                .padding(10)
                                                .glassEffect(.clear.tint(.blue.opacity(0.7)))
                                                .foregroundColor(.white)
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
                    .onChange(of: multipeer.messagesForRoom(roomKey).count) {
                        if let last = multipeer.messagesForRoom(roomKey).last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }

                }

                HStack(spacing: 12) {
                    TextField("Type your message...", text: $newMessage)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                    Button(action: {
                        multipeer.send(message: newMessage, toRoom: roomKey)
                        newMessage = ""
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(12)
                            .glassEffect(.clear.tint(.blue))
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .shadow(radius: 5)
                .padding(.bottom, 8)
            }
        }
        .navigationTitle(peer.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let manager = MultipeerManager()
    let mockPeer = MCPeerID(displayName: "Bob")
    manager.messagesByRoom["Private-Bob"] = [
        ChatMessage(text: "Hey there!", sender: "Me", time: Date()),
        ChatMessage(text: "Hello!", sender: "Bob", time: Date())
    ]
    return NavigationView {
        PrivateChatView(multipeer: manager, peer: mockPeer)
    }
}
