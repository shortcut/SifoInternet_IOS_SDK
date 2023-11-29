//
//  KeychainItemWrapper.swift
//  TSMobileAnalytics
//
//  Created by Andreas Lif on 2023-03-16.
//  Copyright © 2023 Kantar Sifo. All rights reserved.
//


import Foundation

final class KeychainItemWrapper {
    private var genericSearchQuery = [CFString: Any]()
    private var keychainItems = [CFString: Any]()

    private let identifier: String
    private let accessGroup: String

    var keychainData: Data? {
        keychainItems[kSecValueData] as? Data? ?? nil
    }

    init(identifier: String, accessGroup: String) {
        self.identifier = identifier
        self.accessGroup = accessGroup

        configureGenericSearchQuery()

        performSearchQuery()
    }

    func setKeychainItems(
        accessGroup: String,
        securityClass: CFString,
        account: String,
        service: String,
        data: CFData?
    ) {
        keychainItems[kSecAttrAccessGroup] = accessGroup
        keychainItems[kSecClassKey] = securityClass
        keychainItems[kSecAttrAccount] = account
        keychainItems[kSecAttrService] = service
        keychainItems[kSecValueData] = data
    }

    static func bundleSeedID() -> String? {
        var query = [CFString: Any]()
        query[kSecClass] = kSecClassGenericPassword
        query[kSecAttrAccount] = String.bundleSeedID
        query[kSecAttrService] = String.empty
        query[kSecReturnAttributes] = kCFBooleanTrue

        var result: CFTypeRef?

        var status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound {
            status = SecItemAdd(query as CFDictionary, &result)
        }

        guard status == errSecSuccess,
              let result = result as? [CFString: Any],
              let accessGroup = result[kSecAttrAccessGroup] as? String,
              let bundleSeedId = accessGroup.components(
                separatedBy: .init(charactersIn: .dot)).first
        else {
            TSMobileAnalytics.logger.log(
                message: "Failed to get bundle seed id.",
                verbosity: .error)
            return nil
        }

        return bundleSeedId
    }
}

 // MARK: - Private
private extension KeychainItemWrapper {

    func configureGenericSearchQuery() {
        genericSearchQuery[kSecClass] = kSecClassGenericPassword
        genericSearchQuery[kSecAttrGeneric] = identifier
        genericSearchQuery[kSecMatchLimit] = kSecMatchLimitOne
        genericSearchQuery[kSecReturnAttributes] = kCFBooleanTrue
        genericSearchQuery = dictionaryByAddingAccessGroup(accessGroup, to: genericSearchQuery)
    }

    func performSearchQuery() {
        let newSearchQuery = genericSearchQuery
        var outputDictionary: CFTypeRef?

        let status = SecItemCopyMatching(newSearchQuery as CFDictionary, &outputDictionary)

        guard let outputDictionary = outputDictionary as? [CFString: Any],
              status == noErr
        else {
            deleteKeychainItems(in: keychainItems)
            setDefaultValuesForKeychainItemData(identifier: identifier, accessGroup: accessGroup)
            TSMobileAnalytics.logger.log(
                message: "Unexpected result for keychain search query.",
                verbosity: .error)

            return
        }
        keychainItems = dictionaryFromSecItemFormattedDictionary(outputDictionary)
    }

    /// Sets the provided accessGroup for the key `kSecAttrAccessGroup` in the provided dictionary,
    /// provided that the app is not running in the Simulator.
    ///
    /// Apps that are built for the Simulator aren't signed,
    /// so in this case, there's no keychain access group for the simulator to check.
    ///
    /// This means that all apps can see all keychain items when run in simulator.
    ///
    /// If a SecItem contains an access group attribute, SecItemAdd and SecItemUpdate
    /// in the Simulator will return -25243 (errSecNoAccessForItem).
    func dictionaryByAddingAccessGroup(_ accessGroup: String, to dictionary: [CFString : Any]) -> [CFString : Any] {
#if !targetEnvironment(simulator)
        var dictionary = dictionary
        dictionary[kSecAttrAccessGroup] = accessGroup
#endif
        return dictionary
    }

    func deleteKeychainItems(in keychainItems: [CFString: Any]) {
        guard !keychainItems.isEmpty else {
            return
        }

        let secItemDictionary = secItemFormattedDictionary(from: keychainItems)
        let status = SecItemDelete(secItemDictionary as CFDictionary)

        guard status == noErr || status == errSecItemNotFound
        else {
            TSMobileAnalytics.logger.log(
                message: "Failed to delete keychain item.",
                verbosity: .warning)
            return
        }
    }

    func setDefaultValuesForKeychainItemData(identifier: String, accessGroup: String) {
        keychainItems[kSecAttrAccount] = String.empty
        keychainItems[kSecAttrLabel] = String.empty
        keychainItems[kSecAttrDescription] = String.empty
        keychainItems[kSecValueData] = String.empty
        keychainItems[kSecAttrGeneric] = identifier
        keychainItems = dictionaryByAddingAccessGroup(accessGroup, to: keychainItems)
    }

    func secItemFormattedDictionary(from dictionary: [CFString: Any]) -> [CFString: Any] {
        var dictionary = dictionary

        dictionary[kSecClass] = kSecClassGenericPassword

        guard let string = dictionary[kSecValueData] as? String,
              let data = string.data(using: .utf8)
        else {
            TSMobileAnalytics.logger.log(
                message: "Failed to format dictionary.",
                verbosity: .error)
            return dictionary
        }

        dictionary[kSecValueData] = data

        return dictionary
    }

    func dictionaryFromSecItemFormattedDictionary(_ secItemFormatted: [CFString: Any]) -> [CFString: Any] {
        var dictionary = [CFString: Any]()
        dictionary[kSecReturnData] = kCFBooleanTrue
        dictionary[kSecClass] = kSecClassGenericPassword

        var passwordData: CFTypeRef?
        let status = SecItemCopyMatching(dictionary as CFDictionary, &passwordData)

        guard let passwordData = passwordData as? Data,
              status == noErr
        else {
            TSMobileAnalytics.logger.log(
                message: "Failed to retrieve keychain item.",
                verbosity: .error)
            return dictionary
        }
        dictionary.removeValue(forKey: kSecReturnData)
        dictionary[kSecValueData] = passwordData

        return dictionary
    }

}

private extension String {
    static let bundleSeedID = "bundleSeedID"
}
