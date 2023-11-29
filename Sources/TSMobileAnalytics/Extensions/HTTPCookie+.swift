//
//  HTTPCookie+.swift
//  TSMobileAnalytics
//
//  Created by Andreas Lif on 2023-03-31.
//  Copyright © 2023 Kantar Sifo. All rights reserved.
//

import Foundation

extension HTTPCookie {
    convenience init?(
        domain: String,
        name: String,
        path: String = .slash,
        value: String
    ) {
        let properties = [
            HTTPCookiePropertyKey.domain: domain,
            HTTPCookiePropertyKey.name: name,
            HTTPCookiePropertyKey.path: path,
            HTTPCookiePropertyKey.value: value
        ]

        if HTTPCookie(properties: properties) != nil {
            self.init(properties: properties)
        } else {
            TSMobileAnalytics.logger.log(
                message: "Failed to initialize HTTPCookie.",
                verbosity: .error)

            return nil
        }
    }
}
