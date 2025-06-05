import SwiftUI

struct ContentView: View {
    @StateObject private var manager = GatewayManager()

    var body: some View {
        VStack(spacing: 16) {
            Circle()
                .fill(manager.isConnected ? Color.green : Color.red)
                .frame(width: 12, height: 12)
            Button(manager.isConnected ? "Disconnect" : "Connect") {
                if manager.isConnected {
                    manager.disconnect()
                } else {
                    manager.connect()
                }
            }
            .frame(width: 120)
        }
        .padding()
        .frame(minWidth: 200, minHeight: 120)
    }
}

#Preview {
    ContentView()
}

