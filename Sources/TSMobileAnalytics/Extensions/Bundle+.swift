//
//  Bundle+.swift
//  TSMobileAnalytics
//
//  Created by Andreas Lif on 2023-03-14.
//  Copyright © 2023 Kantar Sifo. All rights reserved.
//

import Foundation

extension Bundle {
    var hasAppExchangeURLSchemeSetup: Bool {
        containsURLScheme(exchangeUrlScheme)
    }

    var hasAppQuerySchemeSetup: Bool {
        containsQueryScheme(.kInternetApplicationScheme)
    }

    var exchangeUrlScheme: String { (bundleIdentifier?.lowercased() ?? .empty) + .kExchangeURLSchemeSuffix }
    var panelistQueryScheme: String { .kInternetApplicationScheme }

    var appVersionString: String {
        let versionString = infoDictionary?[.versionString] as? String
        let buildString = infoDictionary?[.buildString] as? String

        return (versionString ?? .empty) + .openParenthesis + (buildString ?? .empty) + .closingParenthesis
    }

    func containsURLScheme(_ scheme: String) -> Bool {
        guard let bundleURLTypes = object(forInfoDictionaryKey: .cfBundleURLTypes) as? Array<Dictionary<String, Any>>
        else { return false }

        for dictionary in bundleURLTypes {
            guard let urlSchemes = dictionary[.cfBundleURLSchemes] as? Array<String>
            else { continue }

            for urlScheme in urlSchemes {
                if urlScheme.lowercased() == scheme.lowercased() { return true }
            }
        }

        return false
    }

    func containsQueryScheme(_ scheme: String) -> Bool {
        guard let querySchemes = object(forInfoDictionaryKey: .lsApplicationQueriesSchemes) as? Array<String>
        else { return false }

        for queryScheme in querySchemes {
            if queryScheme.lowercased() == scheme.lowercased() { return true }
        }

        return false
    }

}

private extension String {
    static let cfBundleURLTypes = "CFBundleURLTypes"
    static let cfBundleURLSchemes = "CFBundleURLSchemes"
    static let kExchangeURLSchemeSuffix = ".tsmobileanalytics"
    static let lsApplicationQueriesSchemes = "LSApplicationQueriesSchemes"
    static let kInternetApplicationScheme = "se.tns-sifo.internetpanelen"
    static let versionString = "CFBundleShortVersionString"
    static let buildString = "CFBundleVersion"
}
