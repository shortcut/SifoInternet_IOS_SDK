//
//  SyncResponse.swift
//  TSMobileAnalytics
//
//  Created by Andreas Lif on 2023-03-24.
//  Copyright © 2023 Kantar Sifo. All rights reserved.
//

import Foundation

struct SyncResponse: Codable {
    let cookies: [Cookie]

    enum CodingKeys: String, CodingKey {
        case cookies = "CookieInfos"
    }
}

struct Cookie: Codable {
    let domain: String
    let key: String
    let value: String
    let path: String?

    enum CodingKeys: String, CodingKey {
        case domain = "domain"
        case key = "key"
        case value = "value"
        case path = "path"
    }
}
