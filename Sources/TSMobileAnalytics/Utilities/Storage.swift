//
//  Storage.swift
//  TSMobileAnalytics
//
//  Created by Andreas Lif on 2023-03-16.
//  Copyright © 2023 Kantar Sifo. All rights reserved.
//

import Foundation

class Storage {
    static let shared = Storage()

    var uuidString: String? {
        didSet { UserDefaults.standard.set(uuidString, forKey: Keys.uuidString) }
    }

    var cookieString: String? {
        didSet { UserDefaults.standard.set(cookieString, forKey: Keys.cookieString) }
    }

    var sdkVersion: String? {
        didSet { UserDefaults.standard.set(sdkVersion, forKey: Keys.sdkVersion)}
    }

    var nextSyncDate: Date? {
        didSet { UserDefaults.standard.set(nextSyncDate, forKey: Keys.nextSyncDate)}
    }

    init() {
        uuidString = UserDefaults.standard.string(forKey: Keys.uuidString)
        cookieString = UserDefaults.standard.string(forKey: Keys.cookieString)
        sdkVersion = UserDefaults.standard.string(forKey: Keys.sdkVersion)

        if let storedDate = UserDefaults.standard.object(forKey: Keys.nextSyncDate) as? Date {
            nextSyncDate = storedDate
        }
    }
}

private extension Storage {
    struct Keys {
        static let nextSyncDate = "nextSyncDate"

        // TODO: Change strings to match variable name, next time breaking changes are introduced.
        static let uuidString = "tns-sifo-device-id"
        static let cookieString = "se.tns-sifo.cookiekey"
        static let sdkVersion = "se.tns-sifo.versionkey"
    }
}
