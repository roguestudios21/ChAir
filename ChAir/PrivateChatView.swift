import SwiftUI
import MultipeerConnectivity

struct PrivateChatView: View {
    @ObservedObject var multipeer: MultipeerManager
    var peer: MCPeerID

    private var roomKey: String {
        multipeer.privateRoomKey(for: peer)
    }

    var body: some View {
        ZStack {
            Image("bgImage")
                .resizable()
                .ignoresSafeArea()

            VoiceChatRoomBody(multipeer: multipeer, roomKey: roomKey, showSenderName: false, isPrivate: true)
        }
        .navigationTitle(peer.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
