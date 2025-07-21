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
