//
//  SDKIntegrationValidator.swift
//  TSMobileAnalytics
//
//  Created by Andreas Lif on 2023-03-14.
//  Copyright © 2023 Kantar Sifo. All rights reserved.
//

import Foundation

class SDKIntegrationValidator {
    static func validate(applicationName: String, cpid: String) {
        if applicationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            TSMobileAnalytics.logger.log(
                message: "Application name must not be an empty string.",
                verbosity: .critical)
        }

        if cpid.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            TSMobileAnalytics.logger.log(
                message: "CPID must not be an empty string.",
                verbosity: .critical)
        }

        if cpid.count != .cpidCorrectLength {
            TSMobileAnalytics.logger.log(
                message: "CPID has incorrect length. Must be \(Int.cpidCorrectLength) characters.",
                verbosity: .critical)
        }

        if !Bundle.main.hasAppExchangeURLSchemeSetup {
            TSMobileAnalytics.logger.log(
                multipleLines: [
                    "Exchange url scheme not setup.",
                    "",
                    "Modify to your info.plist to contain:",
                    "<key>CFBundleURLTypes</key>",
                    "<array>",
                    "    <dict>",
                    "        <key>CFBundleTypeRole</key>",
                    "        <string>None</string>",
                    "        <key>CFBundleURLSchemes</key>",
                    "        <array>",
                    "            <string>\(Bundle.main.exchangeUrlScheme)</string>",
                    "        </array>",
                    "    </dict>",
                    "</array>"
                ],
                verbosity: .critical)
        }

        if !Bundle.main.hasAppQuerySchemeSetup {
            TSMobileAnalytics.logger.log(
                multipleLines: [
                    "Panelist app query scheme not setup.",
                    "",
                    "Modify to your info.plist to contain:",
                    "<key>LSApplicationQueriesSchemes</key>",
                    "<array>",
                    "    <string>\(Bundle.main.panelistQueryScheme)</string>",
                    "</array>"
                ],
                verbosity: .critical)
        }
    }
}

private extension Int {
    static let cpidCorrectLength: Int = 32
}
