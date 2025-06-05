import Foundation
import Security
import AppKit

struct Credentials {
    var username: String
    var password: String
}

class GatewayManager: ObservableObject {
    @Published var isConnected = false
    @Published private(set) var hasCredentials = false
    private var process: Process?
    private var gatewayURL: URL?
    private let serviceName = "IBKRConnect"
    
    init() {
        if let path = UserDefaults.standard.string(forKey: "gatewayPath") {
            gatewayURL = URL(fileURLWithPath: path)
        }
        hasCredentials = storedCredentials() != nil
    }

    func promptForGateway() {
        let panel = NSOpenPanel()
        panel.title = "Select Client Portal Gateway"
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK, let url = panel.url {
            gatewayURL = url
            UserDefaults.standard.set(url.path, forKey: "gatewayPath")
        } else {
            if let helpURL = URL(string: "https://www.interactivebrokers.com/campus/ibkr-api-page/cpapi-v1/#gw-step-one") {
                NSWorkspace.shared.open(helpURL)
            }
        }
    }

    func storedCredentials() -> Credentials? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecSuccess,
           let existingItem = item as? [String: Any],
           let passwordData = existingItem[kSecValueData as String] as? Data,
           let password = String(data: passwordData, encoding: .utf8),
           let username = existingItem[kSecAttrAccount as String] as? String {
            return Credentials(username: username, password: password)
        }
        return nil
    }

    func saveCredentials(_ creds: Credentials) {
        let passwordData = creds.password.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: creds.username,
            kSecValueData as String: passwordData
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
        hasCredentials = true
    }

    func connect() {
        guard process == nil else { return }
        guard let url = gatewayURL else {
            promptForGateway()
            return
        }
        let process = Process()
        process.executableURL = url
        if let creds = storedCredentials() {
            process.arguments = ["-username", creds.username, "-password", creds.password]
        }
        do {
            try process.run()
            self.process = process
            self.isConnected = true
        } catch {
            print("Failed to launch gateway: \(error)")
        }
    }

    func disconnect() {
        process?.terminate()
        process = nil
        isConnected = false
    }
}