# ChAir

**ChAir** (short for **Chat Over Air**) is a privacy-focused, offline-capable iOS chat app that allows users to anonymously communicate with nearby peers over the local network using **Multipeer Connectivity**. Designed with simplicity and security in mind, ChAir requires **no internet access** and shares **no personal data**.

Built entirely with **SwiftUI** and leveraging **Apple's MultipeerConnectivity framework**, ChAir is perfect for quick and secure local conversations in hackathons, classrooms, conferences, or events.

---

##  Features

- Anonymous, peer-to-peer chat with no user registration
- Works entirely **offline** using Bluetooth/Wi-Fi (Multipeer Connectivity)
- Real-time chat with dynamic UI updates
- Auto-deleting messages when users leave the session
- Design with glass-like UI elements (iOS 26 styled)
- Optimized for both iPhone and iPad

---

##  App Architecture

### WelcomePage

- Entry screen with a minimal welcome message and an `X` button to dismiss onboarding.
- Background uses full-screen image (`Image("welcomePage")`) with glassmorphism-styled button for consistent iOS 26 aesthetics.

  <img width="1920" height="1080" alt="ChatOverAir(onboarding)" src="https://github.com/user-attachments/assets/31d319e1-114e-414f-af58-281779ee5ce9" />

---

### MainPage

- Each user is granted a Random Username 
- Allows the user to select from predefined chat rooms (e.g. "General Chat", "Random", etc.).
- Tapping a room name initializes the peer session and navigates to `ChatRoomView`.
- Also shows all the available peers in the network
- Tapping a peer username initializes the peer session and navigates to `PrivateChatView`.
- Background images and UI styling are consistent with the rest of the app.

  <img width="1920" height="1080" alt="Mainscreen" src="https://github.com/user-attachments/assets/30ed88a8-a9e2-4c38-9765-9f162c08681c" />

---

### ChatRoomView

- Displays the actual chat session.
- Shows connected peers, messages exchanged, and live chat updates.
- A dark-textured background ensures visibility of chat bubbles.
- UI consists of:
  - A `ScrollView` for showing messages
  - A `TextField` for message input
  - A `Send` button with animation feedback

When two users join the same room on the same Wi-Fi or Bluetooth range, they automatically connect and can chat instantly.

<img width="1920" height="1080" alt="chaatroom" src="https://github.com/user-attachments/assets/ba85f785-f444-4e70-84a2-f25540304ac3" />

---

### PrivateChatView

- Allows users to initiate and participate in **one-on-one private chats**
- List of connected peers shown; tapping one starts a direct session
- Uses dedicated Multipeer sessions separate from group chats
- Messages are:
  - Private and encrypted within session
  - Auto-deleted once the session ends
- View hierarchy is similar to `ChatRoomView`, but only the selected peer is connected

  <img width="1920" height="1080" alt="privatechat" src="https://github.com/user-attachments/assets/c310c3e2-b822-4725-bb81-52c3bab7a954" />


---

### Message Bubble View

- Bubbles adjust alignment based on sender (self vs peer).
- Uses SwiftUI's `HStack` and dynamic color schemes.
- Supports smooth animation for incoming/outgoing messages.

---

### MultipeerManager

- Core engine for all peer discovery, session handling, and message exchange
- Supports both group and private sessions
- Stores messages in `messagesByRoom` dictionary for each room
- Sends and receives data using `Codable` messages
- Handles lifecycle:
  - Peer discovery
  - Invitations
  - Session state monitoring
  - Disconnect events and cleanup

    <img width="1024" height="1024" alt="ChatGPT Image Jul 17, 2025 at 06_08_57 PM" src="https://github.com/user-attachments/assets/d3a07f85-7f91-4995-b844-459ed21a7a78" />


---

##  Privacy & Security

- **No user data is stored**—everything is in-memory and session-based.
- **Messages are deleted automatically** when a user exits the app or leaves the network.
- Peer names are randomized and session-based to ensure anonymity.
- **No signup or authentication required**
- **Private chats use isolated sessions**, disconnected from group sessions

---

##  UI/UX & Styling

- Uses SwiftUI 3/4 with glass-like blur effects
- Custom padding, rounded shapes, and SF Symbols
- Consistent design between `ChatRoomView` and `PrivateChatView`
- Designed with iOS 26 UI in mind:
  - Card overlays
  - Vibrant backgrounds
  - Tap/scroll animations

---

##  Testing Notes

To test on **TestFlight**:
- Install the app on **two physical devices**
- Ensure both are on the **same Wi-Fi** or **have Bluetooth enabled**
- Accept permission prompts for **Bluetooth**, **Local Network**, and **Nearby Devices**

---

##  Demo Video



https://github.com/user-attachments/assets/e9aadefe-1e5e-4f9a-93e7-0b9012c2397e




