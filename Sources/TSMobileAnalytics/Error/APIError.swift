//
//  APIError.swift
//  TSMobileAnalytics
//
//  Created by Andreas Lif on 2023-04-04.
//  Copyright © 2023 Kantar Sifo. All rights reserved.
//

import Foundation

enum APIError: Error {
    case unknown
    case badResponse(Int?)
    case noData
}
