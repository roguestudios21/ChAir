import Foundation
import MultipeerConnectivity
import Combine

struct ChatMessage: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let sender: String
    let time: Date
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
        return "Private-\(peer.displayName)"
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


    func messagesForRoom(_ room: String) -> [ChatMessage] {
        return messagesByRoom[room] ?? []
    }
    
    func invite(_ peer: MCPeerID) {
        serviceBrowser.invitePeer(peer, to: session, withContext: nil, timeout: 10)
    }
}

// MARK: - Delegates
extension MultipeerManager: MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            self.connectedPeers = session.connectedPeers
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
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
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo: [String : String]?) {
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
