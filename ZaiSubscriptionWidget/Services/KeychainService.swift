import Foundation
import Security

enum KeychainError: Error {
    case encodingError
    case decodingError
    case itemNotFound
    case unexpectedStatus(OSStatus)
}

class KeychainService {
    static let shared = KeychainService()
    
    private let service = "ai.z.subscription-widget"
    private let apiKeyKey = "zai-api-key"
    private let accountsKey = "zai-accounts"
    private let activeAccountKey = "zai-active-account-id"
    
    private init() {}
    
    // MARK: - Legacy Single-Key Methods (kept for migration compatibility)
    
    func saveAPIKey(_ apiKey: String) throws {
        try save(key: apiKeyKey, value: apiKey)
    }
    
    func loadAPIKey() -> String? {
        return load(key: apiKeyKey)
    }
    
    func deleteAPIKey() throws {
        try delete(key: apiKeyKey)
    }
    
    // MARK: - Multi-Account Methods
    
    /// Saves an account to the keychain. Updates existing account if ID matches.
    func saveAccount(_ account: Account) throws {
        var accounts = loadAccounts()
        
        if let index = accounts.firstIndex(where: { $0.id == account.id }) {
            accounts[index] = account
        } else {
            accounts.append(account)
        }
        
        try saveAccountsArray(accounts)
    }
    
    /// Loads all accounts from the keychain
    func loadAccounts() -> [Account] {
        guard let data = loadData(key: accountsKey),
              let accounts = try? JSONDecoder().decode([Account].self, from: data) else {
            // Migration: if no accounts but legacy key exists, create default account
            if let legacyKey = loadAPIKey() {
                let defaultAccount = Account(name: "Default", apiKey: legacyKey)
                try? saveAccountsArray([defaultAccount])
                return [defaultAccount]
            }
            return []
        }
        return accounts
    }
    
    /// Deletes an account by ID
    func deleteAccount(id: UUID) throws {
        var accounts = loadAccounts()
        accounts.removeAll { $0.id == id }
        try saveAccountsArray(accounts)
        
        // If deleted account was active, clear active account
        if loadActiveAccountId() == id {
            try? saveActiveAccountId(nil)
        }
    }
    
    /// Updates an existing account
    func updateAccount(_ account: Account) throws {
        try saveAccount(account)
    }
    
    /// Saves the active account ID
    func saveActiveAccountId(_ id: UUID?) throws {
        if let id = id {
            try save(key: activeAccountKey, value: id.uuidString)
        } else {
            try delete(key: activeAccountKey)
        }
    }
    
    /// Loads the active account ID
    func loadActiveAccountId() -> UUID? {
        guard let idString = load(key: activeAccountKey),
              let uuid = UUID(uuidString: idString) else {
            return nil
        }
        return uuid
    }
    
    // MARK: - Private Helpers
    
    private func saveAccountsArray(_ accounts: [Account]) throws {
        let data = try JSONEncoder().encode(accounts)
        try saveData(key: accountsKey, data: data)
    }
    
    private func save(key: String, value: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.encodingError
        }
        try saveData(key: key, data: data)
    }
    
    private func saveData(key: String, data: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        _ = SecItemDelete(query as CFDictionary)
        
        let addStatus = SecItemAdd(query as CFDictionary, nil)
        
        if addStatus != errSecSuccess {
            throw KeychainError.unexpectedStatus(addStatus)
        }
    }
    
    private func load(key: String) -> String? {
        guard let data = loadData(key: key),
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        return value
    }
    
    private func loadData(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data else {
            return nil
        }
        
        return data
    }
    
    private func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError.unexpectedStatus(status)
        }
    }
}
