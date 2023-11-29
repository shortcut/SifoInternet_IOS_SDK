//
//  Collection+.swift
//  TSMobileAnalytics
//
//  Created by Andreas Lif on 2023-03-28.
//  Copyright © 2023 Kantar Sifo. All rights reserved.
//

import Foundation

extension Collection<[String: String]> {
    func cookies() -> [HTTPCookie] {
        self.compactMap { dictionary in
             guard let domain = dictionary["domain"],
                   let key = dictionary["key"],
                   let path = dictionary["path"],
                   let value = dictionary["value"]
             else {
                 TSMobileAnalytics.logger.log(
                     message: "Failed to parse cookie arguments.",
                     verbosity: .error)
                 return nil
             }

            return HTTPCookie(domain: domain, name: key, path: path, value: value)
         }
    }
}
