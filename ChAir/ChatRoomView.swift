import SwiftUI

struct ChatRoomView: View {
    @ObservedObject var multipeer: MultipeerManager
    let roomName: String
    @State private var newMessage = ""
    
    var body: some View {
        ZStack{
            Image("bgImage")
                .resizable()
                .ignoresSafeArea()
        
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(multipeer.messagesForRoom(roomName)) { msg in
                            VStack(alignment: msg.sender == "Me" ? .trailing : .leading, spacing: 2) {
                                if msg.sender != "Me" {
                                    Text(msg.sender)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 4)
                                }

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
                .onChange(of: multipeer.messagesForRoom(roomName).count) {
                    if let last = multipeer.messagesForRoom(roomName).last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            HStack(spacing: 12) {
                TextField("Type your message...", text: $newMessage)
                    .padding(12)
//                    .glassEffect(.clear.tint((Color(.systemGray6)).opacity(0.7)))
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Button(action: {
                    multipeer.send(message: newMessage, toRoom: roomName)
                    newMessage = ""
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(12)
                        .glassEffect(.clear.tint(.blue))
                    //                        .background(Color.accentColor)
                    //                        .clipShape(Circle())
                    //                        .shadow(radius: 2)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .shadow(radius: 5)
            .padding(.bottom, 8)
        }
    }
        .navigationTitle("\(roomName)")
        .navigationBarTitleDisplayMode(.inline)
    
    }
}

#Preview {
    let manager = MultipeerManager()
    manager.messagesByRoom["Chat Room 1"] = [
        ChatMessage(text: "Hi!", sender: "Me", time: Date()),
        ChatMessage(text: "Hello!", sender: "Alice", time: Date())
    ]
    return NavigationView {
        ChatRoomView(multipeer: manager, roomName: "Chat Room 1")
    }
}
