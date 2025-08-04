import Foundation
import MultipeerConnectivity
import Combine
import UIKit

struct ChatMessage: Identifiable, Hashable {
    let id = UUID()
    let text: String?
    let audioData: Data?
    let imageData: Data?
    let fileData: Data?
    let fileName: String?
    let sender: String
    let time: Date

    init(text: String? = nil, audioData: Data? = nil, imageData: Data? = nil, fileData: Data? = nil, fileName: String? = nil, sender: String, time: Date) {
        self.text = text
        self.audioData = audioData
        self.imageData = imageData
        self.fileData = fileData
        self.fileName = fileName
        self.sender = sender
        self.time = time
    }
}

class MultipeerManager: NSObject, ObservableObject {
    static let serviceType = "chair-chat"

    private let myPeerId = MCPeerID(displayName: UsernameManager.shared.username)
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser

    @Published var nearbyPeers: [MCPeerID] = []
    @Published var connectedPeers: [MCPeerID] = []
    @Published var messagesByRoom: [String: [ChatMessage]] = [:]
    @Published var alertItem: AlertItem? = nil

    private var session: MCSession

    override init() {
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: Self.serviceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: Self.serviceType)

        super.init()

        session.delegate = self
        serviceAdvertiser.delegate = self
        serviceBrowser.delegate = self

        serviceAdvertiser.startAdvertisingPeer()
        serviceBrowser.startBrowsingForPeers()
    }

    func privateRoomKey(for peer: MCPeerID) -> String {
        let names = [peer.displayName, myPeerId.displayName].sorted()
        return "Private-\(names[0])-\(names[1])"
    }

    func send(message: String, toRoom room: String) {
        let newMsg = ChatMessage(text: message, sender: "Me", time: Date())
        messagesByRoom[room, default: []].append(newMsg)

        guard let data = "\(room):\(message)".data(using: .utf8) else { return }

        if room.starts(with: "Private-") {
            if let targetPeer = connectedPeers.first(where: { room == privateRoomKey(for: $0) }) {
                try? session.send(data, toPeers: [targetPeer], with: .reliable)
            }
        } else {
            try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
        }
    }

    func sendVoice(_ data: Data, toRoom room: String) {
        let header = "VOICE|\(room)|"
        guard let headerData = header.data(using: .utf8) else { return }

        var messageData = Data()
        messageData.append(headerData)
        messageData.append(data)

        if room.starts(with: "Private-"),
           let peer = connectedPeers.first(where: { room == privateRoomKey(for: $0) }) {
            try? session.send(messageData, toPeers: [peer], with: .reliable)
        } else {
            try? session.send(messageData, toPeers: session.connectedPeers, with: .reliable)
        }

        let msg = ChatMessage(audioData: data, sender: "Me", time: Date())
        DispatchQueue.main.async {
            self.messagesByRoom[room, default: []].append(msg)
        }
    }

    func sendImage(_ image: UIImage, toRoom room: String) {
        guard let data = image.jpegData(compressionQuality: 0.7) else { return }

        let header = "IMAGE|\(room)|"
        guard let headerData = header.data(using: .utf8) else { return }

        var messageData = Data()
        messageData.append(headerData)
        messageData.append(data)

        if room.starts(with: "Private-"),
           let peer = connectedPeers.first(where: { room == privateRoomKey(for: $0) }) {
            try? session.send(messageData, toPeers: [peer], with: .reliable)
        } else {
            try? session.send(messageData, toPeers: session.connectedPeers, with: .reliable)
        }

        let msg = ChatMessage(imageData: data, sender: "Me", time: Date())
        DispatchQueue.main.async {
            self.messagesByRoom[room, default: []].append(msg)
        }
    }

    func sendFile(_ data: Data, fileName: String, toRoom room: String) {
        let header = "FILE|\(room)|\(fileName)|"
        guard let headerData = header.data(using: .utf8) else { return }

        var messageData = Data()
        messageData.append(headerData)
        messageData.append(data)

        if room.starts(with: "Private-"),
           let peer = connectedPeers.first(where: { room == privateRoomKey(for: $0) }) {
            try? session.send(messageData, toPeers: [peer], with: .reliable)
        } else {
            try? session.send(messageData, toPeers: session.connectedPeers, with: .reliable)
        }

        let msg = ChatMessage(fileData: data, fileName: fileName, sender: "Me", time: Date())
        DispatchQueue.main.async {
            self.messagesByRoom[room, default: []].append(msg)
        }
    }

    func messagesForRoom(_ room: String) -> [ChatMessage] {
        return messagesByRoom[room] ?? []
    }

    func invite(_ peer: MCPeerID) {
        serviceBrowser.invitePeer(peer, to: session, withContext: nil, timeout: 10)
    }
}

extension MultipeerManager: MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            self.connectedPeers = session.connectedPeers
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let voicePrefix = "VOICE|".data(using: .utf8)!
        let imagePrefix = "IMAGE|".data(using: .utf8)!
        let filePrefix = "FILE|".data(using: .utf8)!

        if data.starts(with: voicePrefix) || data.starts(with: imagePrefix) || data.starts(with: filePrefix) {
            if let firstPipe = data.firstIndex(of: UInt8(ascii: "|")),
               let secondPipe = data[firstPipe + 1..<data.count].firstIndex(of: UInt8(ascii: "|")) {
                let roomStart = firstPipe + 1
                let roomEnd = secondPipe
                let type = String(data: data.prefix(upTo: firstPipe), encoding: .utf8) ?? ""
                let room = String(data: data[roomStart..<roomEnd], encoding: .utf8) ?? ""

                var payloadStart = secondPipe + 1
                var fileName: String? = nil

                if type == "FILE" {
                    if let thirdPipe = data[payloadStart..<data.count].firstIndex(of: UInt8(ascii: "|")) {
                        fileName = String(data: data[payloadStart..<thirdPipe], encoding: .utf8)
                        payloadStart = thirdPipe + 1
                    }
                }

                let payload = data.subdata(in: payloadStart..<data.count)

                let msg: ChatMessage
                if type == "VOICE" {
                    msg = ChatMessage(audioData: payload, sender: peerID.displayName, time: Date())
                } else if type == "IMAGE" {
                    msg = ChatMessage(imageData: payload, sender: peerID.displayName, time: Date())
                } else if type == "FILE" {
                    msg = ChatMessage(fileData: payload, fileName: fileName, sender: peerID.displayName, time: Date())
                } else {
                    return
                }

                DispatchQueue.main.async {
                    self.messagesByRoom[room, default: []].append(msg)
                }
                return
            }
        }

        if let message = String(data: data, encoding: .utf8),
           let separatorIndex = message.firstIndex(of: ":") {
            let room = String(message[..<separatorIndex])
            let content = String(message[message.index(after: separatorIndex)...])
            let newMsg = ChatMessage(text: content, sender: peerID.displayName, time: Date())
            DispatchQueue.main.async {
                self.messagesByRoom[room, default: []].append(newMsg)
            }
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName: String, fromPeer: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName: String, fromPeer: MCPeerID, with: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName: String, fromPeer: MCPeerID, at: URL?, withError: Error?) {}

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, self.session)
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo: [String: String]?) {
        DispatchQueue.main.async {
            if !self.nearbyPeers.contains(peerID) {
                self.nearbyPeers.append(peerID)
            }
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.nearbyPeers.removeAll { $0 == peerID }
        }
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        DispatchQueue.main.async {
            self.alertItem = AlertItem(message: "Couldn’t make your device visible to others. Please check Wi‑Fi or Bluetooth.")
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        DispatchQueue.main.async {
            self.alertItem = AlertItem(message: "Couldn’t search for nearby users. Please check your network.")
        }
    }
}
