import SwiftUI

struct ContentView: View {
    @StateObject private var manager = GatewayManager()
    @State private var showingCredentials = false

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(manager.isConnected ? Color.green : Color.red)
                .frame(width: 12, height: 12)

            Button(manager.isConnected ? "Disconnect" : "Connect") {
                if manager.isConnected {
                    manager.disconnect()
                } else {
                    if manager.hasCredentials {
                        manager.connect()
                    } else {
                        showingCredentials = true
                    }
                }
            }
            .frame(width: 120)
        }
        .padding()
        .frame(minWidth: 150, minHeight: 60)
        .sheet(isPresented: $showingCredentials) {
            CredentialsSheet { creds in
                manager.saveCredentials(creds)
                manager.connect()
            }
        }
    }
}

#Preview {
    ContentView()
}
