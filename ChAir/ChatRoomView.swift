import SwiftUI
import MultipeerConnectivity

struct ChatRoomView: View {
    @ObservedObject var multipeer: MultipeerManager
    let roomName: String

    var body: some View {
        ZStack {
            Image("bgImage")
                .resizable()
                .ignoresSafeArea()

            VoiceChatRoomBody(multipeer: multipeer, roomKey: roomName, showSenderName: true, isPrivate: false)
        }
        .navigationTitle(roomName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

class MockMultipeerManager: MultipeerManager {
    override func messagesForRoom(_ room: String) -> [ChatMessage] {
        return [
            ChatMessage(text: "Hello!", audioData: nil, sender: "Alice", time: Date()),
            ChatMessage(text: "Hi Alice!", audioData: nil, sender: "Me", time: Date()),
            ChatMessage(text: nil, audioData: Data(repeating: 0, count: 1000), sender: "Alice", time: Date())
        ]
    }

    override func privateRoomKey(for peer: MCPeerID) -> String {
        return "private:\(peer.displayName)"
    }
}

// MARK: - ChatRoomView Preview

#Preview("ChatRoomView Preview", traits: .sizeThatFitsLayout) {
    NavigationStack {
        ChatRoomView(multipeer: MockMultipeerManager(), roomName: "ChatRoom1")
    }
}
