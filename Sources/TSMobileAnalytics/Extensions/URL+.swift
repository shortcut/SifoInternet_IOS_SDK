//
//  URL+.swift
//  TSMobileAnalytics
//
//  Created by Andreas Lif on 2023-03-29.
//  Copyright © 2023 Kantar Sifo. All rights reserved.
//

import Foundation

extension URL {
    static let panelistAppString: String = .internetApplicationScheme + .colon + .slash + .slash + .syncSuffix

    static let bundleId: String = {
        Bundle.main.bundleIdentifier ?? .empty
    }()

    static let panelistAppUrl = URL(string: panelistAppString)!
    static let appUrl = URL(string: .internetApplicationScheme + .colon + .slash + .slash + bundleId)!

    static let sifoBaseURL = URL(string: sifoBaseURLString)!
    static let sifoBaseURLString = "https://sifopanelen.research-int.se/App/GetPanelistInfo?"

    static let trafficGatewayBaseURL = URL(string: trafficGatewayBaseURLString)!
    static let trafficGatewayBaseURLString = "https://trafficgateway.research-int.se/TrafficCollector?"

    /// The part of the URL that comes after the colon of its scheme.
    ///
    /// This was a property of NSURL used in the original Objective-C code,
    /// but there doesn't seem to be any native Swift equivalent.
    var resourceSpecifier: String? {
        guard let scheme else { return absoluteString }

        let prefix = scheme + .colon
        guard absoluteString.starts(with: prefix) else {
            return absoluteString
        }

        return String(absoluteString.dropFirst(prefix.count))
    }
}

private extension String {
    static let internetApplicationScheme = "se.tns-sifo.internetpanelen"
    static let syncSuffix = "sync/"
}
